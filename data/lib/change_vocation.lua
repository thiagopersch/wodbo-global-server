-- -- data/lib/change_vocation.lua
-- -- Server-side support for the game_changevocation client module.

-- if ChangeVocation and ChangeVocation.__loaded then
--   return
-- end

-- ChangeVocation = ChangeVocation or {}
-- ChangeVocation.__loaded = true

-- local Config = {
--   OPCODE = 4,
--   STORAGE_UNLOCKED = 50001,
--   TIER_STORAGE_BASE = 51000,
--   DEFAULT_MAX_TIER = 15,
--   DEFAULT_LEVEL = 1,
--   DEFAULT_LOOKTYPE = 2410,
--   UpgradeCost = {
--     mode = "item", -- "item" or "money"
--     itemId = 2160, -- golden token
--     base = 1,
--     increment = 1,
--     message = function(playerName, vocationName, nextTier, costCount, itemId)
--       local itemName = getItemNameById(itemId)
--       return string.format(
--         "%s, upgrade %s to tier %d by consuming %d %s?",
--         playerName,
--         vocationName,
--         nextTier,
--         costCount,
--         itemName ~= "" and itemName or ("item #" .. itemId)
--       )
--     end
--   },
--   Vocations = {
--     [1]  = { name = "Bardock", lookType = 1683, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [2]  = { name = "Bills", lookType = 1711, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [3]  = { name = "Botamo", lookType = 1731, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [4]  = { name = "Broly", lookType = 1744, class = 3, type = 5, element = 0, level = 1, maxTier = 15 },
--     [5]  = { name = "Bulma", lookType = 1745, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [6]  = { name = "Buu", lookType = 1755, class = 2, type = 5, element = 5, level = 1, maxTier = 15 },
--     [7]  = { name = "C8", lookType = 1765, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [8]  = { name = "C17", lookType = 1783, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [9]  = { name = "C18", lookType = 1789, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [10] = { name = "Cabba", lookType = 1794, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [11] = { name = "Cell", lookType = 1807, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [12] = { name = "Cooler", lookType = 1812, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [13] = { name = "Dende", lookType = 1822, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [14] = { name = "Freeza", lookType = 1839, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [15] = { name = "Ginn", lookType = 1847, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [16] = { name = "Gohan", lookType = 1854, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [17] = { name = "Goku", lookType = 1881, class = 4, type = 2, element = 1, level = 1, maxTier = 15 },
--     [18] = { name = "Goku Black", lookType = 1876, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [19] = { name = "Hitto", lookType = 1900, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [20] = { name = "Janemba", lookType = 1909, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [21] = { name = "Jiren", lookType = 1917, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [22] = { name = "Kagome", lookType = 1931, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [23] = { name = "Kaio", lookType = 1942, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [24] = { name = "Kame", lookType = 1951, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [25] = { name = "King Cold", lookType = 1963, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [26] = { name = "King Vegeta", lookType = 1973, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [27] = { name = "Kuririn", lookType = 1984, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [28] = { name = "Liquir", lookType = 1995, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [29] = { name = "Pan", lookType = 2003, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [30] = { name = "Piccolo", lookType = 2012, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [31] = { name = "Quitela", lookType = 2026, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [32] = { name = "Raditz", lookType = 2034, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [33] = { name = "Shenron", lookType = 2042, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [34] = { name = "Tapion", lookType = 2051, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [35] = { name = "Trunks", lookType = 2066, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [36] = { name = "Tsuful", lookType = 2079, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [37] = { name = "Turles", lookType = 2093, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [38] = { name = "Uub", lookType = 2106, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [39] = { name = "Vados", lookType = 2113, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [40] = { name = "Vegeta", lookType = 2121, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [41] = { name = "Vegetto", lookType = 2135, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [42] = { name = "Vermouth", lookType = 1701, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [43] = { name = "Videl", lookType = 2144, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [44] = { name = "Zaiko", lookType = 2151, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },
--     [45] = { name = "Zeno", lookType = 2163, class = 4, type = 2, element = 0, level = 1, maxTier = 15 },

--     [47] = { name = "Aizen", lookType = 2176, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [48] = { name = "Byakuya", lookType = 2185, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [49] = { name = "Gin", lookType = 2193, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [50] = { name = "Grimmjow", lookType = 2199, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [51] = { name = "Hitsugaya", lookType = 2207, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [52] = { name = "Ichigo FullBring", lookType = 2213, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [53] = { name = "Ichigo", lookType = 2227, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [54] = { name = "Ishida", lookType = 2239, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [55] = { name = "Kyouraku", lookType = 2250, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [56] = { name = "Neliel", lookType = 2255, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [57] = { name = "Orihime", lookType = 2262, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [58] = { name = "Renji", lookType = 2271, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [59] = { name = "Rukia_Kuchiki", lookType = 2276, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [60] = { name = "Sado", lookType = 2280, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [61] = { name = "Shinji", lookType = 2296, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [62] = { name = "Soi Fong", lookType = 2303, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [63] = { name = "Tousen", lookType = 2309, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [64] = { name = "Ulquiorra", lookType = 2319, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [65] = { name = "Urahara", lookType = 2323, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [66] = { name = "Yoruichi", lookType = 2332, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--     [67] = { name = "Zaraki", lookType = 2339, class = 1, type = 1, element = 9, level = 1, maxTier = 15 },
--   }
-- }

-- ChangeVocation.Config = Config

-- ChangeVocation.Actions = {
--   ServerSync = 1,
--   ServerUpgradePrompt = 2,
--   ServerUpgradeResult = 3,
--   ClientChange = 1,
--   ClientUpgradePrompt = 2,
--   ClientUpgradeConfirm = 3
-- }

-- local function writeU8(num)
--   num = math.max(0, math.min(255, num or 0))
--   return string.char(num)
-- end

-- local function writeU16(num)
--   num = math.max(0, math.min(65535, num or 0))
--   local lo = num % 256
--   local hi = (num - lo) / 256
--   return string.char(lo, hi)
-- end

-- local function writeU32(num)
--   num = math.max(0, math.min(0xFFFFFFFF, num or 0))
--   local b1 = num % 256
--   num = (num - b1) / 256
--   local b2 = num % 256
--   num = (num - b2) / 256
--   local b3 = num % 256
--   local b4 = (num - b3) / 256
--   return string.char(b1, b2, b3, b4)
-- end

-- local function writeString(value)
--   value = tostring(value or "")
--   return writeU16(value:len()) .. value
-- end

-- local function readU8(buffer, pos)
--   local byte = buffer:byte(pos) or 0
--   return byte, pos + 1
-- end

-- local function readU16(buffer, pos)
--   local b1 = buffer:byte(pos) or 0
--   local b2 = buffer:byte(pos + 1) or 0
--   return b1 + b2 * 256, pos + 2
-- end

-- local function readU32(buffer, pos)
--   local b1 = buffer:byte(pos) or 0
--   local b2 = buffer:byte(pos + 1) or 0
--   local b3 = buffer:byte(pos + 2) or 0
--   local b4 = buffer:byte(pos + 3) or 0
--   local value = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
--   return value, pos + 4
-- end

-- local function readString(buffer, pos)
--   local length
--   length, pos = readU16(buffer, pos)
--   local value = buffer:sub(pos, pos + length - 1)
--   return value, pos + length
-- end

-- local function getCurrentVocationId(cid)
--   local vocation = getPlayerVocation(cid)
--   if type(vocation) ~= "number" then
--     vocation = tonumber(vocation) or 0
--   end
--   return vocation
-- end

-- local function getVocationDefinition(vocationId, cid)
--   local def = Config.Vocations[vocationId]
--   if def then
--     return def
--   end

--   local name = "Vocation " .. vocationId
--   local info = getVocationInfo and getVocationInfo(vocationId)
--   if info and info.name then
--     name = info.name
--   end

--   local lookType = Config.DEFAULT_LOOKTYPE
--   if isPlayer(cid) and vocationId == getCurrentVocationId(cid) then
--     local outfit = getCreatureOutfit(cid)
--     if outfit and outfit.lookType and outfit.lookType > 0 then
--       lookType = outfit.lookType
--     end
--   end

--   return {
--     name = name,
--     lookType = lookType,
--     class = 4,
--     type = 2,
--     element = 0,
--     level = Config.DEFAULT_LEVEL,
--     maxTier = Config.DEFAULT_MAX_TIER
--   }
-- end

-- local function parseUnlockedString(value)
--   local unlocked = {}
--   local seen = {}
--   if type(value) ~= "string" then
--     value = tostring(value or "")
--   end

--   -- Handle empty/NULL/-1/nil EXPLICITLY
--   if value == "" or value == "-1" or value == nil then
--     return unlocked
--   end

--   -- Parse comma-separated: "17,67" ou "17, 67"
--   for vocStr in value:gmatch("([^,]+)") do
--     vocStr = vocStr:match("^%s*(.-)%s*$") -- trim
--     local vocId = tonumber(vocStr)
--     if vocId and vocId > 0 and not seen[vocId] then
--       table.insert(unlocked, vocId)
--       seen[vocId] = true
--     end
--   end

--   table.sort(unlocked)
--   return unlocked
-- end

-- local function getUnlockedVocations(cid)
--   local storageValue = getPlayerStorageValue(cid, Config.STORAGE_UNLOCKED)

--   -- CRÍTICO: Sempre tratar "" ou -1 como vazio
--   if storageValue == -1 or storageValue == "" then
--     storageValue = ""
--   elseif type(storageValue) ~= "string" then
--     storageValue = tostring(storageValue or "")
--   end

--   print(string.format("[ChangeVocation] Raw storage '%s' (len=%d, type=%s)",
--     storageValue, #storageValue, type(storageValue)))

--   local unlocked = parseUnlockedString(storageValue)
--   print(string.format("[ChangeVocation] Parsed unlocked: [%s]", table.concat(unlocked, ",")))

--   local current = getCurrentVocationId(cid)
--   print(string.format("[ChangeVocation] Current: %d", current))

--   -- SEMPRE adicionar current, mesmo se duplicado (evita vazios)
--   local hasCurrent = false
--   for _, v in ipairs(unlocked) do
--     if v == current then
--       hasCurrent = true
--       break
--     end
--   end
--   if not hasCurrent then
--     print(string.format("[ChangeVocation] Forcing add current %d", current))
--     table.insert(unlocked, current)
--     table.sort(unlocked)
--   end

--   print(string.format("[ChangeVocation] FINAL list: [%s]", table.concat(unlocked, ",")))
--   return unlocked
-- end

-- local function getTierStorageKey(vocationId)
--   return Config.TIER_STORAGE_BASE + vocationId
-- end

-- local function getTierLevel(cid, vocationId)
--   local value = getPlayerStorageValue(cid, getTierStorageKey(vocationId))
--   if type(value) ~= "number" then
--     value = tonumber(value) or 0
--   end
--   if value < 0 then
--     value = 0
--   end
--   return value
-- end

-- local function setTierLevel(cid, vocationId, tier)
--   setPlayerStorageValue(cid, getTierStorageKey(vocationId), math.max(0, tier or 0))
-- end

-- local function encodeVocationList(cid, entries, currentId)
--   local payload = {}

--   -- Action + Current ID + Count
--   payload[#payload + 1] = writeU8(ChangeVocation.Actions.ServerSync)
--   payload[#payload + 1] = writeU16(currentId)
--   payload[#payload + 1] = writeU16(#entries)

--   print(string.format("[DEBUG] Encoding %d vocations for player %s", #entries, getCreatureName(cid)))

--   for i, entry in ipairs(entries) do
--     print(string.format("  [%d] id=%d name=%s lookType=%d tier=%d level=%d",
--       i, entry.id, entry.name, entry.lookType, entry.tier, entry.level))

--     payload[#payload + 1] = writeU16(entry.id)
--     payload[#payload + 1] = writeU16(entry.lookType or Config.DEFAULT_LOOKTYPE)
--     payload[#payload + 1] = writeU16(entry.tier or 0)
--     payload[#payload + 1] = writeU32(entry.level or Config.DEFAULT_LEVEL)
--     payload[#payload + 1] = writeString(entry.name or ("Vocation " .. entry.id))
--     payload[#payload + 1] = writeU8(entry.class or 4)
--     payload[#payload + 1] = writeU8(entry.type or 2)
--     payload[#payload + 1] = writeU8(entry.element or 0)
--   end

--   local buffer = table.concat(payload)
--   print(string.format("[DEBUG] Buffer size: %d bytes", #buffer))
--   return buffer
-- end

-- local function getUpgradeCost(currentTier)
--   currentTier = currentTier or 0
--   local cfg = Config.UpgradeCost
--   local count = cfg.base + (currentTier * cfg.increment)
--   return {
--     mode = cfg.mode,
--     itemId = cfg.itemId or 0,
--     count = count,
--   }
-- end

-- local function hasUpgradeResources(cid, cost)
--   if cost.mode == "money" then
--     return getPlayerMoney(cid) >= cost.count
--   end
--   return getPlayerItemCount(cid, cost.itemId) >= cost.count
-- end

-- local function spendUpgradeResources(cid, cost)
--   if cost.mode == "money" then
--     if getPlayerMoney(cid) < cost.count then
--       return false
--     end
--     doPlayerRemoveMoney(cid, cost.count)
--     return true
--   end
--   return doPlayerRemoveItem(cid, cost.itemId, cost.count)
-- end

-- function ChangeVocation.syncPlayer(cid)
--   if not isPlayer(cid) then
--     return
--   end

--   local guid = getPlayerGUID(cid)
--   local res = db.getResult("SELECT `unlocked_vocations` FROM `players` WHERE `id` = " .. guid)
--   local dbVocs = ""
--   if res and res:getID() ~= -1 then
--     dbVocs = res:getDataString("unlocked_vocations") or ""
--     res:free()
--   end
--   setPlayerStorageValue(cid, Config.STORAGE_UNLOCKED, dbVocs)
--   print(string.format("[SyncPlayer] FORCED DB reload for %s: '%s'", getCreatureName(cid), dbVocs))

--   local unlocked = getUnlockedVocations(cid)
--   local entries = {}
--   local currentId = getCurrentVocationId(cid)

--   for _, vocId in ipairs(unlocked) do
--     local def = getVocationDefinition(vocId, cid)
--     entries[#entries + 1] = {
--       id = vocId,
--       name = def.name,
--       lookType = def.lookType,
--       class = def.class or 0,
--       type = def.type or 0,
--       element = def.element or 0,
--       level = def.level or Config.DEFAULT_LEVEL,
--       tier = getTierLevel(cid, vocId),
--     }
--   end

--   local unlockedStr = (#unlocked > 0) and table.concat(unlocked, ",") or ""
--   print(string.format("[ChangeVocation] Syncing player %s: vocs=%d unlocked=%s current=%d",
--     getCreatureName(cid) or "?", #entries, unlockedStr, currentId))

--   if #entries == 0 then
--     print(string.format("[ChangeVocation] WARNING: No entries to sync for player %s!",
--       getCreatureName(cid) or "?"))
--   else
--     for i, entry in ipairs(entries) do
--       print(string.format("[ChangeVocation] Entry %d: id=%d name=%s lookType=%d tier=%d",
--         i, entry.id, entry.name, entry.lookType, entry.tier))
--     end
--   end

--   local buffer = encodeVocationList(cid, entries, currentId)
--   doPlayerSendExtendedOpcode(cid, Config.OPCODE, buffer)
-- end

-- local function sendUpgradePrompt(cid, canUpgrade, message)
--   local payload = {}
--   payload[#payload + 1] = writeU8(ChangeVocation.Actions.ServerUpgradePrompt)
--   payload[#payload + 1] = writeU8(canUpgrade and 1 or 0)
--   payload[#payload + 1] = writeString(message)
--   doPlayerSendExtendedOpcode(cid, Config.OPCODE, table.concat(payload))
-- end

-- local function sendUpgradeResult(cid, vocationId, nextTier, success, message)
--   local payload = {}
--   payload[#payload + 1] = writeU8(ChangeVocation.Actions.ServerUpgradeResult)
--   payload[#payload + 1] = writeU16(vocationId)
--   payload[#payload + 1] = writeU16(nextTier)
--   payload[#payload + 1] = writeU8(success and 1 or 0)
--   payload[#payload + 1] = writeString(message)
--   doPlayerSendExtendedOpcode(cid, Config.OPCODE, table.concat(payload))
-- end

-- local function handleChangeRequest(cid, vocationId)
--   if not isPlayer(cid) then
--     return
--   end

--   vocationId = tonumber(vocationId)
--   if not vocationId then
--     return
--   end

--   local currentVocation = getCurrentVocationId(cid)
--   if vocationId == currentVocation then
--     doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You are already using this vocation.")
--     ChangeVocation.syncPlayer(cid)
--     return
--   end

--   local unlocked = getUnlockedVocations(cid)
--   local allowed = false
--   for _, v in ipairs(unlocked) do
--     if v == vocationId then
--       allowed = true
--       break
--     end
--   end

--   if not allowed then
--     doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have not unlocked this vocation yet.")
--     ChangeVocation.syncPlayer(cid)
--     return
--   end

--   doPlayerSetVocation(cid, vocationId)
--   doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "Your vocation has been changed successfully.")
--   ChangeVocation.syncPlayer(cid)
-- end

-- local function handleUpgradeQuery(cid, vocationId)
--   if not isPlayer(cid) then
--     return
--   end

--   vocationId = tonumber(vocationId)
--   if not vocationId then
--     return
--   end

--   local def = getVocationDefinition(vocationId, cid)
--   local currentTier = getTierLevel(cid, vocationId)
--   local maxTier = def.maxTier or Config.DEFAULT_MAX_TIER

--   if currentTier >= maxTier then
--     sendUpgradePrompt(cid, false, "This vocation has already reached the maximum tier.")
--     return
--   end

--   local unlocked = getUnlockedVocations(cid)
--   local allowed = false
--   for _, v in ipairs(unlocked) do
--     if v == vocationId then
--       allowed = true
--       break
--     end
--   end

--   if not allowed then
--     sendUpgradePrompt(cid, false, "You must unlock this vocation before upgrading it.")
--     return
--   end

--   local cost = getUpgradeCost(currentTier)
--   if not hasUpgradeResources(cid, cost) then
--     local message
--     if cost.mode == "money" then
--       message = string.format("You need %d gold coins to upgrade %s.", cost.count, def.name)
--     else
--       message = string.format("You need %d %s to upgrade %s.",
--         cost.count,
--         getItemNameById(cost.itemId),
--         def.name)
--     end
--     sendUpgradePrompt(cid, false, message)
--     return
--   end

--   local message
--   if Config.UpgradeCost.message then
--     message = Config.UpgradeCost.message(getCreatureName(cid), def.name, currentTier + 1, cost.count, cost.itemId)
--   else
--     if cost.mode == "money" then
--       message = string.format("Upgrade %s to tier %d for %d gold?",
--         def.name, currentTier + 1, cost.count)
--     else
--       message = string.format("Upgrade %s to tier %d by consuming %d %s?",
--         def.name, currentTier + 1, cost.count, getItemNameById(cost.itemId))
--     end
--   end

--   sendUpgradePrompt(cid, true, message)
-- end

-- local function handleUpgradeConfirm(cid, vocationId)
--   if not isPlayer(cid) then
--     return
--   end

--   vocationId = tonumber(vocationId)
--   if not vocationId then
--     return
--   end

--   local def = getVocationDefinition(vocationId, cid)
--   local currentTier = getTierLevel(cid, vocationId)
--   local maxTier = def.maxTier or Config.DEFAULT_MAX_TIER

--   if currentTier >= maxTier then
--     sendUpgradeResult(cid, vocationId, currentTier, false, "This vocation has already reached the maximum tier.")
--     return
--   end

--   local cost = getUpgradeCost(currentTier)
--   if not hasUpgradeResources(cid, cost) then
--     sendUpgradeResult(cid, vocationId, currentTier, false, "You do not have the required resources.")
--     return
--   end

--   if not spendUpgradeResources(cid, cost) then
--     sendUpgradeResult(cid, vocationId, currentTier, false, "Failed to consume the required resources.")
--     return
--   end

--   local nextTier = currentTier + 1
--   setTierLevel(cid, vocationId, nextTier)
--   local message = string.format("%s has been upgraded to tier %d.", def.name, nextTier)

--   sendUpgradeResult(cid, vocationId, nextTier, true, message)
--   ChangeVocation.syncPlayer(cid)
-- end

-- function ChangeVocation.handleExtendedOpcode(cid, buffer)
--   if type(buffer) ~= "string" or buffer == "" then
--     ChangeVocation.syncPlayer(cid)
--     return
--   end

--   local pos = 1
--   local action
--   action, pos = readU8(buffer, pos)

--   if action == ChangeVocation.Actions.ClientChange then
--     local vocationId
--     vocationId, pos = readU16(buffer, pos)
--     handleChangeRequest(cid, vocationId)
--   elseif action == ChangeVocation.Actions.ClientUpgradePrompt then
--     local vocationId
--     vocationId, pos = readU16(buffer, pos)
--     handleUpgradeQuery(cid, vocationId)
--   elseif action == ChangeVocation.Actions.ClientUpgradeConfirm then
--     local vocationId
--     vocationId, pos = readU16(buffer, pos)
--     handleUpgradeConfirm(cid, vocationId)
--   else
--     -- Unknown action, just sync data back to avoid desync.
--     ChangeVocation.syncPlayer(cid)
--   end
-- end

-- function ChangeVocation.onUnlock(cid)
--   ChangeVocation.syncPlayer(cid)
-- end
