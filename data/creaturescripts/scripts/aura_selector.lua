-- =============================================================================
-- data/creaturescripts/scripts/aura_selector.lua
-- Handler do opcode 249 — processa respostas do client (a_pick, a_cancel, etc)
-- Registrado em creaturescripts.xml como extendedopcode "AuraSelectorOpcode"
-- =============================================================================

dofile("data/lib/extoutfit_lib.lua")
dofile("data/lib/extoutfit_parser.lua")
local json = dofile("data/lib/json.lua")

local AURA_OPCODE = 249
local ITEM_ID     = 56541

-- Storages — mesmos do action script
local ST_AURA_ITEM     = 81002
local ST_AURA_OPEN     = 81003
local ST_AURA_COOLDOWN = 81004

-- Anti-spam: cooldown de pick separado do cooldown de abertura
local PICK_COOLDOWN_SECONDS = 2
local LOG_TAG = "[AuraSelector:Opcode]"

-- =============================================================================
-- UTILITÁRIOS
-- =============================================================================
local function log(msg)
  local text = LOG_TAG .. " " .. tostring(msg)
  print(text)
  pcall(function()
    if extoutfit and extoutfit.logFile then extoutfit.logFile(text) end
  end)
end

-- Envia mensagem modal ao client via opcode + fallback de texto
local function sendModal(cid, msg)
  doPlayerSendExtendedOpcode(cid, AURA_OPCODE, "a_msg|" .. tostring(msg))
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
end

-- Reseta estado da sessão de aura
local function resetSession(cid)
  setPlayerStorageValue(cid, ST_AURA_ITEM, -1)
  setPlayerStorageValue(cid, ST_AURA_OPEN, -1)
end

-- Divide buffer no PRIMEIRO pipe apenas (JSON pode conter pipes)
local function splitAction(buffer)
  local pipePos = string.find(buffer, '|', 1, true)
  if pipePos then
    return buffer:sub(1, pipePos - 1), buffer:sub(pipePos + 1)
  end
  return buffer, nil
end

-- Sincroniza lista de auras desbloqueadas com o client
local function syncAuras(cid)
  local list = extoutfit.getAuras(cid)
  if list and #list > 0 then
    doPlayerSendExtendedOpcode(cid, AURA_OPCODE, "a_sync|" .. table.concat(list, ","))
  else
    doPlayerSendExtendedOpcode(cid, AURA_OPCODE, "a_sync|")
  end
end

