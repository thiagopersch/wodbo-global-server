dofile("data/lib/tasks/task_core.lua")

function onKill(cid, target, lastHit)
    print("[TaskKill] onKill called cid=" .. cid .. " target=" .. tostring(target) .. " isMonster=" .. tostring(isMonster(target)))
    if not isPlayer(cid) or not isMonster(target) then return true end

    local master = getCreatureMaster(target)
    if master ~= target and isPlayer(master) then
        print("[TaskKill] target is a player summon, skipping")
        return true
    end

    local monsterName = getCreatureName(target)
    print("[TaskKill] monsterName='" .. tostring(monsterName) .. "'")
    if monsterName then
        print("[TaskKill] Calling TaskKill_onKill with monsterName=" .. monsterName)
        TaskKill_onKill(cid, monsterName)
        print("[TaskKill] TaskKill_onKill returned")
    end

    return true
end
