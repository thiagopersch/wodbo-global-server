local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

function onGetFormulaValues(cid, level, maglevel)
    local min, max

    if level <= 1 then
        min = -((level / 5) + (maglevel * 0.5) + 2)
        max = -((level / 5) + (maglevel * 1.2) + 5)
    elseif level <= 30 then
        min = -((level / 5) + (maglevel * 0.7) + 4)
        max = -((level / 5) + (maglevel * 1.8) + 10)
    elseif level <= 50 then
        min = -((level / 5) + (maglevel * 0.9) + 6)
        max = -((level / 5) + (maglevel * 2.2) + 14)
    elseif level <= 75 then
        min = -((level / 5) + (maglevel * 1.1) + 8)
        max = -((level / 5) + (maglevel * 2.6) + 18)
    elseif level <= 100 then
        min = -((level / 5) + (maglevel * 1.3) + 10)
        max = -((level / 5) + (maglevel * 3.0) + 22)
    elseif level <= 150 then
        min = -((level / 5) + (maglevel * 1.6) + 15)
        max = -((level / 5) + (maglevel * 3.5) + 30)
    elseif level <= 200 then
        min = -((level / 5) + (maglevel * 2.0) + 20)
        max = -((level / 5) + (maglevel * 4.0) + 40)
    elseif level <= 250 then
        min = -((level / 5) + (maglevel * 2.5) + 25)
        max = -((level / 5) + (maglevel * 4.5) + 50)
    else -- level >= 500
        min = -((level / 5) + (maglevel * 3.0) + 35)
        max = -((level / 5) + (maglevel * 5.5) + 70)
    end

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
        x = getPlayerPosition(cid).x + 4,
        y = getPlayerPosition(cid).y,
        z = getPlayerPosition(cid).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }
    local magEffect = 669

    addEvent(onCastSpell1, 0, parameters)
    doSendMagicEffect(pos1, magEffect)
    return true
end
