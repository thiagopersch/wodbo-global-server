dofile("data/lib/vocation_ranks_lib.lua")

function onLogin(cid)
  -- 1. Envia os dados completos do rank para o próprio jogador (atualiza a UI dele)
  sendRankDataToClient(cid)

  -- 2. Envia os dados básicos de rank para os outros jogadores (para verem as estrelas dele)
  broadcastPlayerRankData(cid)

  -- 3. Aplica os status bônus permanentes baseados no total de estrelas
  local vocationId = getPlayerVocation(cid)
  local rankData = VocationRankLib.getPlayerVocationRank(cid, vocationId)
  if rankData.totalStars > 0 then
    VocationRankLib.applyStats(cid, vocationId, rankData.totalStars)
  end

  return true
end
