-- ============================================================
-- battle_pass_lib.lua
-- Battle Pass system: season/missions/rewards are administered on the web portal
-- (`/admin/battle-pass`, tables battle_pass_*) — this file loads the active season from the
-- database (same pattern as data/lib/tasks/task_db_loader.lua) and tracks player progress.
--
-- NOTE: "spell_kill" missions are tracked the same way as "kill" missions (monster + amount) —
-- tying a kill to the specific spell that landed the final blow would require last-hit-spell
-- tracking that no existing spell script reports centrally today. Left as a known limitation.
-- ============================================================

if not json then json = dofile("data/lib/json.lua") end

BattlePassLib = BattlePassLib or {}
BATTLE_PASS_OPCODE = 251

-- IMPORTANT: `db.getResult` in this engine returns `-1` only on a hard query error (bad SQL) —
-- a SELECT that matches zero rows still returns a "valid" handle, and reading a field from it
-- returns `false` instead of throwing. So checking `res ~= -1` alone is NOT enough to know a row
-- was actually found; always double check the read value's type before trusting it.
local function readInt(res, column)
    if res == -1 or res == false or res == nil then return nil end
    local value = result.getDataInt(res, column)
    if type(value) ~= "number" then return nil end
    return value
end

local function readString(res, column, default)
    if res == -1 or res == false or res == nil then return default end
    local value = result.getDataString(res, column)
    if type(value) ~= "string" then return default end
    return value
end

