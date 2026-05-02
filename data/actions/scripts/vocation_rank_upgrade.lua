-- dofile("data/lib/vocation_ranks_lib.lua")

-- function onUse(cid, item, fromPosition, itemEx, toPosition)
--   local pos = getCreaturePosition(cid)
--   doSendMagicEffect(pos, 29) -- Efeito verde = script rodou

--   if not isPlayer(cid) then return true end

--   local itemId = item.itemid
--   local uid = item.uid -- UID do item exato que está sendo usado

--   -- Verifica se o item é válido (todos os itens registrados no actions.xml)
--   local validItems = {
--     [56386] = { cost = 1 },   -- Universal Upgrade Crystal
--     [56413] = { cost = 100 }, -- Bronze Fragment (Universal)
--     [56411] = { cost = 100 }, -- Silver Fragment (Universal)
--     [56414] = { cost = 100 }, -- Gold Fragment (Universal)
--     [56412] = { cost = 100 }, -- Diamond Fragment (Universal)
--     [56328] = { cost = 100 }, -- Old Universal Fragment (compatibilidade)
--   }

--   local itemInfo = validItems[itemId]
--   if not itemInfo then
--     local itemName = getItemNameById(itemId) or "Unknown"
--     doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL,
--       "This item (" .. itemName .. " ID: " .. itemId .. ") cannot be used for rank upgrades.")
--     return true
--   end

--   local cost = itemInfo.cost

--   -- IMPORTANTE: Remove o item usando o UID (funciona para item na mão ou chão)
--   local itemCount = item.type or 1 -- item.type = quantidade na pilha
--   local removed = false

--   if itemCount >= cost then
--     if itemCount > cost then
--       -- Reduz a pilha: remove o item atual e cria um novo com o resto
--       doRemoveItem(uid)
--       local rest = itemCount - cost
--       if rest > 0 then
--         doPlayerAddItem(cid, itemId, rest)
--       end
--       removed = true
--     else
--       -- Remove o item inteiro (pilha única)
--       removed = doRemoveItem(uid)
--     end
--   else
--     -- Se não tem item.type, tenta remover do inventário
--     removed = doPlayerRemoveItem(cid, itemId, cost)
--   end

--   if not removed then
--     doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Failed to remove item. Upgrade cancelled.")
--     return true
--   end

--   -- Faz o upgrade
--   local success = VocationRankLib.doUpgrade(cid, true)

--   if success then
--     doSendMagicEffect(pos, 28) -- Efeito de level up
--     doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Upgrade completed! You gained a new star.")
--   else
--     -- Se falhou o upgrade, devolve o item
--     doPlayerAddItem(cid, itemId, cost)
--     doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Upgrade failed. You may have reached max rank.")
--   end

--   return true
-- end
