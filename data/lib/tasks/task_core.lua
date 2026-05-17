if not TaskKill_onKill then dofile("data/lib/tasks/task_kill.lua") end
if not TaskDelivery_deliver then dofile("data/lib/tasks/task_delivery.lua") end

function TaskCore_startTask(cid, taskId)
    print("[TaskCore] startTask called cid=" .. cid .. " taskId=" .. tostring(taskId))
    if not isPlayer(cid) then
        print("[TaskCore] Not a player")
        return false
    end

    local config = TASKS[taskId]
    if not config then
        print("[TaskCore] Task not found in TASKS: " .. tostring(taskId))
        print("[TaskCore] TASKS keys sample: " .. tostring(next(TASKS)))
        doPlayerSendCancel(cid, "Task not found.")
        return false
    end
    print("[TaskCore] Task config found: " .. config.name)

    local category = TaskRank_getPlayerCategory(cid)
    print("[TaskCore] Player category=" .. tostring(category) .. " task category=" .. tostring(config.category))
    if config.category ~= category then
        print("[TaskCore] Category mismatch")
        doPlayerSendCancel(cid, "This task is not available for your vocation.")
        return false
    end

    local level = getPlayerLevel(cid)
    print("[TaskCore] Player level=" .. level .. " required=" .. config.levelRequired)
    if level < config.levelRequired then
        print("[TaskCore] Level too low")
        doPlayerSendCancel(cid, "You need level " .. config.levelRequired .. " to start this task.")
        return false
    end

    if config.rankRequired > 0 then
        local points = TaskStorage_getPlayerPoints(cid)
        print("[TaskCore] Player points=" .. points .. " required=" .. config.rankRequired)
        if points < config.rankRequired then
            print("[TaskCore] Points too low")
            doPlayerSendCancel(cid, "You need " .. config.rankRequired .. " task points to start this task.")
            return false
        end
    end

    if config.requiredTask then
        print("[TaskCore] Required task: " .. tostring(config.requiredTask))
        local required = config.requiredTask
        local cache = TaskCache_getPlayerCache(cid)
        local reqTask = cache[required]
        if not reqTask or reqTask.rewarded ~= 1 then
            print("[TaskCore] Required task not completed")
            doPlayerSendCancel(cid,
                "You must complete '" .. (TASKS[required] and TASKS[required].name or required) .. "' first.")
            return false
        end
    end

    local cache = TaskCache_getPlayerCache(cid)
    local existing = cache[taskId]
    print("[TaskCore] Existing task data: " .. tostring(existing))

    if existing and existing.rewarded ~= 1 then
        if config.unique then
            print("[TaskCore] Task is unique and already active")
            doPlayerSendCancel(cid, "You already have this task.")
            return false
        end
        if not config.repeatable then
            print("[TaskCore] Task is not repeatable and already in progress")
            doPlayerSendCancel(cid, "You already have this task in progress or completed.")
            return false
        end
    end

    local activeCount = 0
    for tid, tdata in pairs(cache) do
        if tid:sub(1, 1) ~= "_" and tdata.rewarded ~= 1 then
            local tconfig = TASKS[tid]
            if tconfig and tconfig.type == config.type then
                print("[TaskCore] Found active task of same type: " .. tid .. " type=" .. tconfig.type)
                activeCount = activeCount + 1
            end
        end
    end
    print("[TaskCore] Active count for type '" .. config.type .. "': " .. activeCount)
    if activeCount >= 1 then
        print("[TaskCore] Too many active tasks of type " .. config.type)
        doPlayerSendCancel(cid, "You already have an active " .. config.type .. " task. Finish it first.")
        return false
    end

    local taskData = {
        kills = 0,
        completed = 0,
        rewarded = 0
    }

    if config.daily and config.daily.enabled then
        taskData._dailyReset = os.time() + (config.daily.resetHours * 3600)
    end

    cache[taskId] = taskData
    print("[TaskCore] Cache entry created for " .. taskId)

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[Task] You started '" .. config.name .. "'!")
    TaskNetwork_sendMessage(cid, "Task started: '" .. config.name .. "'!", "#00ff00")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GREEN_RINGS)
    if config.killsRequired > 0 then
        local names = {}
        for _, m in ipairs(config.monsters) do
            table.insert(names, type(m) == "table" and m.name or m)
        end
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
            "[Task] Kill " .. config.killsRequired .. " " .. table.concat(names, ", ") .. ".")
    end
    if config.delivery and config.delivery.enabled then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
            "[Task] Bring " .. config.delivery.count .. "x " .. getItemNameById(config.delivery.itemId) .. ".")
    end

    print("[TaskCore] Sending updated task list")
    TaskNetwork_sendTaskList(cid)
    print("[TaskCore] startTask completed successfully")

    return true
