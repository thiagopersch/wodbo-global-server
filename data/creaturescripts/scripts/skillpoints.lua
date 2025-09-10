-- Este script gerencia os pontos de habilidade de um jogador.
-- Ele foi ajustado para corrigir o erro 'attempt to call global 'getPlayerById''.

-- IDs de opcode e storage
local SKILL_POINTS_OPCODE_INIT = 40    -- Opcode para o estado inicial
local SKILL_POINTS_OPCODE_UPDATE = 38  -- Opcode para adicionar ponto
local SKILL_POINTS_OPCODE_PENDING = 41 -- Opcode para pontos pendentes

local SKILL_POINTS_STORAGE = 10000     -- Storage para o total de pontos de habilidade

-- Mapeamento de storages para atributos
function getSkillStorage(skill)
  local skillStorage = {
    ["health"] = 90182390120,
    ["mana"] = 90182390121,
    ["bend"] = 90182390122,
    ["dodge"] = 90182390123
  }
  return skillStorage[skill]
end

-- Função para enviar estado inicial de todos os atributos
function sendInitialState(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Enviando estado inicial...")
  local attributes = { "health", "mana", "bend", "dodge" }

  -- Carrega pontos pendentes do banco
  local points = loadAttribute(cid, "skill")
  if points == -1 or points == nil then points = 0 end
  setPlayerStorageValue(cid, SKILL_POINTS_STORAGE, points)

  -- Carrega níveis dos atributos do banco
  for _, skill in ipairs(attributes) do
    local level = loadAttribute(cid, skill)
    if level == -1 or level == nil then level = 0 end
    setPlayerStorageValue(cid, getSkillStorage(skill), level)
  end

  local message = tostring(points)
  for _, skill in ipairs(attributes) do
    local level = getPlayerStorageValue(cid, getSkillStorage(skill))
    if level == -1 then level = 0 end
    local cost = calculateSkillCost(skill, level + 1)
    message = message .. "," .. level .. "," .. cost
  end

  -- Envia o estado inicial usando o opcode
  doSendPlayerExtendedOpcode(cid, SKILL_POINTS_OPCODE_INIT, message)
end

-- Função para calcular custo do próximo nível
function calculateSkillCost(skill, level)
  return level + 1 -- Ajuste conforme sua lógica de custo
end

-- Função para salvar no banco de dados (simplificada)
function saveAttribute(cid, skill, value)
  local column = skill == "skill" and "skill_points" or (skill .. "_skill")
  local query = string.format("UPDATE `players` SET `%s` = %d WHERE `id` = %d",
    column, value, getPlayerGUID(cid))
  db.executeQuery(query)
end

-- Função para carregar do banco de dados (simplificada)
function loadAttribute(cid, skill)
  local column = skill == "skill" and "skill_points" or (skill .. "_skill")
  local query = string.format("SELECT `%s` FROM `players` WHERE `id` = %d",
    column, getPlayerGUID(cid))
  local result = db.getResult(query)
  if result ~= nil and result:getID() ~= -1 then
    local value = result:getDataInt(column) or 0
    result:free()
    return value
  end
  return 0
end

function onExtendedOpcode(cid, opcode, buffer)
  if not isPlayer(cid) then
    return false
  end

  -- Manipula opcode 41 (atualização de pontos pendentes)
  if opcode == SKILL_POINTS_OPCODE_PENDING then
    local points = getPlayerStorageValue(cid, SKILL_POINTS_STORAGE)
    if points == -1 then points = 0 end
    doSendPlayerExtendedOpcode(cid, SKILL_POINTS_OPCODE_PENDING, tostring(points))
    return true
  end

  -- Manipula opcode 38 (adicionar ponto)
  if opcode == SKILL_POINTS_OPCODE_UPDATE then
    local data = split(buffer, ",")
    local action = data[1] and data[1]:match("/add%s+(%w+)%s*,%s*1")
    if not action then
      return false
    end

    local skill = action
    local points = getPlayerStorageValue(cid, SKILL_POINTS_STORAGE)
    if points == -1 then points = 0 end

    if points < 1 then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Você não tem pontos de habilidade.")
      return true
    end

    local currentLevel = getPlayerStorageValue(cid, getSkillStorage(skill))
    if currentLevel == -1 then currentLevel = 0 end
    if currentLevel >= 10 then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Esta habilidade já está no nível máximo.")
      return true
    end

    -- Aplica o novo nível
    local newLevel = currentLevel + 1
    setPlayerStorageValue(cid, getSkillStorage(skill), newLevel)
    setPlayerStorageValue(cid, SKILL_POINTS_STORAGE, points - 1)
    saveAttribute(cid, skill, newLevel)     -- Salva no banco
    saveAttribute(cid, "skill", points - 1) -- Salva pontos pendentes

    -- Aplica efeitos
    applySkillEffects(cid, skill, newLevel)

    -- Envia atualização no formato esperado pelo cliente
    local newCost = calculateSkillCost(skill, newLevel + 1)
    doSendPlayerExtendedOpcode(cid, SKILL_POINTS_OPCODE_UPDATE,
      skill .. "," .. newLevel .. "," .. newCost .. "," .. (points - 1))

    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
      "Você melhorou " .. skill .. " para o nível " .. newLevel .. ".")
    return true
  end

  return true
end

function applySkillEffects(cid, skill, level)
  if skill == "health" then
    local newMaxHealth = (getPlayerMaxHealth(cid) or getCreatureMaxHealth(cid)) + (level * 50)
    doCreatureSetMaxHealth(cid, newMaxHealth)
    doCreatureAddHealth(cid, newMaxHealth - getCreatureHealth(cid))
  elseif skill == "mana" then
    local newMaxMana = (getPlayerMaxMana(cid) or getCreatureMaxMana(cid)) + (level * 50)
    doCreatureSetMaxMana(cid, newMaxMana)
    doCreatureAddMana(cid, newMaxMana - getCreatureMana(cid))
  elseif skill == "bend" then
    -- Placeholder para efeito de "bend" (ex.: aumento de dano)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Efeito de bend aplicado (nível " .. level .. ").")
  elseif skill == "dodge" then
    -- Placeholder para efeito de "dodge" (ex.: aumento de velocidade)
    doChangeSpeed(cid, getCreatureBaseSpeed(cid) + (level * 10))
  end
end

function split(str, sep)
  local result = {}
  sep = sep or ","
  for part in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(result, part)
  end
  return result
end

-- A função onLogin agora chama a função 'sendInitialState' diretamente.
function onLogin(cid)
  sendInitialState(cid)
  return true
end
