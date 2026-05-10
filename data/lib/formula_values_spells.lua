function getCombatFormulaValues(cid, level, maglevel, baseMin, baseMax, levelDiv, magMultMin, magMultMax, spellMaxLevel)
  level = math.min(level, spellMaxLevel)

  -- Get Vocation Archetype Multiplier
  local voc = getPlayerVocation(cid)
  local vocationConfig = VocationRankConfig.Vocations[voc]
  local archetype = vocationConfig and vocationConfig.archetype or "DPS"
  local archetypeData = VocationRankConfig.Archetypes[archetype]
  local damageMult = archetypeData and archetypeData.damageMult or 1.0

  if SkillUpgradesLib then
    local extraMagicDamage = SkillUpgradesLib.getSkillValue(cid, "magic_damage")
    if extraMagicDamage > 0 then
      damageMult = damageMult * (1 + (extraMagicDamage / 100))
    end
  end

  local levelRanges = {
    { maxLevel = 1,         minMult = 0.5,  maxMult = 1.2,  minAdd = 2,   maxAdd = 5 },
    { maxLevel = 30,        minMult = 0.8,  maxMult = 2.0,  minAdd = 5,   maxAdd = 12 },
    { maxLevel = 50,        minMult = 1.2,  maxMult = 2.5,  minAdd = 8,   maxAdd = 18 },
    { maxLevel = 100,       minMult = 1.8,  maxMult = 3.5,  minAdd = 15,  maxAdd = 30 },
    { maxLevel = 200,       minMult = 2.5,  maxMult = 4.5,  minAdd = 25,  maxAdd = 50 },
    { maxLevel = 300,       minMult = 3.5,  maxMult = 5.5,  minAdd = 35,  maxAdd = 70 },
    { maxLevel = 400,       minMult = 4.5,  maxMult = 6.5,  minAdd = 45,  maxAdd = 90 },
    { maxLevel = 500,       minMult = 5.5,  maxMult = 7.5,  minAdd = 55,  maxAdd = 110 },
    { maxLevel = 600,       minMult = 6.5,  maxMult = 8.5,  minAdd = 65,  maxAdd = 130 },
    { maxLevel = 700,       minMult = 7.5,  maxMult = 9.5,  minAdd = 75,  maxAdd = 150 },
    { maxLevel = 800,       minMult = 8.5,  maxMult = 10.5, minAdd = 85,  maxAdd = 170 },
    { maxLevel = 900,       minMult = 9.5,  maxMult = 11.5, minAdd = 95,  maxAdd = 190 },
    { maxLevel = 1000,      minMult = 11.0, maxMult = 13.0, minAdd = 110, maxAdd = 220 },
    { maxLevel = math.huge, minMult = 12.0, maxMult = 14.5, minAdd = 120, maxAdd = 250 }
  }

  local randomFactor = math.random(90, 110) / 100 -- More stable random factor (0.9 to 1.1)

  local str = getPlayerSkill(cid, STAT_STRENGTH) or 0
  local int = getPlayerSkill(cid, STAT_INTELLIGENCE) or 0

  -- Skills scale: Every 10 points adds a significant boost
  local skillMult = 1 + ((str + int) / 200)

  for _, range in ipairs(levelRanges) do
    if level <= range.maxLevel then
      -- Linear scaling with level is usually better for DBZ servers than sqrt
      local baseMinCalc = (level / levelDiv) + (maglevel * range.minMult) + range.minAdd
      local baseMaxCalc = (level / levelDiv) + (maglevel * range.maxMult) + range.maxAdd

      local min = -baseMinCalc * baseMin * skillMult * damageMult * randomFactor
      local max = -baseMaxCalc * baseMax * skillMult * damageMult * randomFactor

      return min, max
    end
  end
end
