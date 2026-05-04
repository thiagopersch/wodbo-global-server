-- ============================================================
-- vocation_rank_upgrade.lua
-- Handles using fragment items to upgrade vocation rank
-- ============================================================

dofile("data/lib/vocation_ranks_lib.lua")

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
  local itemId = item.itemid
  local config = VocationRankConfig

  -- Check if it's the universal fragment
  if itemId == config.UniversalFragmentItemId then
    VocationRankLib.doUpgrade(cid, "universal")
    return true
  end

  -- Check if it's a specific vocation fragment
  local vocationId = getPlayerVocation(cid)
  local vocConfig = config.Vocations[vocationId]
  if not vocConfig then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Your vocation cannot be upgraded.")
    return false
  end

  if itemId == vocConfig.specificFragmentItemId then
    VocationRankLib.doUpgrade(cid, "specific")
    return true
  end

  -- If the item is not a valid fragment
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "This item cannot be used to upgrade your vocation.")
  return false
end
