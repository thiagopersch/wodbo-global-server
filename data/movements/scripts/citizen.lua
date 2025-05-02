function onStepIn(cid, item, pos)
    if isPlayer(cid) == TRUE then
        if (item.actionid == 4036) then
            doPlayerSendTextMessage(cid, 25, "Now you are citizen of Central City.")
            doPlayerSetTown(cid, 1)
        elseif (item.actionid == 4037) then
            doPlayerSendTextMessage(cid, 25, "Now you are citizen of Karakura.")
            doPlayerSetTown(cid, 2)
        end
    end
end
