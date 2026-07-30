info = {
	BlockMonsters = {},
	BlockItemsList = {2123,2515},
	Max_Slots = {free = 5, premium = 20},
	-- [1] personal item list, [2] money auto-collect toggle, [3] system on/off,
	-- [4] money destination (0 = backpack, 1 = bank)
	Storages = {27000,28001,28002,28003}
}

-- Master catalog of items allowed in the autoloot system, administered on the portal at
-- /admin/autoloot-items (table `autoloot_items`) — not every item in items.xml, only the
-- published ones. Loaded once at boot and refreshed by the globalevent below so portal edits
-- propagate without a restart (same pattern as data/lib/tasks/task_db_loader.lua).
AUTOLOOT_CATALOG = AUTOLOOT_CATALOG or {}

function AutolootCatalog_reload()
	local catalog = {}
	local res = db.getResult("SELECT `item_id`, `name` FROM `autoloot_items` WHERE `published` = 1 ORDER BY `name` ASC")
	-- `db.getResult` only returns -1 on a hard query error — a SELECT matching zero rows still
	-- returns a "valid" handle, and reading a field from it returns `false` instead of erroring,
	-- so always check the read value's type before trusting it.
	if res ~= -1 and type(result.getDataInt(res, "item_id")) == "number" then
		repeat
			local itemId = result.getDataInt(res, "item_id")
			local name = result.getDataString(res, "name")
			if type(itemId) == "number" and type(name) == "string" then
				local itemInfo = getItemInfo(itemId)
				local clientId = (itemInfo and itemInfo.clientId and itemInfo.clientId > 0) and itemInfo.clientId or itemId
				table.insert(catalog, {id = itemId, name = name, clientId = clientId})
			end
		until not result.next(res)
	end
	if res ~= -1 then result.free(res) end

	AUTOLOOT_CATALOG = catalog
	print("[AutoLoot] Loaded " .. #catalog .. " items from the admin catalog.")
end

if #AUTOLOOT_CATALOG == 0 then
	AutolootCatalog_reload()
end

function getItemIdFromCache(itemName)
	local queryLower = itemName:lower()
	for _, item in ipairs(AUTOLOOT_CATALOG) do
		if item.name:lower() == queryLower then
			return item.id
		end
	end
	return nil
end

function searchItemsByQuery(query)
	local results = {}
	local queryLower = query:lower()
	for _, item in ipairs(AUTOLOOT_CATALOG) do
		if item.name:lower():find(queryLower, 1, true) then
			table.insert(results, item)
			if #results >= 100 then break end
		end
	end
	return results
end
function setPlayerStorageTable(cid, storage, tab)
	local tabstr = "&"
	for i,x in pairs(tab) do
		tabstr = tabstr .. i .. "," .. x .. ";"
	end
	setPlayerStorageValue(cid, storage, tabstr:sub(1, #tabstr-1))
end
function getPlayerStorageTable(cid, storage)
	local tabstr = getPlayerStorageValue(cid, storage)
	local tab = {}
	if type(tabstr) ~= "string" then
		return {}
	end
	if tabstr:sub(1,1) ~= "&" then
		return {}
	end
	local tabstr = tabstr:sub(2, #tabstr)
	local a = string.explode(tabstr, ";")
	for i,x in pairs(a) do
		local b = string.explode(x, ",")
		tab[tonumber(b[1]) or b[1]] = tonumber(b[2]) or b[2]
	end
	return tab
end
function isInTable(cid, item)
	for _,i in pairs(getPlayerStorageTable(cid, info.Storages[1]))do
		if tonumber(i) == tonumber(item) then
			return true
		end
	end
	return false
end
function addItemTable(cid, item)
	local x = {}
	for i = 1,#getPlayerStorageTable(cid, info.Storages[1]) do
		table.insert(x,getPlayerStorageTable(cid, info.Storages[1])[i])
	end
	if x ~= 0 then
		table.insert(x,tonumber(item))
		setPlayerStorageTable(cid, info.Storages[1], x)
	else
		setPlayerStorageTable(cid, info.Storages[1], {item})
	end
end
function removeItemTable(cid, item)
	local x = {}
	for i = 1,#getPlayerStorageTable(cid, info.Storages[1]) do
		table.insert(x,getPlayerStorageTable(cid, info.Storages[1])[i])
	end
	for i,v in ipairs(x) do
		if tonumber(v) == tonumber(item) then
			table.remove(x,i)
		end
	end
	return setPlayerStorageTable(cid, info.Storages[1], x)
end
function ShowItemsTabble(cid)
	local n,str = 0,"[+] Auto Loot Commands [+]\n\n!autoloot item name --> To add ou Remove item from list.\n!autoloot money --> To collect gold automatically.\n!autoloot clear --> To clear the list.\n!autoloot on/off --> To enable or disable the collecting of items in the system.\n\n[+] Auto Loot Info [+]\n\nSystem: "..(getPlayerStorageValue(cid, info.Storages[3]) <= 0 and "Activated" or "Disabled")..".\nGold Collecting: "..(getPlayerStorageValue(cid, info.Storages[2]) > 0 and "Activated" or "Disabled")..".\nBalance Total: ["..getPlayerBalance(cid).."] gp's.\nMaximum Slots: ["..#getPlayerStorageTable(cid, info.Storages[1]).."/"..(isPremium(cid) and info.Max_Slots.premium or info.Max_Slots.free).."]\n\n[+] Auto Loot Slots [+]\n\n"
	for i = 1,#getPlayerStorageTable(cid, info.Storages[1]) do
		n = n + 1
		str = str.."Slot "..n.." - "..getItemNameById(getPlayerStorageTable(cid, info.Storages[1])[i]).."\n"
	end
	return doPlayerPopupFYI(cid, str)
end
function getContainerItems(containeruid)
	local items = {}
	local containers = {}
	if type(getContainerSize(containeruid)) ~= "number" then
		return false
	end
	for slot = 0, getContainerSize(containeruid)-1 do
		local item = getContainerItem(containeruid, slot)
		if item.itemid == 0 then
			break
		end
		if isContainer(item.uid) then
			table.insert(containers, item.uid)
		end
		table.insert(items, item)
	end
	if #containers > 0 then
		for i,x in ipairs(getContainerItems(containers[1])) do
			table.insert(items, x)
		end
		table.remove(containers, 1)
	end
	return items
end
function getItemsInContainerById(container, itemid)
	local items = {}
	if isContainer(container) and getContainerSize(container) > 0 then
		for slot=0, (getContainerSize(container)-1) do
			local item = getContainerItem(container, slot)
			if isContainer(item.uid) then
				local itemsbag = getItemsInContainerById(item.uid, itemid)
				for i=0, #itemsbag do
					table.insert(items, itemsbag[i])
				end
			else
				if itemid == item.itemid then
					table.insert(items, item.uid)
				end
			end
		end
	end
	return items
end
local MAX_STACK = ITEM_STACK_SIZE or 10000

function doPlayerAddItemStacking(cid, itemid, amount)
	local item, _G = getItemsInContainerById(getPlayerSlotItem(cid, 3).uid, itemid), 0
	if #item > 0 then
		for _ ,x in pairs(item) do
			local ret = getThing(x)
			if ret.type < MAX_STACK then
				doTransformItem(ret.uid, itemid, ret.type+amount)
				if ret.type+amount > MAX_STACK then
					doPlayerAddItem(cid, itemid, ret.type+amount-MAX_STACK)
				end
				break
			else
				_G = _G+1
			end
		end
		if _G == #item then
			doPlayerAddItem(cid, itemid, amount)
		end
	else
		return doPlayerAddItem(cid, itemid, amount)
	end
end
function AutomaticDeposit(cid,item,n)
	local deposit = item == tonumber(2160) and (n*10000) or tonumber(item) == 2152 and (n*100) or (n*1)
	return doPlayerDepositMoney(cid, deposit)
end
function corpseRetireItems(cid, pos)
	local check = false
	for i = 0, 255 do
		pos.stackpos = i
		tile = getTileThingByPos(pos)
		if tile.uid > 0 and isCorpse(tile.uid) then
			check = true break
		end
	end
	if check == true then
		local items = getContainerItems(tile.uid)
		if type(items) ~= "table" then
			return
		end
		local moneyEnabled = getPlayerStorageValue(cid, info.Storages[2]) > 0
		local toBank = getPlayerStorageValue(cid, info.Storages[4]) > 0
		for i,x in pairs(items) do
			local isMoney = isInArray({2148,2152,2160}, tonumber(x.itemid))
			if isInArray(getPlayerStorageTable(cid, info.Storages[1]), tonumber(x.itemid)) or (moneyEnabled and isMoney) then
				if isMoney and toBank then
					AutomaticDeposit(cid, x.itemid, x.type)
				elseif isItemStackable(x.itemid) then
					doPlayerAddItemStacking(cid, x.itemid, x.type)
				else
					doPlayerAddItem(cid, x.itemid, x.type)
				end
				doRemoveItem(x.uid)
			end
		end
	end
end
