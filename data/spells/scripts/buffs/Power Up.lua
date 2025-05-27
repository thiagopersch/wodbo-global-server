local combat = createCombatObject()
local exhaustionId = 13101
local msg = "Please wait 30 seconds to use the spell again."
local effect = 240
local magEffect = 596
local repet = 30
local duration = 30000
local qtdRepet = 500
local condition = createConditionObject(CONDITION_ATTRIBUTES)

setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setConditionParam(condition, CONDITION_PARAM_TICKS, duration)
setConditionParam(condition, CONDITION_PARAM_SKILL_FIST, 1)
setConditionParam(condition, CONDITION_PARAM_SKILL_CLUB, 1)
setConditionParam(condition, CONDITION_PARAM_SKILL_SWORD, 1)
setConditionParam(condition, CONDITION_PARAM_SKILL_AXE, 1)
setConditionParam(condition, CONDITION_PARAM_SKILL_DISTANCE, 1)
setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELD, 1)
setConditionParam(condition, CONDITION_PARAM_STAT_MAGICLEVEL, 1)
setConditionParam(condition, CONDITION_PARAM_BUFF, true)
setCombatCondition(combat, condition)

function onCastSpell(cid, var)
    if exhaustion.check(cid, exhaustionId) == TRUE then
        doPlayerSendCancel(cid, msg)
        doSendMagicEffect(getCreaturePosition(cid), effect)
        return false
    end
    for k = 1, repet do
        addEvent(function()
            if isCreature(cid) then
                local pos1 = {
                    x = getPlayerPosition(cid).x,
                    y = getPlayerPosition(cid).y,
                    z = getPlayerPosition(cid).z
                }
                doSendMagicEffect(pos1, magEffect)
            end
        end, 1 + ((k - 1) * qtdRepet))
    end
    exhaustion.set(cid, exhaustionId, repet)
    return doCombat(cid, combat, var)
end
