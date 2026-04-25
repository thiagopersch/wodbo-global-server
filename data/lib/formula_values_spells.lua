function getCombatFormulaValues(cid, level, maglevel, baseMin, baseMax, levelDiv, magMultMin, magMultMax, spellMaxLevel)
  level = math.min(level, spellMaxLevel)

  local levelRanges = {
    { maxLevel = 1,         minMult = 0.5,  maxMult = 1.2,  minAdd = 2,   maxAdd = 5 },
    { maxLevel = 30,        minMult = 0.7,  maxMult = 1.8,  minAdd = 4,   maxAdd = 10 },
    { maxLevel = 50,        minMult = 0.9,  maxMult = 2.2,  minAdd = 6,   maxAdd = 14 },
    { maxLevel = 75,        minMult = 1.1,  maxMult = 2.6,  minAdd = 8,   maxAdd = 18 },
    { maxLevel = 100,       minMult = 1.3,  maxMult = 3.0,  minAdd = 10,  maxAdd = 22 },
    { maxLevel = 150,       minMult = 1.6,  maxMult = 3.5,  minAdd = 15,  maxAdd = 30 },
    { maxLevel = 200,       minMult = 2.0,  maxMult = 4.0,  minAdd = 20,  maxAdd = 40 },
    { maxLevel = 250,       minMult = 2.5,  maxMult = 4.5,  minAdd = 25,  maxAdd = 50 },
    { maxLevel = 300,       minMult = 3.0,  maxMult = 5.0,  minAdd = 30,  maxAdd = 60 },
    { maxLevel = 350,       minMult = 3.5,  maxMult = 5.5,  minAdd = 35,  maxAdd = 70 },
    { maxLevel = 400,       minMult = 4.0,  maxMult = 6.0,  minAdd = 40,  maxAdd = 80 },
    { maxLevel = 450,       minMult = 4.5,  maxMult = 6.5,  minAdd = 45,  maxAdd = 90 },
    { maxLevel = 500,       minMult = 5.0,  maxMult = 7.0,  minAdd = 50,  maxAdd = 100 },
    { maxLevel = 550,       minMult = 5.5,  maxMult = 7.5,  minAdd = 55,  maxAdd = 110 },
    { maxLevel = 600,       minMult = 6.0,  maxMult = 8.0,  minAdd = 60,  maxAdd = 120 },
    { maxLevel = 650,       minMult = 6.5,  maxMult = 8.5,  minAdd = 65,  maxAdd = 130 },
    { maxLevel = 700,       minMult = 7.0,  maxMult = 9.0,  minAdd = 70,  maxAdd = 140 },
    { maxLevel = 750,       minMult = 7.5,  maxMult = 9.5,  minAdd = 75,  maxAdd = 150 },
    { maxLevel = 800,       minMult = 8.0,  maxMult = 10.0, minAdd = 80,  maxAdd = 160 },
    { maxLevel = 850,       minMult = 8.5,  maxMult = 10.5, minAdd = 85,  maxAdd = 170 },
    { maxLevel = 900,       minMult = 9.0,  maxMult = 11.0, minAdd = 90,  maxAdd = 180 },
    { maxLevel = 950,       minMult = 9.5,  maxMult = 11.5, minAdd = 95,  maxAdd = 190 },
    { maxLevel = 1000,      minMult = 10.0, maxMult = 12.0, minAdd = 100, maxAdd = 200 },
    { maxLevel = math.huge, minMult = 10.5, maxMult = 12.5, minAdd = 105, maxAdd = 210 }
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
