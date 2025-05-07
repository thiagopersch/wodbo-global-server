function onAdvance(cid, skill, oldLevel, newLevel)
  if skill == SKILL__LEVEL and newLevel > oldLevel then
    local pointsToAdd = 2
    local currentPoints = getPlayerStorageValue(cid, 10000)
    if currentPoints == -1 then
      currentPoints = 0
    end
    currentPoints = currentPoints + pointsToAdd
    setPlayerStorageValue(cid, 10000, currentPoints)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
      "Você ganhou " .. pointsToAdd .. " pontos de habilidade! Use /skills para alocá-los.")
    doPlayerSendExtendedOpcode(cid, 50, "updatePoints|" .. currentPoints)
  elseif skill == SKILL__MAGLEVEL then
    local magicPoints = getPlayerStorageValue(cid, 10003)
    if magicPoints == -1 then
      magicPoints = 0
    end
    if magicPoints > 0 then
      local currentTries = getPlayerSkill(cid, SKILL__MAGLEVEL)
      doPlayerAddSkill(cid, SKILL__MAGLEVEL, currentTries * 50)
    end
  end
  return true
end
