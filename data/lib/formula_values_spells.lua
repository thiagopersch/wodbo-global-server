function getCombatFormulaValues(cid, level, maglevel, baseMin, baseMax, levelDiv, magMultMin, magMultMax, spellMaxLevel)
  level = math.min(level, spellMaxLevel)

  local levelRanges = {
    { maxLevel = 1,         minMult = 0.5, maxMult = 1.2, minAdd = 2,  maxAdd = 5 },
    { maxLevel = 30,        minMult = 0.7, maxMult = 1.8, minAdd = 4,  maxAdd = 10 },
    { maxLevel = 50,        minMult = 0.9, maxMult = 2.2, minAdd = 6,  maxAdd = 14 },
    { maxLevel = 75,        minMult = 1.1, maxMult = 2.6, minAdd = 8,  maxAdd = 18 },
    { maxLevel = 100,       minMult = 1.3, maxMult = 3.0, minAdd = 10, maxAdd = 22 },
    { maxLevel = 150,       minMult = 1.6, maxMult = 3.5, minAdd = 15, maxAdd = 30 },
    { maxLevel = 200,       minMult = 2.0, maxMult = 4.0, minAdd = 20, maxAdd = 40 },
    { maxLevel = 250,       minMult = 2.5, maxMult = 4.5, minAdd = 25, maxAdd = 50 },
    { maxLevel = math.huge, minMult = 3.0, maxMult = 5.5, minAdd = 35, maxAdd = 70 }
  }

  local randomFactor = math.random(85, 115) / 100

  local str = getPlayerSkill(cid, STAT_STRENGTH) or 0
  local int = getPlayerSkill(cid, STAT_INTELLIGENCE) or 0

  for _, range in ipairs(levelRanges) do
    if level <= range.maxLevel then
      local baseMinCalc = math.sqrt(level / levelDiv) + (maglevel * range.minMult) + range.minAdd
      local baseMaxCalc = math.sqrt(level / levelDiv) + (maglevel * range.maxMult) + range.maxAdd

      local min = -baseMinCalc * baseMin * (1 + str * 0.01) * randomFactor
      local max = -baseMaxCalc * baseMax * (1 + int * 0.02) * randomFactor

      return min, max
    end
  end
end
