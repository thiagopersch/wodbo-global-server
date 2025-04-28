local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 233)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 37)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 2) + (maglevel * 2.99) + 12)
    local max = -((level / 2) + (maglevel * 4.6) + 32)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_SQUARE1X1)
setCombatArea(combat, area)

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
