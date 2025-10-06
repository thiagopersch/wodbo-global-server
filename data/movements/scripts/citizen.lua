function onStepIn(cid, item, pos)
    local thingPos = getThingPos(cid)
    local magicLevel = 240

    if isPlayer(cid) == TRUE then
        if (item.actionid == 4036) then
            doPlayerSendTextMessage(cid, 25, "Now you are citizen of Central City.")
            doSendMagicEffect(thingPos, magicLevel)
            doPlayerSetTown(cid, 1)
        end
        if (item.actionid == 4037) then
            doPlayerSendTextMessage(cid, 25, "Now you are citizen of Karakura.")
            doSendMagicEffect(thingPos, magicLevel)
            doPlayerSetTown(cid, 2)
        end
    end
end
