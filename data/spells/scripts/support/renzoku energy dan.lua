local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 233)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 37)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 5) + (maglevel * 0.99) + 6)
    local max = -((level / 5) + (maglevel * 2.6) + 16)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
