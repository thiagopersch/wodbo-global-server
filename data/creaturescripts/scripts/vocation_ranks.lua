dofile("data/lib/vocation_ranks_lib.lua")

function onLogin(player)
  sendRankDataToClient(player)
  return true
end
