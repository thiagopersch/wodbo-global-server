local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 233)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 37)

function onGetFormulaValues(cid, level, maglevel)
    return getCombatFormulaValues(cid, level, maglevel, 4, 8, 15, 1, 1)
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_SQUARE1X1)
setCombatArea(combat, area)

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
