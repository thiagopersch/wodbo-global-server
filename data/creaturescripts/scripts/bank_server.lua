if not json then
  json = dofile('data/lib/json.lua')
end

local Config = {
  OpCode = 164,
  CoinIds = {
    gold = 2148,
    platinum = 2152,
    crystal = 2160
  },
  Cooldown = 3 -- seconds
}

local lastAction = {}

function onLogin(cid)
  registerCreatureEvent(cid, "BankOpcode")
  -- Send balance on login to sync client
  addEvent(sendBalance, 1000, cid)
  return true
end

function onExtendedOpcode(cid, opcode, buffer)
  if opcode ~= Config.OpCode then
    return true
  end

  if not getBooleanFromString(getConfigInfo('bankSystem')) then
    return true
  end

  local status, data = pcall(function()
    return json.decode(buffer)
  end)

  if not status or not data then
    return true
  end

  local action = data.action
  if action ~= "get_balance" then
    local now = os.time()
    if lastAction[cid] and now - lastAction[cid] < Config.Cooldown then
      return true
    end

    if hasCondition(cid, CONDITION_INFIGHT) then
      sendError(cid, "Bank cannot be used in fight.")
      return true
    end

    lastAction[cid] = now
  end

  if action == "get_balance" then
    sendBalance(cid)
  elseif action == "deposit" then
    handleDeposit(cid, data.amount)
  elseif action == "withdraw" then
    handleWithdraw(cid, data.amount)
  elseif action == "deposit_all" then
    handleDepositAll(cid)
  elseif action == "withdraw_all" then
    handleWithdrawAll(cid)
  elseif action == "transfer" then
    handleTransfer(cid, data.name, data.amount)
  elseif action == "transfer_all" then
    handleTransferAll(cid, data.name)
  end

  return true
end

function getCoinBreakdown(cid)
  return {
    gold = getPlayerItemCount(cid, Config.CoinIds.gold),
    platinum = getPlayerItemCount(cid, Config.CoinIds.platinum),
    crystal = getPlayerItemCount(cid, Config.CoinIds.crystal)
  }
end

function sendBalance(cid)
  if not isPlayer(cid) then return end

  local coins = getCoinBreakdown(cid)
  doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
    action = "balance_update",
    balance = getPlayerBalance(cid),
    money = getPlayerMoney(cid),
    goldCoins = coins.gold,
    platinumCoins = coins.platinum,
    crystalCoins = coins.crystal
  }))
end

function handleDeposit(cid, amount)
  if not isPlayer(cid) then return end

  amount = tonumber(amount)
  if not amount or amount <= 0 then
    sendError(cid, "Invalid amount.")
    return
  end

  if getPlayerMoney(cid) < amount then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You do not have enough money.")
    sendBalance(cid)
    return
  end

  if doPlayerDepositMoney(cid, amount) then
    local msg = "You have deposited " .. amount .. " gold. Your balance is " .. getPlayerBalance(cid) .. "."
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
    doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
      action = "transaction_result",
      status = "success",
      message = msg
    }))
    sendBalance(cid)
  else
    sendError(cid, "Could not deposit money.")
  end
end

function handleWithdraw(cid, amount)
  if not isPlayer(cid) then return end

  amount = tonumber(amount)
  if not amount or amount <= 0 then
    sendError(cid, "Invalid amount.")
    return
  end

  if getPlayerBalance(cid) < amount then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "There is not enough gold on your account.")
    sendBalance(cid)
    return
  end

  if doPlayerWithdrawMoney(cid, amount) then
    local msg = "You have withdrawn " .. amount .. " gold. Your balance is " .. getPlayerBalance(cid) .. "."
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
    doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
      action = "transaction_result",
      status = "success",
      message = msg
    }))
    sendBalance(cid)
  else
    sendError(cid, "Could not withdraw money.")
  end
end

function handleDepositAll(cid)
  if not isPlayer(cid) then return end

  local money = getPlayerMoney(cid)
  if money <= 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You do not have any money to deposit.")
    sendBalance(cid)
    return
  end

  if doPlayerDepositAllMoney(cid) then
    local msg = "You have deposited " .. money .. " gold. Your balance is " .. getPlayerBalance(cid) .. "."
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
    doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
      action = "transaction_result",
      status = "success",
      message = msg
    }))
    sendBalance(cid)
  else
    sendError(cid, "Could not deposit money.")
  end
end

function handleWithdrawAll(cid)
  if not isPlayer(cid) then return end

  local balance = getPlayerBalance(cid)
  if balance <= 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "There is not enough gold on your account.")
    sendBalance(cid)
    return
  end

  if doPlayerWithdrawAllMoney(cid) then
    local msg = "You have withdrawn " .. balance .. " gold. Your balance is 0."
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
    doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
      action = "transaction_result",
      status = "success",
      message = msg
    }))
    sendBalance(cid)
  else
    sendError(cid, "Could not withdraw money.")
  end
end

function handleTransfer(cid, targetName, amount)
  if not isPlayer(cid) then return end
  
  if not targetName or targetName == "" then
    sendError(cid, "Target name is missing.")
    return
  end

  amount = tonumber(amount)
  if not amount or amount <= 0 then
    sendError(cid, "Invalid amount.")
    return
  end

  if getPlayerBalance(cid) < amount then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You do not have enough gold in your account.")
    sendBalance(cid)
    return
  end

  if not playerExists(targetName) then
    sendError(cid, "Player " .. targetName .. " does not exist.")
    return
  end

  if doPlayerTransferMoneyTo(cid, targetName, amount) then
    doPlayerSave(cid, true)
    local msg = "You have transferred " .. amount .. " gold to " .. targetName .. "."
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
    doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
      action = "transaction_result",
      status = "success",
      message = msg
    }))
    sendBalance(cid)
  else
    sendError(cid, "Could not transfer money.")
  end
end

function handleTransferAll(cid, targetName)
  if not isPlayer(cid) then return end

  if not targetName or targetName == "" then
    sendError(cid, "Target name is missing.")
    return
  end

  local balance = getPlayerBalance(cid)
  if balance <= 0 then
    sendError(cid, "You do not have any gold in your account.")
    return
  end

  if not playerExists(targetName) then
    sendError(cid, "Player " .. targetName .. " does not exist.")
    return
  end

  if doPlayerTransferAllMoneyTo(cid, targetName) then
    doPlayerSave(cid, true)
    local msg = "You have transferred all your gold (" .. balance .. ") to " .. targetName .. "."
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
    doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
      action = "transaction_result",
      status = "success",
      message = msg
    }))
    sendBalance(cid)
  else
    sendError(cid, "Could not transfer money.")
  end
end

function sendError(cid, message)
  if not isPlayer(cid) then return end
  
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, message)
  doPlayerSendExtendedOpcode(cid, Config.OpCode, json.encode({
    action = "transaction_result",
    status = "error",
    message = message
  }))
  sendBalance(cid)
end


