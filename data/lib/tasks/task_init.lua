function TaskInit_createTables()
    local result = db.getResult("SELECT name FROM sqlite_master WHERE type='table' AND name='player_tasks'")
    if result:getID() ~= -1 then
        result:free()
        return
    end

    db.query("CREATE TABLE IF NOT EXISTS player_tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, player_id INTEGER NOT NULL, task_id TEXT NOT NULL, kills INTEGER DEFAULT 0, completed INTEGER DEFAULT 0, rewarded INTEGER DEFAULT 0, started_at DATETIME DEFAULT CURRENT_TIMESTAMP, UNIQUE(player_id, task_id))")
    db.query("CREATE TABLE IF NOT EXISTS player_task_points (player_id INTEGER PRIMARY KEY, points INTEGER DEFAULT 0, total_completed INTEGER DEFAULT 0)")

    print("[Task System] Database tables created successfully.")
end

local ok = pcall(TaskInit_createTables)
if not ok then
    print("[Task System] Warning: Could not create tables on mod load")
end
