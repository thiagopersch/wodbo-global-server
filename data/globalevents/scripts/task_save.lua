json = dofile("data/lib/json.lua")
dofile("data/lib/tasks/task_config.lua")
dofile("data/lib/tasks/task_cache.lua")
dofile("data/lib/tasks/task_storage.lua")
dofile("data/lib/tasks/task_rank.lua")
dofile("data/lib/tasks/task_rewards.lua")
dofile("data/lib/tasks/task_kill.lua")
dofile("data/lib/tasks/task_delivery.lua")
dofile("data/lib/tasks/task_core.lua")
dofile("data/lib/tasks/task_network.lua")
dofile("data/lib/tasks/task_npc.lua")

function onThink(interval)
    TaskStorage_saveAll()
    return true
end
