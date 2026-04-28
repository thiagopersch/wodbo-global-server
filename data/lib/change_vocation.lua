if ChangeVocation and ChangeVocation.__loaded then
  return
end

ChangeVocation = {}
ChangeVocation.__loaded = true
print("[CV] Library loaded")

local Config           = {
  OPCODE = 230,
  STORAGE_UNLOCKED = 50001,
  DEFAULT_LOOKTYPE = 0, -- Alterado para 0 (faz o client buscar a atual)
  Vocations = {
    [1]  = { name = "Bardock", lookType = 1683 },
    [2]  = { name = "Bills", lookType = 1711 },
    [3]  = { name = "Botamo", lookType = 1731 },
    [4]  = { name = "Brolly", lookType = 1739 },
    [5]  = { name = "Bulma", lookType = 1748 },
    [6]  = { name = "Buu", lookType = 1755 },
    [7]  = { name = "C8", lookType = 1777 },
    [8]  = { name = "C17", lookType = 1777 },
    [9]  = { name = "C18", lookType = 1777 },
    [10] = { name = "Cabba", lookType = 1794 },
    [11] = { name = "Cell", lookType = 1804 },
    [12] = { name = "Cooler", lookType = 1811 },
    [13] = { name = "Dende", lookType = 1822 },
    [14] = { name = "Freeza", lookType = 1835 },
    [15] = { name = "Ginn", lookType = 1845 },
    [16] = { name = "Gohan", lookType = 1854 },
    [17] = { name = "Goku", lookType = 1881 },
    [18] = { name = "Goku Black", lookType = 1869 },
    [19] = { name = "Hitto", lookType = 1900 },
    [20] = { name = "Janemba", lookType = 1909 },
    [21] = { name = "Jiren", lookType = 1917 },
    [22] = { name = "Kagome", lookType = 1931 },
    [23] = { name = "Kaio", lookType = 1942 },
    [24] = { name = "Kame", lookType = 1951 },
    [25] = { name = "King Cold", lookType = 1963 },
    [26] = { name = "King Vegeta", lookType = 1973 },
    [27] = { name = "Kuririn", lookType = 1984 },
    [28] = { name = "Liquir", lookType = 1995 },
    [29] = { name = "Pan", lookType = 2003 },
    [30] = { name = "Piccolo", lookType = 2012 },
    [31] = { name = "Quitela", lookType = 2025 },
    [32] = { name = "Raditz", lookType = 2034 },
    [33] = { name = "Shenron", lookType = 2048 },
    [34] = { name = "Tapion", lookType = 2051 },
    [35] = { name = "Trunks", lookType = 2066 },
    [36] = { name = "Tsuful", lookType = 2079 },
    [37] = { name = "Turles", lookType = 2093 },
    [38] = { name = "Uub", lookType = 2106 },
    [39] = { name = "Vados", lookType = 2113 },
    [40] = { name = "Vegeta", lookType = 2121 },
    [41] = { name = "Vegetto", lookType = 2135 },
    [42] = { name = "Vermouth", lookType = 1697 },
    [43] = { name = "Videl", lookType = 2144 },
    [44] = { name = "Zaiko", lookType = 2151 },
    [45] = { name = "Zeno", lookType = 2163 },
    [47] = { name = "Aizen", lookType = 2176 },
    [48] = { name = "Byakuya", lookType = 2185 },
    [49] = { name = "Gin", lookType = 2193 },
    [50] = { name = "Grimmjow", lookType = 2199 },
    [51] = { name = "Hitsugaya", lookType = 2207 },
    [52] = { name = "Ichigo FullBring", lookType = 2218 },
    [53] = { name = "Ichigo", lookType = 2227 },
    [54] = { name = "Ishida", lookType = 2239 },
    [55] = { name = "Kyouraku", lookType = 2250 },
    [56] = { name = "Neliel", lookType = 2255 },
    [57] = { name = "Orihime", lookType = 2262 },
    [58] = { name = "Renji", lookType = 2268 },
    [59] = { name = "Rukia", lookType = 2276 },
    [60] = { name = "Sado", lookType = 2280 },
    [61] = { name = "Shinji", lookType = 2291 },
    [62] = { name = "Soi Fong", lookType = 2303 },
    [63] = { name = "Tousen", lookType = 2309 },
    [64] = { name = "Ulquiorra", lookType = 2315 },
    [65] = { name = "Urahara", lookType = 2323 },
    [66] = { name = "Yoruichi", lookType = 2332 },
    [67] = { name = "Zaraki", lookType = 2339 },
  }
}

