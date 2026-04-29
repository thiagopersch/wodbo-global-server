-- Generic Vocation Unlock Item
dofile("data/lib/change_vocation.lua")

-- config example: { [itemId] = vocationId }
local config = {
    [49509] = 17, -- Goku
    [49510] = 40, -- Vegeta
    [49511] = 35, -- Trunks
    [49512] = 6,  -- Buu
    [49513] = 30, -- Piccolo
    [49514] = 16, -- Gohan
    [49515] = 16, -- Gohan
    [49516] = 11, -- Cell
    [49517] = 38, -- Uub
    [49518] = 8,  -- C17
    [49519] = 9,  -- C18
    [49520] = 12, -- Cooler
    [49521] = 36, -- Tsuful
    [49522] = 13, -- Dende
    -- [49523] = 5,  -- Bulma (não existe Gotenks)
    [49524] = 14, -- Freeza
    [49525] = 15, -- Ginn
    [49526] = 23, -- Kaio
    [49527] = 1,  -- Bardock
    [49528] = 4,  -- Brolly
    --[49529] = 15, -- Jenks (NÃO EXISTE)
    [49530] = 35, -- Trunks
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local vocId = config[item.itemid]
    if not vocId then
        return false
    end

    if ChangeVocation.isUnlocked(cid, vocId) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL,
            "You have already unlocked the " .. ChangeVocation.getVocationName(vocId) .. " vocation.")
        return true
    end

    ChangeVocation.unlockVocation(cid, vocId)
    doRemoveItem(item.uid, 1)

    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
        "You have successfully unlocked the " .. ChangeVocation.getVocationName(vocId) .. " vocation!")
    doSendMagicEffect(getCreaturePosition(cid), 13) -- Effect 13 (magical) ou CONST_ME_HOLYDAMAGE

    ChangeVocation.syncPlayer(cid)
    return true
end
