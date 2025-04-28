local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 158)
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -5, -6, -15, -20, -5, -200, 1, 1)

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end

function onCastSpell(cid, var)
    local position1 = {
        x = getThingPosition(getCreatureTarget(cid)).x + 1,
        y = getThingPosition(getCreatureTarget(cid)).y + 1,
        z = getThingPosition(getCreatureTarget(cid)).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }
    local repet = 200     -- Intervalo entre repetições (ms)
    local qtdRepet = 10   -- Quantidade de repetições
    local magEffect = 292 -- Magic Effect

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
