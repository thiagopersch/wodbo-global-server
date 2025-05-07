function onSay(cid, words, param, channel)
  if not isPlayer(cid) then
    return false
  end
  local points = getPlayerStorageValue(cid, 10000)
  if points == -1 then
    points = 0
  end
  doPlayerSendExtendedOpcode(cid, 50, "openSkillsWindow|" .. points)
  return true
end
