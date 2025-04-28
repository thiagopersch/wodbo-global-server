local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 160)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 5) + (maglevel * 3.99) + 75)
    local max = -((level / 5) + (maglevel * 9.99) + 150)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local position1 = {
        x = getThingPosition(getCreatureTarget(cid)).x + 1,
        y = getThingPosition(getCreatureTarget(cid)).y,
        z = getThingPosition(getCreatureTarget(cid)).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }
    local repet = 200
    local qtdRepet = 1
    local magEffect = 500 -- ID do efeito

    for k = 1, qtdRepet do
        addEvent(function()
            if isCreature(cid) then
                addEvent(onCastSpell1, 1, parameters)
                doSendMagicEffect(position1, magEffect)
            end
        end, 1 + ((k - 1) * repet))
    end
    return true
end
