local config = {
  type = COMBAT_PHYSICALDAMAGE,
  effect = 278, -- efeito visual (ajuste para o desejado)
  minDmg = 100,
  maxDmg = 200,
  areaIncreaseDelay = 150,
  maxRadius = 6 -- quantos SQMs a magia vai expandir
}

-- Função para enviar efeitos e causar dano em todas as posições dentro do raio
local function doAreaDamage(cid, radius)
  if not isCreature(cid) then
    return false
  end

  local center = getCreaturePosition(cid)
  for x = -radius, radius do
    for y = -radius, radius do
      local areaPos = { x = center.x + x, y = center.y + y, z = center.z }
      -- Aqui criamos o formato de diamante (somente dentro da área visual da expansão)
      if math.abs(x) + math.abs(y) <= radius then
        doSendMagicEffect(areaPos, config.effect)

        -- Damos dano apenas se houver criatura no sqm
        local creature = getTopCreature(areaPos).uid
        if creature > 0 and isCreature(creature) and creature ~= cid then
          local min = -(config.minDmg * radius)
          local max = -(config.maxDmg * radius)
          doTargetCombatHealth(cid, creature, config.type, min, max, config.effect)
        end
      end
    end
  end
end

-- Função recursiva para a expansão
local function expandArea(cid, radius)
  if radius > config.maxRadius then
    return
  end

  addEvent(function()
    if isCreature(cid) then
      doAreaDamage(cid, radius)
      expandArea(cid, radius + 1)
    end
  end, config.areaIncreaseDelay)
end

function onCastSpell(cid, var)
  expandArea(cid, 1)
  return true
end

-- local combat = createCombatObject()
-- setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
-- setCombatParam(combat, COMBAT_PARAM_EFFECT, 278)

-- function onGetFormulaValues(cid, level, maglevel)
--     return getCombatFormulaValues(cid, level, maglevel, 2, 4, 40, 1, 1)
-- end

-- setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- local area = createCombatArea(AREA_CROSS6X6)
-- setCombatArea(combat, area)

-- function onCastSpell(cid, var)
--     return doCombat(cid, combat, var)
-- end
