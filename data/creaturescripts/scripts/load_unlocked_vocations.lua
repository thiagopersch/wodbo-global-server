local STORAGE_KEY = 50001

function onLogin(cid)
  local player = cid
  local guid = getPlayerGUID(player)

  local res = db.getResult("SELECT `unlocked_vocations` FROM `players` WHERE `id` = " .. guid)
  if res and res:getID() ~= -1 then
    local vocs = res:getDataString("unlocked_vocations")
    setPlayerStorageValue(player, STORAGE_KEY, vocs ~= "" and vocs or "")
    res:free()
  else
    setPlayerStorageValue(player, STORAGE_KEY, "")
  end

  return true
end
