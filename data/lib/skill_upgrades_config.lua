SkillUpgradesConfig = {
    Opcode = 240,
    PointsPerLevel = 1,

    ResetItemId = 9004,
    ResetItemCount = 1,

    SkillGroups = {
        ["attack"]     = { name = "Attack", order = 1 },
        ["support"]    = { name = "Support", order = 2 },
        ["techniques"] = { name = "Techniques", order = 3 },
        ["looting"]    = { name = "Looting", order = 4 },
        ["bonus"]      = { name = "Bonus", order = 5 },
    },

    Categories = {
        ["fist_fighting"]      = { id = 1, group = "attack", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Fist Fighting", desc = "Increases your Fist skill, raising damage with unarmed attacks.", formulaDisplay = "+%d Skill" },
        ["club_fighting"]      = { id = 2, group = "attack", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Club Fighting", desc = "Increases your Club skill, raising damage with clubs.", formulaDisplay = "+%d Skill" },
        ["axe_fighting"]       = { id = 3, group = "attack", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Axe Fighting", desc = "Increases your Axe skill, raising damage with axes.", formulaDisplay = "+%d Skill" },
        ["sword_fighting"]     = { id = 4, group = "attack", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Sword Fighting", desc = "Increases your Sword skill, raising damage with swords.", formulaDisplay = "+%d Skill" },
        ["distance_fighting"]  = { id = 5, group = "attack", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Distance Fighting", desc = "Increases your Distance skill, raising damage with distance weapons.", formulaDisplay = "+%d Skill" },
        ["shielding"]          = { id = 6, group = "attack", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Shielding", desc = "Increases your Shielding skill, improving block rate with shields.", formulaDisplay = "+%d Skill" },
        ["critical_damage"]    = { id = 7, group = "attack", maxLevel = 100, formula = function(lvl) return lvl * 2 end, name = "Critical Damage", desc = "Multiplier for your critical strikes.", formulaDisplay = "+%d%% damage" },
        ["magic_damage"]       = { id = 8, group = "attack", maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Magic Damage", desc = "Increases all magic damage you deal.", formulaDisplay = "+%d%% damage" },
        ["life_leech_chance"]  = { id = 9, group = "support", maxLevel = 100, formula = function(lvl) return lvl * 0.5 end, name = "Life Leech Chance", desc = "Chance to heal based on a percentage of the damage you deal.", formulaDisplay = "%.1f%% chance" },
        ["mana_leech_chance"]  = { id = 10, group = "support", maxLevel = 100, formula = function(lvl) return lvl * 0.5 end, name = "Mana Leech Chance", desc = "Chance to restore mana based on a percentage of the damage you deal.", formulaDisplay = "%.1f%% chance" },
        ["critical_chance"]    = { id = 11, group = "support", maxLevel = 75, formula = function(lvl) return lvl * 1 end, name = "Critical Hit Chance", desc = "Chance to land a critical hit on your attacks and spells.", formulaDisplay = "%d%% chance" },
        ["healing_power"]      = { id = 12, group = "support", maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Healing", desc = "Increases the effectiveness of all your healing spells and items.", formulaDisplay = "+%d%% healing" },
        ["magic_level"]        = { id = 13, group = "techniques", maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Magic Level", desc = "Directly increases your magic level, boosting spell power.", formulaDisplay = "+%d ML" },
        ["loot_chance"]        = { id = 14, group = "looting", maxLevel = 100, formula = function(lvl) return lvl * 2 end, name = "Loot Chance", desc = "Increases the chance of finding rare items on slain creatures.", formulaDisplay = "+%d%% chance" },
        ["reflect_chance"]     = { id = 15, group = "bonus", maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Reflect Hit Chance", desc = "Chance to reflect a portion of incoming damage back to the attacker.", formulaDisplay = "%d%% chance" },
        ["cooldown_reduction"] = { id = 16, group = "bonus", maxLevel = 60, formula = function(lvl) return lvl * 1 end, name = "Cooldown Reduction Spells", desc = "Reduces the mana cost and cooldown of your spells and techniques.", formulaDisplay = "-%d%% cost" },
        ["exp_bonus"]          = { id = 17, group = "bonus", maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Experience Bonus", desc = "Increases all experience gained from defeating creatures.", formulaDisplay = "+%d%% EXP" },
    },

    GetUpgradeCost = function(currentLevel)
        local tier = math.floor(currentLevel / 5)
        return tier + 1
    end,

    GetTotalSpentPoints = function(currentLevel)
        local total = 0
        for i = 0, currentLevel - 1 do
            total = total + SkillUpgradesConfig.GetUpgradeCost(i)
        end
        return total
    end
}
