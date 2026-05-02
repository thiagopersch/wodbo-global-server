if not VocationRankConfig then dofile("data/lib/vocation_ranks_config.lua") end

VOCATION_RANK_OPCODE = 235
VocationRankLib = {}

function VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local guid = getPlayerGUID(cid)
  if not guid then return { rank = 1, stars = 0, totalStars = 0 } end

  local query = db.getResult("SELECT `rank`, `stars`, `total_stars` FROM `player_vocation_ranks` WHERE `player_id` = " ..
    guid .. " AND `vocation_id` = " .. vocationId)
  if query:getID() ~= -1 then
    local data = {
      rank = query:getDataInt("rank"),
      stars = query:getDataInt("stars"),
      totalStars = query:getDataInt(
        "total_stars")
    }
    query:free()
    return data
  end

  db.query("INSERT INTO `player_vocation_ranks` (`player_id`, `vocation_id`, `rank`, `stars`, `total_stars`) VALUES (" ..
    guid .. ", " .. vocationId .. ", 1, 0, 0)")
  return { rank = 1, stars = 0, totalStars = 0 }
end

function VocationRankLib.setPlayerVocationRank(cid, vocationId, rank, stars, totalStars)
  local guid = getPlayerGUID(cid)
  if not guid then return false end
  db.query("UPDATE `player_vocation_ranks` SET `rank` = " ..
    rank ..
    ", `stars` = " ..
    stars ..
    ", `total_stars` = " .. totalStars .. " WHERE `player_id` = " .. guid .. " AND `vocation_id` = " .. vocationId)
  return true
end

function sendRankDataToClient(cid)
  if not isPlayer(cid) then return end
  local vocationId = getPlayerVocation(cid)
  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local config = VocationRankConfig.Vocations[vocationId]

  local univCount = getPlayerItemCount(cid, VocationRankConfig.UniversalFragmentItemId)
  local specCount = config and getPlayerItemCount(cid, config.specificFragmentItemId) or 0
  local cost = (config and config.costs[rankData.rank]) or 9999

  local atk, def, hp, mp = 0, 0, 0, 0
  if config then
    atk = config.statsPerStar.attack
    def = config.statsPerStar.defense
    hp = config.statsPerStar.health
    mp = config.statsPerStar.mana
  end

  local playerName = getCreatureName(cid)
  local vocName = getVocationInfo(vocationId).name

  -- 1=Info Pessoal, 2=Broadcast
  local str = string.format("1|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%s|%s",
    vocationId, rankData.rank, rankData.stars, rankData.totalStars, univCount, specCount, cost, atk, def, hp, mp,
    playerName, vocName)
  doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE, str)
end

function broadcastPlayerRankData(cid)
  if not isPlayer(cid) then return end
  local vocationId = getPlayerVocation(cid)
  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)

  local str = string.format("2|%d|%d|%d", cid, rankData.rank, rankData.stars)
  for _, pid in ipairs(getPlayersOnline()) do
    if pid ~= cid then doPlayerSendExtendedOpcode(pid, VOCATION_RANK_OPCODE, str) end
  end
end

function VocationRankLib.doUpgrade(cid)
  local vocationId = getPlayerVocation(cid)
  local config = VocationRankConfig.Vocations[vocationId]

  if not config then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Your vocation cannot be upgraded.")
    return false
  end

  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  if rankData.rank >= config.maxRank and rankData.stars >= VocationRankConfig.StarsPerRank then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Max upgrade level reached!")
    return false
  end

  local cost = config.costs[rankData.rank]
  local specificFrag = config.specificFragmentItemId
  local universalFrag = VocationRankConfig.UniversalFragmentItemId

  -- Tenta usar Específico primeiro, se não tiver, tenta o Universal
  if getPlayerItemCount(cid, specificFrag) >= cost then
    doPlayerRemoveItem(cid, specificFrag, cost)
  elseif getPlayerItemCount(cid, universalFrag) >= cost then
    doPlayerRemoveItem(cid, universalFrag, cost)
  else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "You don't have enough fragments (" .. cost .. ").")
    return false
  end

  rankData.stars = rankData.stars + 1
  rankData.totalStars = rankData.totalStars + 1

  if rankData.stars > VocationRankConfig.StarsPerRank then
    if rankData.rank >= config.maxRank then
      rankData.stars = VocationRankConfig.StarsPerRank
      rankData.totalStars = rankData.totalStars - 1
    else
      rankData.rank = rankData.rank + 1
      rankData.stars = 1
    end
  end

  VocationRankLib.setPlayerVocationRank(cid, vocationId, rankData.rank, rankData.stars, rankData.totalStars)
  sendRankDataToClient(cid)
  broadcastPlayerRankData(cid)

  local pos = getCreaturePosition(cid)
  doSendMagicEffect(pos, 29)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Upgrade successful!")
  VocationRankLib.applyStats(cid, vocationId, rankData.totalStars)
  return true
end

function VocationRankLib.applyStats(cid, vocationId, totalStars)
  local config = VocationRankConfig.Vocations[vocationId]
  if not config or totalStars == 0 then return end

  local bonusAtk = config.statsPerStar.attack * totalStars
  local bonusDef = config.statsPerStar.defense * totalStars
  local bonusHp = config.statsPerStar.health * totalStars
  local bonusMana = config.statsPerStar.mana * totalStars

  local condition = createConditionObject(CONDITION_ATTRIBUTES)
  setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
  setConditionParam(condition, CONDITION_PARAM_STAT_MAXHITPOINTS, bonusHp)
  setConditionParam(condition, CONDITION_PARAM_STAT_MAXMANAPOINTS, bonusMana)
  setConditionParam(condition, CONDITION_PARAM_SKILL_MELEE, bonusAtk)
  setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELD, bonusDef)
  setConditionParam(condition, CONDITION_PARAM_SUBID, 12345)
  doAddCondition(cid, condition)
end
