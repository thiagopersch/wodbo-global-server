function onExtendedOpcode(cid, opcode, buffer)
  if opcode == 50 then
    if not isPlayer(cid) then
      return false
    end
    local data = {}
    for i, v in ipairs(split(buffer, "|")) do
      data[i] = v
    end
    local action = data[1]
    local skill = data[2]
    if action == "addPoint" then
      local points = getPlayerStorageValue(cid, 10000)
      if points == -1 then
        points = 0
      end
      if points < 1 then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Você não tem pontos de habilidade.")
        return true
      end
      local skillStorage = {
        ["exp"] = 10001,
        ["stamina"] = 10002,
        ["magic"] = 10003,
        ["speed"] = 10004,
        ["attack_speed"] = 10005,
        ["fist"] = 10006,
        ["club"] = 10007,
        ["sword"] = 10008,
        ["axe"] = 10009,
        ["distance"] = 10010,
        ["shielding"] = 10011,
        ["fishing"] = 10012,
        ["health"] = 10013,
        ["mana"] = 10014,
        ["defense"] = 10015,
        ["cooldown"] = 10016,
        ["loot"] = 10017,
        ["critical"] = 10018
      }
      local currentLevel = getPlayerStorageValue(cid, skillStorage[skill])
      if currentLevel == -1 then
        currentLevel = 0
      end
      if currentLevel >= 10 then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Esta habilidade já está no nível máximo.")
        return true
      end
      setPlayerStorageValue(cid, skillStorage[skill], currentLevel + 1)
      setPlayerStorageValue(cid, 10000, points - 1)
      applySkillEffects(cid, skill, currentLevel + 1)
      doPlayerSendExtendedOpcode(cid, 50, "updatePoints|" .. (points - 1))
      doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
        "Você melhorou " .. skill .. " para o nível " .. (currentLevel + 1) .. ".")
    end
  end
  return true
end

function applySkillEffects(cid, skill, level)
  -- Ganho de experiência: tratado em onAdvance
  if skill == "exp" then
    -- Implementado em creaturescripts/skillpoints.lua
    -- Stamina: tratado em global.lua ou outro sistema
  elseif skill == "stamina" then
    -- Requer sistema de stamina customizado
    -- Magic level: tratado em onAdvance
  elseif skill == "magic" then
    -- Implementado em creaturescripts/skillpoints.lua
    -- Velocidade
  elseif skill == "speed" then
    local baseSpeed = getCreatureBaseSpeed(cid)
    doChangeSpeed(cid, baseSpeed + (level * 10))
    -- Velocidade de ataque: não suportado sem modificação no código-fonte
  elseif skill == "attack_speed" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Velocidade de ataque não implementada.")
    -- Vida
  elseif skill == "health" then
    local increase = level * 50
    doCreatureSetMaxHealth(cid, getCreatureMaxHealth(cid) + increase)
    doCreatureAddHealth(cid, increase)
    -- Mana
  elseif skill == "mana" then
    local increase = level * 50
    doPlayerAddMana(cid, increase)
    -- Defesa: tratado via equipamento ou condições
  elseif skill == "defense" then
    -- Requer sistema de defesa customizado
    -- Cooldown de magias: não suportado sem modificação no código-fonte
  elseif skill == "cooldown" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Cooldown de magias não implementado.")
    -- Chance de loot: tratado em onKill
  elseif skill == "loot" then
    -- Implementado em creaturescripts/skillpoints.lua
    -- Chance crítica: tratado em onAttack
  elseif skill == "critical" then
    -- Requer sistema de crítico customizado
    -- Habilidades de combate e pesca
  else
    local skillId = ({
      fist = SKILL_FIST,
      club = SKILL_CLUB,
      sword = SKILL_SWORD,
      axe = SKILL_AXE,
      distance = SKILL_DISTANCE,
      shielding = SKILL_SHIELD,
      fishing = SKILL_FISHING
    })[skill]
    if skillId then
      local currentTries = getPlayerSkillTries(cid, skillId)
      doPlayerAddSkillTry(cid, skillId, level * 100)
    end
  end
