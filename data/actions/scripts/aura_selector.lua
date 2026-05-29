-- =============================================================================
-- data/actions/scripts/aura_selector.lua
-- Action do item 56541 — abre o Aura Selector no client via opcode 249
-- =============================================================================

dofile("data/lib/extoutfit_lib.lua")
dofile("data/lib/extoutfit_parser.lua")
local json = dofile("data/lib/json.lua")

local AURA_OPCODE = 249

-- Storages internos do sistema (faixa 81000+)
local ST_AURA_ITEM     = 81002  -- uid do item em uso
local ST_AURA_OPEN     = 81003  -- flag: janela aberta (1 = sim)
local ST_AURA_COOLDOWN = 81004  -- timestamp do cooldown

local COOLDOWN_SECONDS = 2
local ITEM_ID          = 56541
local LOG_TAG          = "[AuraSelector:Action]"

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

-- Envia mensagem modal como opcode (exibida como janela no client)
-- Se o client não tratar a_msg, cai para texto de console
local function sendModal(cid, msg)
  doPlayerSendExtendedOpcode(cid, AURA_OPCODE, "a_msg|" .. tostring(msg))
  -- Fallback: texto de console
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
end

-- =============================================================================
-- onUse — disparado ao clicar/usar o item 56541
-- =============================================================================
function onUse(cid, item, fromPosition, itemEx, toPosition)
  if not isPlayer(cid) then
    return false
  end

  local playerName = getPlayerName(cid)

  -- ── Proteção: janela já aberta ────────────────────────────────────────────
  if getPlayerStorageValue(cid, ST_AURA_OPEN) == 1 then
    sendModal(cid, "Você já possui uma seleção de aura aberta.")
    log("BLOCKED: janela já aberta para " .. playerName)
    return true
  end

  -- ── Proteção: cooldown ────────────────────────────────────────────────────
  local cooldown = getPlayerStorageValue(cid, ST_AURA_COOLDOWN)
  if type(cooldown) == "number" and cooldown > os.time() then
    local remaining = cooldown - os.time()
    sendModal(cid, "Aguarde " .. remaining .. " segundo(s) antes de usar novamente.")
    log("COOLDOWN: " .. playerName .. " deve aguardar " .. remaining .. "s")
    return true
  end

  -- ── Carrega auras do XML ──────────────────────────────────────────────────
  local auras = extoutfit_parser.loadAuras()
  if not auras or #auras == 0 then
    sendModal(cid, "Nenhuma aura disponível no momento. Tente novamente mais tarde.")
    log("WARNING: loadAuras() retornou 0 auras para " .. playerName)
    return true
  end

  -- ── Monta JSON seguro ─────────────────────────────────────────────────────
  local ok, aurasJson = pcall(json.encode, auras)
  if not ok or not aurasJson then
    log("ERROR: json.encode falhou: " .. tostring(aurasJson))
    sendModal(cid, "Falha ao carregar lista de auras. Tente novamente.")
    return true
  end

  -- ── Salva estado da sessão ────────────────────────────────────────────────
  setPlayerStorageValue(cid, ST_AURA_ITEM, item.uid)
  setPlayerStorageValue(cid, ST_AURA_OPEN, 1)
  setPlayerStorageValue(cid, ST_AURA_COOLDOWN, os.time() + COOLDOWN_SECONDS)

  -- ── Envia ao client: "a_open|{JSON}" ─────────────────────────────────────
  -- O client usa splitAction() que separa apenas no PRIMEIRO pipe,
  -- portanto o JSON (que pode conter pipes internos) é preservado.
  doPlayerSendExtendedOpcode(cid, AURA_OPCODE, "a_open|" .. aurasJson)

  log("OPEN: player=" .. playerName .. " auras=" .. #auras .. " item_uid=" .. item.uid)
  return true
end