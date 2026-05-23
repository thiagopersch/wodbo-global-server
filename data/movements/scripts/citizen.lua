function onStepIn(cid, item, pos)
    if isPlayer(cid) ~= TRUE then
        return true
    end

    local thingPos = getThingPos(cid)
    local magicEffect = 240

    print("[Citizen Portal] Player '" .. getCreatureName(cid) .. "' stepped on teleport (Item ID: " .. item.itemid .. ", Action ID: " .. item.actionid .. ")")

    local townId = nil
    if item.actionid == 4036 then
        townId = 2 -- Central City (Main City on map)
    elseif item.actionid == 4037 then
        townId = 1 -- Ressuration Temple on map
    end

    if townId then
        local townName = getTownName(townId)
        if townName then
            print("[Citizen Portal] Setting town of '" .. getCreatureName(cid) .. "' to " .. townName .. " (ID: " .. townId .. ")")
            local success = doPlayerSetTown(cid, townId)
            print("[Citizen Portal] doPlayerSetTown success: " .. tostring(success))

            local templePos = getTownTemplePosition(townId)
            if templePos and templePos.x > 0 then
                doSendMagicEffect(thingPos, magicEffect)
                doTeleportThing(cid, templePos)
                doSendMagicEffect(templePos, magicEffect)
                doPlayerSave(cid, true)
                doPlayerSendTextMessage(cid, 25, "Now you are citizen of " .. townName .. ".")
            else
                print("[Citizen Portal] Error: Town " .. townName .. " has an invalid temple position.")
            end
        else
            print("[Citizen Portal] Error: Town ID " .. townId .. " not found on the map.")
        end
    end

    return true
end

