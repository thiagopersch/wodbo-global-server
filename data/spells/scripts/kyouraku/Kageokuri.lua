local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 206)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 501)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 1) + (maglevel * 5.99) + 10)
    local max = -((level / 2) + (maglevel * 10.6) + 32)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_SQUARE1X1)
setCombatArea(combat, area)

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
