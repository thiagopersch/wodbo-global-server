local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 813, 897 }, -- lista de efeitos para alternar 282
    minDmg = 100,
    maxDmg = 200,
    areaIncreaseDelay = 100,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
