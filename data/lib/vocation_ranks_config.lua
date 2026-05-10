VocationRankConfig = {
  StarsPerRank = 5,
  UniversalFragmentItemIds = { 56386, 56411, 56412, 56413, 56414, 56328 }, -- All universal fragment types
  UniversalFragmentItemId = 56386,                                         -- Primary universal fragment (kept for compatibility)
  Ranks = {
    [0] = { name = "None", color = "#aaaaaa", starImage = "" },
    [1] = { name = "Bronze", color = "#cd7f32", starImage = "/images/ranks/bronze_star.png" },
    [2] = { name = "Silver", color = "#c0c0c0", starImage = "/images/ranks/silver_star.png" },
    [3] = { name = "Gold", color = "#ffd700", starImage = "/images/ranks/gold_star.png" },
    [4] = { name = "Diamond", color = "#b9f2ff", starImage = "/images/ranks/diamond_star.png" }
  },
  Vocations = {}
}

VocationRankConfig.Archetypes = {
  ["DPS"] = { damageMult = 2.5, defenseMult = 1.0 },
  ["Bruiser"] = { damageMult = 2.0, defenseMult = 1.05 },
  ["Support"] = { damageMult = 1.0, defenseMult = 1.10, manaRegenBuff = 15000 },
  ["Tank"] = { damageMult = 1.0, defenseMult = 1.20, hpRegenBuff = 15000 }
}

-- Helper to add vocation configs quickly
local function addVocation(id, archetype, maxRank, specificItemId, stats, costs)
  VocationRankConfig.Vocations[id] = {
    archetype = archetype,
    maxRank = maxRank,
    specificFragmentItemId = specificItemId,
    statsPerStar = stats,
    costs = costs
  }
end

-- DBZ Vocations (ID 0-45)
-- None (ID 0) has no config (cannot upgrade)

