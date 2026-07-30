-- Chest system (module game_chest on the OTC): the portal (/admin/chests) manages up to 3
-- chests in the `chests` table (name, key_item_id, rewards JSON [{itemId,count}] x<=3,
-- published). The client shows all published chests (1 centered + up to 2 on the sides),
-- requests "list" to populate them, then "open" on whichever one is centered. Opening consumes
-- 1x key_item_id (player must have it), rolls 1 reward uniformly among `rewards`, and grants it.
-- Queried directly per request (like highscore.lua) instead of cached — at most 3 rows, editing
-- happens rarely on the portal, no reload plumbing needed.

if not json then json = dofile("data/lib/json.lua") end

local CHEST_OPCODE = 252

local function loadPublishedChests()
    local chests = {}
    local res = db.getResult("SELECT `id`, `name`, `key_item_id`, `rewards` FROM `chests` WHERE `published` = 1 ORDER BY `id` ASC")
    if res == -1 then return chests end

    repeat
        local okRewards, rewards = pcall(json.decode, result.getDataString(res, "rewards") or "[]")
        table.insert(chests, {
            id = result.getDataInt(res, "id"),
            name = result.getDataString(res, "name"),
            keyItemId = result.getDataInt(res, "key_item_id"),
            rewards = okRewards and rewards or {},
        })
    until not result.next(res)
    result.free(res)

    return chests
end

local function findChest(chestId)
    for _, chest in ipairs(loadPublishedChests()) do
        if chest.id == chestId then return chest end
    end
    return nil
end

local function sendChestList(cid)
    local list = {}
    for _, chest in ipairs(loadPublishedChests()) do
        table.insert(list, {
            id = chest.id,
            name = chest.name,
            keyItemId = chest.keyItemId,
            hasKey = getPlayerItemCount(cid, chest.keyItemId) >= 1,
        })
    end

    doPlayerSendExtendedOpcode(cid, CHEST_OPCODE, json.encode({
        action = "list",
        chests = list,
    }))
end

local function sendChestResult(cid, success, message, extra)
    local response = { action = "result", success = success, message = message }
    if extra then
        for key, value in pairs(extra) do
            response[key] = value
        end
    end
    doPlayerSendExtendedOpcode(cid, CHEST_OPCODE, json.encode(response))
end

local function grantRewardItem(cid, itemId, count)
    local backpack = doPlayerAddItem(cid, 5801, 1)
    if not backpack then
        backpack = doPlayerAddItem(cid, 1988, 1)
    end
    if not backpack then return false end

    if isItemStackable(itemId) or count == 1 then
        doAddContainerItem(backpack, itemId, count)
    else
        for _ = 1, count do
            doAddContainerItem(backpack, itemId, 1)
        end
    end
    return true
end

local function openChest(cid, chestId)
    local chest = findChest(chestId)
    if not chest then
        sendChestResult(cid, false, "This chest is not available.")
        return
    end

    if #chest.rewards == 0 then
        sendChestResult(cid, false, "This chest has no rewards configured.")
        return
    end

    if getPlayerItemCount(cid, chest.keyItemId) < 1 then
        sendChestResult(cid, false, "You don't have the required key item.")
        return
    end

    if not doPlayerRemoveItem(cid, chest.keyItemId, 1) then
        sendChestResult(cid, false, "Failed to remove the key item.")
        return
    end

    local reward = chest.rewards[math.random(1, #chest.rewards)]
    local itemId = reward.itemId
    local count = reward.count or 1

    if not grantRewardItem(cid, itemId, count) then
        -- Refunds the key so a full backpack doesn't silently eat the player's key item.
        doPlayerAddItem(cid, chest.keyItemId, 1)
        sendChestResult(cid, false, "Your backpack is full.")
        return
    end

    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GIFT_WRAPS)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
        "You opened " .. chest.name .. " and received " .. count .. "x " .. getItemNameById(itemId) .. "!")

    sendChestResult(cid, true, nil, {
        chestId = chest.id,
        itemId = itemId,
        count = count,
        name = getItemNameById(itemId),
    })
end

function onLogin(cid)
    registerCreatureEvent(cid, "ChestOpcode")
    return true
end

function onExtendedOpcode(cid, opcode, buffer)
    if opcode ~= CHEST_OPCODE then return false end
    if not isPlayer(cid) then return true end

    local success, data = pcall(json.decode, buffer)
    if not success or type(data) ~= "table" then
        sendChestList(cid)
        return true
    end

    if data.action == "open" and data.chestId then
        openChest(cid, tonumber(data.chestId))
    else
        sendChestList(cid)
    end

    return true
end
