dofile("data/lib/vocation_ranks_lib.lua")

function onExtendedOpcode(cid, opcode, buffer)
  if opcode ~= VOCATION_RANK_OPCODE then return false end
  local player = Player(cid)
  if not player then return false end
  local data = json.decode(buffer or "")
  if data and data.action == "upgrade" then
    sendRankDataToClient(player)
  elseif data and data.action == "request" then
    sendRankDataToClient(player)
  end
  return true
end