function BattlePassLib.reload()
    local seasonResult = db.getResult(
        "SELECT `id`, `month`, `year`, `max_level`, `xp_per_level`, `gold_pass_item_id`, `gold_pass_cost` " ..
        "FROM `battle_pass_seasons` WHERE `is_active` = 1 LIMIT 1")

    local seasonId = readInt(seasonResult, "id")
    if not seasonId then
        if seasonResult ~= -1 then result.free(seasonResult) end
        BATTLE_PASS_SEASON = nil
        return
    end

    local season = {
        id = seasonId,
        month = readInt(seasonResult, "month") or 0,
        year = readInt(seasonResult, "year") or 0,
        maxLevel = readInt(seasonResult, "max_level") or 100,
        xpPerLevel = readInt(seasonResult, "xp_per_level") or 1000,
        goldPassItemId = readInt(seasonResult, "gold_pass_item_id") or 0,
        goldPassCost = readInt(seasonResult, "gold_pass_cost") or 0,
        missions = {},
        rewards = {},
    }
    result.free(seasonResult)

    local missionsResult = db.getResult(
        "SELECT `id`, `type`, `target`, `description`, `xp_reward` FROM `battle_pass_missions` " ..
        "WHERE `season_id` = " .. season.id .. " AND `published` = 1")
    if readInt(missionsResult, "id") then
        repeat
            local okTarget, target = pcall(json.decode, readString(missionsResult, "target", "{}"))
            table.insert(season.missions, {
                id = readInt(missionsResult, "id"),
                type = readString(missionsResult, "type", ""),
                target = okTarget and target or {},
                description = readString(missionsResult, "description", ""),
                xpReward = readInt(missionsResult, "xp_reward") or 0,
            })
        until not result.next(missionsResult)
    end
    if missionsResult ~= -1 then result.free(missionsResult) end

    local rewardsResult = db.getResult(
        "SELECT `level`, `track`, `item_id`, `count` FROM `battle_pass_rewards` WHERE `season_id` = " .. season.id)
    if readInt(rewardsResult, "level") then
        repeat
            local level = readInt(rewardsResult, "level")
            local track = readString(rewardsResult, "track", "")
            season.rewards[track .. "_" .. level] = {
                itemId = readInt(rewardsResult, "item_id") or 0,
                count = readInt(rewardsResult, "count") or 1,
            }
        until not result.next(rewardsResult)
    end
    if rewardsResult ~= -1 then result.free(rewardsResult) end

    BATTLE_PASS_SEASON = season
    print("[BattlePass] Loaded season " .. season.month .. "/" .. season.year ..
        " (" .. #season.missions .. " missions).")
end

-- Ensures a season row exists for the current month/year, cloning the most recent previous
-- season's missions/rewards when a new one has to be created (same behaviour as
-- lib/battle-pass-season.ts on the portal, kept independent so the game doesn't depend on the
-- portal running to roll over at midnight on the last day of the month).
function BattlePassLib.ensureSeason()
    local month = tonumber(os.date("%m"))
    local year = tonumber(os.date("%Y"))

    local existing = db.getResult(
        "SELECT `id` FROM `battle_pass_seasons` WHERE `month` = " .. month .. " AND `year` = " .. year)
    local existingId = readInt(existing, "id")
    if existing ~= -1 then result.free(existing) end
    if existingId then
        BattlePassLib.reload()
        return
    end

    local prevResult = db.getResult(
        "SELECT `id`, `max_level`, `xp_per_level`, `gold_pass_item_id`, `gold_pass_cost` " ..
        "FROM `battle_pass_seasons` ORDER BY `year` DESC, `month` DESC LIMIT 1")

    local maxLevel, xpPerLevel, goldItem, goldCost = 100, 1000, 0, 0
    local prevId = readInt(prevResult, "id")
    if prevId then
        maxLevel = readInt(prevResult, "max_level") or maxLevel
        xpPerLevel = readInt(prevResult, "xp_per_level") or xpPerLevel
        goldItem = readInt(prevResult, "gold_pass_item_id") or goldItem
        goldCost = readInt(prevResult, "gold_pass_cost") or goldCost
    end
    if prevResult ~= -1 then result.free(prevResult) end

    db.query("UPDATE `battle_pass_seasons` SET `is_active` = 0")
    -- `created_at`/`updated_at` set explicitly — don't rely on a DB-side DEFAULT CURRENT_TIMESTAMP
    -- existing, some deployments (ex.: `prisma db push` on this schema) don't set one.
    db.query("INSERT INTO `battle_pass_seasons` (`month`, `year`, `max_level`, `xp_per_level`, " ..
        "`gold_pass_item_id`, `gold_pass_cost`, `is_active`, `created_at`, `updated_at`) VALUES (" ..
        month .. ", " .. year .. ", " .. maxLevel .. ", " .. xpPerLevel .. ", " ..
        goldItem .. ", " .. goldCost .. ", 1, NOW(), NOW())")

    if prevId then
        local newSeasonResult = db.getResult(
            "SELECT `id` FROM `battle_pass_seasons` WHERE `month` = " .. month .. " AND `year` = " .. year)
        local newId = readInt(newSeasonResult, "id")
        if newSeasonResult ~= -1 then result.free(newSeasonResult) end

        db.query("INSERT INTO `battle_pass_missions` (`season_id`, `type`, `target`, `description`, " ..
            "`xp_reward`, `published`, `created_at`, `updated_at`) SELECT " .. newId ..
            ", `type`, `target`, `description`, `xp_reward`, `published`, NOW(), NOW() " ..
            "FROM `battle_pass_missions` WHERE `season_id` = " .. prevId)
        db.query("INSERT INTO `battle_pass_rewards` (`season_id`, `level`, `track`, `rarity`, " ..
            "`item_id`, `count`) SELECT " .. newId ..
            ", `level`, `track`, `rarity`, `item_id`, `count` FROM `battle_pass_rewards` " ..
            "WHERE `season_id` = " .. prevId)

        print("[BattlePass] Rolled over to season " .. month .. "/" .. year .. " (cloned from previous).")
    else
        print("[BattlePass] Created first season " .. month .. "/" .. year .. ".")
    end

    BattlePassLib.reload()
end

