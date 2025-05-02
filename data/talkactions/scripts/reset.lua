local config = {
    backToLevel = 1,         -- Level to reset to
    resetLevelFree = 350,    -- Minimum level required to reset (free accounts)
    resetLevelPremium = 330, -- Minimum level required to reset (premium accounts)
    redSkull = false,        -- Must not have red/black skull to reset
    battle = false,          -- Must not be in battle to reset
    pz = true,               -- Must be in protection zone to reset
}

-- Function to get player's reset count from database
local function getPlayerResets(cid)
    local result = db.getResult("SELECT `resets` FROM `players` WHERE `id` = " .. getPlayerGUID(cid))
    if result:getID() ~= -1 then
        local resets = result:getDataInt("resets")
        result:free()
        return resets < 0 and 0 or resets
    end
    return 0
end

-- Function to increment player's reset count in database
local function doPlayerAddResets(cid)
    db.query("UPDATE `players` SET `resets` = `resets` + 1 WHERE `id` = " .. getPlayerGUID(cid))
end

-- Reset command handler
function onSay(cid, words, param)
    -- Check skull status (red or black skull)
    if config.redSkull and (getCreatureSkullType(cid) == SKULL_RED or getCreatureSkullType(cid) == SKULL_BLACK) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ORANGE, "You cannot reset while having a red or black skull.")
        return true
    end

    -- Check protection zone
    if config.pz and not getTilePzInfo(getCreaturePosition(cid)) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ORANGE, "You must be in a protection zone to reset.")
        return true
    end

    -- Check battle status
    if config.battle and getCreatureCondition(cid, CONDITION_INFIGHT) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ORANGE, "You cannot reset while in battle.")
        return true
    end

    -- Determine required level based on account type
    local resetLevel = isPremium(cid) and config.resetLevelPremium or config.resetLevelFree

    -- Check if player meets the level requirement
    if getPlayerLevel(cid) < resetLevel then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ORANGE, "You need to be at least level " .. resetLevel .. " to reset.")
        return true
    end

    -- Perform the reset
    local healthMax, manaMax = getCreatureMaxHealth(cid), getCreatureMaxMana(cid)
    doPlayerAddLevel(cid, -(getPlayerLevel(cid) - config.backToLevel)) -- Reset to backToLevel
    setCreatureMaxHealth(cid, healthMax)
    setCreatureMaxMana(cid, manaMax)
    doPlayerAddResets(cid) -- Increment reset count in database
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_RED)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        "You have reset your level! You now have " .. getPlayerResets(cid) .. " reset(s).")

    return true
end
