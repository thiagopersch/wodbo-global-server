local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 37 }, -- lista de efeitos para alternar
    minDmg = 100,
    maxDmg = 2000,
    areaIncreaseDelay = 100,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