end

function TaskCore_abortTask(cid, taskId)
    if not isPlayer(cid) then return false end

    local cache = TaskCache_getPlayerCache(cid)
    local playerTask = cache[taskId]

    if not playerTask then
        doPlayerSendCancel(cid, "You don't have this task.")
        return false
    end

    if playerTask.rewarded == 1 then
        doPlayerSendCancel(cid, "You already completed this task.")
        return false
    end

    cache[taskId] = nil

    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "[Task] Task aborted.")
    TaskNetwork_sendMessage(cid, "Task cancelled!", "#ff4444")

    TaskNetwork_sendTaskList(cid)

    return true
end

function TaskCore_completeTask(cid, taskId)
    if not isPlayer(cid) then return false end

    local config = TASKS[taskId]
    if not config then return false end

    local cache = TaskCache_getPlayerCache(cid)
    local playerTask = cache[taskId]

    if not playerTask then
        doPlayerSendCancel(cid, "You don't have this task.")
        return false
    end

    if playerTask.completed == 1 then
        doPlayerSendCancel(cid, "Task already completed. Talk to Taskerman to claim reward.")
        return false
    end

    if config.killsRequired > 0 and (playerTask.kills or 0) < config.killsRequired then
        doPlayerSendCancel(cid, "Task not yet completed. Keep killing!")
        return false
    end

    playerTask.completed = 1

    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
        "[Task] '" .. config.name .. "' completed! Open the Tasks window and click Claim Rewards.")
    TaskNetwork_sendMessage(cid, "Task '" .. config.name .. "' completed! Claim your rewards.", "#00ff00")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREAREA)

    TaskNetwork_sendCompletePopup(cid, taskId, config)

    return true
end

function TaskCore_claimTask(cid, taskId)
    if not isPlayer(cid) then return false end

    local config = TASKS[taskId]
    if not config then
        doPlayerSendCancel(cid, "Task not found.")
        return false
    end

    local cache = TaskCache_getPlayerCache(cid)
    local playerTask = cache[taskId]

    if not playerTask then
        doPlayerSendCancel(cid, "You don't have this task active.")
        return false
    end

    if playerTask.rewarded == 1 then
        doPlayerSendCancel(cid, "You already claimed the reward for this task.")
        return false
    end

    if config.killsRequired > 0 and (playerTask.kills or 0) < config.killsRequired then
        if playerTask.completed ~= 1 then
            doPlayerSendCancel(cid, "Task not yet completed. Keep killing!")
            return false
        end
    end

    if config.delivery and config.delivery.enabled then
        if not TaskRewards_removeDeliveryItems(cid, config) then
            doPlayerSendCancel(cid, "You don't have the required delivery items.")
            return false
        end
    end

    TaskRewards_grantAll(cid, config)

    playerTask.rewarded = 1

    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "[Task] Rewards delivered for '" .. config.name .. "'!")
    TaskNetwork_sendMessage(cid, "Rewards claimed for '" .. config.name .. "'!", "#00ff00")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_HOLYDAMAGE)

    TaskNetwork_sendTaskList(cid)

    return true
end

function TaskCore_getAvailableTasks(cid)
    local category = TaskRank_getPlayerCategory(cid)
    local level = getPlayerLevel(cid)
    local points = TaskStorage_getPlayerPoints(cid)
    local cache = TaskCache_getPlayerCache(cid)

    local available = {}

    for taskId, config in pairs(TASKS) do
        if config.category == category then
            if level >= config.levelRequired and points >= config.rankRequired then
                local playerTask = cache[taskId]
                if not playerTask or playerTask.rewarded == 1 then
                    table.insert(available, taskId)
                elseif config.repeatable and playerTask.rewarded == 1 then
                    table.insert(available, taskId)
                end
            end
        end
    end

    return available
end

function TaskCore_getActiveTasks(cid)
    local cache = TaskCache_getPlayerCache(cid)
    local active = {}

    for taskId, data in pairs(cache) do
        if taskId:sub(1, 1) ~= "_" and data.rewarded ~= 1 then
            table.insert(active, taskId)
        end
    end

    return active
end

function TaskCore_getCompletedTasks(cid)
    local cache = TaskCache_getPlayerCache(cid)
    local completed = {}

    for taskId, data in pairs(cache) do
        if taskId:sub(1, 1) ~= "_" and data.completed == 1 and data.rewarded == 0 then
            table.insert(completed, taskId)
        end
    end

    return completed
end
