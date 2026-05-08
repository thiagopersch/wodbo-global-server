local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 2379, 2507 }, -- lista de efeitos para alternar
    minDmg = 5000,
    maxDmg = 15000,
    areaIncreaseDelay = 65,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
