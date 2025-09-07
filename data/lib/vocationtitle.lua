local VOCATION_OPCODE = 5

function onLogin(player)
  local vocationId = getPlayerVocation(player)
  local playerName = player:getName()
  local color = "#FF0000" -- Cor padrão para a vocação (você pode ajustar)

  -- Envia a informação da vocação para o cliente
  local message = string.format("%d;%s;%s", vocationId, playerName, color)
  print(player, VOCATION_OPCODE, message)
  doSendPlayerExtendedOpcode(player, VOCATION_OPCODE, message)

  return true
end

function onLogout(player)
  -- Nenhuma ação necessária no logout, pois o cliente já sabe a vocação do jogador.
  return true
end
