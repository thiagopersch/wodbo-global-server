local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 489 }, -- lista de efeitos para alternar
    minDmg = 100,
    maxDmg = 200,
    areaIncreaseDelay = 65,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
