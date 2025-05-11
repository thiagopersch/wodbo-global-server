function onSay(cid, words, param, channel)
    if (param == '') then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
        return true
    end
    local t = string.explode(param, " ", 1)
    doBroadcastMessage(param)
    return true
end
