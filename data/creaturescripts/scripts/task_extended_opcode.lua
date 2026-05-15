json = dofile("data/lib/json.lua")
dofile("data/lib/tasks/task_config.lua")
dofile("data/lib/tasks/task_monsters.lua")
dofile("data/talkactions/scripts/tasks.lua")
dofile("data/lib/tasks/task_network.lua")

function onExtendedOpcode(cid, opcode, buffer)
    if opcode ~= TASK_OPCODE then return false end
    if not isPlayer(cid) then return false end

    local success, data = pcall(json.decode, buffer)
    if not success or not data then
        return false
    end

    TaskNetwork_handleAction(cid, data)
    return true
end
