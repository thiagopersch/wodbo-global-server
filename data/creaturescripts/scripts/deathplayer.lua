function onDeath(cid, corpse, deathList)
    if not isPlayer(cid) then
        return true
    end

    local killer = deathList[1]
    if isPlayer(killer) then
        doBroadcastMessage(
        getCreatureName(cid) ..
        " [Level: " ..
        getPlayerLevel(cid) ..
        "] foi morto pelo jogador " .. getCreatureName(killer) .. " [Level: " .. getPlayerLevel(killer) .. "].",
            MESSAGE_STATUS_CONSOLE_ORANGE)
    elseif isPlayer(killer) then
        doBroadcastMessage(
        getCreatureName(cid) ..
        " [Level: " ..
        getPlayerLevel(cid) ..
        "] foi morto pelo jogador " .. getCreatureName(killer) .. " [Level: " .. getPlayerLevel(killer) .. "].",
            MESSAGE_STATUS_CONSOLE_ORANGE)
    end
    return true
end

function onLogin(cid)
    registerCreatureEvent(cid, "DeathPlayer")
    return true
end
