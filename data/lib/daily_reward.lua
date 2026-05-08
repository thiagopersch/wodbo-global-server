DailyReward = {
    opcode = 155,

    bonusDays = {5, 10, 15, 20, 25, 30},

    -- Pools de itens DIÁRIOS
    dailyPools = {
        common = {
            weight = 60,
            items = {
                {id = 49693, count = 10, clientId = 44638},
                {id = 56697, count = 5,  clientId = 51642},
                {id = 56745, count = 3,  clientId = 51690},
                {id = 49694, count = 5,  clientId = 44639},
            }
        },
        rare = {
            weight = 30,
            items = {
                {id = 56744, count = 2,  clientId = 51689},
                {id = 56817, count = 2,  clientId = 51762},
                {id = 49695, count = 1,  clientId = 44640},
            }
        },
        ultra = {
            weight = 10,
            items = {
                {id = 56818, count = 1, clientId = 51763},
                {id = 49696, count = 1, clientId = 44641},
            }
        }
    },

    -- Pools de itens BÔNUS (separada dos diários)
    bonusPools = {
        items = {
            {id = 56406, count = 1, clientId = 51351, name = "Skill Potion 30min"},
            {id = 56407, count = 1, clientId = 51352, name = "XP Potion 30min"},
            {id = 9971,  count = 5, clientId = 9971,  name = "5x Gold Ingot"},
            {id = 56399, count = 1, clientId = 51344, name = "Mysterious Key"},
        },
        outfits = {
            {lookType = 128, name = "Armadura Dourada"},
            {lookType = 129, name = "Armadura Demoníaca"},
            {lookType = 130, name = "Armadura do Dragão"},
        }
    }
}

function DailyReward.getDaysInMonth(month, year)
    local days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    if month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
        return 29
    end
    return days[month] or 30
end

function DailyReward.setBit(mask, bit)
    return mask + (2 ^ (bit - 1))
end

function DailyReward.isBitSet(mask, bit)
    return (math.floor(mask / (2 ^ (bit - 1))) % 2) == 1
end

