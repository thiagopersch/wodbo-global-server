dofile("data/lib/vocation_ranks_lib.lua")

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  player:sendTextMessage(MESSAGE_STATUS_SMALL, "Sistema carregado!")
  return true
end
