-- ============================================================
-- skill_upgrades_stats.lua
-- Handles Combat Stats (Crit, Leech, Healing) for Skill Upgrades
-- ============================================================

if not SkillUpgradesLib then dofile("data/lib/skill_upgrades_lib.lua") end

function onStatsChange(cid, attacker, type, combat, value)
    if value <= 0 then return true end

    -- Healing Power handling
    if type == STATSCHANGE_HEALTHGAIN then
        if SkillUpgradesLib then
            local healPower = SkillUpgradesLib.getSkillValue(cid, "healing_power")
            if healPower > 0 then
                value = math.ceil(value * (1 + (healPower / 100)))
                doTargetCombatHealth(0, cid, combat, value, value, 255)
                return false -- block original to apply new value
            end
        end
        return true
    end

    -- From here, we handle damage (HEALTHLOSS or MANALOSS)
    if not isPlayer(attacker) or attacker == cid then return true end
    if type ~= STATSCHANGE_HEALTHLOSS and type ~= STATSCHANGE_MANALOSS then return true end

    local damage = value
    local appliedCrit = false

    -- Critical Strike
    local critChance = SkillUpgradesLib.getSkillValue(attacker, "critical_chance")
    if critChance > 0 and math.random(1, 100) <= critChance then
        local critDmg = SkillUpgradesLib.getSkillValue(attacker, "critical_damage") -- Example: 100% extra
        if critDmg <= 0 then critDmg = 50 end -- Base critical if they only have chance
        
        damage = math.ceil(damage * (1 + (critDmg / 100)))
        appliedCrit = true
        doSendAnimatedText(getCreaturePosition(cid), "CRITICAL!", 144)
    end

    -- Life Leech
    local llChance = SkillUpgradesLib.getSkillValue(attacker, "life_leech_chance")
    if llChance > 0 and math.random(1, 100) <= llChance then
        local llAmount = SkillUpgradesLib.getSkillValue(attacker, "life_leech_amount")
        if llAmount > 0 then
            local healAmount = math.ceil((damage * llAmount) / 100)
            if healAmount > 0 then
                doCreatureAddHealth(attacker, healAmount)
                doSendMagicEffect(getCreaturePosition(attacker), CONST_ME_MAGIC_RED)
            end
        end
    end

    -- Mana Leech
    local mlChance = SkillUpgradesLib.getSkillValue(attacker, "mana_leech_chance")
    if mlChance > 0 and math.random(1, 100) <= mlChance then
        local mlAmount = SkillUpgradesLib.getSkillValue(attacker, "mana_leech_amount")
        if mlAmount > 0 then
            local manaAmount = math.ceil((damage * mlAmount) / 100)
            if manaAmount > 0 then
                doCreatureAddMana(attacker, manaAmount)
                doSendMagicEffect(getCreaturePosition(attacker), CONST_ME_MAGIC_BLUE)
            end
        end
    end

    -- Apply modified damage if crit triggered
    if appliedCrit then
        doTargetCombatHealth(attacker, cid, combat, -damage, -damage, 255)
        return false
    end

    return true
end
