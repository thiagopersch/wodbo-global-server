local combat1 = createCombatObject()
setCombatParam(combat1, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat1, COMBAT_PARAM_DISTANCEEFFECT, 96)
setCombatParam(combat1, COMBAT_PARAM_EFFECT, 709)
setCombatFormula(combat1, COMBAT_FORMULA_LEVELMAGIC, -1, -8, -1, -24, 5, 50, 1.39, 2.19)

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local parameters = { cid = cid, var = var, combat1 = combat1 }
    local repet = 200
    local qtdRepet = 3

    for k = 1, qtdRepet do
        addEvent(function()
            if isCreature(cid) then
                addEvent(onCastSpell1, 1, parameters)
            end
        end, 1 + ((k - 1) * repet))
    end
    return true
end
