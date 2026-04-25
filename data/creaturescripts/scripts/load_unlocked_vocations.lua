-- local STORAGE_KEY = 50001

-- function onLogin(cid)
--   local player = cid
--   local guid = getPlayerGUID(player)

--   local res = db.getResult("SELECT `unlocked_vocations` FROM `players` WHERE `id` = " .. guid)
--   local vocsStr
--   if res and res:getID() ~= -1 then
--     vocsStr = res:getDataString("unlocked_vocations") or ""
--     res:free()
--   else
--     vocsStr = ""
--   end

--   print(string.format("[LoadUnlocked] Player %s: DB='%s'", getCreatureName(player), tostring(vocsStr)))

--   setPlayerStorageValue(player, STORAGE_KEY, vocsStr)

--   -- **CRÍTICO: Sync APÓS setar storage**
--   dofile("data/lib/change_vocation.lua")
--   ChangeVocation.syncPlayer(player)

--   return true
-- end