end

function split(str, sep)
  local result = {}
  local regex = ("([^%s]+)"):format(sep)
  for each in str:gmatch(regex) do
    table.insert(result, each)
  end
  return result
end

-- function onExtendedOpcode(cid, opcode, buffer)
--   if opcode == 50 then
--     local player = getPlayerStorageValue(cid)
--     local data = {}
--     for i, v in ipairs(split(buffer, "|")) do
--       data[i] = v
--     end
--     local action = data[1]
--     local skill = data[2]
--     if action == "addPoint" then
--       local points = player:getStorageValue(10000)
--       if points == -1 then
--         points = 0
--       end
--       if points < 1 then
--         player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Você não tem pontos de habilidade.")
--         return true
--       end
--       local skillStorage = {
--         ["exp"] = 10001,
--         ["stamina"] = 10002,
--         ["magic"] = 10003,
--         ["speed"] = 10004,
--         ["attackspeed"] = 10005,
--         ["fist"] = 10006,
--         ["club"] = 10007,
--         ["sword"] = 10008,
--         ["axe"] = 10009,
--         ["distance"] = 10010,
--         ["shielding"] = 10011,
--         ["fishing"] = 10012,
--         ["health"] = 10013,
--         ["mana"] = 10014,
--         ["defense"] = 10015,
--         ["cooldown"] = 10016,
--         ["loot"] = 10017,
--         ["critical"] = 10018
--       }
--       local currentLevel = player:getStorageValue(skillStorage[skill])
--       if currentLevel == -1 then
--         currentLevel = 0
--       end
--       if currentLevel >= 10 then
--         player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Esta habilidade já está no nível máximo.")
--         return true
--       end
--       player:setStorageValue(skillStorage[skill], currentLevel + 1)
--       player:setStorageValue(10000, points - 1)
--       applySkillEffects(player, skill, currentLevel + 1)
--       player:sendExtendedOpcode(50, "updatePoints|" .. (points - 1))
--       player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
--         "Você melhorou " .. skill .. " para o nível " .. (currentLevel + 1) .. ".")
--       player:save()
--     end
--   end
--   return true
-- end

-- function applySkillEffects(player, skill, level)
--   -- Ganho de experiência
--   if skill == "exp" then
--     -- Tratado em onAdvance
--   elseif skill == "stamina" then
--     -- Tratado em global.lua
--   elseif skill == "magic" then
--     -- Tratado em onAdvance
--   elseif skill == "speed" then
--     local baseSpeed = player:getBaseSpeed()
--     player:setBaseSpeed(baseSpeed + (level * 10))
--   elseif skill == "attackspeed" then
--     -- Requer modificação no código-fonte ou script de velocidade de ataque
--   elseif skill == "health" then
--     local increase = level * 50
--     player:setMaxHealth(player:getMaxHealth() + increase)
--     player:addHealth(increase)
--   elseif skill == "mana" then
--     local increase = level * 50
--     player:setMaxMana(player:getMaxMana() + increase)
--     player:addMana(increase)
--   elseif skill == "defense" then
--     -- Tratado via equipamento ou condições
--   elseif skill == "cooldown" then
--     -- Requer modificação no código-fonte
--   elseif skill == "loot" then
--     -- Tratado em onKill
--   elseif skill == "critical" then
--     -- Tratado em onAttack
--   else
--     -- Habilidades: fist, club, sword, axe, distance, shielding, fishing
--     local skillId = ({
--       fist = SKILL_FIST,
--       club = SKILL_CLUB,
--       sword = SKILL_SWORD,
--       axe = SKILL_AXE,
--       distance = SKILL_DISTANCE,
--       shielding = SKILL_SHIELD,
--       fishing = SKILL_FISHING
--     })[skill]
--     if skillId then
--       player:addSkillTries(skillId, level * 100)
--     end
--   end
-- end
