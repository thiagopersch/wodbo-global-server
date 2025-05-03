local config = {
    storage = 030220122041,
    version = 1,
    marks = {
        { mark = 5, pos = { x = 1095, y = 1062, z = 7 }, desc = "Temple." },
        { mark = 4, pos = { x = 895, y = 996, z = 7 }, desc = "Depot." }
    }
}

local f_addMark = doPlayerAddMapMark
if (not f_addMark) then f_addMark = doAddMapMark end

function onThink(cid, interval)
    if (isPlayer(cid) ~= TRUE or getPlayerStorageValue(cid, config.storage) == config.version) then
        return
    end

    for _, m in pairs(config.marks) do
        f_addMark(cid, m.pos, m.mark, m.desc ~= nil and m.desc or "")
    end
    setPlayerStorageValue(cid, config.storage, config.version)
    return TRUE
end
