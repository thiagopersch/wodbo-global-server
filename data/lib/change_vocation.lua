if ChangeVocation and ChangeVocation.__loaded then
  return
end

ChangeVocation = {}
ChangeVocation.__loaded = true
print("[CV] Library loaded - Advanced Database System")

local Config           = {
  OPCODE = 230,
  STORAGE_UNLOCKED = 50001,
  DEFAULT_LOOKTYPE = 0,
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
ChangeVocation.Actions = { ServerOpen = 1, ServerSync = 2, ClientChange = 1, ServerOpenSync = 3, ServerClose = 4, ForceLogout = 5 }

local function dbQuery(query)
  if db.query then
    return db.query(query)
  elseif db.executeQuery then
    return db.executeQuery(query)
  end
end

function ChangeVocation.initDB()
  dbQuery(
    "CREATE TABLE IF NOT EXISTS `player_vocation_stats` (`player_id` INTEGER NOT NULL, `vocation_id` INTEGER NOT NULL, `level` INTEGER NOT NULL DEFAULT 1, `experience` BIGINT NOT NULL DEFAULT 0, `healthmax` INTEGER NOT NULL DEFAULT 150, `manamax` INTEGER NOT NULL DEFAULT 150, `maglevel` INTEGER NOT NULL DEFAULT 0, `manaspent` BIGINT NOT NULL DEFAULT 0, `cap` INTEGER NOT NULL DEFAULT 400, `health_skill` INTEGER NOT NULL DEFAULT 0, `mana_skill` INTEGER NOT NULL DEFAULT 0, `bend_skill` INTEGER NOT NULL DEFAULT 0, `dodge_skill` INTEGER NOT NULL DEFAULT 0, `skill_points` INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`, `vocation_id`));")
  dbQuery(
    "CREATE TABLE IF NOT EXISTS `player_vocation_skills` (`player_id` INTEGER NOT NULL, `vocation_id` INTEGER NOT NULL, `skillid` INTEGER NOT NULL, `value` INTEGER NOT NULL DEFAULT 10, `count` BIGINT NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`, `vocation_id`, `skillid`));")
  dbQuery(
    "CREATE TABLE IF NOT EXISTS `player_vocation_spells` (`player_id` INTEGER NOT NULL, `vocation_id` INTEGER NOT NULL, `name` VARCHAR(255) NOT NULL, PRIMARY KEY (`player_id`, `vocation_id`, `name`));")
end

local function toHex(s) return (s:gsub(".", function(c) return string.format("%02x", c:byte()) end)) end
local function encU16(v) return string.char(math.floor(v / 256)) .. string.char(v % 256) end

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
  local unlocked = {}
  local current  = getPlayerVocation(cid)
  table.insert(unlocked, current)

  local guid = getPlayerGUID(cid)
  local q = db.getResult("SELECT `unlocked_vocations` FROM `players` WHERE `id` = " .. guid)

  if q and q:getID() ~= -1 then
    local str = q:getDataString("unlocked_vocations")
    q:free()

    if str and str ~= "" then
      for vocId in str:gmatch("(%d+)") do
        local id = tonumber(vocId)
        if id and id > 0 and id ~= current then
          table.insert(unlocked, id)
        end
      end
    end
  end
  return unlocked
end

-- AQUI SINCRONIZA O STORAGE COM A COLUNA UNLOCKED_VOCATIONS DO BANCO DE DADOS
function ChangeVocation.unlockVocation(cid, vocId)
  local guid = getPlayerGUID(cid)
  local q = db.getResult("SELECT `unlocked_vocations` FROM `players` WHERE `id` = " .. guid)
  local str = ""

  if q and q:getID() ~= -1 then
    str = q:getDataString("unlocked_vocations")
    q:free()
  end

  local found = false
  for existing in str:gmatch("(%d+)") do
    if tonumber(existing) == vocId then
      found = true
      break
    end
  end

  if not found then
    local newValue = (str == "") and tostring(vocId) or (str .. "," .. vocId)
    dbQuery("UPDATE `players` SET `unlocked_vocations` = '" .. newValue .. "' WHERE `id` = " .. guid)
  end
end

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
  return toHex(bin)
end

function ChangeVocation.open(cid)
  if not isPlayer(cid) then return end
  local payload = ChangeVocation.buildPayload(cid, ChangeVocation.Actions.ServerOpenSync)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, payload)
end

function ChangeVocation.syncPlayer(cid)
  if not isPlayer(cid) then return end
  local payload = ChangeVocation.buildPayload(cid, ChangeVocation.Actions.ServerSync)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, payload)
end

function ChangeVocation.close(cid)
  if not isPlayer(cid) then return end
  local bin = string.char(ChangeVocation.Actions.ServerClose)
  doPlayerSendExtendedOpcode(cid, Config.OPCODE, toHex(bin))
end

