function onSay(cid, words, param, channel)
  if not isPlayer(cid) then
    return false
  end
  local points = getPlayerStorageValue(cid, 10000)
  if points == -1 then
    points = 0
  end
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    "You have " .. points .. " skill points available. Use /skill <skill> to allocate them.")
  return true
end
