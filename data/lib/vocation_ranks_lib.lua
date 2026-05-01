-- Vocation Ranks Library
if not VocationRankConfig then
  dofile("data/lib/vocation_ranks_config.lua")
end

VOCATION_RANK_OPCODE = 235

function sendRankDataToClient(player)
  if not player:getProtocolGame() then return end
  local data = json.encode({playerId=player:getId(), vocationId=player:getVocation():getId(), rank=1, stars=0})
  player:getProtocolGame():sendExtendedOpcode(VOCATION_RANK_OPCODE, data)
end
