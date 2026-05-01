VocationRankConfig = {
  Ranks = {
    {id=1, name="Bronze"},
    {id=2, name="Prata"},
    {id=3, name="Ouro"},
    {id=4, name="Diamante"}
  },
  StarsPerRank = 5,
  UniversalUpgradeItem = {itemId=0, countPerStar=10},
  Vocations = {}
}

for i=0,67 do
  if i ~= 46 then
    VocationRankConfig.Vocations[i] = {
      maxRank = 4,
      specificUpgradeItemId = 0,
      statsPerStar = {attack=5, defense=3, health=100, mana=50}
    }
  end
end
