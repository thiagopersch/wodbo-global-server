local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 535)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 5) + (maglevel * 0.99) + 6)
    local max = -((level / 5) + (maglevel * 2.6) + 16)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- local area = createCombatArea(AREA_CROSS1X1)
-- setCombatArea(combat, area)

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