function BattlePassLib.getProgress(cid)
    if not BATTLE_PASS_SEASON then return nil end
    local guid = getPlayerGUID(cid)
    if not guid then return nil end

    local res = db.getResult(
        "SELECT `xp`, `level`, `has_gold_pass`, `mission_progress`, `claimed_bronze`, `claimed_gold` " ..
        "FROM `player_battle_pass` WHERE `player_id` = " .. guid .. " AND `season_id` = " .. BATTLE_PASS_SEASON.id)

    local xp = readInt(res, "xp")
    if not xp then
        if res ~= -1 then result.free(res) end
        db.query("INSERT INTO `player_battle_pass` (`player_id`, `season_id`, `xp`, `level`, " ..
            "`has_gold_pass`, `mission_progress`, `claimed_bronze`, `claimed_gold`) VALUES (" ..
            guid .. ", " .. BATTLE_PASS_SEASON.id .. ", 0, 0, 0, '{}', '[]', '[]')")
        return { xp = 0, level = 0, hasGoldPass = false, missionProgress = {}, claimedBronze = {}, claimedGold = {} }
    end

    local okProgress, missionProgress = pcall(json.decode, readString(res, "mission_progress", "{}"))
    local okBronze, claimedBronze = pcall(json.decode, readString(res, "claimed_bronze", "[]"))
    local okGold, claimedGold = pcall(json.decode, readString(res, "claimed_gold", "[]"))

    local progress = {
        xp = xp,
        level = readInt(res, "level") or 0,
        hasGoldPass = readInt(res, "has_gold_pass") == 1,
        missionProgress = okProgress and missionProgress or {},
        claimedBronze = okBronze and claimedBronze or {},
        claimedGold = okGold and claimedGold or {},
    }
    result.free(res)
    return progress
end

function BattlePassLib.saveProgress(cid, progress)
    local guid = getPlayerGUID(cid)
    if not guid or not BATTLE_PASS_SEASON then return end

    db.query("UPDATE `player_battle_pass` SET `xp` = " .. progress.xp ..
        ", `level` = " .. progress.level ..
        ", `has_gold_pass` = " .. (progress.hasGoldPass and 1 or 0) ..
        ", `mission_progress` = " .. db.escapeString(json.encode(progress.missionProgress)) ..
        ", `claimed_bronze` = " .. db.escapeString(json.encode(progress.claimedBronze)) ..
        ", `claimed_gold` = " .. db.escapeString(json.encode(progress.claimedGold)) ..
        " WHERE `player_id` = " .. guid .. " AND `season_id` = " .. BATTLE_PASS_SEASON.id)
end

function BattlePassLib.sendUpdate(cid, progress)
    if not BATTLE_PASS_SEASON then return end
    local payload = json.encode({
        action = "update",
        season = {
            month = BATTLE_PASS_SEASON.month,
            year = BATTLE_PASS_SEASON.year,
            maxLevel = BATTLE_PASS_SEASON.maxLevel,
            xpPerLevel = BATTLE_PASS_SEASON.xpPerLevel,
            goldPassItemId = BATTLE_PASS_SEASON.goldPassItemId,
            goldPassCost = BATTLE_PASS_SEASON.goldPassCost,
        },
        missions = BATTLE_PASS_SEASON.missions,
        progress = progress,
    })
    doPlayerSendExtendedOpcode(cid, BATTLE_PASS_OPCODE, payload)
end

function BattlePassLib.addXp(cid, amount)
    if not BATTLE_PASS_SEASON or amount <= 0 then return end
    local progress = BattlePassLib.getProgress(cid)
    if not progress or progress.level >= BATTLE_PASS_SEASON.maxLevel then return end

    progress.xp = progress.xp + amount
    local leveledUp = false
    while progress.level < BATTLE_PASS_SEASON.maxLevel and progress.xp >= BATTLE_PASS_SEASON.xpPerLevel do
        progress.xp = progress.xp - BATTLE_PASS_SEASON.xpPerLevel
        progress.level = progress.level + 1
        leveledUp = true
    end
    if progress.level >= BATTLE_PASS_SEASON.maxLevel then
        progress.xp = 0
    end

    BattlePassLib.saveProgress(cid, progress)
    if leveledUp and isPlayer(cid) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
            "Battle Pass level up! You are now level " .. progress.level .. ".")
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
    end
    BattlePassLib.sendUpdate(cid, progress)