-- =============================================================================
-- HANDLER PRINCIPAL
-- =============================================================================
function onExtendedOpcode(cid, opcode, buffer)
  -- Filtra opcodes de outros sistemas
  if opcode ~= AURA_OPCODE then
    return false
  end

  -- Valida que é um jogador
  if not isPlayer(cid) then
    return false
  end

  -- Buffer vazio — ignora silenciosamente
  if not buffer or #buffer == 0 then
    log("WARN: buffer vazio recebido de " .. getPlayerName(cid))
    return false
  end

  local playerName = getPlayerName(cid)
  local action, rest = splitAction(buffer)

  -- ============================================================
  -- a_cleanup — client iniciou uma nova sessão de jogo
  -- ============================================================
  if action == "a_cleanup" then
    resetSession(cid)
    log("CLEANUP: " .. playerName)
    return true
  end

  -- ============================================================
  -- a_cancel — jogador fechou/cancelou a janela sem confirmar
  -- NÃO remove o item
  -- ============================================================
  if action == "a_cancel" then
    if getPlayerStorageValue(cid, ST_AURA_OPEN) ~= 1 then
      -- Já estava fechado — ignora
      return true
    end
    resetSession(cid)
    sendModal(cid, "Seleção de aura cancelada. Você pode usar o item novamente a qualquer momento.")
    log("CANCEL: " .. playerName)
    return true
  end

  -- ============================================================
  -- a_pick — jogador confirmou uma aura
  -- ============================================================
  if action == "a_pick" then

    -- ── Anti-spam por cooldown ──────────────────────────────────────────────
    local cooldown = getPlayerStorageValue(cid, ST_AURA_COOLDOWN)
    if type(cooldown) == "number" and cooldown > os.time() then
      log("SPAM: a_pick bloqueado por cooldown, player=" .. playerName)
      return true
    end
    setPlayerStorageValue(cid, ST_AURA_COOLDOWN, os.time() + PICK_COOLDOWN_SECONDS)

    -- ── Validação: ID da aura ──────────────────────────────────────────────
    local auraId = tonumber(rest)
    if not auraId or auraId <= 0 then
      sendModal(cid, "Seleção de aura inválida.")
      resetSession(cid)
      log("INVALID_ID: player=" .. playerName .. " id=" .. tostring(rest))
      return true
    end

    -- ── Validação: janela estava aberta ────────────────────────────────────
    if getPlayerStorageValue(cid, ST_AURA_OPEN) ~= 1 then
      sendModal(cid, "Você não possui uma seleção de aura ativa.")
      log("EXPLOIT: a_pick sem janela aberta, player=" .. playerName)
      return true
    end

    -- ── Validação: uid do item na sessão ──────────────────────────────────
    local itemUid = getPlayerStorageValue(cid, ST_AURA_ITEM)
    if not itemUid or itemUid <= 0 then
      sendModal(cid, "Item de aura não encontrado. Tente novamente.")
      resetSession(cid)
      log("NO_ITEM_UID: player=" .. playerName)
      return true
    end

    -- ── Validação: item ainda existe no inventário ─────────────────────────
    local item = getThingByUID(itemUid)
    if not item or not isItem(item) then
      sendModal(cid, "O item de aura não está mais disponível.")
      resetSession(cid)
      log("ITEM_GONE: uid=" .. itemUid .. " player=" .. playerName)
      return true
    end

    -- ── Validação: item ID correto (anti-exploit) ──────────────────────────
    if item.itemid ~= ITEM_ID then
      sendModal(cid, "Item inválido.")
      resetSession(cid)
      log("WRONG_ITEM: itemid=" .. item.itemid .. " esperado=" .. ITEM_ID .. " player=" .. playerName)
      return true
    end

    -- ── Validação: aura existe no XML ─────────────────────────────────────
    local allAuras = extoutfit_parser.loadAuras()
    local auraData = extoutfit_parser.findAura(allAuras, auraId)
    if not auraData then
      sendModal(cid, "Esta aura não existe no servidor.")
      resetSession(cid)
      log("NOT_FOUND: aura_id=" .. auraId .. " player=" .. playerName)
      return true
    end

    -- ── Proteção: aura já desbloqueada ────────────────────────────────────
    if extoutfit.hasAura(cid, auraId) then
      sendModal(cid, 'Você já possui a aura "' .. auraData.name .. '" desbloqueada.')
      resetSession(cid)
      log("DUPLICATE: aura_id=" .. auraId .. " player=" .. playerName)
      return true
    end

    -- ── Adiciona a aura ao banco de dados ─────────────────────────────────
    local success = extoutfit.addAura(cid, auraId)
    if not success then
      sendModal(cid, "Falha ao desbloquear aura. Tente novamente.")
      log("DB_FAIL: extoutfit.addAura falhou, aura_id=" .. auraId .. " player=" .. playerName)
      return true
    end

    -- ── Remove 1 item do inventário ───────────────────────────────────────
    if not doRemoveItem(itemUid, 1) then
      log("WARN: doRemoveItem falhou uid=" .. itemUid .. " player=" .. playerName)
      -- Mesmo com falha na remoção do item, a aura foi concedida — registra mas não desfaz
    end

    -- ── Limpa sessão ──────────────────────────────────────────────────────
    resetSession(cid)

    -- ── Equipa a aura imediatamente (sem relog) ───────────────────────────
    local outfit = getCreatureOutfit(cid)
    outfit.aura = auraData.looktype
    doCreatureChangeOutfit(cid, outfit)
    doPlayerSave(cid)

    -- ── Feedback: quantidade total desbloqueada ───────────────────────────
    local updatedList = extoutfit.getAuras(cid)
    local totalUnlocked = updatedList and #updatedList or 1

    local msg = 'Aura "' .. auraData.name .. '" adicionada com sucesso!\nVocê possui agora ' .. totalUnlocked .. ' aura(s) desbloqueada(s).'
    sendModal(cid, msg)

    -- ── Sincroniza lista de desbloqueadas com o client ───────────────────
    syncAuras(cid)

    -- ── Notifica looktype equipado ────────────────────────────────────────
    doPlayerSendExtendedOpcode(cid, AURA_OPCODE, "a_equipped|" .. auraData.looktype)

    -- ── Reabre a outfitwindow para refletir mudanças ──────────────────────
    -- Pequeno delay para garantir que o client processou o unlock antes
    addEvent(function()
      if isPlayer(cid) then
        doPlayerSendOutfitWindow(cid)
      end
    end, 300)

    log("SUCCESS: aura_id=" .. auraId ..
        ' name="' .. auraData.name .. '"' ..
        " looktype=" .. auraData.looktype ..
        " player=" .. playerName ..
        " total=" .. totalUnlocked)
    return true
  end

  -- Ação desconhecida — possível packet manipulado
  log("UNKNOWN_ACTION: '" .. tostring(action) .. "' player=" .. playerName)
  return false
end