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

    for k = 1, 2 do
        addEvent(function()
            if isCreature(cid) then
                addEvent(onCastSpell1, 1, parameters)
            end
        end, 1 + ((k - 1) * 200))
    end
    return true
end
