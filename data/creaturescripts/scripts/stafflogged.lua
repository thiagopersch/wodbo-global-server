function onLogin(cid)
  if getPlayerGroupId(cid) >= 3 then
    local msg = "The member of staff " .. getCreatureName(cid) .. " has just entered the server!"
    local formattedText = "center|" .. TEXTCOLOR_YELLOW .. "|" .. msg

    addEvent(doBroadcastMessage, 21, formattedText)
  end
  return true
end
