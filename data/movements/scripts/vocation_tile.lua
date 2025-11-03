local ACTION_ID = 5500
local STORAGE_KEY = 50001
local OPCODE_OPEN = 100
local OPCODE_CLOSE = 101

local vocInfo = {
  [17] = { name = "Goku", info = "Saiyajin protetor da Terra.", class = "Saiyajin", type = "Tank", element = "Energy", outfitId = 1881 },
  [6]  = { name = "Buu", info = "Regeneração insana.", class = "Demonic", type = "DPS", element = "Undead", outfitId = 1755 },
  [4]  = { name = "Broly", info = "Poder lendário destrutivo.", class = "Saiyajin", type = "Tank", element = "Physical", outfitId = 1744 },
  [59] = { name = "Rukia", info = "Shinigami do gelo.", class = "Shinigami", type = "Dano Pvp", element = "Ice", outfitId = 2276 },
}

function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) or item.actionid ~= ACTION_ID then return true end

  local unlockedStr = getPlayerStorageValue(cid, STORAGE_KEY)
  local unlocked = {}

  if unlockedStr and unlockedStr ~= "" and unlockedStr ~= "-1" then
    for id in string.gmatch(unlockedStr, "([^,]+)") do
      local vid = tonumber(id)
      if vid and vocInfo[vid] then table.insert(unlocked, vid) end
    end
  end

  local current = getPlayerVocation(cid)
  local hasCurrent = false
  for _, v in ipairs(unlocked) do
    if v == current then
      hasCurrent = true; break;
    end
  end
  if not hasCurrent and vocInfo[current] then table.insert(unlocked, current) end

  if #unlocked == 0 then
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "No vocations.")
    return true
  end

  local data = ""
  for i, vid in ipairs(unlocked) do
    local v = vocInfo[vid]
    if v then
      if i > 1 then data = data .. "|" end
      data = data ..
          vid ..
          ";" .. v.name .. ";" .. v.info .. ";" .. v.class .. ";" .. v.type .. ";" .. v.element .. ";" .. v.outfitId
    end
  end

  doPlayerSendExtendedOpcode(cid, OPCODE_OPEN, data)
  return true
end

function onStepOut(cid, item, position, toPosition)
  if not isPlayer(cid) or item.actionid ~= ACTION_ID then return true end
  doPlayerSendExtendedOpcode(cid, OPCODE_CLOSE, "")
  return true
end
