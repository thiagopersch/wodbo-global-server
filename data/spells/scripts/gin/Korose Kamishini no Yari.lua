local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 277 }, -- lista de efeitos para alternar
    minDmg = 100,
    maxDmg = 200,
    areaIncreaseDelay = 100,
    maxRadius = 6
}

local function positionToString(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function doAreaDamage(cid, radius, hitCreatures, hitPositions)
    if not isCreature(cid) then
        return false
    end

    local center = getCreaturePosition(cid)
    for x = -radius, radius do
        for y = -radius, radius do
            local areaPos = { x = center.x + x, y = center.y + y, z = center.z }
            if math.abs(x) + math.abs(y) <= radius then
                -- Ignorar a posição do jogador para efeitos visuais
                if not (areaPos.x == center.x and areaPos.y == center.y and areaPos.z == center.z) then
                    local posStr = positionToString(areaPos)
                    if not hitPositions[posStr] then
                        hitPositions[posStr] = true
                        -- Escolher efeito baseado no raio, alternando na lista de efeitos
                        local effectIndex = (radius - 1) % #config.effects + 1
                        local selectedEffect = config.effects[effectIndex]
                        doSendMagicEffect(areaPos, selectedEffect)
                    end
                end

                -- Aplicar dano apenas uma vez por criatura
                local creature = getTopCreature(areaPos).uid
                if creature > 0 and isCreature(creature) and creature ~= cid then
                    if not hitCreatures[creature] then
                        hitCreatures[creature] = true
                        local min = -(config.minDmg * radius)
                        local max = -(config.maxDmg * radius)
                        doTargetCombatHealth(cid, creature, config.type, min, max, config.effects
                            [(radius - 1) % #config.effects + 1])
                    end
                end
            end
        end
    end
end

local function expandArea(cid, radius, hitCreatures, hitPositions)
    if radius > config.maxRadius then
        return
    end

    if not isCreature(cid) then
        return
    end

    doAreaDamage(cid, radius, hitCreatures, hitPositions)

    addEvent(function()
        expandArea(cid, radius + 1, hitCreatures, hitPositions)
    end, config.areaIncreaseDelay)
end

function onCastSpell(cid, var)
    local hitCreatures = {}
    local hitPositions = {}
    expandArea(cid, 1, hitCreatures, hitPositions)
    return true
end
