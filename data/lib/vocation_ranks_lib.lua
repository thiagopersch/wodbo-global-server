-- ============================================================
-- vocation_upgraded_lib.lua
-- Main logic for Vocation Upgraded System (TFS 0.4)
-- ============================================================

if not VocationRankConfig then dofile("data/lib/vocation_ranks_config.lua") end

VOCATION_RANK_OPCODE = 235
VocationRankLib      = {}

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

  db.query(
    "INSERT INTO `player_vocation_ranks`" ..
    " (`player_id`, `vocation_id`, `rank`, `stars`, `total_stars`)" ..
    " VALUES (" .. guid .. ", " .. vocationId .. ", 0, 0, 0)"
  )
  return { rank = 0, stars = 0, totalStars = 0 }
end

function VocationRankLib.applyStats(cid, vocationId, totalStars)
  local config = VocationRankConfig.Vocations[vocationId]
  if not config or totalStars == 0 then return end

  local s         = config.statsPerStar
  local condition = createConditionObject(CONDITION_ATTRIBUTES)
  setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
  setConditionParam(condition, CONDITION_PARAM_SUBID, 12345)

  if s.health and s.health > 0 then setConditionParam(condition, CONDITION_PARAM_STAT_MAXHITPOINTS, s.health * totalStars) end
  if s.mana and s.mana > 0 then setConditionParam(condition, CONDITION_PARAM_STAT_MAXMANAPOINTS, s.mana * totalStars) end
  if s.attack and s.attack > 0 then setConditionParam(condition, CONDITION_PARAM_SKILL_MELEE, s.attack * totalStars) end
  if s.defense and s.defense > 0 then setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELD, s.defense * totalStars) end
  if s.magic and s.magic > 0 then setConditionParam(condition, CONDITION_PARAM_STAT_MAGICLEVEL, s.magic * totalStars) end
  if s.distance and s.distance > 0 then setConditionParam(condition, CONDITION_PARAM_SKILL_DISTANCE, s.distance * totalStars) end

  doAddCondition(cid, condition)
end

function sendRankDataToClient(cid)
  if not isPlayer(cid) then return end

  local vocationId = getPlayerVocation(cid)
  local config = VocationRankConfig.Vocations[vocationId]
  if not config then return end

  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  
  -- Sum all universal fragments
  local univCount = 0
  for _, itemId in ipairs(VocationRankConfig.UniversalFragmentItemIds) do
    univCount = univCount + getPlayerItemCount(cid, itemId)
  end
  
  local specCount = getPlayerItemCount(cid, config.specificFragmentItemId)
  
  -- The cost is based on the CURRENT rank (or 1 if rank 0)
  local costIndex = math.max(1, rankData.rank)
  local costAmount = config.costs[costIndex] or 0

  -- Stats per single star (from config)
  local s = config.statsPerStar
  local sHp = s.health or 0
  local sMana = s.mana or 0
  local sMelee = s.attack or 0
  local sShield = s.defense or 0
  local sMagic = s.magic or 0

  local vocName = getVocationInfo(vocationId).name or "None"
  if VocationRankConfig and VocationRankConfig.Vocations and VocationRankConfig.Vocations[vocationId] then
      local archetype = VocationRankConfig.Vocations[vocationId].archetype
      if archetype then
          if archetype == "Support" then archetype = "Suporte" end
          vocName = vocName .. " (" .. archetype .. ")"
      end
  end
  local playerName = getCreatureName(cid)

  -- Protocol version 2: Added per-star bonuses
  local buffer = table.concat({
    "2", -- Protocol version
    rankData.rank, rankData.stars, rankData.totalStars,
    univCount, costAmount, specCount, costAmount,
    sHp, sMana, sMelee, sShield, sMagic, 
    vocName, playerName
  }, "|")

  if doSendPlayerExtendedOpcode then
    doSendPlayerExtendedOpcode(cid, VOCATION_RANK_OPCODE, buffer)
  elseif doPlayerSendExtendedOpcode then
    doPlayerSendExtendedOpcode(cid, VOCATION_RANK_OPCODE, buffer)
  end
  
  -- Also update the stars for everyone else
  broadcastPlayerRankData(cid)
