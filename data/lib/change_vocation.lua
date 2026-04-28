if ChangeVocation and ChangeVocation.__loaded then
  return
end

ChangeVocation = {}
ChangeVocation.__loaded = true
print("[CV] Library loaded")

local Config           = {
  OPCODE = 230,
  STORAGE_UNLOCKED = 50001,
  DEFAULT_LOOKTYPE = 2410,
  Vocations = {
    [1]  = { name = "Bardock", lookType = 1683 },
    [2]  = { name = "Bills", lookType = 1711 },
    [3]  = { name = "Botamo", lookType = 1731 },
    [4]  = { name = "Broly", lookType = 1744 },
    [17] = { name = "Goku", lookType = 1881 },
    [40] = { name = "Vegeta", lookType = 2121 },
    [53] = { name = "Ichigo", lookType = 2227 },
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
  print("[CV] Storage: " .. tostring(storageValue))

  local unlocked = {}
  local current  = getPlayerVocation(cid)
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

  print("[CV] Unlocked count: " .. #unlocked)
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

    print("[CV] Adding: " .. name .. " id=" .. vocId .. " look=" .. lookType)

    bin = bin .. encU16(vocId)
    bin = bin .. encU16(lookType)
    bin = bin .. encU16(#name)
    bin = bin .. name
  end

  local hex = toHex(bin)
  print("[CV] Payload bin=" .. #bin .. " hex=" .. #hex .. ": " .. hex:sub(1, 60))
  return hex
end

-- -------------------------------------------------------------------- open --

function ChangeVocation.open(cid)
  if not isPlayer(cid) then return end
  print("[CV] === OPEN for " .. getCreatureName(cid) .. " ===")

  local payload = ChangeVocation.buildPayload(cid, ChangeVocation.Actions.ServerOpenSync)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, payload)
  print("[CV] === OPEN END ===")
end

-- -------------------------------------------------------------------- sync --

function ChangeVocation.syncPlayer(cid)
  if not isPlayer(cid) then return end
  print("[CV] === SYNC for " .. getCreatureName(cid) .. " ===")

  local payload = ChangeVocation.buildPayload(cid, ChangeVocation.Actions.ServerSync)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, payload)
  print("[CV] === SYNC END ===")
end

-- --------------------------------------------------------------- handle ext --

function ChangeVocation.handleExtendedOpcode(cid, buffer)
  if type(buffer) ~= "string" or buffer == "" then return end

  local action = buffer:byte(1)
  print("[CV] Client action: " .. action .. " from " .. getCreatureName(cid))

  if action == ChangeVocation.Actions.ClientChange then
    if #buffer < 3 then
      print("[CV] ERROR: Buffer too short (len=" .. #buffer .. ")")
      return
    end

    local vocId = buffer:byte(2) + (buffer:byte(3) or 0) * 256
    print("[CV] Requested change to: " .. vocId)

    if ChangeVocation.isUnlocked(cid, vocId) then
      doPlayerSetVocation(cid, vocId)
      local v = Config.Vocations[vocId] or {}
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
        "Vocation changed to " .. (v.name or "Unknown") .. "!")
      if v.lookType then
        local outfit = getCreatureOutfit(cid)
        outfit.lookType = v.lookType
        doSetCreatureOutfit(cid, outfit, -1)
      end
    else
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "You don't have permission!")
    end

    ChangeVocation.syncPlayer(cid)
  end
end
