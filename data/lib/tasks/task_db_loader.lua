if not json then json = dofile("data/lib/json.lua") end

TASK_DIFFICULTY_ORDER = TASK_DIFFICULTY_ORDER or { "easy", "medium", "hard", "elite" }
TASK_CATEGORIES = TASK_CATEGORIES or { "dragonball", "bleach" }

-- Carrega o catálogo de tasks da tabela `task_definitions` (fonte de verdade: portal web,
-- administrado em `/admin/tasks`) e monta o global TASKS no mesmo formato que o antigo
-- data/lib/tasks/task_config.lua estático produzia — o resto do sistema de tasks
-- (task_core/task_kill/task_rewards/task_delivery/task_network/...) não muda.
-- Chamado uma vez no boot (dofile lazy, como antes) e recarregado periodicamente pelo
-- globalevent `task_save.lua` para refletir edições feitas no portal sem reiniciar o servidor.
function TaskConfig_reload()
    local resultId = db.getResult(
        "SELECT `id`, `name`, `look_type`, `category`, `type`, `difficulty`, `level_required`, " ..
        "`rank_required`, `kills_required`, `points`, `experience`, `money`, `published`, " ..
        "`monsters`, `rewards`, `delivery`, `monster_details` FROM `task_definitions`")

    local tasks = {}
    local count = 0

    if resultId ~= -1 then
        repeat
            if result.getDataInt(resultId, "published") == 1 then
                local id = result.getDataString(resultId, "id")

                local okMonsters, monsters = pcall(json.decode, result.getDataString(resultId, "monsters") or "[]")
                local okRewards, rewards = pcall(json.decode, result.getDataString(resultId, "rewards") or "{}")
                local okDelivery, delivery = pcall(json.decode, result.getDataString(resultId, "delivery") or "{}")
                local okDetails, monsterDetails =
                    pcall(json.decode, result.getDataString(resultId, "monster_details") or "[]")

                tasks[id] = {
                    id = id,
                    name = result.getDataString(resultId, "name"),
                    lookType = result.getDataInt(resultId, "look_type"),
                    category = result.getDataString(resultId, "category"),
                    type = result.getDataString(resultId, "type"),
                    difficulty = result.getDataString(resultId, "difficulty"),
                    levelRequired = result.getDataInt(resultId, "level_required"),
                    rankRequired = result.getDataInt(resultId, "rank_required"),
                    monsters = okMonsters and monsters or {},
                    killsRequired = result.getDataInt(resultId, "kills_required"),
                    points = result.getDataInt(resultId, "points"),
                    experience = result.getDataInt(resultId, "experience"),
                    money = result.getDataInt(resultId, "money"),
                    rewards = okRewards and rewards or { items = {} },
                    delivery = okDelivery and delivery or { enabled = false },
                    monsterDetails = okDetails and monsterDetails or {},
                }
                count = count + 1
            end
        until not result.next(resultId)
        result.free(resultId)
    end

    TASKS = tasks
    print("[Task System] Loaded " .. count .. " tasks from database.")
end

if not TASKS then
    TaskConfig_reload()
end
