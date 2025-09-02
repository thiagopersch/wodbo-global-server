local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- OTServ event handling functions
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end

function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end

function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

function onThink() npcHandler:onThink() end

-- Tabela de Configuração Centralizada
-- Use esta tabela para adicionar, remover ou modificar cidades de viagem.
-- Não é necessário alterar a lógica do script abaixo.
local destinations = {
	['central city'] = {
		text = 'Do you want to go to {Central City}?',
		destination = { x = 31951, y = 32227, z = 7 },
		cost = 0,
		premium_required = false,
		min_level = 8, -- Nível mínimo para a viagem
		max_level = 200 -- Nível máximo para a viagem
	}
}

-- Esta tabela armazena a última cidade que o jogador escolheu para confirmação.
local travel_confirmation = {}

-- Callback principal que gerencia o diálogo e as ações do NPC.
function onCreatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

	local message = string.lower(msg)

	local player = getPlayerName(cid)

	-- Lógica para o 'hi' ou 'travel' inicial
	if message == 'hi' or message == 'travel' then
		local city_list = {}
		for city, data in pairs(destinations) do
			table.insert(city_list, '{' .. string.gsub(city, '^%l', string.upper) .. '}')
		end
		selfSay('Dear ' .. player .. ', You need to travel to: ' .. table.concat(city_list, ', ') .. '.', cid)
		travel_confirmation[talkUser] = nil
		return true
	end

	-- Lógica de processamento de cidades
	for city, data in pairs(destinations) do
		if message == city then
			selfSay(data.text, cid)
			travel_confirmation[talkUser] = city
			return true
		end
	end

	-- Lógica para a confirmação 'yes'
	if message == 'yes' then
		local city = travel_confirmation[talkUser]
		if city and destinations[city] then
			local city_data = destinations[city]

			-- Validação de nível mínimo
			if getPlayerLevel(cid) < city_data.min_level then
				selfSay('Sorry, you must be at least level ' .. city_data.min_level .. ' to travel to this city.', cid)
				travel_confirmation[talkUser] = nil
				return true
			end

			-- Validação de nível máximo
			if getPlayerLevel(cid) > city_data.max_level then
				selfSay('Sorry, you must be at most level ' .. city_data.max_level .. ' to travel to this city.', cid)
				travel_confirmation[talkUser] = nil
				return true
			end

			-- Validação da conta premium
			if city_data.premium_required and getPlayerPremiumDays(cid) <= 0 then
				selfSay('Sorry, this destination is for premium players only.', cid)
				travel_confirmation[talkUser] = nil
				return true
			end

			-- Validação do custo
			local cost = city_data.cost
			if getPlayerMoney(cid) < cost then -- Utilizando getPlayerMoney para verificar antes de remover
				selfSay('Sorry, you don\'t have enough money for this trip. The cost is ' .. cost .. ' gold coins.', cid)
				travel_confirmation[talkUser] = nil
				return true
			end

			-- Teletransporte e remoção de dinheiro
			if doPlayerRemoveMoney(cid, cost) then
				doTeleportThing(cid, city_data.destination, true)
				selfSay('All aboard! Have a safe trip to ' .. string.gsub(city, '^%l', string.upper) .. '.', cid)
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
			else
				selfSay('I am sorry, but something went wrong with the payment.', cid)
			end

			travel_confirmation[talkUser] = nil
			return true
		end
	end

	-- Lógica para o 'no'
	if message == 'no' then
		selfSay('Then go hunting again! Bye Bye!', cid)
		travel_confirmation[talkUser] = nil
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, onCreatureSayCallback)
npcHandler:addModule(FocusModule:new())
