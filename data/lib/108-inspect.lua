InspectModule = {
	opcode = 13,
	privacy_storage = 10000, -- storage para checar se o alvo quer mostrar o set
}

-- fix for some servers missing these constants
SKILL_FIRST = SKILL_FIRST or SKILL_FIST or 0
SKILL_LAST = SKILL_LAST or SKILL_FISHING or 6

---@param cid number
---@param opcode number
---@param buffer string
function InspectModule:handleOpcode(cid, opcode, buffer)
	local split = buffer:explode("&")
	local action = split[1]

	if action == "1" then
		-- requested data by creature id
		local creatureID = tonumber(split[2])
		if creatureID then
			self:sendPlayerData(cid, creatureID)
		else
			doPlayerPopupFYI(cid, "ID de criatura inv·lido.")
		end
	elseif action == "2" and #split > 1 then
		-- requested data by creature name
		local creatureName = table.concat(split, "", 2)
		local creatureID = getPlayerByName(creatureName)
		if creatureID then
			self:sendPlayerData(cid, creatureID)
		else
			doPlayerPopupFYI(cid, "Jogador n„o existe ou est· offline.")
		end
	elseif action == "3" and #split > 1 then
		-- requested to change equipments privacy
		local enable = (tonumber(split[2]) or 0) ~= 0
		doCreatureSetStorage(cid, self.privacy_storage, enable and 0 or 1)
	else
		doPlayerPopupFYI(cid, "aÁ„o inv·lida.")
	end
end

---@param cid number
---@param creatureID number
function InspectModule:sendPlayerData(cid, creatureID)
	-- Verifique se o alvo È um jogador valido
	if not isPlayer(creatureID) then
		doPlayerPopupFYI(cid, "Este alvo N„o È um jogador.")
		return
	end

	-- Impedir que jogadores com maior acesso tenham suas informa√ß√µes inspecionadas
	if getPlayerAccess(creatureID) > getPlayerAccess(cid) then
		doPlayerPopupFYI(cid, "VocÍ tem permiss„o para inspecionar este jogador.")
		return
	end

	--local guildName = getPlayerGuildName(creatureID) or "Nenhuma"
	local data = {
		getCreatureName(creatureID),
		getCreatureMaxHealth(creatureID),
		getCreatureMaxMana(creatureID),
		getPlayerLevel(creatureID),
		getPlayerVocationName(creatureID),
		getTownName(getPlayerTown(creatureID)),
		getPlayerStamina(creatureID),
		getPlayerGuildName(creatureID),
		isPremium(creatureID) and 1 or 0,
	}

	-- Adicionando as habilidades (skills)
	for i = SKILL_FIRST, SKILL_LAST do
		data[#data + 1] = getPlayerSkillLevel(creatureID, i)
	end

	-- Adiciona o nÌ≠vel m·gico do jogador
	data[#data + 1] = getPlayerMagLevel(creatureID, false)

	-- Verifica se os equipamentos est√£o vis√≠veis e se o jogador local est√° inspecionando a si mesmo
	local showEquipments = getCreatureStorage(creatureID, self.privacy_storage) ~= 1
	data[#data + 1] = cid == creatureID and 1 or 0
	data[#data + 1] = showEquipments and 1 or 0

	-- Envia os equipamentos se permitido
	for i = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		local slotItem = getPlayerSlotItem(creatureID, i)
		if slotItem.itemid ~= 0 then
			local itemInfo = getItemInfo(slotItem.itemid)
			data[#data + 1] = itemInfo.clientId or 0
			data[#data + 1] = math.max(1, slotItem.type) -- Ajusta a quantidade do item
		else
			data[#data + 1] = 0
			data[#data + 1] = 0
			-- data[#data + 1] = 0
		end
	end

	-- Envia os dados ao jogador que solicitou
	doSendPlayerExtendedOpcode(cid, self.opcode, table.concat(data, "&"))
end
