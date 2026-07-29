-- Chest system: consuming an item tagged actionid="9500" (see actions.xml) rolls a weighted
-- random reward from `chest_rewards` (managed on the portal at /admin/chest-rewards) and puts
-- it in the player's backpack. Notifies the OTC client (opcode 252) so it can show a small
-- "you received X" popup.

if not json then json = dofile("data/lib/json.lua") end

local CHEST_OPCODE = 252

local function rollReward()
    local res = db.getResult("SELECT `item_id`, `count`, `weight` FROM `chest_rewards` WHERE `published` = 1")

    -- `db.getResult` only returns -1 on a hard query error — a SELECT matching zero rows still
    -- returns a "valid" handle, and reading a field from it returns `false` instead of erroring.
    -- Must check the type of the first read before trusting the handle has any row at all.
    local firstWeight = res ~= -1 and result.getDataInt(res, "weight") or nil
    if type(firstWeight) ~= "number" then
        if res ~= -1 then result.free(res) end
        return nil
    end

    local rewards, totalWeight = {}, 0
    repeat
        local weight = result.getDataInt(res, "weight")
        if type(weight) == "number" then
            table.insert(rewards, {
                itemId = result.getDataInt(res, "item_id") or 0,
                count = result.getDataInt(res, "count") or 1,
                weight = weight,
            })
            totalWeight = totalWeight + weight
        end
    until not result.next(res)
    result.free(res)

    if totalWeight <= 0 or #rewards == 0 then return nil end

    local roll = math.random(1, totalWeight)
    local accumulated = 0
    for _, reward in ipairs(rewards) do
        accumulated = accumulated + reward.weight
        if roll <= accumulated then
            return reward
        end
    end
    return rewards[#rewards]
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local reward = rollReward()
    if not reward then
        doPlayerSendCancel(cid, "This chest has no rewards configured.")
        return true
    end

    doPlayerAddItem(cid, reward.itemId, reward.count)
    doRemoveItem(item.uid, 1)
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GIFT_WRAPS)

    local itemName = getItemNameById(reward.itemId)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
        "You opened the chest and received " .. reward.count .. "x " .. itemName .. "!")

    if doPlayerSendExtendedOpcode then
        doPlayerSendExtendedOpcode(cid, CHEST_OPCODE, json.encode({
            itemId = reward.itemId,
            count = reward.count,
            name = itemName,
        }))
    end

    return true
end
