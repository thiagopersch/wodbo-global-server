dofile('data/lib/autoloot_lib.lua')

function onLogin(cid)
	print("[AutoLoot] onLogin called for CID: " .. cid)
	local registered = registerCreatureEvent(cid, "AutoLootOpcode")
	print("[AutoLoot] registerCreatureEvent returned: " .. tostring(registered))
	return true
end

function onExtendedOpcode(cid, opcode, buffer)
	print("[AutoLoot] onExtendedOpcode called - CID: " .. cid .. ", Opcode: " .. opcode .. ", Buffer: '" .. (buffer or "") .. "'")

	if opcode ~= 157 then
		return true
	end

	local param = buffer:match("^%s*(.-)%s*$") or ""

	if param == "" then
		ShowItemsTabble(cid)
	elseif param == "clean" then
		setPlayerStorageValue(cid, info.Storages[1], -1)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[Auto Loot] Your list has been cleaned.")
	elseif isInArray({ "on", "off" }, param:lower()) then
		local current = getPlayerStorageValue(cid, info.Storages[3])
		setPlayerStorageValue(cid, info.Storages[3], current <= 0 and 1 or 0)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
			"[Auto Loot] " .. (current <= 0 and "Started" or "Stopped") .. ".")
		return true
	else
		local parts = string.explode(param, ",")
		local command = parts[1]:lower()
		local rest = (parts[2] or ""):match("^%s*(.-)%s*$") or ""

		if command == "search" then
			local results = searchItemsByQuery(rest)
			local resp = "searchresult"
			for _, item in ipairs(results) do
				resp = resp .. "|" .. item.id .. ";" .. item.name .. ";" .. item.clientId
			end
			doPlayerSendExtendedOpcode(cid, 157, resp)
			print("[AutoLoot] Search for '" .. rest .. "' returned " .. #results .. " results")
			return true

		elseif command == "add" then
			local itemId, itemName

			local hasTilde = rest:find("~")
			if hasTilde then
				local idStr, nameStr = rest:match("^(%d+)~(.*)$")
				if idStr then
					itemId = tonumber(idStr)
					itemName = nameStr:match("^%s*(.-)%s*$")
				end
			end

			if not itemId then
				local numId = tonumber(rest)
				if numId then
					itemId = numId
					local info = getItemInfo(itemId)
					itemName = info and info.name or tostring(itemId)
				else
					itemId = getItemIdFromCache(rest)
					if not itemId then
						itemId = getItemIdByName(rest, false)
					end
					if itemId then
						itemName = rest
					end
				end
			end

			if not itemId or itemId <= 0 then
				print("[AutoLoot] Item not found: " .. (rest or "nil"))
				doPlayerSendCancel(cid, "This item does not exist.")
				return true
			end

			if isInArray(info.BlockItemsList, itemId) then
				doPlayerSendCancel(cid, "You can not add this item in the list!")
				return true
			end

			local slots = isPremium(cid) and info.Max_Slots.premium or info.Max_Slots.free
			local currentCount = #getPlayerStorageTable(cid, info.Storages[1])

			if currentCount >= slots then
				doPlayerSendCancel(cid, "max " .. slots .. " from auto loot")
				return true
			end

			if not isInTable(cid, itemId) then
				addItemTable(cid, itemId)
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
					"[AutoLoot] You added the item [" .. (itemName or tostring(itemId)) .. "] in the list")
			else
				doPlayerSendCancel(cid, "This item is already in your list.")
			end

		elseif command == "remove" then
			local itemId = tonumber(rest)
			if not itemId then
				itemId = getItemIdFromCache(rest)
				if not itemId then
					itemId = getItemIdByName(rest, false)
				end
			end

			if not itemId or itemId <= 0 then
				doPlayerSendCancel(cid, "This item does not exist.")
				return true
			end

			removeItemTable(cid, itemId)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
				"[AutoLoot] You removed the item from the list")
		end
	end

	sendAutolootList(cid)
	return true
end

function sendAutolootList(cid)
	local maxSlots = isPremium(cid) and info.Max_Slots.premium or info.Max_Slots.free
	local loot = maxSlots .. '|'
	local storageTable = getPlayerStorageTable(cid, info.Storages[1])
	for i = 1, #storageTable do
		local storedItemId = storageTable[i]
		local itemInfo = getItemInfo(storedItemId)
		local clientId = (itemInfo and itemInfo.clientId and itemInfo.clientId > 0) and itemInfo.clientId or storedItemId
		local itemName = getItemNameById(storedItemId)
		loot = loot .. storedItemId .. ";" .. clientId .. "-" .. itemName .. '@'
	end
	doPlayerSendExtendedOpcode(cid, 157, loot)
end
