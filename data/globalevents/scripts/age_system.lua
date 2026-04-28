local STORAGE_AGE = 1000
local MINUTES_PER_YEAR = 60
local opcode = 50

local config = {
    effects = {
        [1] = 491,
        [2] = 2,
        [3] = 3,
        [4] = 4,
        [5] = 4,
        [6] = 4,
        [7] = 4,
        [8] = 4
    }
}

local function getTitleByAge(age)
    if age <= 2 then
        return "Baby"
    elseif age <= 10 then
        return "Child"
    elseif age <= 17 then
        return "Teenager"
    elseif age <= 30 then
        return "Young"
    elseif age <= 60 then
        return "Adult"
    elseif age <= 100 then
        return "Veteran"
    elseif age <= 150 then
        return "Elder"
    else
        return "Legendary"
    end
end

local function getEffectIndex(age)
    if age <= 2 then
        return 1
    elseif age <= 10 then
        return 2
    elseif age <= 17 then
        return 3
    elseif age <= 30 then
        return 4
    elseif age <= 60 then
        return 5
    elseif age <= 100 then
        return 6
    elseif age <= 150 then
        return 7
    else
        return 8
    end
end

local function getPlayerAgeMinutesReal(cid)
    local guid = getPlayerGUID(cid)
    local result = db.getResult("SELECT `age_minutes` FROM `players` WHERE `id` = " .. guid)
    local minutes = 0
    if result and result:getID() ~= -1 then
        minutes = result:getDataInt("age_minutes")
        result:free()
    end
    return minutes
end

local function setPlayerAgeMinutesReal(cid, minutes)
    local guid = getPlayerGUID(cid)
    -- Use db.query directly instead of db.executeQuery
    local query = "UPDATE `players` SET `age_minutes` = " .. minutes .. " WHERE `id` = " .. guid
    local result = db.storeQuery(query)
    if result then
        result:free()
    end
end

local function getPlayerAgeReal(cid)
    local minutes = getPlayerAgeMinutesReal(cid)
    return math.floor(minutes / MINUTES_PER_YEAR)
end

function onThink(interval, lastExecution)
    local players = getPlayersOnline()

    for i = 1, #players do
        local cid = players[i]

        local minutes = getPlayerAgeMinutesReal(cid)
        local age = getPlayerAgeReal(cid)

        if minutes < 0 then minutes = 0 end
        if age < 0 then age = 0 end

        local agingPoints = isPremium(cid) and 2 or 1
        local newMinutes = minutes + agingPoints
        local newAge = math.floor(newMinutes / MINUTES_PER_YEAR)
        local title = getTitleByAge(newAge)

        if newAge > age then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
                "Voce envelheceu! Agora voce tem " .. newAge .. " anos. (" .. title .. ")")

            local effectId = config.effects[getEffectIndex(newAge)]
            if effectId then
                doSendMagicEffect(getCreaturePosition(cid), effectId)
            end

            local ageData = newAge .. "|" .. title
            doPlayerSendExtendedOpcode(cid, opcode, ageData)
        end

        setPlayerAgeMinutesReal(cid, newMinutes)
    end

    return true
end
