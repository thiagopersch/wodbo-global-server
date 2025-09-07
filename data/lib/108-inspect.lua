InspectModule = {
	opcode = 13,
	privacy_storage = 78165798134, -- Storage key for equipment visibility
}

-- Fix for servers missing skill constants
SKILL_FIRST = SKILL_FIRST or SKILL_FIST or 0
SKILL_LAST = SKILL_LAST or SKILL_FISHING or 6

-- Fix for servers missing slot constants
CONST_SLOT_FIRST = CONST_SLOT_FIRST or 1
CONST_SLOT_LAST = CONST_SLOT_LAST or 10

--- Handles incoming extended opcode requests from the client
---@param cid number Creature ID of the requesting player
---@param opcode number Opcode number
---@param buffer string Data buffer sent by the client
function InspectModule:handleOpcode(cid, opcode, buffer)
	if opcode ~= self.opcode then
		return
	end

	local split = buffer:explode("&")
	local action = split[1]

	if action == "1" then
		-- Request profile by creature ID
		local creatureID = tonumber(split[2])
		if creatureID then
			self:sendPlayerData(cid, creatureID)
		else
			doPlayerPopupFYI(cid, "ID de criatura inválido.")
		end
	elseif action == "2" and #split > 1 then
		-- Request profile by creature name
		local creatureName = table.concat(split, "", 2)
		local creatureID = getPlayerByName(creatureName)
		if creatureID then
			self:sendPlayerData(cid, creatureID)
		else
			doPlayerPopupFYI(cid, "Jogador não existe ou está offline.")
		end
	elseif action == "3" and #split > 1 then
		-- Change equipment visibility
		local enable = (tonumber(split[2]) or 0) ~= 0
		doCreatureSetStorage(cid, self.privacy_storage, enable and 0 or 1) -- 0 = show, 1 = hide
		self:sendPlayerData(cid, cid)                                    -- Refresh requester's profile
	else
		doPlayerPopupFYI(cid, "Ação inválida.")
	end
end

--- Sends player profile data to the requesting player
---@param cid number Creature ID of the requesting player
---@param creatureID number Creature ID of the target player
function InspectModule:sendPlayerData(cid, creatureID)
	-- Verify if the target is a valid player
	if not isPlayer(creatureID) then
		doPlayerPopupFYI(cid, "Este alvo não é um jogador.")
		return
	end

	-- Prevent inspection of players with higher access
	if getPlayerAccess(creatureID) > getPlayerAccess(cid) then
		doPlayerPopupFYI(cid, "Você não tem permissão para inspecionar este jogador.")
		return
	end

	local isLocalPlayer = (cid == creatureID)
	local showEquipments = isLocalPlayer or getCreatureStorage(creatureID, self.privacy_storage) ~= 1

	local data = {
		getCreatureName(creatureID),          -- 1: Name
		getCreatureMaxHealth(creatureID),     -- 2: Max Health
		getCreatureMaxMana(creatureID),       -- 3: Max Mana
		getPlayerLevel(creatureID),           -- 4: Level
		getPlayerVocationName(creatureID),    -- 5: Vocation Name
		getTownName(getPlayerTown(creatureID)), -- 6: Town Name
		getPlayerStamina(creatureID),         -- 7: Stamina (in minutes)
		getPlayerGuildName(creatureID) or "", -- 8: Guild Name
		isPremium(creatureID) and 1 or 0,     -- 9: Premium Status
	}

	-- Skills (indices 10-16: Fist, Club, Sword, Axe, Distance, Shielding, Fishing)
	for i = SKILL_FIRST, SKILL_LAST do
		data[#data + 1] = getPlayerSkillLevel(creatureID, i)
	end

	-- Magic Level
	data[#data + 1] = getPlayerMagLevel(creatureID, false) -- 17: Magic Level

	-- Is Local Player
	data[#data + 1] = isLocalPlayer and 1 or 0 -- 18: Is Local Player

	-- Show Equipments
	data[#data + 1] = showEquipments and 1 or 0 -- 19: Show Equipments

	-- Equipment (slots 1-10: Head, Neck, Back, Body, Right, Left, Legs, Feet, Finger, Ammo)
	for i = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		if showEquipments then
			local slotItem = getPlayerSlotItem(creatureID, i)
			data[#data + 1] = slotItem.itemid ~= 0 and slotItem.itemid or 0
			data[#data + 1] = slotItem.itemid ~= 0 and math.max(1, slotItem.type) or 0
		else
			data[#data + 1] = 0
			data[#data + 1] = 0
		end
	end
	print('ENVIO DOS DADOS PARA O CLIENTE: ', doSendPlayerExtendedOpcode(cid, self.opcode, table.concat(data, "&")))
	doSendPlayerExtendedOpcode(cid, self.opcode, table.concat(data, "&"))
end
