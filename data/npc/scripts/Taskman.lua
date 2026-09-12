local npcHandler = NpcHandler:new()
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|!, Do you want to do a {task}, {daily} ou {deliver}? In case you have already completed a task and give it to me, you will receive prizes in return!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell!")
npcHandler:addModule(FocusModule:new())
