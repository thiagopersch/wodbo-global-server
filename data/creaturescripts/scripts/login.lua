local config = {
  loginMessage = getConfigValue('loginMessage'),
  useFragHandler = getBooleanFromString(getConfigValue('useFragHandler'))
}

function onLogin(cid)
  local loss = getConfigValue('deathLostPercent')
  if (loss ~= nil) then
    doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, loss * 10)
  end

  local accountManager = getPlayerAccountManager(cid)
  if (accountManager == MANAGER_NONE) then
    local lastLogin, str = getPlayerLastLoginSaved(cid), config.loginMessage
    if (lastLogin > 0) then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, str)
      str = "Your last visit was on " .. os.date("%a %b %d %X %Y", lastLogin) .. "."
    else
      str = str .. " Welcome to DBOSupreme!"
      setPlayerStorageValue(cid, 30024, 0)
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, str)
  elseif (accountManager == MANAGER_NAMELOCK) then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
      "Hello, it appears that your character has been namelocked, what would you like as your new name?")
  elseif (accountManager == MANAGER_ACCOUNT) then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
      "Hello, type 'account' to manage your account and if you want to start over then type 'cancel'.")
  else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
      "Hello, type 'account' to create an account or type 'recover' to recover an account.")
  end

  local loot = ''
  for i = 1, #getPlayerStorageTable(cid, info.Storages[1]) do
    loot = loot ..
        getItemInfo(getPlayerStorageTable(cid, info.Storages[1])[i]).clientId ..
        '-' .. getItemNameById(getPlayerStorageTable(cid, info.Storages[1])[i]) .. '@'
  end
  doPlayerSendExtendedOpcode(cid, 157, loot)

  if (not isPlayerGhost(cid)) then
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
  end

  if getPlayerStorageValue(cid, 48913) == -1 then
    setPlayerStorageValue(cid, 48913, 0)
  end

  registerCreatureEvent(cid, "OutfitFilter")
  if (config.useFragHandler) then registerCreatureEvent(cid, "SkullCheck") end
  registerCreatureEvent(cid, "AnnounceDeath")
  registerCreatureEvent(cid, "AmuletDeath")
  registerCreatureEvent(cid, "critical")
  registerCreatureEvent(cid, "FullHpMana")
  registerCreatureEvent(cid, "FragReward")
  registerCreatureEvent(cid, "Mail")
  registerCreatureEvent(cid, "GuildMotd")
  registerCreatureEvent(cid, "Idle")
  registerCreatureEvent(cid, "KillingInTheNameOf")
  registerCreatureEvent(cid, "ReportBug")
  registerCreatureEvent(cid, "AdvanceSave")
  registerCreatureEvent(cid, "onlinepoints")
  registerCreatureEvent(cid, "fraglook")
  registerCreatureEvent(cid, "DeathPlayer")
  registerCreatureEvent(cid, "LevelRecompense")
  registerCreatureEvent(cid, "showKD")
  registerCreatureEvent(cid, "AdvLevelSpells")
  registerCreatureEvent(cid, "timelevel")
  registerCreatureEvent(cid, "IconMap")
  registerCreatureEvent(cid, "ChangeVocationOpcode")
  registerCreatureEvent(cid, "ChangeVocationLogin")
  registerCreatureEvent(cid, "ProfileOpcode")
  registerCreatureEvent(cid, "BankExtended")

  -- [NOVO]: Lê e escreve DIRETAMENTE na coluna SQL, ignorando storages limitados do TFS!
  local currentVoc = getPlayerVocation(cid)
  local guid = getPlayerGUID(cid)

  local q = db.getResult("SELECT `unlocked_vocations` FROM `players` WHERE `id` = " .. guid)
  local unlockedStr = ""
  if q and q:getID() ~= -1 then
    unlockedStr = q:getDataString("unlocked_vocations")
    q:free()
  end

  if unlockedStr == "" then
    db.query("UPDATE `players` SET `unlocked_vocations` = '" .. currentVoc .. "' WHERE `id` = " .. guid)
  else
    local found = false
    for v in unlockedStr:gmatch("(%d+)") do
      if tonumber(v) == currentVoc then
        found = true
        break
      end
    end
    if not found then
      local newVal = unlockedStr .. "," .. currentVoc
      db.query("UPDATE `players` SET `unlocked_vocations` = '" .. newVal .. "' WHERE `id` = " .. guid)
    end
  end

  -- [CORREÇÃO]: Sagastor parsing seguro
  local sagastor = 578744
  local sagaValue = getPlayerStorageValue(cid, sagastor)

  if sagaValue ~= -1 and tostring(sagaValue) ~= "" then
    local w = tostring(sagaValue):gsub(':', ''):explode(',')
    if w and #w >= 2 then
      local lookType = tonumber(w[1])
      local vocation = tonumber(w[2])

      if lookType and vocation and vocation > 0 then
        doCreatureChangeOutfit(cid, { lookType = lookType })
        doPlayerSetVocation(cid, vocation)

        if saga and saga[vocation] then
          for _, outfit in ipairs(saga[vocation]) do
            if type(outfit) == "table" and outfit.lookType == lookType then
              if outfit.aura then
                startAura(cid, outfit.aura, outfit.auraPos)
              end
              break
            end
          end
        end
      end
    end
  else
    if saga and saga[currentVoc] and saga[currentVoc][1] then
      doCreatureChangeOutfit(cid, { lookType = saga[currentVoc][1].lookType })
    end
  end

  local age = math.max(0, getPlayerStorageValue(cid, STORAGE_AGE))
  local title = getAgeTitle(age)
  local frags = getPlayerFrags(cid)
  local resets = getPlayerResets(cid)

  doPlayerSendExtendedOpcode(cid, 50, age .. "|" .. title .. "|" .. frags .. "|" .. resets)

  return true
end
