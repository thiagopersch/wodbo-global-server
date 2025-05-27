local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 125)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 282)

function onGetFormulaValues(cid, level, maglevel)
    return getCombatFormulaValues(cid, level, maglevel, 1, 2, 10, 1, 1)
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local parameters = { cid = cid, var = var, combat1 = combat }
    local repet = 200  -- Intervalo entre repetições (ms)
    local qtdRepet = 2 -- Quantidade de repetições

    for k = 1, qtdRepet do
        addEvent(function()
            if isCreature(cid) then
                addEvent(onCastSpell1, 1, parameters)
            end
        end, 1 + ((k - 1) * repet))
    end
    return true
end
