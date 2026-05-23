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

  local function isBlocked(pos)
    -- Verifica se o tile existe primeiro para evitar spam de "Tile not found" no console
    local ground = getThingfromPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 }, false)
    if ground.itemid == 0 then return true end -- Se não há chão, está bloqueado

    local t = getTileInfo(pos)
    if type(t) ~= 'table' then return false end
    
    -- 1. Checa Zona de Proteção / No-PvP / Casas
    local pz = t.protection or t.pz or t.nopvp or t.house or false
    if pz == true or (type(pz) == 'number' and pz > 0) then
      return true
    end

    -- 2. Checa se o tile bloqueia projéteis (Paredes e objetos sólidos)
    local block = t.blockprojectile or false
    if block == true or (type(block) == 'number' and block > 0) then
      return true
    end

    return false
  end

  local casterPos = getCreaturePosition(cid)
  if isBlocked(casterPos) then
    return false
  end

  local hitCreatures = {}

  local function getEffect(radius)
    if config.effects then
      return config.effects[(radius - 1) % #config.effects + 1]
    end
    return config.effect
  end



  local function doAreaDamage(radius)
    if not isCreature(cid) then
      return false
    end

    local center = getCreaturePosition(cid)
    if isBlocked(center) then
      return false
    end

    -- 1. Efeitos (Apenas no anel do raio atual, se NÃO for PZ)
    for x = -radius, radius do
      for y = -radius, radius do
        if math.abs(x) + math.abs(y) == radius then
          local areaPos = { x = center.x + x, y = center.y + y, z = center.z }
          if not isBlocked(areaPos) then
            doSendMagicEffect(areaPos, getEffect(radius))
          end
        end
      end
    end

    -- 2. Dano (Usando getSpectators para ser eficiente e evitar logs de 'Tile not found')
    local spectators = getSpectators(center, radius, radius, false)
    if spectators then
      for _, creature in ipairs(spectators) do
        if isCreature(creature) and creature ~= cid then
          local targetPos = getCreaturePosition(creature)
          local dist = math.abs(targetPos.x - center.x) + math.abs(targetPos.y - center.y)

          if dist <= radius and not hitCreatures[creature] then
            hitCreatures[creature] = true
            -- Checar PZ na posição da criatura (Sempre segura/válida)
            if not isBlocked(targetPos) then
              local min = -(config.minDmg * radius)
              local max = -(config.maxDmg * radius)
              doTargetCombatHealth(cid, creature, config.type, min, max, getEffect(radius))
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
