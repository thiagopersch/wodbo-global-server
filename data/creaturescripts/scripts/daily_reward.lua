dofile('data/lib/daily_reward.lua')

function onLogin(cid)
    local month = tonumber(os.date("%m"))
    local year = tonumber(os.date("%Y"))
    DailyReward.ensureMonthlyList(month, year)
    DailyReward.sendState(cid)
    return true
end

function DailyReward.sendState(cid)
    local day = tonumber(os.date("%d"))
    local month = tonumber(os.date("%m"))
    local year = tonumber(os.date("%Y"))
    local daysInMonth = DailyReward.getDaysInMonth(month, year)
    local guid = getPlayerGUID(cid)

    local claimedMask = DailyReward.getClaimedMask(guid, month, year)
    local missedMask = DailyReward.getMissedMask(guid, month, year)
    local consecutive = DailyReward.getConsecutive(guid, month, year)

    local dailyItems = {}
    for i = 1, daysInMonth do
        local cfg = DailyReward.getDailyItem(i, month, year)
        if cfg then
            dailyItems[i] = cfg.clientId .. "," .. cfg.count
        else
            dailyItems[i] = "0,0"
        end
    end

    local bonusItems = {}
    for _, streakDay in ipairs(DailyReward.bonusDays) do
        local cfg = DailyReward.getBonusItem(streakDay, month, year)
        if cfg then
            local name = "Bonus"
            for _, item in ipairs(DailyReward.bonusPools.items) do
                if item.id == cfg.id then
                    name = item.name
                    break
                end
            end
            bonusItems[#bonusItems + 1] = streakDay .. ":" .. cfg.clientId .. "," .. cfg.count .. ":" .. name
        end
    end

    local bonusClaimedMask, bonusAvailableMask = DailyReward.getBonusState(guid, month, year, consecutive)

    local buffer = table.concat({
        day,
        month,
        year,
        daysInMonth,
        claimedMask,
        missedMask,
        consecutive,
        table.concat(dailyItems, ";"),
        table.concat(bonusItems, ";"),
        bonusClaimedMask,
        bonusAvailableMask
    }, "|")

    doPlayerSendExtendedOpcode(cid, DailyReward.opcode, buffer)
end

function onExtendedOpcode(cid, opcode, buffer)
    if opcode ~= DailyReward.opcode then return end

    if buffer == "open" then
        DailyReward.sendState(cid)
        return
    end

    if buffer == "claim" then
        local day = tonumber(os.date("%d"))
        local month = tonumber(os.date("%m"))
        local year = tonumber(os.date("%Y"))
        local guid = getPlayerGUID(cid)

        local checkQ = db.getResult(string.format(
            "SELECT 1 FROM `player_daily_rewards` WHERE `player_id` = %d AND `day` = %d AND `month` = %d AND `year` = %d",
            guid, day, month, year))
        if checkQ and checkQ:getID() ~= -1 then
            checkQ:free()
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Você já resgatou sua recompensa de hoje.")
            return
        end

        local cfg = DailyReward.getDailyItem(day, month, year)
        if not cfg then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro: Recompensa do dia não encontrada.")
            return
        end

        local itemInfo = getItemInfo(cfg.id)
        local weight = itemInfo and (itemInfo.weight * cfg.count) or 0
        if getPlayerFreeCap(cid) < weight then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Você não tem capacidade suficiente.")
            return
        end

        local item = doCreateItemEx(cfg.id, cfg.count)
        if item > 0 then
            local ret = doPlayerAddItemEx(cid, item, true)
            if ret == RETURNVALUE_NOERROR then
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
                    "Você resgatou sua recompensa diária: " .. cfg.count .. "x " .. getItemNameById(cfg.id) .. ".")

                db.query(string.format(
                    "INSERT INTO `player_daily_rewards` (`player_id`, `day`, `month`, `year`, `item_id`, `count`, `timestamp`) VALUES (%d, %d, %d, %d, %d, %d, %d)",
                    guid, day, month, year, cfg.id, cfg.count, os.time()))

                DailyReward.sendState(cid)
            else
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro ao entregar item. Verifique sua backpack.")
            end
        else
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro técnico: Item inválido.")
        end
        return
    end

    local claimBonusPrefix = "claim_bonus|"
    if string.sub(buffer, 1, #claimBonusPrefix) == claimBonusPrefix then
        local streakDay = tonumber(string.sub(buffer, #claimBonusPrefix + 1))
        if not streakDay then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro: Bônus inválido.")
            return
        end

        local month = tonumber(os.date("%m"))
        local year = tonumber(os.date("%Y"))
        local guid = getPlayerGUID(cid)

        local checkQ = db.getResult(string.format(
            "SELECT 1 FROM `player_daily_reward_bonus` WHERE `player_id` = %d AND `month` = %d AND `year` = %d AND `streak_day` = %d",
            guid, month, year, streakDay))
        if checkQ and checkQ:getID() ~= -1 then
            checkQ:free()
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Você já resgatou este bônus.")
            return
        end

        local consecutive = DailyReward.getConsecutive(guid, month, year)
        if consecutive < streakDay then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL,
                "Você precisa de " .. streakDay .. " dias consecutivos para resgatar este bônus. Atual: " .. consecutive .. ".")
            return
        end

        local cfg = DailyReward.getBonusItem(streakDay, month, year)
        if not cfg then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro: Item do bônus não encontrado.")
            return
        end

        local itemInfo = getItemInfo(cfg.id)
        local weight = itemInfo and (itemInfo.weight * cfg.count) or 0
        if getPlayerFreeCap(cid) < weight then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Você não tem capacidade suficiente.")
            return
        end

        local item = doCreateItemEx(cfg.id, cfg.count)
        if item > 0 then
            local ret = doPlayerAddItemEx(cid, item, true)
            if ret == RETURNVALUE_NOERROR then
                local bonusName = "Bônus"
                for _, bi in ipairs(DailyReward.bonusPools.items) do
                    if bi.id == cfg.id then
                        bonusName = bi.name
                        break
                    end
                end

                db.query(string.format(
                    "INSERT INTO `player_daily_reward_bonus` (`player_id`, `month`, `year`, `streak_day`, `claimed_at`) VALUES (%d, %d, %d, %d, %d)",
                    guid, month, year, streakDay, os.time()))

                -- Outfit aleatório
                local outfit = DailyReward.bonusPools.outfits[math.random(#DailyReward.bonusPools.outfits)]
                DailyReward.giveOutfit(cid, outfit.lookType)

                -- Lista de dias resgatados
                local daysList = DailyReward.getClaimedDaysList(guid, month, year)

                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
                    "Você resgatou o bônus de " .. streakDay .. " dias consecutivos!\n" ..
                    "Item: " .. cfg.count .. "x " .. bonusName .. "\n" ..
                    "Outfit: " .. outfit.name .. "\n" ..
                    "Dias consecutivos: " .. consecutive .. "\n" ..
                    "Dias resgatados: " .. daysList)

                DailyReward.sendState(cid)
            else
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro ao entregar bônus. Verifique sua backpack.")
            end
        else
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro técnico: Item de bônus inválido.")
        end
        return
    end
end