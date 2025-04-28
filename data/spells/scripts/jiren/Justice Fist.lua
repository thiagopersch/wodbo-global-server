local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

function onGetFormulaValues(cid, level, maglevel)
    local min = -((level / 5) + (maglevel * 0.99) + 6)
    local max = -((level / 5) + (maglevel * 2.6) + 16)
    return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")


local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local position1 = {
        x = getThingPosition(getCreatureTarget(cid)).x + 2,
        y = getThingPosition(getCreatureTarget(cid)).y + 2,
        z = getThingPosition(getCreatureTarget(cid)).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }
    local repet = 200     -- Intervalo entre repetições (ms)
    local qtdRepet = 1    -- Quantidade de repetições
    local magEffect = 520 -- ID do efeito

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