function ChangeVocation.swapVocationSQL(guid, old_voc, new_voc, looktype)
  ChangeVocation.initDB()

  -- Backup Atual
  dbQuery(
    "REPLACE INTO `player_vocation_stats` (`player_id`, `vocation_id`, `level`, `experience`, `healthmax`, `manamax`, `maglevel`, `manaspent`, `cap`, `health_skill`, `mana_skill`, `bend_skill`, `dodge_skill`, `skill_points`) SELECT `id`, " ..
    old_voc ..
    ", `level`, `experience`, `healthmax`, `manamax`, `maglevel`, `manaspent`, `cap`, `health_skill`, `mana_skill`, `bend_skill`, `dodge_skill`, `skill_points` FROM `players` WHERE `id` = " ..
    guid)
  dbQuery(
    "REPLACE INTO `player_vocation_skills` (`player_id`, `vocation_id`, `skillid`, `value`, `count`) SELECT `player_id`, " ..
    old_voc .. ", `skillid`, `value`, `count` FROM `player_skills` WHERE `player_id` = " .. guid)
  dbQuery("DELETE FROM `player_vocation_spells` WHERE `player_id` = " .. guid .. " AND `vocation_id` = " .. old_voc)
  dbQuery("INSERT INTO `player_vocation_spells` (`player_id`, `vocation_id`, `name`) SELECT `player_id`, " ..
    old_voc .. ", `name` FROM `player_spells` WHERE `player_id` = " .. guid)

  -- [SOLUÇÃO DO BUG VOCATION 0]: Salva a string do sagastor direto no banco!
  dbQuery("REPLACE INTO `player_storage` (`player_id`, `key`, `value`) VALUES (" ..
    guid .. ", 578744, '" .. looktype .. "," .. new_voc .. "')")

  local q = db.getResult("SELECT 1 FROM `player_vocation_stats` WHERE `player_id` = " ..
    guid .. " AND `vocation_id` = " .. new_voc)

  if q and q:getID() ~= -1 then
    q:free()
    -- Restaura Backup
    dbQuery("UPDATE `players` SET `level` = (SELECT `level` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `experience` = (SELECT `experience` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `healthmax` = (SELECT `healthmax` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `health` = (SELECT `healthmax` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `manamax` = (SELECT `manamax` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `mana` = (SELECT `manamax` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `maglevel` = (SELECT `maglevel` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `manaspent` = (SELECT `manaspent` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `cap` = (SELECT `cap` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `health_skill` = (SELECT `health_skill` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `mana_skill` = (SELECT `mana_skill` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `bend_skill` = (SELECT `bend_skill` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `dodge_skill` = (SELECT `dodge_skill` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      "), `skill_points` = (SELECT `skill_points` FROM `player_vocation_stats` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc .. "), `vocation` = " .. new_voc .. ", `looktype` = " .. looktype .. " WHERE `id` = " .. guid)
    dbQuery("UPDATE `player_skills` SET `value` = (SELECT `value` FROM `player_vocation_skills` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " ..
      new_voc ..
      " AND `skillid` = `player_skills`.`skillid`), `count` = (SELECT `count` FROM `player_vocation_skills` WHERE `player_id` = " ..
      guid ..
      " AND `vocation_id` = " .. new_voc .. " AND `skillid` = `player_skills`.`skillid`) WHERE `player_id` = " .. guid)

    dbQuery("DELETE FROM `player_spells` WHERE `player_id` = " .. guid)
    dbQuery(
      "INSERT INTO `player_spells` (`player_id`, `name`) SELECT `player_id`, `name` FROM `player_vocation_spells` WHERE `player_id` = " ..
      guid .. " AND `vocation_id` = " .. new_voc)
  else
    -- Começa do Level 1
    dbQuery(
      "UPDATE `players` SET `level` = 1, `experience` = 0, `healthmax` = 150, `health` = 150, `manamax` = 150, `mana` = 150, `maglevel` = 0, `manaspent` = 0, `cap` = 500, `health_skill` = 0, `mana_skill` = 0, `bend_skill` = 0, `dodge_skill` = 0, `skill_points` = 0, `vocation` = " ..
      new_voc .. ", `looktype` = " .. looktype .. " WHERE `id` = " .. guid)
    dbQuery("UPDATE `player_skills` SET `value` = 10, `count` = 0 WHERE `player_id` = " .. guid)
    dbQuery("DELETE FROM `player_spells` WHERE `player_id` = " .. guid)
  end
end

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
    local looktype = v.lookType or Config.DEFAULT_LOOKTYPE

    doPlayerSendExtendedOpcode(cid, Config.OPCODE, toHex(string.char(ChangeVocation.Actions.ForceLogout)))

    -- REMOVIDO o setPlayerStorage string daqui. Vai ser executado direto no SQL de forma limpa.
    doPlayerSave(cid)

    local player_guid = getPlayerGUID(cid)
    local current_voc = getPlayerVocation(cid)
    doRemoveCreature(cid)

    addEvent(function(guid, old_v, new_v, look_t)
      ChangeVocation.swapVocationSQL(guid, old_v, new_v, look_t)
    end, 150, player_guid, current_voc, vocId, looktype)
  end
end
