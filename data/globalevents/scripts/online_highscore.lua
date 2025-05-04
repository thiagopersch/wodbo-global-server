function onThink(interval, lastExecution)
  local players = getPlayersOnline()
  table.sort(players, function(a, b) return a:getExperience() > b:getExperience() end)

  local msg = "~ TOP 5 players online ~"

  for i = 1, 5 do
    if not players[i] then
      break
    end
    msg = msg .. "\n" .. i .. ". " .. players[i]:getName() .. "  [Lv: " .. players[i]:getLevel() .. "]"
  end

  for _, player in pairs(players) do
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, msg)
  end

  return true
end
