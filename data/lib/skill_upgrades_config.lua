SkillUpgradesConfig = {
    Opcode = 240, -- Custom opcode for the system
    PointsPerLevel = 1, -- Points given per level advanced
    
    -- Categories available
    Categories = {
        ["cooldown_reduction"] = { id = 1, maxLevel = 60, formula = function(lvl) return lvl * 1 end, name = "Cooldown Reduction", desc = "Reduces the cooldown of your spells and techniques.", formulaDisplay = "%d%%" },
        ["life_leech_chance"] = { id = 2, maxLevel = 100, formula = function(lvl) return lvl * 0.5 end, name = "Life Leech Chance", desc = "Chance to heal a percentage of the damage you deal.", formulaDisplay = "%.1f%% chance" },
        ["life_leech_amount"] = { id = 3, maxLevel = 100, formula = function(lvl) return lvl * 0.5 end, name = "Life Leech Amount", desc = "Percentage of damage converted to health on a successful leech.", formulaDisplay = "%.1f%% amount" },
        ["mana_leech_chance"] = { id = 4, maxLevel = 100, formula = function(lvl) return lvl * 0.5 end, name = "Mana Leech Chance", desc = "Chance to restore mana based on the damage you deal.", formulaDisplay = "%.1f%% chance" },
        ["mana_leech_amount"] = { id = 5, maxLevel = 100, formula = function(lvl) return lvl * 0.5 end, name = "Mana Leech Amount", desc = "Percentage of damage converted to mana on a successful leech.", formulaDisplay = "%.1f%% amount" },
        ["critical_chance"] = { id = 6, maxLevel = 75, formula = function(lvl) return lvl * 1 end, name = "Critical Chance", desc = "Chance to deal critical damage on attacks and spells.", formulaDisplay = "%d%% chance" },
        ["critical_damage"] = { id = 7, maxLevel = 100, formula = function(lvl) return lvl * 2 end, name = "Critical Damage", desc = "Multiplier for your critical strikes.", formulaDisplay = "+%d%% damage" },
        ["magic_damage"] = { id = 8, maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Magic Damage", desc = "Increases the damage of your spells.", formulaDisplay = "+%d%% damage" },
        ["healing_power"] = { id = 9, maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Healing Power", desc = "Increases the effectiveness of your healing spells.", formulaDisplay = "+%d%% healing" },
        ["magic_level"] = { id = 10, maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Magic Level", desc = "Directly increases your magic level attribute.", formulaDisplay = "+%d ML" },
        ["melee_skill"] = { id = 11, maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Melee Skill", desc = "Directly increases your melee combat skill.", formulaDisplay = "+%d Skill" },
        ["distance_skill"] = { id = 12, maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Distance Skill", desc = "Directly increases your distance combat skill.", formulaDisplay = "+%d Skill" },
        ["shielding_skill"] = { id = 13, maxLevel = 200, formula = function(lvl) return lvl * 1 end, name = "Shielding Skill", desc = "Directly increases your shielding skill.", formulaDisplay = "+%d Skill" },
        ["loot_chance"] = { id = 14, maxLevel = 100, formula = function(lvl) return lvl * 2 end, name = "Loot Chance", desc = "Increases the chance of dropping rare items.", formulaDisplay = "+%d%% chance" },
        ["exp_bonus"] = { id = 15, maxLevel = 100, formula = function(lvl) return lvl * 1 end, name = "Experience Bonus", desc = "Increases the experience gained from defeating enemies.", formulaDisplay = "+%d%% EXP" },
        ["mana_reduction"] = { id = 16, maxLevel = 80, formula = function(lvl) return lvl * 1 end, name = "Mana Cost Reduction", desc = "Reduces the mana cost of all spells.", formulaDisplay = "-%d%% cost" }
    },

    -- Cost Scaling logic
    -- Every 5 levels, the cost increases by 1
    ResetItemId = 9004,
    ResetItemCount = 1,

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
