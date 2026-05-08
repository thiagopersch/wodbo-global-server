local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 1153, 1154 }, -- lista de efeitos para alternar
    minDmg = 5000,
    maxDmg = 15000,
    areaIncreaseDelay = 100,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
