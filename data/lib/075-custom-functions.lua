function doShowTimeByPos(uid, pos, duration, type, effectId)
  type = type or 20
  effectId = effectId or CONST_ME_SMOKE
  local steps = duration * 10
  for i = 0, steps do
    addEvent(function()
      if isCreature(uid) then
        local remaining = duration - (i / 10)
        if remaining >= 0 then
          doSendAnimatedText(pos, string.format("%.1f", remaining), TEXTCOLOR_BLUE)
        end
      end
    end, i * 100)
  end
  addEvent(function()
    if isCreature(uid) then
      doSendMagicEffect(pos, effectId)
    end
  end, duration * 1000)
  return true
end

function doExpandingWaveCombat(cid, config)
  if not isCreature(cid) then
    return false
  end

  local casterPos = getCreaturePosition(cid)
  if getTilePzInfo(casterPos) then
    return false
  end

  local hitCreatures = {}
  local hitPositions = {}

  local function getEffect(radius)
    if config.effects then
      return config.effects[(radius - 1) % #config.effects + 1]
    end
    return config.effect
  end

  local function positionToString(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
  end

  local function doAreaDamage(radius)
    if not isCreature(cid) then
      return false
    end

    local center = getCreaturePosition(cid)
    if getTilePzInfo(center) then
      return false
    end

    for x = -radius, radius do
      for y = -radius, radius do
        local areaPos = { x = center.x + x, y = center.y + y, z = center.z }
        if math.abs(x) + math.abs(y) <= radius then
          if not (areaPos.x == center.x and areaPos.y == center.y and areaPos.z == center.z) then
            -- ✅ Só mostra efeito se a posição NÃO for PZ
            if not getTilePzInfo(areaPos) then
              local posStr = positionToString(areaPos)
              if not hitPositions[posStr] then
                hitPositions[posStr] = true
                doSendMagicEffect(areaPos, getEffect(radius))
              end
            end
          end

          local creature = getTopCreature(areaPos).uid
          if creature > 0 and isCreature(creature) and creature ~= cid then
            if not hitCreatures[creature] then
              hitCreatures[creature] = true
              local targetPos = getCreaturePosition(creature)
              if not getTilePzInfo(targetPos) then
                local min = -(config.minDmg * radius)
                local max = -(config.maxDmg * radius)
                doTargetCombatHealth(cid, creature, config.type, min, max, getEffect(radius))
              end
            end
          end
        end
      end
    end
  end

  local function expandArea(radius)
    if radius > config.maxRadius then
      return
    end
    if not isCreature(cid) then
      return
    end
    doAreaDamage(radius)
    addEvent(function()
      expandArea(radius + 1)
    end, config.areaIncreaseDelay)
  end

  expandArea(1)
  return true
end
