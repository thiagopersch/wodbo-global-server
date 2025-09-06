-- Função para enviar estado inicial de todos os atributos (escopo global)
function sendInitialState(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Enviando estado inicial...")
  local attributes = { "health", "mana", "bend", "dodge" }

  -- Carrega pontos pendentes do banco
  local points = loadAttribute(cid, "skill")
  if points == -1 or points == nil then points = 0 end
  setPlayerStorageValue(cid, 10000, points)

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
    message = message .. ", " .. level .. ", " .. cost
  end

  -- Envia o estado inicial usando o canal de chat
  sendExtendedOpcode(cid, 40, message)
end

-- Função para calcular custo do próximo nível
function calculateSkillCost(skill, level)
  return level + 1   -- Ajuste conforme sua lógica de custo
end

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
  if opcode == 41 then
    local points = getPlayerStorageValue(cid, 10000)
    if points == -1 then points = 0 end
    sendExtendedOpcode(cid, 41, tostring(points))
    return true
  end

  -- Manipula opcode 38 (adicionar ponto)
  if opcode == 38 then
    local data = split(buffer, ",")
    local action = data[1] and data[1]:match("/add%s+(%w+)%s*,%s*1")
    if not action then
      return false
    end

    local skill = action
    local points = getPlayerStorageValue(cid, 10000)
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
    setPlayerStorageValue(cid, 10000, points - 1)
    saveAttribute(cid, skill, newLevel)         -- Salva no banco
    saveAttribute(cid, "skill", points - 1)     -- Salva pontos pendentes

    -- Aplica efeitos
    applySkillEffects(cid, skill, newLevel)

    -- Envia atualização no formato esperado pelo cliente
    local newCost = calculateSkillCost(skill, newLevel + 1)
    sendExtendedOpcode(cid, 38, skill .. "," .. newLevel .. "," .. newCost .. "," .. (points - 1))

    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
      "Você melhorou " .. skill .. " para o nível " .. newLevel .. ".")
    return true
  end

  return true
end

function applySkillEffects(cid, skill, level)
  if skill == "health" then
    local baseHealth = getCreatureMaxHealth(cid) - ((level - 1) * 50)
    local newMaxHealth = baseHealth + (level * 50)
    doCreatureSetMaxHealth(cid, newMaxHealth)
    doCreatureAddHealth(cid, newMaxHealth - getCreatureHealth(cid))
  elseif skill == "mana" then
    local baseMana = getCreatureMaxMana and getCreatureMaxMana(cid) or 0
    local newMaxMana = baseMana + (level * 50)
    if setCreatureMaxMana then
      setCreatureMaxMana(cid, newMaxMana)
    else
      doPlayerAddMana(cid, level * 50)
    end
  elseif skill == "bend" then
    -- Placeholder para efeito de "bend" (ex.: aumento de dano)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Efeito de bend aplicado (nível " .. level .. ").")
  elseif skill == "dodge" then
    -- Placeholder para efeito de "dodge" (ex.: aumento de velocidade)
    local baseSpeed = getCreatureBaseSpeed(cid)
    doChangeSpeed(cid, baseSpeed + (level * 10))
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

-- Função para enviar opcodes estendidos (substitui ExtendedOpcode)
function sendExtendedOpcode(cid, opcode, message)
  -- Envia os dados via canal de chat (canal 8 como exemplo)
  local player = getPlayerById(cid)
  if player then
    doPlayerSendChannelMessage(cid, "", "ATTRIB:" .. opcode .. ":" .. message, TALKTYPE_CHANNEL_R1, 8)
  end
end

-- Função para inicializar estados ao logar
function onLogin(cid)
  sendInitialState(cid)
  return true
end
