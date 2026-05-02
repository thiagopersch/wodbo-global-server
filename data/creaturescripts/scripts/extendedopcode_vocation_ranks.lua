dofile("data/lib/vocation_ranks_lib.lua")

function onExtendedOpcode(cid, opcode, buffer)
  if opcode ~= VOCATION_RANK_OPCODE then return false end
  if not isPlayer(cid) then return false end

  if buffer == "request" then
    sendRankDataToClient(cid)
  elseif buffer == "upgrade" then
    VocationRankLib.doUpgrade(cid)
  end
  return true
end
