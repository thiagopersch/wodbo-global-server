local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 278)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 61)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 1) + (maglevel * 3.99) + 20)
    local max = -((level / 3) + (maglevel * 40) + 60)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- local area = createCombatArea(AREA_CROSS1X1)
-- setCombatArea(combat, area)

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
