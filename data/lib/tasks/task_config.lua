TASKS = {
    -- ============================================================
    -- DRAGON BALL - KILL TASKS
    -- ============================================================
    db_raditz_kill = {
        id = "db_raditz_kill",
        name = "Raditz Hunter",
        lookType = 1,
        category = "dragonball",
        type = "kill",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Small Goku" },
        killsRequired = 100,
        points = 50,
        experience = 500000,
        money = 20000,
        rewards = {
            items = { { 2160, 10 }, { 2494, 1 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Small Goku", level = 10, size = "Small", location = "West Plains", probability = 85 }
        }
    },

    db_nappa_kill = {
        id = "db_nappa_kill",
        name = "Nappa Hunter",
        lookType = 2,
        category = "dragonball",
        type = "kill",
        difficulty = "easy",
        levelRequired = 30,
        rankRequired = 0,
        monsters = { "Nappa" },
        killsRequired = 150,
        points = 75,
        experience = 1000000,
        money = 50000,
        image = "images/tasks/nappa_spawn.png", -- opcional: imagem estatica do mapa
        rewards = {
            items = { { 2160, 20 }, { 2494, 2 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Nappa", level = 30, size = "Large", location = "East Desert", probability = 40 }
        }
    },

    db_sayajin_elite_kill = {
        id = "db_sayajin_elite_kill",
        name = "Elite Saiyajin",
        lookType = 3,
        category = "dragonball",
        type = "kill",
        difficulty = "medium",
        levelRequired = 60,
        rankRequired = 201,
        monsters = { "Elite Saiyajin", "Saiyajin Warrior" },
        killsRequired = 300,
        points = 150,
        experience = 3000000,
        money = 100000,
        rewards = {
            items = { { 2160, 30 }, { 2494, 3 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Elite Saiyajin",   level = 60, size = "Large",  location = "East Desert", probability = 35 },
            { name = "Saiyajin Warrior", level = 40, size = "Medium", location = "East Desert", probability = 50 }
        }
    },

    db_freeza_kill = {
        id = "db_freeza_kill",
        name = "Freeza Hunter",
        lookType = 4,
        category = "dragonball",
        type = "kill",
        difficulty = "hard",
        levelRequired = 100,
        rankRequired = 501,
        monsters = { "Freeza", "Freeza Final Form" },
        killsRequired = 500,
        points = 300,
        experience = 8000000,
        money = 200000,
        rewards = {
            items = { { 2160, 50 }, { 2494, 5 }, { 56386, 10 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Freeza",            level = 100, size = "Medium", location = "North Frozen Tundra", probability = 30 },
            { name = "Freeza Final Form", level = 120, size = "Medium", location = "North Frozen Tundra", probability = 15 }
        }
    },

    db_cell_kill = {
        id = "db_cell_kill",
        name = "Cell Hunter",
        lookType = 5,
        category = "dragonball",
        type = "kill",
        difficulty = "hard",
        levelRequired = 150,
        rankRequired = 751,
        monsters = { "Cell", "Cell Perfect" },
        killsRequired = 500,
        points = 400,
        experience = 15000000,
        money = 500000,
        rewards = {
            items = { { 2160, 75 }, { 2494, 8 }, { 56386, 20 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Cell",         level = 150, size = "Large", location = "Cell Games Arena", probability = 25 },
            { name = "Cell Perfect", level = 180, size = "Large", location = "Cell Games Arena", probability = 10 }
        }
    },

    db_majinbuu_kill = {
        id = "db_majinbuu_kill",
        name = "Majin Boo Hunter",
        lookType = 6,
        category = "dragonball",
        type = "kill",
        difficulty = "elite",
        levelRequired = 200,
        rankRequired = 1501,
        monsters = { "Majin Boo", "Super Boo", "Kid Boo" },
        killsRequired = 1000,
        points = 600,
        experience = 30000000,
        money = 1000000,
        rewards = {
            items = { { 2160, 100 }, { 2494, 10 }, { 56386, 50 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Majin Boo", level = 200, size = "Medium", location = "South Dark Mountains", probability = 20 },
            { name = "Super Boo", level = 230, size = "Large",  location = "South Dark Mountains", probability = 15 },
            { name = "Kid Boo",   level = 250, size = "Small",  location = "Supreme Kai Planet",   probability = 10 }
        }
    },

    db_beerus_kill = {
        id = "db_beerus_kill",
        name = "Bills Hunter",
        lookType = 7,
        category = "dragonball",
        type = "kill",
        difficulty = "elite",
        levelRequired = 300,
        rankRequired = 3001,
        monsters = { "Bills", "Whis" },
        killsRequired = 1500,
        points = 1000,
        experience = 50000000,
        money = 2000000,
        rewards = {
            items = { { 2160, 200 }, { 2494, 20 }, { 56386, 100 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Bills", level = 300, size = "Medium", location = "God of Destruction Planet", probability = 10 },
            { name = "Whis",  level = 350, size = "Medium", location = "God of Destruction Planet", probability = 5 }
        }
    },

    db_jiren_kill = {
        id = "db_jiren_kill",
        name = "Jiren Hunter",
        lookType = 8,
        category = "dragonball",
        type = "kill",
        difficulty = "elite",
        levelRequired = 500,
        rankRequired = 5001,
        monsters = { "Jiren" },
        killsRequired = 2000,
        points = 1500,
        experience = 100000000,
        money = 5000000,
        rewards = {
            items = { { 2160, 500 }, { 2494, 50 }, { 56386, 200 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Jiren", level = 500, size = "Large", location = "World of Void", probability = 5 }
        }
    },

    -- ============================================================
    -- DRAGON BALL - DELIVERY TASKS
    -- ============================================================
    db_dragon_balls = {
        id = "db_dragon_balls",
        name = "Dragon Balls",
        lookType = 1,
        category = "dragonball",
        type = "delivery",
        difficulty = "medium",
        levelRequired = 50,
        rankRequired = 201,
        monsters = {},
        killsRequired = 0,
        points = 200,
        experience = 5000000,
        money = 100000,
        rewards = {
            items = { { 2160, 50 }, { 2494, 5 }, { 56386, 25 } }
        },
        delivery = {
            enabled = true,
            itemId = 5890,
            count = 7
        }
    },

    db_senzu_beans = {
        id = "db_senzu_beans",
        name = "Senzu Beans",
        lookType = 1,
        category = "dragonball",
        type = "delivery",
        difficulty = "easy",
        levelRequired = 20,
        rankRequired = 0,
        monsters = {},
        killsRequired = 0,
        points = 30,
        experience = 500000,
        money = 25000,
        rewards = {
            items = { { 2160, 15 }, { 2494, 1 } }
        },
        delivery = {
            enabled = true,
            itemId = 5891,
            count = 25
        }
    },

    -- ============================================================
    -- DRAGON BALL - HYBRID TASKS
    -- ============================================================
    db_saiyan_warrior_hybrid = {
        id = "db_saiyan_warrior_hybrid",
        name = "Full Saiyajin Warrior",
        lookType = 3,
        category = "dragonball",
        type = "hybrid",
        difficulty = "medium",
        levelRequired = 80,
        rankRequired = 501,
        monsters = { "Saiyajin Warrior", "Elite Saiyajin" },
        killsRequired = 250,
        points = 250,
        experience = 5000000,
        money = 150000,
        rewards = {
            items = { { 2160, 40 }, { 2494, 4 }, { 56386, 15 } }
        },
        delivery = {
            enabled = true,
            itemId = 5892,
            count = 10
        },
        monsterDetails = {
            { name = "Saiyajin Warrior", level = 40, size = "Medium", location = "East Desert", probability = 50 },
            { name = "Elite Saiyajin",   level = 60, size = "Large",  location = "East Desert", probability = 35 }
        }
    },

    -- ============================================================
    -- DRAGON BALL - BOSS TASKS
    -- ============================================================
    db_frieza_boss = {
        id = "db_frieza_boss",
        name = "Emperor Freeza",
        lookType = 4,
        category = "dragonball",
        type = "boss",
        difficulty = "hard",
        levelRequired = 120,
        rankRequired = 751,
        monsters = { "Freeza Boss" },
        killsRequired = 10,
        points = 500,
        experience = 20000000,
        money = 500000,
        rewards = {
            items = { { 2160, 100 }, { 2494, 10 }, { 56386, 50 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Freeza Boss", level = 120, size = "Large", location = "Freeza's Ship", probability = 100 }
        }
    },

    -- ============================================================
    -- DRAGON BALL - SAGA TASKS (chain)
    -- ============================================================
    db_saga_saiyan_1 = {
        id = "db_saga_saiyan_1",
        name = "Saga Saiyajin: Raditz",
        lookType = 1,
        category = "dragonball",
        type = "saga",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Raditz" },
        killsRequired = 50,
        points = 25,
        experience = 250000,
        money = 10000,
        rewards = { items = { { 2160, 5 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Raditz", level = 10, size = "Medium", location = "West Plains", probability = 60 }
        },
        sagaNext = "db_saga_saiyan_2"
    },

    db_saga_saiyan_2 = {
        id = "db_saga_saiyan_2",
        name = "Saga Saiyajin: Nappa",
        lookType = 2,
        category = "dragonball",
        type = "saga",
        difficulty = "easy",
        levelRequired = 30,
        rankRequired = 0,
        monsters = { "Nappa" },
        killsRequired = 100,
        points = 50,
        experience = 500000,
        money = 25000,
        rewards = { items = { { 2160, 10 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Nappa", level = 30, size = "Large", location = "East Desert", probability = 40 }
        },
        requiredTask = "db_saga_saiyan_1",
        sagaNext = "db_saga_saiyan_3"
    },

    db_saga_saiyan_3 = {
        id = "db_saga_saiyan_3",
        name = "Saga Saiyajin: Vegeta",
        lookType = 3,
        category = "dragonball",
        type = "saga",
        difficulty = "medium",
        levelRequired = 50,
        rankRequired = 201,
        monsters = { "Vegeta" },
        killsRequired = 200,
        points = 100,
        experience = 1000000,
        money = 50000,
        rewards = { items = { { 2160, 20 }, { 2494, 2 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Vegeta", level = 50, size = "Medium", location = "East Desert", probability = 25 }
        },
        requiredTask = "db_saga_saiyan_2"
    },

    -- ============================================================
    -- DRAGON BALL - DAILY TASKS
    -- ============================================================
    db_daily_small_goku = {
        id = "db_daily_small_goku",
        name = "Daily: Small Goku",
        lookType = 1,
        category = "dragonball",
        type = "daily",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Small Goku" },
        killsRequired = 50,
        points = 10,
        experience = 100000,
        money = 5000,
        rewards = { items = { { 2160, 5 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Small Goku", level = 10, size = "Small", location = "West Plains", probability = 85 }
        },
        daily = { enabled = true, resetHours = 24 }
    },

    db_daily_freeza = {
        id = "db_daily_freeza",
        name = "Daily: Freeza",
        lookType = 4,
        category = "dragonball",
        type = "daily",
        difficulty = "hard",
        levelRequired = 100,
        rankRequired = 501,
        monsters = { "Freeza" },
        killsRequired = 100,
        points = 25,
        experience = 500000,
        money = 50000,
        rewards = { items = { { 2160, 15 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Freeza", level = 100, size = "Medium", location = "North Frozen Tundra", probability = 30 }
        },
        daily = { enabled = true, resetHours = 24 }
    },

    -- ============================================================
    -- DRAGON BALL - REPEATABLE TASKS
    -- ============================================================
    db_repeat_small_goku = {
        id = "db_repeat_small_goku",
        name = "Repeatable: Small Goku",
        lookType = 1,
        category = "dragonball",
        type = "repeatable",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Small Goku" },
        killsRequired = 100,
        points = 25,
        experience = 250000,
        money = 10000,
        rewards = { items = { { 2160, 5 }, { 2494, 1 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Small Goku", level = 10, size = "Small", location = "West Plains", probability = 85 }
        },
        repeatable = true
    },

    db_repeat_nappa = {
        id = "db_repeat_nappa",
        name = "Repeatable: Nappa",
        lookType = 2,
        category = "dragonball",
        type = "repeatable",
        difficulty = "easy",
        levelRequired = 30,
        rankRequired = 0,
        monsters = { "Nappa" },
        killsRequired = 150,
        points = 50,
        experience = 500000,
        money = 25000,
        rewards = { items = { { 2160, 10 }, { 2494, 2 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Nappa", level = 30, size = "Large", location = "East Desert", probability = 40 }
        },
        repeatable = true
    },

    -- ============================================================
    -- DRAGON BALL - UNIQUE TASKS
    -- ============================================================
    db_unique_beerus = {
        id = "db_unique_beerus",
        name = "Unique: Bills Awakening",
        lookType = 7,
        category = "dragonball",
        type = "unique",
        difficulty = "elite",
        levelRequired = 400,
        rankRequired = 10001,
        monsters = { "Bills" },
        killsRequired = 1,
        points = 5000,
        experience = 500000000,
        money = 10000000,
        rewards = { items = { { 2160, 1000 }, { 2494, 100 }, { 56386, 500 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Bills", level = 300, size = "Medium", location = "God of Destruction Planet", probability = 100 }
        },
        unique = true
    },

    -- ============================================================
    -- BLEACH - KILL TASKS
    -- ============================================================
    bleach_hollow_kill = {
        id = "bleach_hollow_kill",
        name = "Hollows",
        lookType = 2348,
        category = "bleach",
        type = "kill",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Hollow", "Lesser Hollow" },
        killsRequired = 100,
        points = 50,
        experience = 500000,
        money = 20000,
        rewards = {
            items = { { 2160, 10 }, { 2494, 1 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Hollow",        level = 10, size = "Medium", location = "Shadow Realm", probability = 50 },
            { name = "Lesser Hollow", level = 5,  size = "Small",  location = "Dark Forest",  probability = 60 }
        }
    },

    bleach_shinigami_kill = {
        id = "bleach_shinigami_kill",
        name = "Shinigami",
        lookType = 12,
        category = "bleach",
        type = "kill",
        difficulty = "medium",
        levelRequired = 60,
        rankRequired = 201,
        monsters = { "Shinigami", "Soul Reaper" },
        killsRequired = 300,
        points = 150,
        experience = 3000000,
        money = 100000,
        rewards = {
            items = { { 2160, 30 }, { 2494, 3 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Shinigami",   level = 60, size = "Medium", location = "Soul Society", probability = 35 },
            { name = "Soul Reaper", level = 70, size = "Medium", location = "Soul Society", probability = 25 }
        }
    },

    bleach_arrancar_kill = {
        id = "bleach_arrancar_kill",
        name = "Arrancar Hunter",
        lookType = 13,
        category = "bleach",
        type = "kill",
        difficulty = "hard",
        levelRequired = 100,
        rankRequired = 751,
        monsters = { "Arrancar", "Arrancar Elite" },
        killsRequired = 500,
        points = 300,
        experience = 8000000,
        money = 200000,
        rewards = {
            items = { { 2160, 50 }, { 2494, 5 }, { 56386, 10 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Arrancar",       level = 100, size = "Medium", location = "Hueco Mundo", probability = 30 },
            { name = "Arrancar Elite", level = 120, size = "Large",  location = "Las Noches",  probability = 15 }
        }
    },

    bleach_espada_kill = {
        id = "bleach_espada_kill",
        name = "Espada Hunter",
        lookType = 14,
        category = "bleach",
        type = "kill",
        difficulty = "elite",
        levelRequired = 200,
        rankRequired = 1501,
        monsters = { "Espada", "Espada Elite" },
        killsRequired = 1000,
        points = 600,
        experience = 30000000,
        money = 1000000,
        rewards = {
            items = { { 2160, 100 }, { 2494, 10 }, { 56386, 50 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Espada",       level = 200, size = "Medium", location = "Las Noches",             probability = 15 },
            { name = "Espada Elite", level = 250, size = "Large",  location = "Las Noches Throne Room", probability = 8 }
        }
    },

    bleach_captain_kill = {
        id = "bleach_captain_kill",
        name = "Captain Hunter",
        lookType = 15,
        category = "bleach",
        type = "kill",
        difficulty = "elite",
        levelRequired = 350,
        rankRequired = 5001,
        monsters = { "Captain", "Captain Commander" },
        killsRequired = 1500,
        points = 1000,
        experience = 50000000,
        money = 2000000,
        rewards = {
            items = { { 2160, 200 }, { 2494, 20 }, { 56386, 100 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Captain",           level = 350, size = "Medium", location = "Seireitei",    probability = 12 },
            { name = "Captain Commander", level = 400, size = "Medium", location = "Seireitei HQ", probability = 5 }
        }
    },

    bleach_yhwach_kill = {
        id = "bleach_yhwach_kill",
        name = "Yhwach Hunter",
        lookType = 16,
        category = "bleach",
        type = "kill",
        difficulty = "elite",
        levelRequired = 500,
        rankRequired = 10001,
        monsters = { "Yhwach" },
        killsRequired = 2000,
        points = 1500,
        experience = 100000000,
        money = 5000000,
        rewards = {
            items = { { 2160, 500 }, { 2494, 50 }, { 56386, 200 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Yhwach", level = 500, size = "Large", location = "Wandenreich", probability = 5 }
        }
    },

    -- ============================================================
    -- BLEACH - DELIVERY TASKS
    -- ============================================================
    bleach_reiryoku = {
        id = "bleach_reiryoku",
        name = "Reiryoku Collection",
        lookType = 11,
        category = "bleach",
        type = "delivery",
        difficulty = "medium",
        levelRequired = 50,
        rankRequired = 201,
        monsters = {},
        killsRequired = 0,
        points = 200,
        experience = 5000000,
        money = 100000,
        rewards = {
            items = { { 2160, 50 }, { 2494, 5 }, { 56386, 25 } }
        },
        delivery = {
            enabled = true,
            itemId = 5893,
            count = 25
        }
    },

    -- ============================================================
    -- BLEACH - HYBRID TASKS
    -- ============================================================
    bleach_hunt_hybrid = {
        id = "bleach_hunt_hybrid",
        name = "Full Hunt",
        lookType = 13,
        category = "bleach",
        type = "hybrid",
        difficulty = "hard",
        levelRequired = 120,
        rankRequired = 751,
        monsters = { "Arrancar", "Hollow" },
        killsRequired = 300,
        points = 350,
        experience = 8000000,
        money = 200000,
        rewards = {
            items = { { 2160, 60 }, { 2494, 6 }, { 56386, 20 } }
        },
        delivery = {
            enabled = true,
            itemId = 5894,
            count = 15
        },
        monsterDetails = {
            { name = "Arrancar", level = 100, size = "Medium", location = "Hueco Mundo",  probability = 30 },
            { name = "Hollow",   level = 10,  size = "Medium", location = "Shadow Realm", probability = 50 }
        }
    },

    -- ============================================================
    -- BLEACH - BOSS TASKS
    -- ============================================================
    bleach_aizen_boss = {
        id = "bleach_aizen_boss",
        name = "Sosuke Aizen",
        lookType = 17,
        category = "bleach",
        type = "boss",
        difficulty = "elite",
        levelRequired = 200,
        rankRequired = 1501,
        monsters = { "Aizen Boss" },
        killsRequired = 10,
        points = 500,
        experience = 30000000,
        money = 1000000,
        rewards = {
            items = { { 2160, 150 }, { 2494, 15 }, { 56386, 50 } }
        },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Aizen Boss", level = 200, size = "Medium", location = "Las Noches Throne Room", probability = 100 }
        }
    },

    -- ============================================================
    -- BLEACH - DAILY TASKS
    -- ============================================================
    bleach_daily_hollow = {
        id = "bleach_daily_hollow",
        name = "Daily: Hollows",
        lookType = 11,
        category = "bleach",
        type = "daily",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Hollow" },
        killsRequired = 50,
        points = 10,
        experience = 100000,
        money = 5000,
        rewards = { items = { { 2160, 5 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Hollow", level = 10, size = "Medium", location = "Shadow Realm", probability = 50 }
        },
        daily = { enabled = true, resetHours = 24 }
    },

    -- ============================================================
    -- BLEACH - REPEATABLE TASKS
    -- ============================================================
    bleach_repeat_hollow = {
        id = "bleach_repeat_hollow",
        name = "Repeatable: Hollows",
        lookType = 11,
        category = "bleach",
        type = "repeatable",
        difficulty = "easy",
        levelRequired = 10,
        rankRequired = 0,
        monsters = { "Hollow" },
        killsRequired = 100,
        points = 25,
        experience = 250000,
        money = 10000,
        rewards = { items = { { 2160, 5 }, { 2494, 1 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Hollow", level = 10, size = "Medium", location = "Shadow Realm", probability = 50 }
        },
        repeatable = true
    },

    -- ============================================================
    -- BLEACH - UNIQUE TASKS
    -- ============================================================
    bleach_unique_yhwach = {
        id = "bleach_unique_yhwach",
        name = "Unique: The Quincy Father",
        lookType = 16,
        category = "bleach",
        type = "unique",
        difficulty = "elite",
        levelRequired = 500,
        rankRequired = 20001,
        monsters = { "Yhwach" },
        killsRequired = 1,
        points = 5000,
        experience = 500000000,
        money = 10000000,
        rewards = { items = { { 2160, 1000 }, { 2494, 100 }, { 56386, 500 } } },
        delivery = { enabled = false },
        monsterDetails = {
            { name = "Yhwach", level = 500, size = "Large", location = "Wandenreich", probability = 100 }
        },
        unique = true
    }
}

TASK_DIFFICULTY_ORDER = { "easy", "medium", "hard", "elite" }

TASK_CATEGORIES = { "dragonball", "bleach" }
