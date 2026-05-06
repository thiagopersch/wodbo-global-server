dofile('data/lib/daily_reward.lua')

function onLogin(cid)
    DailyReward.sendState(cid)
    return true
end

function DailyReward.sendState(cid)
    local day = tonumber(os.date("%d"))
    local month = tonumber(os.date("%m"))
    local year = tonumber(os.date("%Y"))
    local daysInMonth = DailyReward.getDaysInMonth(month, year)

    -- Reset se mudar o mês
    if getPlayerStorageValue(cid, DailyReward.storageLastMonth) ~= month then
        setPlayerStorageValue(cid, DailyReward.storageLastMonth, month)
        -- Não precisamos mais resetar storage de claimed, o DB cuida disso pelo month/year
    end

    -- Lógica de dias consecutivos
    local lastDay = getPlayerStorageValue(cid, DailyReward.storageLastDay)
    local consecutive = getPlayerStorageValue(cid, DailyReward.storageConsecutive)
    if consecutive == -1 then consecutive = 0 end

    if lastDay ~= day then
        if lastDay == day - 1 or (lastDay > day and day == 1) then
            setPlayerStorageValue(cid, DailyReward.storageConsecutive, consecutive + 1)
        else
            setPlayerStorageValue(cid, DailyReward.storageConsecutive, 1)
        end
        setPlayerStorageValue(cid, DailyReward.storageLastDay, day)
    end

    -- Busca dias coletados no Banco de Dados e monta o Bitmask para o Client
    local claimedMask = 0
    local guid = getPlayerGUID(cid)
    local q = db.getResult(string.format(
        "SELECT `day` FROM `player_daily_rewards` WHERE `player_id` = %d AND `month` = %d AND `year` = %d", guid, month,
        year))

    if q and q:getID() ~= -1 then
        repeat
            local d = q:getDataInt("day")
            claimedMask = DailyReward.setDayClaimed(claimedMask, d)
        until not q:next()
        q:free()
    end

    -- Conta o total de resgates no mês atual para os bônus
    local totalClaimsInMonth = 0
    local countQ = db.getResult(string.format(
        "SELECT COUNT(*) as `total` FROM `player_daily_rewards` WHERE `player_id` = %d AND `month` = %d AND `year` = %d",
        guid, month, year))
    if countQ and countQ:getID() ~= -1 then
        totalClaimsInMonth = countQ:getDataInt("total")
        countQ:free()
    end

    local lastClaim = getPlayerStorageValue(cid, DailyReward.storageLastClaim)

    local itemsTable = {}
    for i = 1, daysInMonth do
        local cfg = DailyReward.getItemForDate(i, month)
        table.insert(itemsTable, cfg.clientId .. "," .. cfg.count)
    end

    local bonusTable = {}
    for k, v in pairs(DailyReward.bonusItems) do
        table.insert(bonusTable, k .. "," .. v.clientId .. "," .. v.count .. "," .. v.name)
    end

    local buffer = table.concat({
        day,
        month,
        year,
        claimedMask,
        totalClaimsInMonth, -- Enviando o total do mês em vez da sequência
        lastClaim,
        table.concat(itemsTable, ";"),
        table.concat(bonusTable, ";")
    }, "|")

    doPlayerSendExtendedOpcode(cid, DailyReward.opcode, buffer)
end

function onExtendedOpcode(cid, opcode, buffer)
    if opcode ~= DailyReward.opcode then return end

    if buffer == "claim" then
        print("DailyReward: Tentativa de resgate por " .. getCreatureName(cid))
        local day = tonumber(os.date("%d"))
        local month = tonumber(os.date("%m"))
        local year = tonumber(os.date("%Y"))

        local lastClaim = getPlayerStorageValue(cid, DailyReward.storageLastClaim)
        if lastClaim > 0 and os.date("%d", lastClaim) == os.date("%d") and os.date("%m", lastClaim) == os.date("%m") then
            print("DailyReward: Jogador já resgatou hoje.")
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Você já resgatou sua recompensa de hoje.")
            return
        end

        local cfg = DailyReward.getItemForDate(day, month)
        if not cfg then 
            print("DailyReward: Configuração não encontrada para o dia " .. day .. " do mês " .. month)
            return
        end

        -- VERIFICAÇÃO DE SEGURANÇA: Checa no DB se o dia já foi resgatado
        local guid = getPlayerGUID(cid)
        local checkQ = db.getResult(string.format(
            "SELECT 1 FROM `player_daily_rewards` WHERE `player_id` = %d AND `day` = %d AND `month` = %d AND `year` = %d",
            guid, day, month, year))
        if checkQ and checkQ:getID() ~= -1 then
            checkQ:free()
            print("DailyReward: Tentativa de resgate duplicado bloqueada pelo DB para GUID: " .. guid)
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL,
                "Você já resgatou a recompensa de hoje (Validado pelo sistema).")
            return
        end

        -- Checagem de peso compatível com TFS 0.4
        local itemInfo = getItemInfo(cfg.id)
        local weight = itemInfo and (itemInfo.weight * cfg.count) or 0
        if getPlayerFreeCap(cid) < weight then
            print("DailyReward: Sem capacidade. Peso necessário: " .. weight)
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Você não tem capacidade suficiente.")
            return
        end

        -- Dar item usando a logica identica ao comando /i (createitem.lua)
        print("DailyReward: Tentando adicionar item " .. cfg.id .. " (Quantidade: " .. cfg.count .. ")")

        local item = doCreateItemEx(cfg.id, cfg.count)
        if item > 0 then
            local ret = doPlayerAddItemEx(cid, item, true) -- O 'true' garante que caia no chao se estiver cheio
            if ret == RETURNVALUE_NOERROR then
                print("DailyReward: Item adicionado com sucesso!")
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
                    "Você recebeu sua recompensa diária: " .. cfg.count .. "x " .. getItemNameById(cfg.id) .. ".")

                -- Salva no Banco de Dados
                local guid = getPlayerGUID(cid)
                print("DailyReward: Salvando no banco de dados para GUID: " .. guid)
                db.query(string.format(
                    "INSERT INTO `player_daily_rewards` (`player_id`, `day`, `month`, `year`, `item_id`, `count`, `timestamp`) VALUES (%d, %d, %d, %d, %d, %d, %d)",
                    guid, day, month, year, cfg.id, cfg.count, os.time()))

                setPlayerStorageValue(cid, DailyReward.storageLastClaim, os.time())

                local consecutive = getPlayerStorageValue(cid, DailyReward.storageConsecutive)
                if DailyReward.bonusItems[consecutive] then
                    local bCfg = DailyReward.bonusItems[consecutive]
                    local bItem = doCreateItemEx(bCfg.id, bCfg.count)
                    doPlayerAddItemEx(cid, bItem, true)
                    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
                        "BÔNUS CONSECUTIVO! Você recebeu: " .. bCfg.count .. "x " .. bCfg.name .. ".")
                end

                DailyReward.sendState(cid)
            else
                print("DailyReward: Erro ao adicionar item (Erro: " .. ret .. ")")
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro ao entregar item. Verifique sua backpack.")
            end
        else
            print("DailyReward: Erro ao criar o item (ID invalido: " .. cfg.id .. ")")
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Erro tecnico: Item invalido.")
        end
    elseif buffer == "open" then
        DailyReward.sendState(cid)
    end
end
