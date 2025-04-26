local positions = {
    ["Itens iniciais"] = {
        pos = { x = 31999, y = 32004, z = 7 },
        color = { 205, 210 },
        effect = {}
    },
}

function onThink(cid, interval, lastExecution)
    for t, pos in pairs(positions) do
        for _, effect in ipairs(pos.effect) do
            if (#pos.effect > 0) then
                doSendMagicEffect(pos.pos, effect)
            end
        end
        doSendAnimatedText(pos.pos, t, #pos.color > 0 and
            pos.color[math.random(#pos.color)] or 215)
    end
    return true
end
