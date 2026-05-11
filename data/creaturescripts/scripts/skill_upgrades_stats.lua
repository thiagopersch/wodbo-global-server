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
    if type ~= STATSCHANGE_HEALTHLOSS and type ~= STATSCHANGE_MANALOSS then return true end

    -- Reflect: when the player takes damage, chance to reflect back
    if type == STATSCHANGE_HEALTHLOSS and isPlayer(cid) and attacker ~= cid then
        local reflectChance = SkillUpgradesLib.getSkillValue(cid, "reflect_chance")
        if reflectChance > 0 and math.random(1, 100) <= reflectChance then
            local reflectDamage = math.ceil(value * 0.5)
            if reflectDamage > 0 then
                doTargetCombatHealth(0, attacker, combat, -reflectDamage, -reflectDamage, 255)
                doSendMagicEffect(getCreaturePosition(attacker), CONST_ME_MAGIC_RED)
            end
        end
    end

    -- Skip attacker-side bonuses (crit, leech) if attacker is not a valid player
    if not isPlayer(attacker) or attacker == cid then return true end

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

    -- Life Leech (chance only, fixed 50% leech rate)
    local llChance = SkillUpgradesLib.getSkillValue(attacker, "life_leech_chance")
    if llChance > 0 and math.random(1, 100) <= llChance then
        local healAmount = math.ceil(damage * 0.5)
        if healAmount > 0 then
            doCreatureAddHealth(attacker, healAmount)
            doSendMagicEffect(getCreaturePosition(attacker), CONST_ME_MAGIC_RED)
        end
    end

    -- Mana Leech (chance only, fixed 50% leech rate)
    local mlChance = SkillUpgradesLib.getSkillValue(attacker, "mana_leech_chance")
    if mlChance > 0 and math.random(1, 100) <= mlChance then
        local manaAmount = math.ceil(damage * 0.5)
        if manaAmount > 0 then
            doCreatureAddMana(attacker, manaAmount)
            doSendMagicEffect(getCreaturePosition(attacker), CONST_ME_MAGIC_BLUE)
        end
    end

    -- Apply modified damage if crit triggered
    if appliedCrit then
        doTargetCombatHealth(attacker, cid, combat, -damage, -damage, 255)
        return false
    end

    return true
end
