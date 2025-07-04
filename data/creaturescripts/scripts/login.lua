local config = {
    loginMessage = getConfigValue('loginMessage'),
    useFragHandler = getBooleanFromString(getConfigValue('useFragHandler'))
}

function onLogin(cid)
    local loss = getConfigValue('deathLostPercent')
    if (loss ~= nil) then
        doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, loss * 10)
    end

    local accountManager = getPlayerAccountManager(cid)
    if (accountManager == MANAGER_NONE) then
        local lastLogin, str = getPlayerLastLoginSaved(cid), config.loginMessage
        if (lastLogin > 0) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, str)
            str = "Your last visit was on " ..
                os.date("%a %b %d %X %Y", lastLogin) .. "."
        else
            str = str .. " Please choose your outfit."
            doPlayerSendOutfitWindow(cid)
            setPlayerStorageValue(cid, 30024, 0)
        end

        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, str)
    elseif (accountManager == MANAGER_NAMELOCK) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
            "Hello, it appears that your character has been namelocked, what would you like as your new name?")
    elseif (accountManager == MANAGER_ACCOUNT) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
            "Hello, type 'account' to manage your account and if you want to start over then type 'cancel'.")
    else
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
            "Hello, type 'account' to create an account or type 'recover' to recover an account.")
    end

    if (not isPlayerGhost(cid)) then
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
    end

    --registerCreatureEvent(cid, "Outfit")
    registerCreatureEvent(cid, "AmuletDeath")
    registerCreatureEvent(cid, "FullHpMana")
    registerCreatureEvent(cid, "FragReward")
    registerCreatureEvent(cid, "Mail")
    registerCreatureEvent(cid, "GuildMotd")
    registerCreatureEvent(cid, "Idle")
    registerCreatureEvent(cid, "KillingInTheNameOf")
    if (config.useFragHandler) then registerCreatureEvent(cid, "SkullCheck") end
    registerCreatureEvent(cid, "ReportBug")
    registerCreatureEvent(cid, "AdvanceSave")
    registerCreatureEvent(cid, "onlinepoints")
    registerCreatureEvent(cid, "fraglook")
    registerCreatureEvent(cid, "DeathPlayer")
    registerCreatureEvent(cid, "LevelRecompense")
    registerCreatureEvent(cid, "showKD")
    registerCreatureEvent(cid, "AdvLevelSpells")
    registerCreatureEvent(cid, "timelevel")
    registerCreatureEvent(cid, "IconMap")
    registerCreatureEvent(cid, "SkillPoints")
    registerCreatureEvent(cid, "ExtendedOpcode")

    local sagastor = 578744
    if getPlayerStorageValue(cid, sagastor) ~= -1 then
        local w = tostring(getPlayerStorageValue(cid, sagastor)):gsub(':', '')
            :explode(',')
        doCreatureChangeOutfit(cid, { lookType = tonumber(w[1]) })
        doPlayerSetVocation(cid, tonumber(w[2]))
    end

    return true
end
