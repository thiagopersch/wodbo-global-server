dofile("data/lib/vocation_ranks_lib.lua")

function onSay(player, words, param)
  player:sendTextMessage(MESSAGE_STATUS_SMALL, "Rank: Bronze 0/5")
  return true
end
