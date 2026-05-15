if not json then
    json = dofile("data/lib/json.lua")
end
if not TaskRank_getPlayerRankName then
    dofile("data/lib/tasks/task_rank.lua")
end
if not TaskMonsters_getData then
    dofile("data/lib/tasks/task_monsters.lua")
end
if not TaskSpawn_getSpawns then
    dofile("data/talkactions/scripts/tasks.lua")
end

TASK_OPCODE = 215

function TaskNetwork_sendJSON(cid, data)
    if not isPlayer(cid) then return end

    local ok, encoded = pcall(json.encode, data)
    if not ok then return end

    doPlayerSendExtendedOpcode(cid, TASK_OPCODE, encoded)
end

function TaskNetwork_sendTaskList(cid)
    local cache = TaskCache_getPlayerCache(cid)
    local category = TaskRank_getPlayerCategory(cid)
    local playerLevel = getPlayerLevel(cid)
    local playerPoints = TaskStorage_getPlayerPoints(cid)

    local allTasks = {}
    local playerTasks = {}

    for taskId, task in pairs(TASKS) do
        if task.category == category then
            local taskData = {
                id = taskId,
                name = task.name,
                category = task.category,
                type = task.type,
                difficulty = task.difficulty,
                levelRequired = task.levelRequired,
                rankRequired = task.rankRequired,
                kills = task.killsRequired,
                exp = task.experience,
                money = task.money,
                points = task.points,
                rewards = task.rewards,
                delivery = task.delivery,
                monsters = task.monsters,
                lookType = task.lookType,
                monsterDetails = task.monsterDetails,
                image = task.image
            }

            -- Add monster extra data
            if task.monsters and #task.monsters > 0 then
                local monsterExtra = {}
                for _, mName in ipairs(task.monsters) do
                    local data = TaskMonsters_getData(mName)
                    if data then
                        table.insert(monsterExtra, data)
                    end
                end
                if #monsterExtra > 0 then
                    taskData.monsterExtra = monsterExtra
                end

                -- Add spawn info for first monster
                local spawns = TaskSpawn_getSpawns(task.monsters[1])
                if spawns and #spawns > 0 then
                    taskData.spawns = spawns
                    taskData.encounterChance = TaskSpawn_getEncounterChance(task.monsters[1])
                    taskData.primaryArea = TaskSpawn_getPrimaryArea(task.monsters[1])
                end
            end

            local showLocked = false
            if playerLevel < task.levelRequired then
                showLocked = true
            end
            if playerPoints < task.rankRequired then
                showLocked = true
            end
            taskData.locked = showLocked

            table.insert(allTasks, taskData)

            local playerTask = cache[taskId]
            if playerTask and playerTask.kills and playerTask.kills > 0 then
                local playerTaskData = {
                    id = taskId,
                    name = task.name,
                    kills = task.killsRequired,
                    done = math.min(playerTask.kills, task.killsRequired),
                    exp = task.experience,
                    points = task.points,
                    completed = playerTask.completed,
                    rewarded = playerTask.rewarded
                }
                table.insert(playerTasks, playerTaskData)
            end
        end
    end

    local rankName, rankColor, rankPoints = TaskRank_getPlayerRank(cid, category)
    local nextRankName, pointsToNext, pointsInThisRank, pointsToNextMax = TaskRank_getNextRank(cid, category)

    local rankTable = TaskRank_getTableForCategory(category)
    local _, rankIdx = TaskRank_getRankByPoints(category, playerPoints)
    local currentRank = rankTable[rankIdx]
    local pointsPerDifficulty = currentRank and currentRank.pointsPerDifficulty or { easy = 10, medium = 25, hard = 50, elite = 100 }

    local response = {
        allTasks = allTasks,
        playerTasks = playerTasks,
        rank = {
            name = rankName,
            color = rankColor,
            points = rankPoints,
            nextRank = nextRankName,
            pointsToNext = pointsToNext,
            pointsInThisRank = pointsInThisRank,
            pointsToNextMax = pointsToNextMax,
            category = category,
            pointsPerDifficulty = pointsPerDifficulty
        }
    }

    TaskNetwork_sendJSON(cid, response)
end

function TaskNetwork_sendTaskUpdate(cid, taskId, kills, killsRequired, completed)
    local response = {
        update = {
            taskId = taskId,
            kills = kills,
            killsRequired = killsRequired,
            completed = completed
        }
    }
    TaskNetwork_sendJSON(cid, response)
end

function TaskNetwork_sendCompletePopup(cid, taskId, taskConfig)
    local actualPoints = TaskRank_getPointsForDifficulty(cid, taskConfig.difficulty)
    local response = {
        complete = {
            taskId = taskId,
            name = taskConfig.name,
            points = actualPoints or taskConfig.points,
            exp = taskConfig.experience,
            money = taskConfig.money,
            rewards = taskConfig.rewards
        }
    }
    TaskNetwork_sendJSON(cid, response)
end

function TaskNetwork_sendMessage(cid, message, color)
    if not color then color = "white" end
    local response = {
        message = message,
        color = color
    }
    TaskNetwork_sendJSON(cid, response)
end

function TaskNetwork_sendRankUpdate(cid)
    local category = TaskRank_getPlayerCategory(cid)
    local rankName, rankColor, rankPoints = TaskRank_getPlayerRank(cid, category)
    local nextRankName, pointsToNext, pointsInThisRank, pointsToNextMax = TaskRank_getNextRank(cid, category)

    local rankTable = TaskRank_getTableForCategory(category)
    local _, rankIdx = TaskRank_getRankByPoints(category, rankPoints)
    local currentRank = rankTable[rankIdx]
    local pointsPerDifficulty = currentRank and currentRank.pointsPerDifficulty or { easy = 10, medium = 25, hard = 50, elite = 100 }

    local response = {
        rankUpdate = {
            name = rankName,
            color = rankColor,
            points = rankPoints,
            nextRank = nextRankName,
            pointsToNext = pointsToNext,
            pointsInThisRank = pointsInThisRank,
            pointsToNextMax = pointsToNextMax,
            category = category,
            pointsPerDifficulty = pointsPerDifficulty
        }
    }
    TaskNetwork_sendJSON(cid, response)
end

function TaskNetwork_handleAction(cid, data)
    if not data or not data.action then return end

    local action = data.action

    if action == "info" then
        TaskNetwork_sendTaskList(cid)
    elseif action == "start" then
        if data.taskId then
            TaskCore_startTask(cid, data.taskId)
        end
    elseif action == "cancel" then
        if data.taskId then
            TaskCore_abortTask(cid, data.taskId)
        end
    elseif action == "complete" then
        if data.taskId then
            TaskCore_claimTask(cid, data.taskId)
        end
    elseif action == "hide" then
    end
end
