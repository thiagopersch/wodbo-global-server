-- ============================================================
-- vocation_ranks_lib.lua
-- Main logic for Vocation Rank System (TFS 0.4)
-- ============================================================

if not VocationRankConfig then dofile("data/lib/vocation_ranks_config.lua") end

VOCATION_RANK_OPCODE = 235
VocationRankLib      = {}

-- ─────────────────────────────────────────────
--  DB helpers
-- ─────────────────────────────────────────────
function VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local guid = getPlayerGUID(cid)
  if not guid then return { rank = 0, stars = 0, totalStars = 0 } end

  local query = db.getResult(
    "SELECT `rank`, `stars`, `total_stars` FROM `player_vocation_ranks`" ..
    " WHERE `player_id` = " .. guid ..
    " AND `vocation_id` = " .. vocationId
  )

  if query:getID() ~= -1 then
    local data = {
      rank       = query:getDataInt("rank"),
      stars      = query:getDataInt("stars"),
      totalStars = query:getDataInt("total_stars")
    }
    query:free()
    return data
  end

  -- First time: insert with rank=0
  db.query(
    "INSERT INTO `player_vocation_ranks`" ..
    " (`player_id`, `vocation_id`, `rank`, `stars`, `total_stars`)" ..
    " VALUES (" .. guid .. ", " .. vocationId .. ", 0, 0, 0)"
  )
  return { rank = 0, stars = 0, totalStars = 0 }
end

function VocationRankLib.setPlayerVocationRank(cid, vocationId, rank, stars, totalStars)
  local guid = getPlayerGUID(cid)
  if not guid then return false end

  local exists = db.getResult(
    "SELECT `id` FROM `player_vocation_ranks`" ..
    " WHERE `player_id` = " .. guid ..
    " AND `vocation_id` = " .. vocationId
  )

  if exists:getID() ~= -1 then
    exists:free()
    db.query(
      "UPDATE `player_vocation_ranks`" ..
      " SET `rank` = " .. rank ..
      ", `stars` = " .. stars ..
      ", `total_stars` = " .. totalStars ..
      " WHERE `player_id` = " .. guid ..
      " AND `vocation_id` = " .. vocationId
    )
  else
    db.query(
      "INSERT INTO `player_vocation_ranks`" ..
      " (`player_id`, `vocation_id`, `rank`, `stars`, `total_stars`)" ..
      " VALUES (" .. guid .. ", " .. vocationId .. ", " ..
      rank .. ", " .. stars .. ", " .. totalStars .. ")"
    )
  end
  return true
end

