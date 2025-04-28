local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 115)
setCombatParam(combat, COMBAT_PARAM_EFFECT, 282)
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -5, -6, -15, -20, -5, -200, 1, 1)

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
