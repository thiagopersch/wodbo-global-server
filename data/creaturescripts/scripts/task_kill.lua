dofile("data/lib/tasks/task_core.lua")

function onKill(cid, target, lastHit)
    if not isPlayer(cid) or not isMonster(target) then return true end

    if getCreatureMaster(target) ~= target then return true end

    local monsterName = getCreatureName(target)
    if monsterName then
        TaskKill_onKill(cid, monsterName)
    end

    return true
end
