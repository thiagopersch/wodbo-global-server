domodlib('task_func')
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end

function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end

function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then return false end
    local talkUser, msg, str, rst = NPCHANDLER_CONVbehavior == CONVERSATION_DEFAULT and 0 or cid, msg:lower(), "", ""
    local task, daily, hours = getTaskMission(cid), getDailyTaskMission(cid), 24
    if isInArray({ "task", "tasks", "missao", "mission" }, msg) then
        if task_sys[task] then
            if getPlayerStorageValue(cid, task_sys[task].start) <= 0 then
                if getPlayerLevel(cid) >= task_sys[task].level then
                    setPlayerStorageValue(cid, task_sys[task].start, 1)
                    npcHandler:say(
                    "[Task System] Congratulations, you are now participating in the Task " ..
                    task_sys[task].name ..
                    " and must kill " ..
                    task_sys[task].count ..
                    " from this list: " ..
                    getMonsterFromList(task_sys[task].monsters_list) ..
                    ". " ..
                    (#task_sys[task].items > 0 and "Oh, and please bring me " .. getItemsFromList(task_sys[task].items) .. " for me." or "") ..
                    "", cid)
                else
                    npcHandler:say(
                    "Sorry, but you need to reach level " ..
                    task_sys[task].level .. " to be able to participate in the Task " .. task_sys[task].name .. "!", cid)
                end
            else
                npcHandler:say(
                "Sorry, but you are currently on the task " ..
                task_sys[task].name .. ". You can {deliver} if you've already finished.", cid)
            end
        else
            npcHandler:say("Sorry, but for now I don't have any tasks for you!", cid)
        end
    elseif isInArray({ "diaria", "daili", "daily", "dayli", "diario" }, msg) then
        if getPlayerStorageValue(cid, task_sys_storages[6]) - os.time() > 0 then
            npcHandler:say(
            "Sorry, you must wait until " ..
            os.date("%d %B %Y %X", getPlayerStorageValue(cid, task_sys_storages[6])) .. " to start a new daily task!",
                cid)
            return true
        elseif daily_task[daily] and
            getPlayerStorageValue(cid, task_sys_storages[5]) >=
            daily_task[daily].count then
            npcHandler:say("Sorry, you have a task to {deliver}!", cid)
            return true
        end
        local r = doRandomDailyTask(cid)
        if r == 0 then
            npcHandler:say("Sorry, but you have no level to complete any daily task.", cid)
            return true
        end
        setPlayerStorageValue(cid, task_sys_storages[4], r)
        setPlayerStorageValue(cid, task_sys_storages[6], os.time() + hours * 3600)
        setPlayerStorageValue(cid, task_sys_storages[7], 1)
        setPlayerStorageValue(cid, task_sys_storages[5], 0)
        local dtask = daily_task[r]
        npcHandler:say(
        "[Daily Task System] Congratulations, you are now participating in the Task Daily " ..
        dtask.name ..
        " and should kill " ..
        dtask.count ..
        " monsters on this list: " ..
        getMonsterFromList(dtask.monsters_list) ..
        " to " .. os.date("%d %B %Y %X", getPlayerStorageValue(cid, task_sys_storages[6])) .. ". Good luck!", cid)
    elseif isInArray({ "receber", "reward", "recompensa", "reportar", "entregar", "entrega", "deliver" }, msg) then
        local v, k = task_sys[task], daily_task[daily]
        if v then -- original task
            if getPlayerStorageValue(cid, v.start) > 0 then
                if getPlayerStorageValue(cid, task_sys_storages[3]) >= v.count then
                    if #v.items > 0 and not doRemoveItemsFromList(cid, v.items) then
                        npcHandler:say(
                        "Sorry, but you also need to deliver the items on this list: " .. getItemsFromList(v.items), cid)
                        return true
                    end
                    if v.exp > 0 then
                        doPlayerAddExp(cid, v.exp)
                        str = str .. "" .. (str == "" and "" or ", ") .. " " .. v.exp .. " of experience"
                    end
                    if v.points > 0 then
                        setPlayerStorageValue(cid, task_sys_storages[2], (getTaskPoints(cid) + v.points))
                        str = str .. "" .. (str == "" and "" or ", ") .. " + " .. v.points .. "task points"
                    end
                    if v.money > 0 then
                        doPlayerAddMoney(cid, v.money)
                        str = str .. "" .. (str == "" and "" or ", ") .. "" .. v.money .. " gps"
                    end
                    if table.maxn(v.reward) > 0 then
                        GiveRewardsTask(cid, v.reward)
                        str = str .. "" .. (str == "" and "" or ", ") .. "" .. getItemsFromList(v.reward)
                    end
                    npcHandler:say(
                    "Thanks for your help Rewards: " ..
                    (str == "" and "none" or "" .. str .. "") .. " for completing the task of " .. v.name, cid)
                    setPlayerStorageValue(cid, task_sys_storages[3], 0)
                    setPlayerStorageValue(cid, task_sys_storages[1], (task + 1))
                else
                    npcHandler:say(
                        "Sorry, but you haven't finished your task yet " .. v.name .. ". I need you to kill more " ..
                        (getPlayerStorageValue(cid, task_sys_storages[3]) < 0 and v.count or -(getPlayerStorageValue(cid, task_sys_storages[3]) - v.count)) ..
                        " of these terrible monsters!", cid)
                end
            end
        end
        if k then -- daily task
            if getPlayerStorageValue(cid, task_sys_storages[7]) > 0 then
                if getPlayerStorageValue(cid, task_sys_storages[5]) >= k.count then
                    if k.exp > 0 then
                        doPlayerAddExp(cid, k.exp)
                        rst = rst .. "" .. (rst == "" and "" or ", ") .. " " .. k.exp .. " of experience"
                    end
                    if k.points > 0 then
                        setPlayerStorageValue(cid, task_sys_storages[2], (getTaskPoints(cid) + k.points))
                        rst = rst .. "" .. (rst == "" and "" or ", ") .. " + " .. k.points .. "task points"
                    end
                    if k.money > 0 then
                        doPlayerAddMoney(cid, k.money)
                        rst = rst .. "" .. (rst == "" and "" or ", ") .. "" .. k.money .. " gps"
                    end
                    if table.maxn(k.reward) > 0 then
                        GiveRewardsTask(cid, k.reward)
                        rst = rst .. "" .. (rst == "" and "" or ", ") .. "" .. getItemsFromList(k.reward)
                    end
                    npcHandler:say(
                    "Thanks for your help! Rewards: " ..
                    (rst == "" and "none" or "" .. rst .. "") .. " for completing the task of " .. k.name, cid)
                    setPlayerStorageValue(cid, task_sys_storages[4], 0)
                    setPlayerStorageValue(cid, task_sys_storages[5], 0)
                    setPlayerStorageValue(cid, task_sys_storages[7], 0)
                else
                    npcHandler:say(
                    "Sorry, but you haven't finished your daily task yet. " ..
                    k.name ..
                    ". I need you to kill more " ..
                    (getPlayerStorageValue(cid, task_sys_storages[5]) < 0 and k.count or -(getPlayerStorageValue(cid, task_sys_storages[5]) - k.count)) ..
                    " of these monsters!", cid)
                end
            end
        end
    elseif msg == "no" then
        selfSay("Okay.", cid)
        talkState[talkUser] = 0
        npcHandler:releaseFocus(cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