-- ─────────────────────────────────────────────
--  sendRankDataToClient
--
--  PACKET FORMAT (all pipe-separated):
--  pos  1 = "1"            (packet type)
--  pos  2 = vocationId
--  pos  3 = rank
--  pos  4 = stars
--  pos  5 = totalStars
--  pos  6 = univCount
--  pos  7 = specCount
--  pos  8 = cost
--  pos  9 = maxRank
--  pos 10 = specItemId
--  pos 11 = bonusCount     ← NEW: how many bonus entries follow
--  pos 12..11+N = "key:val" entries  (N = bonusCount)
--  pos 12+N = playerName
--  pos 13+N = vocName
--
--  Using an explicit count avoids any parsing ambiguity when
--  playerName or vocName might contain colons or commas.
-- ─────────────────────────────────────────────
function sendRankDataToClient(cid)
  if not isPlayer(cid) then return end

  local vocationId    = getPlayerVocation(cid)
  local rankData      = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local config        = VocationRankConfig.Vocations[vocationId]

  local univCount     = getPlayerItemCount(cid, VocationRankConfig.UniversalFragmentItemId)
  local specCount     = (config and config.specificFragmentItemId and config.specificFragmentItemId > 0)
      and getPlayerItemCount(cid, config.specificFragmentItemId) or 0

  local effectiveRank = (rankData.rank == 0) and 1 or rankData.rank
  local cost          = (config and config.costs and config.costs[effectiveRank]) or 9999
  local maxRank       = (config and config.maxRank) or 0
  local specItemId    = (config and config.specificFragmentItemId) or 0

  -- Collect ALL bonus entries as individual pipe tokens (include magic, distance, shield)
  local bonusParts    = {}
  if config and config.statsPerStar then
    for k, v in pairs(config.statsPerStar) do
      bonusParts[#bonusParts + 1] = k .. ":" .. tostring(v)
    end
  end

  local playerName = getCreatureName(cid)
  local vocName    = getVocationInfo(vocationId).name

  -- Build packet: fixed fields | bonusCount | bonus entries... | playerName | vocName
  local parts      = {
    "1",
    tostring(vocationId),
    tostring(rankData.rank),
    tostring(rankData.stars),
    tostring(rankData.totalStars),
    tostring(univCount),
    tostring(specCount),
    tostring(cost),
    tostring(maxRank),
    tostring(specItemId),
    tostring(#bonusParts), -- pos 11: how many bonus tokens follow
  }

  for _, bp in ipairs(bonusParts) do
    parts[#parts + 1] = bp -- pos 12..11+N
  end

  parts[#parts + 1] = playerName -- pos 12+N
  parts[#parts + 1] = vocName    -- pos 13+N

  local str = table.concat(parts, "|")
  doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE, str)
end

-- ─────────────────────────────────────────────
--  Broadcast minimal rank info to all OTHER players
--  Packet type 2:  2|creatureId|rank|stars
-- ─────────────────────────────────────────────
function broadcastPlayerRankData(cid)
  if not isPlayer(cid) then return end

  local vocationId = getPlayerVocation(cid)
  local rankData   = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local str        = string.format("2|%d|%d|%d", cid, rankData.rank, rankData.stars)

  for _, pid in ipairs(getPlayersOnline()) do
    if pid ~= cid then
      doPlayerSendExtendedOpcode(pid, VOCATION_RANK_OPCODE, str)
    end
  end
end

-- ─────────────────────────────────────────────
--  doUpgrade
--  EITHER/OR fragment logic: accepts universal OR specific, not both
-- ─────────────────────────────────────────────
function VocationRankLib.doUpgrade(cid, source)
  local vocationId = getPlayerVocation(cid)
  local config     = VocationRankConfig.Vocations[vocationId]

  if not config then
    doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE,
      "err|Your vocation cannot be upgraded.")
    return false
  end

  local rankData      = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local effectiveRank = (rankData.rank == 0) and 1 or rankData.rank

  if rankData.rank >= config.maxRank and rankData.stars >= VocationRankConfig.StarsPerRank then
    doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE,
      "err|You have reached the maximum rank for your vocation!")
    return false
  end

  local cost        = config.costs[effectiveRank] or 9999
  local specificId  = config.specificFragmentItemId or 0
  local universalId = VocationRankConfig.UniversalFragmentItemId

  -- Either/Or logic: check if player has enough of selected source
  if source == "specific" then
    if specificId == 0 or getPlayerItemCount(cid, specificId) < cost then
      doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE,
        "err|You don't have enough specific fragments (" .. cost .. " needed).")
      return false
    end
    doPlayerRemoveItem(cid, specificId, cost)
  elseif source == "universal" then
    if getPlayerItemCount(cid, universalId) < cost then
      doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE,
        "err|You don't have enough universal fragments (" .. cost .. " needed).")
      return false
    end
    doPlayerRemoveItem(cid, universalId, cost)
  else
    -- auto: specific first, then universal (either/or)
    if specificId > 0 and getPlayerItemCount(cid, specificId) >= cost then
      doPlayerRemoveItem(cid, specificId, cost)
    elseif getPlayerItemCount(cid, universalId) >= cost then
      doPlayerRemoveItem(cid, universalId, cost)
    else
      doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE,
        "err|You don't have enough fragments (" .. cost .. " needed).")
      return false
    end
  end

  rankData.stars      = rankData.stars + 1
  rankData.totalStars = rankData.totalStars + 1

  if rankData.stars > VocationRankConfig.StarsPerRank then
    if rankData.rank >= config.maxRank then
      rankData.stars      = VocationRankConfig.StarsPerRank
      rankData.totalStars = rankData.totalStars - 1
    else
      rankData.rank  = (rankData.rank == 0) and 1 or (rankData.rank + 1)
      rankData.stars = 1
    end
  elseif rankData.rank == 0 then
    rankData.rank = 1
  end

  VocationRankLib.setPlayerVocationRank(cid, vocationId,
    rankData.rank, rankData.stars, rankData.totalStars)

  doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE, "ok|Upgrade successful!")
  sendRankDataToClient(cid)
  broadcastPlayerRankData(cid)
  doSendMagicEffect(getCreaturePosition(cid), 29)
  VocationRankLib.applyStats(cid, vocationId, rankData.totalStars)
  return true
end

-- ─────────────────────────────────────────────
--  applyStats: handles all stat types (attack, defense, health, mana, magic, distance, shield)
-- ─────────────────────────────────────────────
function VocationRankLib.applyStats(cid, vocationId, totalStars)
  local config = VocationRankConfig.Vocations[vocationId]
  if not config or totalStars == 0 then return end

  local s         = config.statsPerStar
  local condition = createConditionObject(CONDITION_ATTRIBUTES)
  setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
  setConditionParam(condition, CONDITION_PARAM_SUBID, 12345) -- Unique SUBID for rank bonuses

  if s.health and s.health > 0 then
    setConditionParam(condition, CONDITION_PARAM_STAT_MAXHITPOINTS, s.health * totalStars)
  end
  if s.mana and s.mana > 0 then
    setConditionParam(condition, CONDITION_PARAM_STAT_MAXMANAPOINTS, s.mana * totalStars)
  end
  if s.attack and s.attack > 0 then
    setConditionParam(condition, CONDITION_PARAM_SKILL_MELEE, s.attack * totalStars)
  end
  if s.defense and s.defense > 0 then
    setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELD, s.defense * totalStars)
  end
  if s.magic and s.magic > 0 then
    setConditionParam(condition, CONDITION_PARAM_SKILL_MAGIC, s.magic * totalStars)
  end
  if s.distance and s.distance > 0 then
    setConditionParam(condition, CONDITION_PARAM_SKILL_DISTANCE, s.distance * totalStars)
  end

  doAddCondition(cid, condition)
end
