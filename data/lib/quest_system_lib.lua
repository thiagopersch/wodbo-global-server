-- Tabela de quests gerenciada pelo servidor
questData = {
  quests = {
    { id = 1, name = "Bueiro Pt. 1", description = "Encontre um ba� no bueiro de Viridian no andar mais alto do bueiro.", lvl = 14, storage = 0, successful = 3298 },
    { id = 2, name = "Bueiro Pt. 2", description = "Encontre o segundo ba� no bueiro", lvl = 25, storage = 0, successful = 7440 },
    { id = 3, name = "Thomas Psyduck", description = "Entregue 4x Psyduck Pots ao Thomas.", lvl = 30, storage = 0, successful = 7111 },
    { id = 4, name = "Bike Pt. 1", description = "V� para Pewter e encontre o ba� com palladium na caverna. Voc� precisar� de um pok�mon com rock smash.", lvl = 30, storage = 0, successful = 5458756546287 },
    { id = 5, name = "Bike Pt. 2", description = "V� para a praia de Viridian e entregue o palladium ao NPC Vini. ele estar� no ultimo andar do farol.", lvl = 30, storage = 0, successful = 5458756546288 },
    { id = 6, name = "Poison Hole", description = "Se encontra numa hunt de pok�mons venenosos. na esquerda de Viridian.", lvl = 30, storage = 0, successful = 3952 },
    { id = 7, name = "Electric Hole", description = "Seguindo pra baixo de Viridian ter� uma floresta e nela ter� uma escada para descer e entrar nessa quest.", lvl = 30, storage = 0, successful = 485615 },
    { id = 8, name = "Three Stones", description = "Se encontra no andar mais baixo da Hunt inicial de Pidgeot. no caminho da saida de cima de Viridian.", lvl = 40, storage = 0, successful = 587493212 },
    { id = 9, name = "BOX+2", description = "Fica no caminho da saida da direita de Viridian numa casa eletrica.", lvl = 40, storage = 0, successful = 3297 },
    { id = 10, name = "Rock Tunnel", description = "Na pequena civiliza��o que fica entre Viridian e Cerulean tem uma hunt de pedra. suba a escada proxima ao Mark e v� at� a posi��o marcada.", lvl = 40, storage = 0, successful = 3295 },
    { id = 11, name = "Desert Island", description = "Dentro de uma piramide des�a at� o andar mais baixo para encontrar o ba�.", lvl = 50, storage = 0, successful = 20914 },
    { id = 12, name = "Ash Pikachu", description = "No caminho entre Viridian(baixo) e Vermilion temos uma grande usina eletrica e dentro do mesmo cercado mais atr�s temos a casa eletrica dessa quest.", lvl = 50, storage = 0, successful = 545875654678 },
    { id = 13, name = "Waterfall Pt. 1", description = "Se encontra em baixo da hunt dos Pidgeot. � necessario Surf e Dig para acessar.", lvl = 55, storage = 0, successful = 17999 },
    { id = 14, name = "Waterfall Pt. 2", description = "Se encontra em baixo da hunt dos Pidgeot. � necessario Surf e Dig para acessar.", lvl = 55, storage = 0, successful = 18000 },
    { id = 15, name = "Earth Hole", description = "Se encontra na hunt de terrestres no nordeste das redondezas de Viridian. Des�a a escada marcada.", lvl = 55, storage = 0, successful = 587493214 },
    { id = 16, name = "Plant Cave", description = "Fica dentro da hunt de planta no norte das redondezas de Viridian. � necessario Rock Smash.", lvl = 60, storage = 0, successful = 587493213 },
    { id = 17, name = "Ghost Plague", description = "Fica bem proximo da saida da direita de Celadon. N�o � necessario Fly.", lvl = 80, storage = 0, successful = 23500 }
    --{ id = , name = "", description = ".", lvl = , storage = 0, successful = 0 },
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
      "," .. quest.id .. "," .. quest.name .. "," .. (quest.description or "Sem descri��o") .. "," .. completa
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