end

-- Função para remover fragmentos universais (consome o primeiro que encontrar com quantidade)
function VocationRankLib.removeUniversalFragments(cid, amount)
  local remaining = amount
  for _, itemId in ipairs(VocationRankConfig.UniversalFragmentItemIds) do
    local count = getPlayerItemCount(cid, itemId)
    if count > 0 then
      local toRemove = math.min(count, remaining)
      if doPlayerRemoveItem(cid, itemId, toRemove) then
        remaining = remaining - toRemove
      end
    end
    if remaining <= 0 then break end
  end
  return remaining <= 0
end

-- Função Consertada: Consumo de itens e upgrade real
function VocationRankLib.doUpgrade(cid, source)
  local vocationId = getPlayerVocation(cid)
  local config = VocationRankConfig.Vocations[vocationId]
  if not config then return false end

  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  
  -- Check if maxed out (Max Rank + 5 stars)
  if rankData.rank >= config.maxRank and rankData.stars >= VocationRankConfig.StarsPerRank then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You have already reached the maximum rank for this vocation.")
    return false
  end

  local costIndex = math.max(1, rankData.rank)
  local costAmount = config.costs[costIndex]
  if not costAmount then return false end

  local success = false
  if source == "universal" then
    success = VocationRankLib.removeUniversalFragments(cid, costAmount)
  elseif source == "specific" then
    success = doPlayerRemoveItem(cid, config.specificFragmentItemId, costAmount)
  end

  if success then
    rankData.stars = rankData.stars + 1
    rankData.totalStars = rankData.totalStars + 1

    -- Promotion logic: If reached 5 stars, advance rank
    if rankData.stars >= VocationRankConfig.StarsPerRank then
      if rankData.rank + 1 > config.maxRank then
        rankData.stars = VocationRankConfig.StarsPerRank
      else
        rankData.rank = rankData.rank + 1
        if rankData.rank > 1 then
          rankData.stars = 1
          rankData.totalStars = rankData.totalStars + 1
        else
          rankData.stars = 0
        end
      end
    end

    -- Salva no banco de dados
    local guid = getPlayerGUID(cid)
    db.query("UPDATE `player_vocation_ranks` SET `rank` = " ..
    rankData.rank ..
    ", `stars` = " ..
    rankData.stars ..
    ", `total_stars` = " ..
    rankData.totalStars .. " WHERE `player_id` = " .. guid .. " AND `vocation_id` = " .. vocationId)

    VocationRankLib.applyStats(cid, vocationId, rankData.totalStars)
    sendRankDataToClient(cid)
    doSendMagicEffect(getCreaturePosition(cid), 29) -- Efeito visual
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Vocation upgraded successfully!")
    return true
  else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You do not have enough fragments for the upgrade.")
    return false
  end
end

function broadcastPlayerRankData(cid)
  if not isPlayer(cid) then return end
  
  local vocationId = getPlayerVocation(cid)
  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  
  -- Buffer for overhead stars: "3|creatureId|rank|stars"
  local buffer = "3|" .. cid .. "|" .. rankData.rank .. "|" .. rankData.stars
  
  local spectators = getSpectators(getCreaturePosition(cid), 10, 10, false)
  if spectators then
    for _, spectator in ipairs(spectators) do
      if isPlayer(spectator) then
        if doSendPlayerExtendedOpcode then
          doSendPlayerExtendedOpcode(spectator, VOCATION_RANK_OPCODE, buffer)
        elseif doPlayerSendExtendedOpcode then
          doPlayerSendExtendedOpcode(spectator, VOCATION_RANK_OPCODE, buffer)
        end
      end
    end
  end
end

