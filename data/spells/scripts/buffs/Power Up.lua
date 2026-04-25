-- Power Up Spell
-- Applies a buff increasing all combat skills and magic level for 30 seconds.
-- Visual effect continuously pulses from the caster's current position
-- for as long as the buff is active, without a fixed tick counter.

local EXHAUSTION_ID = 13101
local CANCEL_EFFECT = 240   -- Effect shown when spell is on cooldown
local BUFF_EFFECT   = 765   -- Visual effect displayed during the buff

local DURATION_MS   = 30000 -- Buff duration in milliseconds (30 seconds)
local TICK_INTERVAL = 500   -- Interval between each effect pulse (1 second)

-- Combat setup
local combat        = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

-- Condition setup
local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, DURATION_MS)
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
    -- Block cast if cooldown is still active
    if exhaustion.check(cid, EXHAUSTION_ID) == TRUE then
        doPlayerSendCancel(cid, "Please wait 30 seconds to use the spell again.")
        doSendMagicEffect(getCreaturePosition(cid), CANCEL_EFFECT)
        return false
    end

    exhaustion.set(cid, EXHAUSTION_ID, DURATION_MS / 1000)

    -- Calculate the exact timestamp when the buff expires
    local expireAt = os.time() + (DURATION_MS / 1000)

    -- Closure: captures cid and expireAt, reschedules itself until buff expires
    local function emitBuffEffect()
        if not isCreature(cid) then return end
        if os.time() >= expireAt then return end

        doSendMagicEffect(getCreaturePosition(cid), BUFF_EFFECT)
        addEvent(emitBuffEffect, TICK_INTERVAL)
    end

    emitBuffEffect()
    return doCombat(cid, combat, var)
end
