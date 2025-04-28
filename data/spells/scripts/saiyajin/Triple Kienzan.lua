local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 154)
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -2, -3, -15, -20, -5, -100, 1, 1)

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local position1 = {
        x = getThingPosition(getCreatureTarget(cid)).x,
        y = getThingPosition(getCreatureTarget(cid)).y,
        z = getThingPosition(getCreatureTarget(cid)).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }

    for k = 1, 3 do
        addEvent(function()
            if isCreature(cid) then
                addEvent(onCastSpell1, 1, parameters)
                doSendMagicEffect(position1, 282)
            end
        end, 1 + ((k - 1) * 200))
    end
    return true
end
