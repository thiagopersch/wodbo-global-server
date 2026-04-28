function onLogin(cid)
  if getPlayerGroupId(cid) >= 3 then
    doBroadcastMessage("The member of staff " .. getCreatureName(cid) .. " has just entered the server!")
  end
  return true
end
