local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 5) + (maglevel * 3.99) + 75)
    local max = -((level / 5) + (maglevel * 9.99) + 150)
    return min, max
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
    local magEffect = 283

    addEvent(onCastSpell1, 0, parameters)
    doSendMagicEffect(pos1, magEffect)
    return true
end
