dofile("data/lib/extoutfit_lib.lua")

local WING_ID = 1

function onUse(cid, item, fromPosition, itemEx, toPosition)
  if extoutfit.hasWing(cid, WING_ID) then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You already have this wing unlocked.")
    return true
  end

  extoutfit.addWing(cid, WING_ID)
  doPlayerSave(cid)
  doRemoveItem(item.uid, 1)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Dark Wings unlocked! Open the outfit window to equip it.")
  doPlayerSendOutfitWindow(cid)
  return true
end
