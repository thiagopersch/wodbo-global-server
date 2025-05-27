local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

function onGetFormulaValues(cid, level, maglevel)
    return getCombatFormulaValues(cid, level, maglevel, 2, 4, 40, 1, 1)
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area1 = createCombatArea(AREA_SQUARE2X2)

setCombatArea(combat, area1)

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local pos1 = {
        x = getPlayerPosition(cid).x + 2,
        y = getPlayerPosition(cid).y + 2,
        z = getPlayerPosition(cid).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }
    local magEffect = 534

    addEvent(onCastSpell1, 0, parameters)
    doSendMagicEffect(pos1, magEffect)
    return true
end
