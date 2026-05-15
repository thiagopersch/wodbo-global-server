dofile("data/lib/tasks/task_npc.lua")

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then return false end

    local user = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
    local lower = msg:lower()

    if lower == "tasks" or lower == "task" or lower == "missao" or lower == "missoes" then
        local available = TaskNPC_listAvailable(cid)
        local active = TaskCore_getActiveTasks(cid)
        local completed = TaskCore_getCompletedTasks(cid)

        local response = available

        if #active > 0 then
            local names = {}
            for _, tid in ipairs(active) do
                local cfg = TASKS[tid]
                if cfg then
                    local kills = TaskCache_getPlayerTask(cid, tid)
                    local killStr = ""
                    if kills and cfg.killsRequired > 0 then
                        killStr = " (" .. kills.kills .. "/" .. cfg.killsRequired .. ")"
                    end
                    table.insert(names, cfg.name .. killStr)
                end
            end
            response = response .. "\nActive: " .. table.concat(names, ", ") .. "."
        end

        if #completed > 0 then
            local names = {}
            for _, tid in ipairs(completed) do
                local cfg = TASKS[tid]
                if cfg then table.insert(names, cfg.name) end
            end
            response = response .. "\nReady to deliver: " .. table.concat(names, ", ") .. ". Say {deliver} to claim rewards."
        end

        npcHandler:say(response, cid)
        talkState[user] = 1

    elseif lower == "deliver" or lower == "entrega" or lower == "entregar" or lower == "reward" or lower == "receber" then
        local completed = TaskCore_getCompletedTasks(cid)

        if #completed == 0 then
            npcHandler:say("You don't have any completed tasks to deliver.", cid)
            return true
        end

        if #completed == 1 then
            local success = TaskDelivery_deliver(cid, completed[1])
            if success then
                local cfg = TASKS[completed[1]]
                npcHandler:say("Great work! Here are your rewards for '" .. (cfg and cfg.name or "task") .. "'!", cid)
            end
            return true
        end

        local names = {}
        for _, tid in ipairs(completed) do
            local cfg = TASKS[tid]
            if cfg then table.insert(names, cfg.name) end
        end
        npcHandler:say("Which task would you like to deliver? " .. table.concat(names, ", "), cid)
        talkState[user] = 2

    elseif talkState[user] == 2 then
        local completed = TaskCore_getCompletedTasks(cid)
        for _, tid in ipairs(completed) do
            local cfg = TASKS[tid]
            if cfg and cfg.name:lower() == lower then
                local success = TaskDelivery_deliver(cid, tid)
                if success then
                    npcHandler:say("Great work! Here are your rewards for '" .. cfg.name .. "'!", cid)
                end
                talkState[user] = 0
                return true
            end
        end
        npcHandler:say("I don't recognize that task name.", cid)
        talkState[user] = 0

    elseif lower == "rank" or lower == "elo" then
        local info = TaskNPC_getRankInfo(cid)
        npcHandler:say(info, cid)

    elseif lower == "daily" or lower == "diaria" or lower == "diario" then
        local success = TaskNPC_startDaily(cid)
        if success then
            npcHandler:say("I've assigned you a daily task. Check your tasks panel for details!", cid)
        end

    elseif lower == "no" or lower == "nao" or lower == "não" then
        selfSay("Come back anytime!", cid)
        talkState[user] = 0
        npcHandler:releaseFocus(cid)
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
