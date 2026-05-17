if not json then json = dofile("data/lib/json.lua") end
dofile("data/lib/tasks/task_config.lua")
dofile("data/talkactions/scripts/tasks.lua")
dofile("data/lib/tasks/task_network.lua")

TASK_LAST_SEND = {}

function TaskOpcode_debounce(cid)
    local now = os.time()
    local last = TASK_LAST_SEND[cid] or 0
    if now - last < 2 then
        print("[TaskOpcode] Debounce: skipping send for cid=" .. cid)
        return false
    end
    TASK_LAST_SEND[cid] = now
    return true
end

function onExtendedOpcode(cid, opcode, buffer)
    print("[TaskOpcode] Received opcode=" .. opcode .. " TASK_OPCODE=" .. tostring(TASK_OPCODE))
    if not isPlayer(cid) then
        print("[TaskOpcode] Not a player, returning false")
        return false
    end

    if opcode == 201 or opcode == 240 or opcode == 125 or opcode == 235 then
        print("[TaskOpcode] Legacy opcode " .. opcode)
        if not TaskOpcode_debounce(cid) then return true end
        TaskNetwork_sendTaskList(cid)
        return true
    end

    if opcode ~= TASK_OPCODE then
        print("[TaskOpcode] Opcode mismatch, returning false")
        return false
    end

    local success, data = pcall(json.decode, buffer)
    if not success or not data then
        print("[TaskOpcode] JSON decode failed")
        if not TaskOpcode_debounce(cid) then return true end
        TaskNetwork_sendTaskList(cid)
        return true
    end

    print("[TaskOpcode] Decoded action=" .. tostring(data.action) .. " taskId=" .. tostring(data.taskId))
    TaskNetwork_handleAction(cid, data)
    print("[TaskOpcode] handleAction returned")
    return true
end
