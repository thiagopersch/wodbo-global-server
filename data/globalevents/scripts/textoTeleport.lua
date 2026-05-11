local positions = {
    ["Itens iniciais"] = {
        pos = { x = 32000, y = 32004, z = 7 },
        color = { 205, 210 },
        effect = { 55 }
    },
    ["Trainers"] = {
        pos = { x = 31893, y = 32222, z = 7 },
        color = { 205, 210 },
        effect = { 251 }
    },
    ["Arena PvP"] = {
        pos = { x = 31893, y = 32224, z = 7 },
        color = { 205, 210 },
        effect = { 10 }
    },
    ["Change vocation"] = {
        pos = { x = 31910, y = 32209, z = 7 },
        color = { 205, 210 },
        effect = { 39, 55, 56 }
    },
    ["To become a citizen of the city"] = {
        pos = { x = 31942, y = 32226, z = 7 },
        color = { 205, 210 },
        effect = { 16 }
    },
}

function onThink(cid, interval, lastExecution)
    for t, pos in pairs(positions) do
        for _, effect in ipairs(pos.effect) do
            if (#pos.effect > 0) then
                doSendMagicEffect(pos.pos, effect)
            end
        end
        doSendAnimatedText(pos.pos, t, #pos.color > 0 and pos.color[math.random(#pos.color)] or 215)
    end
    return true
end
