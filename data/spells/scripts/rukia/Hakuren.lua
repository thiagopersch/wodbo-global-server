local config = {
    type = COMBAT_ICEDAMAGE,
    effects = { 1172, 1173, 1174 },
    minDmg = 5000,
    maxDmg = 15000,
    areaIncreaseDelay = 65,
    maxRadius = 4
}

function onCastSpell(cid, var)
    return doExpandingWaveCombat(cid, config)
end
