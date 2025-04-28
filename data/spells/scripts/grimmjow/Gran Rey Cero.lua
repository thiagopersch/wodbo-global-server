local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, 96)
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -1, -8, -1, -24, 5, 50, 1.39, 2.19)

local area = createCombatArea({
    { 0, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 0 },
    { 0, 1, 3, 1, 0 },
    { 0, 1, 1, 1, 0 },
    { 0, 0, 0, 0, 0 }
})
setCombatArea(combat, area)

local function onCastSpell1(parameters)
    doCombat(parameters.cid, parameters.combat1, parameters.var)
end



function onCastSpell(cid, var)
    local target = getCreatureTarget(cid)
    if not target then
        return false
    end

    local position = {
        x = getThingPosition(getCreatureTarget(cid)).x + 2,
        y = getThingPosition(getCreatureTarget(cid)).y + 2,
        z = getThingPosition(getCreatureTarget(cid)).z
    }
    local parameters = { cid = cid, var = var, combat1 = combat }
    local repet = 200
    local qtdRepet = 3

    for k = 1, qtdRepet do
        addEvent(function()
            if isCreature(cid) and isCreature(target) then
                addEvent(onCastSpell1, 1, parameters)
                doSendMagicEffect(position, 530)
            end
        end, 1 + ((k - 1) * repet))
    end
    return true
end
