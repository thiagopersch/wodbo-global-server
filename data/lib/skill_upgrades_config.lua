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

    -- All categories are now "all-or-nothing": the bonus below only applies once the
    -- skill reaches maxLevel (200 for every category). Before that, formula(lvl) is 0.
    Categories = {
        ["fist_fighting"]      = { id = 1, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Fist Fighting", desc = "At max level: +25% attack speed with the weapon in your hand.", formulaDisplay = "+%d%% atk speed" },
        ["club_fighting"]      = { id = 2, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Club Fighting", desc = "At max level: +25% damage while wielding a club.", formulaDisplay = "+%d%% damage" },
        ["axe_fighting"]       = { id = 3, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Axe Fighting", desc = "At max level: +25% damage while wielding an axe.", formulaDisplay = "+%d%% damage" },
        ["sword_fighting"]     = { id = 4, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Sword Fighting", desc = "At max level: +25% damage while wielding a sword.", formulaDisplay = "+%d%% damage" },
        ["distance_fighting"]  = { id = 5, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Distance Fighting", desc = "At max level: +25% damage while wielding a distance weapon.", formulaDisplay = "+%d%% damage" },
        ["shielding"]          = { id = 6, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Shielding", desc = "At max level: -25% damage taken while a shield is equipped.", formulaDisplay = "-%d%% dmg taken" },
        ["critical_damage"]    = { id = 7, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Critical Damage", desc = "At max level: your critical strikes deal +25% damage.", formulaDisplay = "+%d%% crit dmg" },
        ["magic_damage"]       = { id = 8, group = "attack", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Magic Damage", desc = "At max level: +25% damage dealt by offensive spells.", formulaDisplay = "+%d%% damage" },
        ["life_leech_chance"]  = { id = 9, group = "support", maxLevel = 200, maxBonus = 20, formula = function(lvl) return lvl >= 200 and 20 or 0 end, name = "Life Leech Chance", desc = "At max level: leech 20% of the damage you deal as life.", formulaDisplay = "%d%% leech" },
        ["mana_leech_chance"]  = { id = 10, group = "support", maxLevel = 200, maxBonus = 20, formula = function(lvl) return lvl >= 200 and 20 or 0 end, name = "Mana Leech Chance", desc = "At max level: leech 20% of the damage you deal as mana.", formulaDisplay = "%d%% leech" },
        ["critical_chance"]    = { id = 11, group = "support", maxLevel = 200, maxBonus = 15, formula = function(lvl) return lvl >= 200 and 15 or 0 end, name = "Critical Hit Chance", desc = "At max level: 15% chance to land a critical hit.", formulaDisplay = "%d%% chance" },
        ["healing_power"]      = { id = 12, group = "support", maxLevel = 200, maxBonus = 50, formula = function(lvl) return lvl >= 200 and 50 or 0 end, name = "Healing", desc = "At max level: +50% effectiveness on regeneration spells.", formulaDisplay = "+%d%% healing" },
        ["magic_level"]        = { id = 13, group = "techniques", maxLevel = 200, maxBonus = 35, formula = function(lvl) return lvl >= 200 and 35 or 0 end, name = "Magic Level", desc = "At max level: +35% faster magic level progress from training and regular spells.", formulaDisplay = "+%d%% ML speed" },
        ["loot_chance"]        = { id = 14, group = "looting", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Loot Chance", desc = "At max level: +25% chance of finding loot on slain creatures.", formulaDisplay = "+%d%% chance" },
        ["reflect_chance"]     = { id = 15, group = "bonus", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Reflect Hit Chance", desc = "At max level: chance to reflect 25% of incoming damage back to the attacker.", formulaDisplay = "%d%% reflect" },
        ["cooldown_reduction"] = { id = 16, group = "bonus", maxLevel = 200, maxBonus = 60, formula = function(lvl) return lvl >= 200 and 60 or 0 end, name = "Cooldown Reduction Spells", desc = "At max level: -60% cooldown and mana cost on spells and techniques.", formulaDisplay = "-%d%% cost" },
        ["exp_bonus"]          = { id = 17, group = "bonus", maxLevel = 200, maxBonus = 25, formula = function(lvl) return lvl >= 200 and 25 or 0 end, name = "Experience Bonus", desc = "At max level: +25% faster level progress.", formulaDisplay = "+%d%% EXP" },
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
