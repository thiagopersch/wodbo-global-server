local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 143)
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -1, -8, -1, -24, 5, 50, 1.39, 2.19)

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
    local repet = 200     -- Intervalo entre repetições (ms)
    local qtdRepet = 3    -- Quantidade de repetições
    local magEffect = 282 -- ID do efeito

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
