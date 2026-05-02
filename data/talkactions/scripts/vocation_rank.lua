dofile("data/lib/vocation_ranks_lib.lua")

function onSay(cid, words, param)
  if not isPlayer(cid) then return true end
  
  local vocationId = getPlayerVocation(cid)
  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  local rankName = "Bronze"
  
  if VocationRankConfig and VocationRankConfig.Ranks[rankData.rank] then
      rankName = VocationRankConfig.Ranks[rankData.rank].name
  end
  
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Rank: " .. rankName .. " " .. rankData.stars .. "/" .. VocationRankConfig.StarsPerRank .. " stars.")
  return true
end
