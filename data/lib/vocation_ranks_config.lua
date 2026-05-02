VocationRankConfig = {
  StarsPerRank = 5,
  UniversalFragmentItemId = 56386, -- ID do Universal (usado por todos se nao tiver o específico)

  Vocations = {}
}

-- Exemplo de configuração (Goku, ID 17):
VocationRankConfig.Vocations[17] = {
  maxRank = 4,
  specificFragmentItemId = 49852,                                        -- Fragmento especifico dele
  statsPerStar = { attack = 10, defense = 5, health = 200, mana = 100 }, -- Bônus por estrela
  costs = {
    -- Quantos fragmentos custa POR estrela dependendo do Rank Atual do player
    [1] = 50,  -- Bronze: Custa 50 fragmentos para cada estrela
    [2] = 75,  -- Prata: Custa 75 fragmentos
    [3] = 100, -- Ouro: Custa 100 fragmentos
    [4] = 200  -- Diamante: Custa 150 fragmentos
  }
}

-- Exemplo Vegeta (ID 40):
VocationRankConfig.Vocations[40] = {
  maxRank = 3, -- Vegeta vai até Ouro apenas
  specificFragmentItemId = 49853,
  statsPerStar = { attack = 8, defense = 4, health = 150, mana = 80 },
  costs = {
    [1] = 50, [2] = 75, [3] = 100, [4] = 200
  }
}