function DailyReward.generateMonthlyList(month, year)
    local daysInMonth = DailyReward.getDaysInMonth(month, year)

    for day = 1, daysInMonth do
        local roll = math.random(1, 100)
        local accumulated = 0
        local pool

        for _, p in pairs(DailyReward.dailyPools) do
            accumulated = accumulated + p.weight
            if roll <= accumulated then
                pool = p.items
                break
            end
        end
        if not pool then
            pool = DailyReward.dailyPools.common.items
        end

        local item = pool[math.random(#pool)]

        db.query(string.format(
            "INSERT INTO `daily_rewards_monthly` (`month`, `year`, `day`, `item_id`, `count`, `client_id`) VALUES (%d, %d, %d, %d, %d, %d)",
            month, year, day, item.id, item.count, item.clientId))
    end

    for _, streakDay in ipairs(DailyReward.bonusDays) do
        local item = DailyReward.bonusPools.items[math.random(#DailyReward.bonusPools.items)]
        db.query(string.format(
            "INSERT INTO `daily_rewards_bonus_monthly` (`month`, `year`, `streak_day`, `item_id`, `count`, `client_id`) VALUES (%d, %d, %d, %d, %d, %d)",
            month, year, streakDay, item.id, item.count, item.clientId))
    end
end

function DailyReward.ensureMonthlyList(month, year)
    local q = db.getResult(string.format(
        "SELECT COUNT(*) as `cnt` FROM `daily_rewards_monthly` WHERE `month` = %d AND `year` = %d",
        month, year))
    local count = 0
    if q and q:getID() ~= -1 then
        count = q:getDataInt("cnt")
        q:free()
    end
    if count == 0 then
        DailyReward.generateMonthlyList(month, year)
    end
end

function DailyReward.getDailyItem(day, month, year)
    local q = db.getResult(string.format(
        "SELECT `item_id`, `count`, `client_id` FROM `daily_rewards_monthly` WHERE `month` = %d AND `year` = %d AND `day` = %d",
        month, year, day))
    if q and q:getID() ~= -1 then
        local result = {
            id = q:getDataInt("item_id"),
            count = q:getDataInt("count"),
            clientId = q:getDataInt("client_id")
        }
        q:free()
        return result
    end
    return nil
end

function DailyReward.getBonusItem(streakDay, month, year)
    local q = db.getResult(string.format(
        "SELECT `item_id`, `count`, `client_id` FROM `daily_rewards_bonus_monthly` WHERE `month` = %d AND `year` = %d AND `streak_day` = %d",
        month, year, streakDay))
    if q and q:getID() ~= -1 then
        local result = {
            id = q:getDataInt("item_id"),
            count = q:getDataInt("count"),
            clientId = q:getDataInt("client_id")
        }
        q:free()
        return result
    end
    return nil
end

function DailyReward.getConsecutive(player_id, month, year)
    local today = tonumber(os.date("%d"))
    local consecutive = 0
    for day = today, 1, -1 do
        local q = db.getResult(string.format(
            "SELECT 1 FROM `player_daily_rewards` WHERE `player_id` = %d AND `month` = %d AND `year` = %d AND `day` = %d",
            player_id, month, year, day))
        if q and q:getID() ~= -1 then
            q:free()
            consecutive = consecutive + 1
        else
            break
        end
    end
    return consecutive
end

function DailyReward.getClaimedMask(player_id, month, year)
    local mask = 0
    local q = db.getResult(string.format(
        "SELECT `day` FROM `player_daily_rewards` WHERE `player_id` = %d AND `month` = %d AND `year` = %d",
        player_id, month, year))
    if q and q:getID() ~= -1 then
        repeat
            mask = DailyReward.setBit(mask, q:getDataInt("day"))
        until not q:next()
        q:free()
    end
    return mask
end

function DailyReward.getMissedMask(player_id, month, year)
    local today = tonumber(os.date("%d"))
    local claimedMask = DailyReward.getClaimedMask(player_id, month, year)
    local mask = 0
    for day = 1, today - 1 do
        if not DailyReward.isBitSet(claimedMask, day) then
            mask = DailyReward.setBit(mask, day)
        end
    end
    return mask
end

function DailyReward.getClaimedDaysList(player_id, month, year)
    local days = {}
    local q = db.getResult(string.format(
        "SELECT `day` FROM `player_daily_rewards` WHERE `player_id` = %d AND `month` = %d AND `year` = %d ORDER BY `day` ASC",
        player_id, month, year))
    if q and q:getID() ~= -1 then
        repeat
            days[#days + 1] = q:getDataInt("day")
        until not q:next()
        q:free()
    end
    return table.concat(days, ", ")
end

function DailyReward.getBonusState(player_id, month, year, consecutive)
    local claimedMask = 0
    local availableMask = 0

    local q = db.getResult(string.format(
        "SELECT `streak_day` FROM `player_daily_reward_bonus` WHERE `player_id` = %d AND `month` = %d AND `year` = %d",
        player_id, month, year))
    if q and q:getID() ~= -1 then
        repeat
            local sd = q:getDataInt("streak_day")
            for i, bd in ipairs(DailyReward.bonusDays) do
                if bd == sd then
                    claimedMask = DailyReward.setBit(claimedMask, i)
                    break
                end
            end
        until not q:next()
        q:free()
    end

    for i, bd in ipairs(DailyReward.bonusDays) do
        if not DailyReward.isBitSet(claimedMask, i) and consecutive >= bd then
            availableMask = DailyReward.setBit(availableMask, i)
        end
    end

    return claimedMask, availableMask
end

function DailyReward.giveOutfit(cid, lookType)
    if pcall(doPlayerAddOutfit, cid, lookType) then
        return true
    end
    return false
end