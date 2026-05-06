function onSay(cid, words, param, channel)
    local dodge = math.max(0, getPlayerStorageValue(cid, 48700))
    local crit = math.max(0, getPlayerStorageValue(cid, 48701))
    
    local text = "--- Character Extra Skills ---\n"
    text = text .. "Dodge: " .. dodge .. "/1000 (" .. string.format("%.3f", dodge * 0.025) .. "%)\n"
    text = text .. "Critical: " .. crit .. "/1000 (" .. string.format("%.3f", crit * 0.025) .. "%)\n"
    
    doPlayerPopupFYI(cid, text)
    return true
end
