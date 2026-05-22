function onStepIn(cid, item, pos)
    local thingPos = getThingPos(cid)
    local magicEffect = 240
    local towns = {
        central_city = 2,
        karakura = 3,
    }

    if isPlayer(cid) == TRUE then
        if (item.actionid == 4036) then
            doPlayerSendTextMessage(cid, 25, "Now you are citizen of Central City.")
            doSendMagicEffect(thingPos, magicEffect)
            doPlayerSetTown(cid, towns.central_city)
            doTeleportThing(cid, getTownTemplePosition(towns.central_city))
            doSendMagicEffect(getTownTemplePosition(towns.central_city), magicEffect)
        elseif (item.actionid == 4037) then
            doPlayerSendTextMessage(cid, 25, "Now you are citizen of Karakura.")
            doSendMagicEffect(thingPos, magicEffect)
            doPlayerSetTown(cid, towns.karakura)
            doTeleportThing(cid, getTownTemplePosition(towns.karakura))
            doSendMagicEffect(getTownTemplePosition(towns.karakura), magicEffect)
        end
    end
    return true
end
