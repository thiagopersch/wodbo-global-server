local config = {
    type = COMBAT_PHYSICALDAMAGE,
    effects = { 282 }, -- lista de efeitos para alternar
    minDmg = 100,
    maxDmg = 200,
    areaIncreaseDelay = 100,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
