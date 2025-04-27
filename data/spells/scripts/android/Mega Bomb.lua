local combat1 = createCombatObject()
setCombatParam(combat1, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat1, COMBAT_PARAM_DISTANCEEFFECT, 107)
setCombatFormula(combat1, COMBAT_FORMULA_LEVELMAGIC, -1, -8, -1, -24, 5, 50, 1.39, 2.19)

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local position1 = {
        x = getThingPosition(getCreatureTarget(cid)).x + 1,
        y = getThingPosition(getCreatureTarget(cid)).y + 1,
        z = getThingPosition(getCreatureTarget(cid)).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat1 }

    for k = 1, 3 do
        addEvent(function()
            if isCreature(cid) then
                addEvent(onCastSpell1, 1, parameters)
                doSendMagicEffect(position1, 289)
            end
        end, 1 + ((k - 1) * 200))
    end
    return true
end
