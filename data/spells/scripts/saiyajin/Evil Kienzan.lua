local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 280)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 74)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 1) + (maglevel * 15) + 10)
    local max = -((level / 2) + (maglevel * 30) + 50)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- local area = createCombatArea(AREA_CROSS1X1)
-- setCombatArea(combat, area)

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
