dofile("data/lib/change_vocation.lua") -- era vocation_change_lib.lua

function onStepIn(cid, item, position, fromPosition)
    print("[DEBUG] StepIn VocationChange for: " .. getCreatureName(cid))
    if not isPlayer(cid) then return true end
    ChangeVocation.open(cid)
    return true
end