-- Bardock (1) - Max Rank 4 (Diamond)
addVocation(1, "DPS", 4, 49856,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Bills (2) - Max Rank 4 (Diamond)
addVocation(2, "DPS", 4, 49857,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Botamo (3) - Max Rank 3 (Gold)
addVocation(3, "Tank", 4, 49858,
  { attack = 4, defense = 8, health = 3000, mana = 500, magic = 1, distance = 4, shield = 8 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Brolly (4) - Max Rank 4 (Diamond)
addVocation(4, "DPS", 4, 49859,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Bulma (5) - Max Rank 2 (Silver)
addVocation(5, "Bruiser", 4, 49860,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Buu (6) - Max Rank 4 (Diamond)
addVocation(6, "Bruiser", 4, 49861,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- C8 (7) - Max Rank 3 (Gold)
addVocation(7, "Bruiser", 4, 49862,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- C17 (8) - Max Rank 3 (Gold)
addVocation(8, "Bruiser", 4, 49863,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- C18 (9) - Max Rank 3 (Gold)
addVocation(9, "Bruiser", 4, 49864,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Cabba (10) - Max Rank 4 (Diamond)
addVocation(10, "DPS", 4, 49865,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Cell (11) - Max Rank 4 (Diamond)
addVocation(11, "DPS", 4, 49866,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Cooler (12) - Max Rank 4 (Diamond)
addVocation(12, "DPS", 4, 49867,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Dende (13) - Max Rank 2 (Silver)
addVocation(13, "Support", 4, 49868,
  { attack = 2, defense = 8, health = 500, mana = 5000, magic = 8, distance = 2, shield = 6 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Freeza (14) - Max Rank 4 (Diamond)
addVocation(14, "Bruiser", 4, 49869,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Ginn (15) - Max Rank 4 (Diamond)
addVocation(15, "DPS", 4, 49870,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Gohan (16) - Max Rank 2 (Silver) [User Example]
addVocation(16, "Bruiser", 4, 49854,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Goku (17) - Max Rank 4 (Diamond) [User Example]
addVocation(17, "DPS", 4, 49852,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Goku Black (18) - Max Rank 4 (Diamond)
addVocation(18, "DPS", 4, 49871,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Hitto (19) - Max Rank 4 (Diamond)
addVocation(19, "DPS", 4, 49872,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Janemba (20) - Max Rank 3 (Gold)
addVocation(20, "DPS", 4, 49873,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Jiren (21) - Max Rank 4 (Diamond)
addVocation(21, "DPS", 4, 49874,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Kagome (22) - Max Rank 2 (Silver)
addVocation(22, "Bruiser", 4, 49875,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Kaio (23) - Max Rank 3 (Gold)
addVocation(23, "Bruiser", 4, 49876,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Kame (24) - Max Rank 3 (Gold)
addVocation(24, "Bruiser", 4, 49877,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- King Cold (25) - Max Rank 3 (Gold)
addVocation(25, "Bruiser", 4, 49878,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- King Vegeta (26) - Max Rank 3 (Gold)
addVocation(26, "Bruiser", 4, 49879,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Kuririn (27) - Max Rank 2 (Silver)
addVocation(27, "Bruiser", 4, 49880,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Liquir (28) - Max Rank 4 (Diamond)
addVocation(28, "DPS", 4, 49881,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Pan (29) - Max Rank 2 (Silver)
addVocation(29, "Support", 4, 49882,
  { attack = 2, defense = 6, health = 500, mana = 3000, magic = 8, distance = 2, shield = 6 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Piccolo (30) - Max Rank 1 (Bronze) [User Example]
addVocation(30, "Support", 4, 49855,
  { attack = 2, defense = 6, health = 500, mana = 3000, magic = 8, distance = 2, shield = 6 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Quitela (31) - Max Rank 4 (Diamond)
addVocation(31, "Bruiser", 4, 49883,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Raditz (32) - Max Rank 3 (Gold)
addVocation(32, "Bruiser", 4, 49884,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Shenron (33) - Max Rank 3 (Gold)
addVocation(33, "DPS", 4, 49885,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Tapion (34) - Max Rank 3 (Gold)
addVocation(34, "DPS", 4, 49886,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Trunks (35) - Max Rank 3 (Gold)
addVocation(35, "DPS", 4, 49887,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Tsuful (36) - Max Rank 1 (Bronze)
addVocation(36, "Bruiser", 4, 49888,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Turles (37) - Max Rank 3 (Gold)
addVocation(37, "DPS", 4, 49889,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Uub (38) - Max Rank 4 (Diamond)
addVocation(38, "Bruiser", 4, 49890,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Vados (39) - Max Rank 4 (Diamond)
addVocation(39, "Bruiser", 4, 49891,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Vegeta (40) - Max Rank 3 (Gold) [User Example]
addVocation(40, "DPS", 4, 49853,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Vegetto (41) - Max Rank 4 (Diamond)
addVocation(41, "DPS", 4, 49892,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Vermouth (42) - Max Rank 4 (Diamond)
addVocation(42, "DPS", 4, 49893,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Videl (43) - Max Rank 2 (Silver)
addVocation(43, "Support", 4, 49894,
  { attack = 2, defense = 6, health = 500, mana = 3000, magic = 8, distance = 2, shield = 6 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Zaiko (44) - Max Rank 3 (Gold)
addVocation(44, "DPS", 4, 49895,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Zeno (45) - Max Rank 4 (Diamond)
addVocation(45, "DPS", 4, 49896,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Bleach Vocations (ID 47-67)
-- Aizen (47) - Max Rank 4 (Diamond)
addVocation(47, "DPS", 4, 49897,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Byakuya (48) - Max Rank 4 (Diamond)
addVocation(48, "DPS", 4, 49898,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Gin (49) - Max Rank 4 (Diamond)
addVocation(49, "Bruiser", 4, 49899,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Grimmjow (50) - Max Rank 4 (Diamond)
addVocation(50, "DPS", 4, 49900,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Hitsugaya (51) - Max Rank 4 (Diamond)
addVocation(51, "Bruiser", 4, 49901,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Ichigo FullBring (52) - Max Rank 4 (Diamond)
addVocation(52, "DPS", 4, 49902,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Ichigo (53) - Max Rank 4 (Diamond)
addVocation(53, "DPS", 4, 49903,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Ishida (54) - Max Rank 3 (Gold)
addVocation(54, "Bruiser", 4, 49904,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Kyouraku (55) - Max Rank 4 (Diamond)
addVocation(55, "DPS", 4, 49905,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Neliel (56) - Max Rank 4 (Diamond)
addVocation(56, "Bruiser", 4, 49906,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Orihime (57) - Max Rank 2 (Silver)
addVocation(57, "Support", 4, 49907,
  { attack = 2, defense = 6, health = 500, mana = 3000, magic = 8, distance = 2, shield = 6 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Renji (58) - Max Rank 4 (Diamond)
addVocation(58, "Bruiser", 4, 49908,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Rukia (59) - Max Rank 4 (Diamond)
addVocation(59, "Bruiser", 4, 49909,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Sado (60) - Max Rank 3 (Gold)
addVocation(60, "Tank", 4, 49910,
  { attack = 4, defense = 8, health = 3000, mana = 500, magic = 1, distance = 4, shield = 8 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Shinji (61) - Max Rank 4 (Diamond)
addVocation(61, "Bruiser", 4, 49911,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Soi Fong (62) - Max Rank 3 (Gold)
addVocation(62, "Bruiser", 4, 49912,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Tousen (63) - Max Rank 3 (Gold)
addVocation(63, "Bruiser", 4, 49913,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Ulquiorra (64) - Max Rank 4 (Diamond)
addVocation(64, "DPS", 4, 49914,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Urahara (65) - Max Rank 4 (Diamond)
addVocation(65, "Bruiser", 4, 49915,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Yoruichi (66) - Max Rank 4 (Diamond)
addVocation(66, "Bruiser", 4, 49916,
  { attack = 6, defense = 4, health = 1500, mana = 1500, magic = 2, distance = 6, shield = 4 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })

-- Zaraki (67) - Max Rank 4 (Diamond)
addVocation(67, "DPS", 4, 49917,
  { attack = 8, defense = 2, health = 2000, mana = 2000, magic = 3, distance = 8, shield = 2 },
  { [1] = 50, [2] = 75, [3] = 100, [4] = 200 })
