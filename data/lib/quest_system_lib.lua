-- Tabela de quests gerenciada pelo servidor
questData = {
  quests = {
    --{ id = , name = "", description = ".", lvl = , storage = 0, successful = 0 },
    { id = 1, name = "Initial items", description = "When you start the game you will receive some basic items by clicking on the chest.", lvl = 1, storage = 0, successful = 10000 },
  }
}

-- Enviar lista de quests ao cliente
function sendQuestLog(cid)
  if not isPlayer(cid) then return end
  local msg = "#questlog#"
  local questCount = 0
  local playerLevel = getPlayerLevel(cid) or 1

  for _, quest in ipairs(questData.quests) do
    local meetsLevel = (playerLevel >= quest.lvl)
    local meetsStorage = (quest.storage == 0 or (quest.storage > 0 and getPlayerStorageValue(cid, quest.storage) >= 1))
    local isCompleted = (quest.successful > 0 and getPlayerStorageValue(cid, quest.successful) >= 1)
    local completa = isCompleted and 1 or 0 -- 1 para verde, 0 para branco
    --print("Checking quest - ID: " .. quest.id .. ", Name: " .. quest.name .. ", Level check: " .. tostring(meetsLevel) .. ", Storage check: " .. tostring(meetsStorage) .. ", Completed: " .. tostring(isCompleted) .. ", Completa: " .. completa)
    if meetsLevel and meetsStorage then
      questCount = questCount + 1
      msg = msg ..
          "," ..
          quest.id .. "," .. quest.name .. "," .. (quest.description or "No description provided.") .. "," .. completa
    end
  end

  if questCount > 0 then
    --print("Sending opcode 135: " .. msg)
    doSendPlayerExtendedOpcode(cid, 135, msg)
  else
    --print("No quests available for player")
    doSendPlayerExtendedOpcode(cid, 135, "#questlog#") -- Envia buffer vazio para evitar erros
  end
end
