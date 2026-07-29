if not BattlePassLib then dofile("data/lib/battle_pass_lib.lua") end

-- Cheap check every 5 minutes: ensureSeason() only does real work (clone previous season)
-- the first time it's called after the month rolls over.
function onThink(interval)
    BattlePassLib.ensureSeason()
    return true
end
