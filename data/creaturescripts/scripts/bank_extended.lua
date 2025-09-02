function onExtendedOpcode(player, opcode, buffer)
  if opcode == 8 then
    local data = buffer:explode("&")
    local action = tonumber(data[1])

    if action == 1 then
      -- Solicitação de saldo
      local inventoryBalance = player:getMoney()
      local bankBalance = player:getBankBalance()
      player:sendExtendedOpcode(8, "1&" .. inventoryBalance .. "&" .. bankBalance)
    elseif action == 2 then
      -- Depósito total
      local money = player:getMoney()
      if money > 0 then
        player:setBankBalance(player:getBankBalance() + money)
        player:removeMoney(money)
        player:sendExtendedOpcode(8, "1&" .. player:getMoney() .. "&" .. player:getBankBalance())
      else
        player:sendExtendedOpcode(8, "10&No money to deposit")
      end
    elseif action == 3 then
      -- Saque total
      local bankBalance = player:getBankBalance()
      if bankBalance > 0 then
        player:addMoney(bankBalance)
        player:setBankBalance(0)
        player:sendExtendedOpcode(8, "1&" .. player:getMoney() .. "&" .. player:getBankBalance())
      else
        player:sendExtendedOpcode(8, "10&No money to withdraw")
      end
    elseif action == 4 then
      -- Depósito de valor específico
      local amount = tonumber(data[2])
      if amount and amount > 0 and player:getMoney() >= amount then
        player:setBankBalance(player:getBankBalance() + amount)
        player:removeMoney(amount)
        player:sendExtendedOpcode(8, "1&" .. player:getMoney() .. "&" .. player:getBankBalance())
      else
        player:sendExtendedOpcode(8, "10&Invalid amount or not enough money")
      end
    elseif action == 5 then
      -- Saque de valor específico
      local amount = tonumber(data[2])
      if amount and amount > 0 and player:getBankBalance() >= amount then
        player:addMoney(amount)
        player:setBankBalance(player:getBankBalance() - amount)
        player:sendExtendedOpcode(8, "1&" .. player:getMoney() .. "&" .. player:getBankBalance())
      else
        player:sendExtendedOpcode(8, "10&Invalid amount or not enough money in bank")
      end
    end
  end
end