end

local function checkMissions(cid, matches)
    if not BATTLE_PASS_SEASON or not isPlayer(cid) then return end
    local progress = BattlePassLib.getProgress(cid)
    if not progress then return end

    local changed = false
    for _, mission in ipairs(BATTLE_PASS_SEASON.missions) do
        if matches(mission) then
            local key = tostring(mission.id)
            local required = mission.target.amount or 1
            local current = progress.missionProgress[key] or 0
            if current < required then
                current = current + 1
                progress.missionProgress[key] = current
                changed = true
                if current >= required then
                    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
                        "[Battle Pass] Mission complete: " .. mission.description)
                    BattlePassLib.addXp(cid, mission.xpReward)
                end
            end
        end
    end

    if changed then
        BattlePassLib.saveProgress(cid, progress)
        BattlePassLib.sendUpdate(cid, progress)
    end
end

function BattlePassLib.onKill(cid, target)
    if not isMonster(target) then return end
    local monsterName = string.lower(getCreatureName(target))

    checkMissions(cid, function(mission)
        return (mission.type == "kill" or mission.type == "spell_kill")
            and mission.target.monster
            and string.lower(mission.target.monster) == monsterName
    end)
end

function BattlePassLib.onQuestCompleted(cid, questId)
    checkMissions(cid, function(mission)
        return mission.type == "quest" and mission.target.questId == questId
    end)
end

function BattlePassLib.claimReward(cid, level, track)
    if not BATTLE_PASS_SEASON then return false, "There is no active battle pass." end
    if track ~= "bronze" and track ~= "gold" then return false, "Invalid track." end

    local progress = BattlePassLib.getProgress(cid)
    if not progress then return false, "Error loading progress." end
    if progress.level < level then return false, "You haven't reached this level yet." end
    if track == "gold" and not progress.hasGoldPass then return false, "You need the Gold Pass." end

    local claimedList = track == "gold" and progress.claimedGold or progress.claimedBronze
    for _, claimedLevel in ipairs(claimedList) do
        if claimedLevel == level then return false, "Already claimed." end
    end

    local reward = BATTLE_PASS_SEASON.rewards[track .. "_" .. level]
    if not reward then return false, "No reward configured for this level." end

    doPlayerAddItem(cid, reward.itemId, reward.count)
    table.insert(claimedList, level)
    if track == "gold" then progress.claimedGold = claimedList else progress.claimedBronze = claimedList end

    BattlePassLib.saveProgress(cid, progress)
    BattlePassLib.sendUpdate(cid, progress)
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GIFT_WRAPS)
    return true, "Reward claimed!"
end

function BattlePassLib.buyGoldPass(cid)
    if not BATTLE_PASS_SEASON then return false, "There is no active battle pass." end
    if BATTLE_PASS_SEASON.goldPassItemId == 0 then return false, "Gold Pass is not purchasable this season." end

    local progress = BattlePassLib.getProgress(cid)
    if not progress then return false, "Error loading progress." end
    if progress.hasGoldPass then return false, "You already have the Gold Pass." end

    if getPlayerItemCount(cid, BATTLE_PASS_SEASON.goldPassItemId) < BATTLE_PASS_SEASON.goldPassCost then
        return false, "Not enough currency."
    end

    doPlayerRemoveItem(cid, BATTLE_PASS_SEASON.goldPassItemId, BATTLE_PASS_SEASON.goldPassCost)
    progress.hasGoldPass = true
    BattlePassLib.saveProgress(cid, progress)
    BattlePassLib.sendUpdate(cid, progress)
    return true, "Gold Pass purchased!"
end

if not BATTLE_PASS_SEASON then
    BattlePassLib.ensureSeason()
end
