if not TaskCache_getPlayerTask then dofile("data/lib/tasks/task_cache.lua") end
if not TaskNetwork_sendTaskUpdate then dofile("data/lib/tasks/task_network.lua") end

function TaskKill_onKill(cid, monsterName)
    print("[TaskKill_lib] TaskKill_onKill called cid=" .. cid .. " monsterName='" .. tostring(monsterName) .. "'")
    if not isPlayer(cid) or not monsterName then
        print("[TaskKill_lib] Invalid params, returning")
        return
    end

    local taskIds = TaskCache_getTasksForMonster(monsterName)
    print("[TaskKill_lib] TaskCache_getTasksForMonster returned " .. #taskIds .. " ids")
    if #taskIds == 0 then
        print("[TaskKill_lib] No tasks found for monster, returning")
        return
    end

    local cache = TaskCache_getPlayerCache(cid)
    print("[TaskKill_lib] Player cache obtained")

    for _, taskId in ipairs(taskIds) do
        print("[TaskKill_lib] Processing taskId=" .. tostring(taskId))
        local config = TASKS[taskId]
        if not config then
            print("[TaskKill_lib] Config not found for taskId=" .. tostring(taskId))
        else
            print("[TaskKill_lib] Config found: name=" .. config.name .. " type=" .. config.type)
            local shouldProcess = config.type ~= "delivery"
            print("[TaskKill_lib] shouldProcess=" .. tostring(shouldProcess))

            if shouldProcess then
                local playerTask = cache[taskId]
                print("[TaskKill_lib] playerTask=" .. tostring(playerTask))
                if playerTask then
                    print("[TaskKill_lib] playerTask.completed=" .. tostring(playerTask.completed) .. " rewarded=" .. tostring(playerTask.rewarded) .. " kills=" .. tostring(playerTask.kills))
                end
                if playerTask and playerTask.completed ~= 1 then
                    local canProgress = true

                    if playerTask.rewarded == 1 and not config.repeatable then
                        print("[TaskKill_lib] Cannot progress: already rewarded and not repeatable")
                        canProgress = false
                    end

                    if canProgress then
                        if config.daily and config.daily.enabled then
                            if playerTask._dailyReset and os.time() > playerTask._dailyReset then
                                print("[TaskKill_lib] Daily reset triggered")
                                playerTask.kills = 0
                                playerTask.completed = 0
                                playerTask.rewarded = 0
                            end
                        end

                        playerTask.kills = (playerTask.kills or 0) + 1
                        print("[TaskKill_lib] Incremented kills to " .. playerTask.kills)

                        if playerTask.kills >= config.killsRequired then
                            playerTask.completed = 1
                            print("[TaskKill_lib] Task completed!")
                            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
                                "[Task] '" .. config.name .. "' completed! Open the Tasks window and claim your reward.")
                            TaskNetwork_sendMessage(cid, "Task '" .. config.name .. "' completed!", "#00ff00")
                            doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREAREA)
                            TaskNetwork_sendCompletePopup(cid, taskId, config)
                        else
                            print("[TaskKill_lib] Sending progress: " .. playerTask.kills .. "/" .. config.killsRequired)
                            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
                                "[Task] " .. config.name .. ": " ..
                                playerTask.kills .. "/" .. config.killsRequired)
                        end

                        TaskNetwork_sendTaskUpdate(cid, taskId, playerTask.kills, config.killsRequired,
                            playerTask.completed)
                    end
                else
                    print("[TaskKill_lib] playerTask nil or already completed")
                end
            end
        end
    end
end