ChangeVocation.Config  = Config
ChangeVocation.Actions = {
  ServerOpen     = 1,
  ServerSync     = 2,
  ClientChange   = 1,
  ServerOpenSync = 3,
}

-- Converte binário para hex string (Lua 5.1 safe)
local function toHex(s)
  return (s:gsub(".", function(c)
    return string.format("%02x", c:byte())
  end))
end

-- Encode U16 big-endian sem operadores bitwise (Lua 5.1)
local function encU16(v)
  return string.char(math.floor(v / 256)) .. string.char(v % 256)
end

-- ------------------------------------------------------------------ helpers --

function ChangeVocation.getVocationName(vocId)
  local v = Config.Vocations[vocId]
  return v and v.name or ("Voc " .. vocId)
end

function ChangeVocation.isUnlocked(cid, vocId)
  local unlocked = ChangeVocation.getUnlockedVocations(cid)
  for _, id in ipairs(unlocked) do
    if id == vocId then return true end
  end
  return false
end

function ChangeVocation.getUnlockedVocations(cid)
  local storageValue = getPlayerStorageValue(cid, Config.STORAGE_UNLOCKED)

  local unlocked     = {}
  local current      = getPlayerVocation(cid)
  table.insert(unlocked, current)

  if storageValue and storageValue ~= -1 and storageValue ~= "" then
    local str = tostring(storageValue)
    for vocId in str:gmatch("(%d+)") do
      local id = tonumber(vocId)
      if id and id > 0 and id ~= current then
        table.insert(unlocked, id)
      end
    end
  end

  return unlocked
end

-- ------------------------------------------------------------------- unlock --

function ChangeVocation.unlockVocation(cid, vocId)
  local current = getPlayerStorageValue(cid, Config.STORAGE_UNLOCKED)
  local str = (current and current ~= -1) and tostring(current) or ""

  for existing in str:gmatch("(%d+)") do
    if tonumber(existing) == vocId then return end
  end

  local newValue = (str == "") and tostring(vocId) or (str .. "," .. vocId)
  setPlayerStorageValue(cid, Config.STORAGE_UNLOCKED, newValue)
  print("[CV] Unlocked voc " .. vocId .. " for " .. getCreatureName(cid))
end

-- ------------------------------------------------------------------- build --

function ChangeVocation.buildPayload(cid, action)
  local unlocked  = ChangeVocation.getUnlockedVocations(cid)
  local currentId = getPlayerVocation(cid)

  local bin       = ""
  bin             = bin .. string.char(action)
  bin             = bin .. encU16(currentId)
  bin             = bin .. encU16(#unlocked)

  for _, vocId in ipairs(unlocked) do
    local v        = Config.Vocations[vocId] or {}
    local name     = v.name or ("Voc " .. vocId)
    local lookType = v.lookType or Config.DEFAULT_LOOKTYPE

    bin            = bin .. encU16(vocId)
    bin            = bin .. encU16(lookType)
    bin            = bin .. encU16(#name)
    bin            = bin .. name
  end

  local hex = toHex(bin)
  return hex
end

-- -------------------------------------------------------------------- open --

function ChangeVocation.open(cid)
  if not isPlayer(cid) then return end
  local payload = ChangeVocation.buildPayload(cid, ChangeVocation.Actions.ServerOpenSync)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, payload)
end

-- -------------------------------------------------------------------- sync --

function ChangeVocation.syncPlayer(cid)
  if not isPlayer(cid) then return end
  local payload = ChangeVocation.buildPayload(cid, ChangeVocation.Actions.ServerSync)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, payload)
end

-- --------------------------------------------------------------- handle ext --

function ChangeVocation.handleExtendedOpcode(cid, buffer)
  if type(buffer) ~= "string" or buffer == "" then return end

  local action = buffer:byte(1)

  if action == ChangeVocation.Actions.ClientChange then
    if #buffer < 3 then return end

    local vocId = buffer:byte(2) + (buffer:byte(3) or 0) * 256

    if not ChangeVocation.isUnlocked(cid, vocId) then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "You don't have permission!")
      return
    end

    local v = Config.Vocations[vocId] or {}

    -- Aplica vocation e outfit
    doPlayerSetVocation(cid, vocId)
    if v.lookType then
      local outfit = getCreatureOutfit(cid)
      outfit.lookType = v.lookType
      doSetCreatureOutfit(cid, outfit, -1)
    end

    -- Avisa e desloga para aplicar as mudanças
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
      "Vocation changed to " .. (v.name or "Unknown") .. "! You will be disconnected now.")

    -- Salva e desloga após 2 segundos
    addEvent(function()
      if isPlayer(cid) then
        doSavePlayer(cid)
        doRemoveCreature(cid)
      end
    end, 2000)
  end
end
