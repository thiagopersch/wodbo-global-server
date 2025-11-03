-- data/actions/scripts/unlock_vocation.lua

local fragments = {
  [49509] = { vocId = 17, vocName = "Goku", required = 1 },
  [49512] = { vocId = 6, vocName = "Buu", required = 1 },
  [49528] = { vocId = 4, vocName = "Broly", required = 1 },
  [49515] = { vocId = 59, vocName = "Rukia", required = 100 },
  -- Adicione mais aqui...
}

local STORAGE_KEY = 50001

function onUse(cid, item, fromPosition, itemEx, toPosition)
  local player = cid
  local frag = fragments[item.itemid]
  if not frag then
    return false
  end

  -- Conta quantos fragments o jogador tem
  local count = getPlayerItemCount(player, item.itemid)
  if count < frag.required then
    doPlayerSendCancel(player,
      "You need " .. frag.required .. " " .. getItemNameById(item.itemid) .. " to unlock " .. frag.vocName .. ".")
    return true
  end

  -- Carrega vocações desbloqueadas
  local unlockedStr = getPlayerStorageValue(player, STORAGE_KEY)
  local unlocked = {}
  if unlockedStr and unlockedStr ~= "" and unlockedStr ~= "-1" then
    for voc in string.gmatch(unlockedStr, "[^,]+") do
      local v = tonumber(voc)
      if v then table.insert(unlocked, v) end
    end
  end

  -- Já tem?
  for _, v in ipairs(unlocked) do
    if v == frag.vocId then
      doPlayerSendCancel(player, "You already unlocked " .. frag.vocName .. " vocation.")
      return true
    end
  end

  -- Adiciona
  table.insert(unlocked, frag.vocId)
  local newStr = table.concat(unlocked, ",")

  -- Salva no DB
  local guid = getPlayerGUID(player)
  db.query("UPDATE `players` SET `unlocked_vocations` = " .. db.escapeString(newStr) .. " WHERE `id` = " .. guid)

  -- Atualiza storage
  setPlayerStorageValue(player, STORAGE_KEY, newStr)

  -- Remove 100 fragments
  doPlayerRemoveItem(player, item.itemid, frag.required)

  -- Feedback
  doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "You unlocked " .. frag.vocName .. " vocation!")
  doSendMagicEffect(getCreaturePosition(player), CONST_ME_HOLYDAMAGE)

  return true
end
