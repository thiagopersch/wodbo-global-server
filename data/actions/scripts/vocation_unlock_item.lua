-- Generic Vocation Unlock Item
dofile("data/lib/change_vocation.lua")

-- config example: { [itemId] = vocationId }
local config = {
    [2160] = 53, -- Crystal Coin (example) unlocks Ichigo
    [1234] = 67, -- Zaraki Item unlocks Zaraki
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local vocId = config[item.itemid]
    if not vocId then
        return false
    end

    if VocationChange.isUnlocked(cid, vocId) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL,
            "You have already unlocked the " .. VocationChange.getVocationName(vocId) .. " vocation.")
        return true
    end

    VocationChange.unlockVocation(cid, vocId)
    doRemoveItem(item.uid, 1)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
        "You have successfully unlocked the " .. VocationChange.getVocationName(vocId) .. " vocation!")
    doSendMagicEffect(getCreaturePosition(cid), 13) -- Effect 13 (magical)
    VocationChange.sync(cid)
    return true
end
