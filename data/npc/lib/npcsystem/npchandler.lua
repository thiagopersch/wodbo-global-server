-- Advanced NPC System (Created by Jiddo),
-- Modified by TheForgottenServer Team.

if (NpcHandler == nil) then
	-- Constant talkdelay behaviors.
	TALKDELAY_NONE               = 0 -- No talkdelay. Npc will reply immedeatly.
	TALKDELAY_ONTHINK            = 1 -- Talkdelay handled through the onThink callback function. (Default)
	TALKDELAY_EVENT              = 2 -- Not yet implemented

	-- Currently applied talkdelay behavior. TALKDELAY_ONTHINK is default.
	NPCHANDLER_TALKDELAY         = TALKDELAY_ONTHINK

	-- Constant conversation behaviors.
	CONVERSATION_DEFAULT         = 0 -- Conversation through default window, like it was before 8.2 update.
	CONVERSATION_PRIVATE         = 1 -- Conversation through NPCs chat window, as of 8.2 update. (Default)
	--Small Note: Private conversations also means the NPC will use multi-focus system.

	-- Currently applied conversation behavior. CONVERSATION_PRIVATE is default.
	NPCHANDLER_CONVBEHAVIOR      = CONVERSATION_PRIVATE

	-- Constant indexes for defining default messages.
	MESSAGE_GREET                = 1 -- When the player greets the npc.
	MESSAGE_FAREWELL             = 2 -- When the player unGreets the npc.
	MESSAGE_BUY                  = 3 -- When the npc asks the player if he wants to buy something.
	MESSAGE_ONBUY                = 4 -- When the player successfully buys something via talk.
	MESSAGE_BOUGHT               = 5 -- When the player bought something through the shop window.
	MESSAGE_SELL                 = 6 -- When the npc asks the player if he wants to sell something.
	MESSAGE_ONSELL               = 7 -- When the player successfully sells something via talk.
	MESSAGE_SOLD                 = 8 -- When the player sold something through the shop window.
	MESSAGE_MISSINGMONEY         = 9 -- When the player does not have enough money.
	MESSAGE_NEEDMONEY            = 10 -- Same as above, used for shop window.
	MESSAGE_MISSINGITEM          = 11 -- When the player is trying to sell an item he does not have.
	MESSAGE_NEEDITEM             = 12 -- Same as above, used for shop window.
	MESSAGE_NEEDSPACE            = 13 -- When the player don't have any space to buy an item
	MESSAGE_NEEDMORESPACE        = 14 -- When the player has some space to buy an item, but not enough space
	MESSAGE_IDLETIMEOUT          = 15 -- When the player has been idle for longer then idleTime allows.
	MESSAGE_WALKAWAY             = 16 -- When the player walks out of the talkRadius of the npc.
	MESSAGE_DECLINE              = 17 -- When the player says no to something.
	MESSAGE_SENDTRADE            = 18 -- When the npc sends the trade window to the player
	MESSAGE_NOSHOP               = 19 -- When the npc's shop is requested but he doesn't have any
	MESSAGE_ONCLOSESHOP          = 20 -- When the player closes the npc's shop window
	MESSAGE_ALREADYFOCUSED       = 21 -- When the player already has the focus of this npc.
	MESSAGE_PLACEDINQUEUE        = 22 -- When the player has been placed in the costumer queue.

	-- Constant indexes for callback functions. These are also used for module callback ids.
	CALLBACK_CREATURE_APPEAR     = 1
	CALLBACK_CREATURE_DISAPPEAR  = 2
	CALLBACK_CREATURE_SAY        = 3
	CALLBACK_ONTHINK             = 4
	CALLBACK_GREET               = 5
	CALLBACK_FAREWELL            = 6
	CALLBACK_MESSAGE_DEFAULT     = 7
	CALLBACK_PLAYER_ENDTRADE     = 8
	CALLBACK_PLAYER_CLOSECHANNEL = 9
	CALLBACK_ONBUY               = 10
	CALLBACK_ONSELL              = 11

	-- Addidional module callback ids
	CALLBACK_MODULE_INIT         = 12
	CALLBACK_MODULE_RESET        = 13

	-- Constant strings defining the keywords to replace in the default messages.
	TAG_PLAYERNAME               = '|PLAYERNAME|'
	TAG_ITEMCOUNT                = '|ITEMCOUNT|'
	TAG_TOTALCOST                = '|TOTALCOST|'
	TAG_ITEMNAME                 = '|ITEMNAME|'
	TAG_QUEUESIZE                = '|QUEUESIZE|'

	NpcHandler                   = {
		keywordHandler = nil,
		focuses = nil,
		talkStart = nil,
		idleTime = 300,
		talkRadius = 3,
		talkDelayTime = 1, -- Seconds to delay outgoing messages.
		queue = nil,
		talkDelay = nil,
		callbackFunctions = nil,
		modules = nil,
		shopItems = nil, -- They must be here since ShopModule uses "static" functions
		messages = {
			-- These are the default replies of all npcs. They can/should be changed individually for each npc.
			[MESSAGE_GREET]          = 'Welcome, |PLAYERNAME|! I’ve been waiting for you!',
			[MESSAGE_FAREWELL]       = 'Goodbye, |PLAYERNAME|!',
			[MESSAGE_BUY]            = 'Do you want to buy |ITEMCOUNT| |ITEMNAME| for |TOTALCOST| gold coins?',
			[MESSAGE_ONBUY]          = 'Goodbye, come back anytime.',
			[MESSAGE_BOUGHT]         = 'Bought |ITEMCOUNT|x |ITEMNAME| for |TOTALCOST| gold.',
			[MESSAGE_SELL]           = 'Do you want to sell |ITEMCOUNT| |ITEMNAME| for |TOTALCOST| gold coins?',
			[MESSAGE_ONSELL]         = 'Thank you for this |ITEMNAME|, |PLAYERNAME|.',
			[MESSAGE_SOLD]           = 'Sold |ITEMCOUNT|x |ITEMNAME| for |TOTALCOST| gold.',
			[MESSAGE_MISSINGMONEY]   = 'Sorry, you don’t have any money.',
			[MESSAGE_NEEDMONEY]      = 'You don’t have enough money.',
			[MESSAGE_MISSINGITEM]    = 'You don’t even have that item, |PLAYERNAME|!',
			[MESSAGE_NEEDITEM]       = 'You don’t have that item.',
			[MESSAGE_NEEDSPACE]      = 'You don’t have enough capacity.',
			[MESSAGE_NEEDMORESPACE]  = 'You don’t have enough capacity for all the items.',
			[MESSAGE_IDLETIMEOUT]    = 'Next, please!',
			[MESSAGE_WALKAWAY]       = 'See you later!',
			[MESSAGE_DECLINE]        = 'Not good enough, huh...?',
			[MESSAGE_SENDTRADE]      = 'Here’s my offer, |PLAYERNAME|. Want anything?',
			[MESSAGE_NOSHOP]         = 'Sorry, I don’t trade anything.',
			[MESSAGE_ONCLOSESHOP]    = 'Thanks, come back whenever you need.',
			[MESSAGE_ALREADYFOCUSED] = '|PLAYERNAME|! I’m already talking to you...',
			[MESSAGE_PLACEDINQUEUE]  = '|PLAYERNAME|, please wait your turn. There are |QUEUESIZE| customers ahead of you.'
		}
	}

	-- Creates a new NpcHandler with an empty callbackFunction stack.
	function NpcHandler:new(keywordHandler)
		local obj = {}
		obj.callbackFunctions = {}
		obj.modules = {}
		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
			obj.focuses = {}
			obj.talkStart = {}
		else
			obj.queue = Queue:new(obj)
			obj.focuses = 0
			obj.talkStart = 0
		end
		obj.talkDelay = {}
		obj.keywordHandler = keywordHandler
		obj.messages = {}
		obj.shopItems = {}

		setmetatable(obj.messages, self.messages)
		self.messages.__index = self.messages

		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	-- Re-defines the maximum idle time allowed for a player when talking to this npc.
	function NpcHandler:setMaxIdleTime(newTime)
		self.idleTime = newTime
	end

	-- Attackes a new keyword handler to this npchandler
	function NpcHandler:setKeywordHandler(newHandler)
		self.keywordHandler = newHandler
	end

	-- Function used to change the focus of this npc.
	function NpcHandler:addFocus(newFocus)
		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
			if (self:isFocused(newFocus)) then
				return
			end

			table.insert(self.focuses, newFocus)
		else
			self.focuses = newFocus
		end

		self:updateFocus()
	end

	NpcHandler.changeFocus = NpcHandler.addFocus --"changeFocus" looks better for CONVERSATION_DEFAULT

	-- Function used to verify if npc is focused to certain player
	function NpcHandler:isFocused(focus)
		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
			for k, v in pairs(self.focuses) do
				if v == focus then
					return true
				end
			end

			return false
		end

		return (self.focuses == focus)
	end

	-- This function should be called on each onThink and makes sure the npc faces the player it is talking to.
	--	Should also be called whenever a new player is focused.
	function NpcHandler:updateFocus()
		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
			for pos, focus in pairs(self.focuses) do
				if (focus ~= nil) then
					doNpcSetCreatureFocus(focus)
					return
				end
			end

			doNpcSetCreatureFocus(0)
		else
			doNpcSetCreatureFocus(self.focuses)
		end
	end

	-- Used when the npc should un-focus the player.
	function NpcHandler:releaseFocus(focus)
		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
			if (not self:isFocused(focus)) then
				return
			end

			local pos = nil
			for k, v in pairs(self.focuses) do
				if v == focus then
					pos = k
				end
			end
			table.remove(self.focuses, pos)
			self.talkStart[focus] = nil
			closeShopWindow(focus) --Even if it can not exist, we need to prevent it.
			self:updateFocus()
		else
			closeShopWindow(focus)
			self:changeFocus(0)
		end
	end

	-- Returns the callback function with the specified id or nil if no such callback function exists.
	function NpcHandler:getCallback(id)
		local ret = nil
		if (self.callbackFunctions ~= nil) then
			ret = self.callbackFunctions[id]
		end

		return ret
	end

	-- Changes the callback function for the given id to callback.
	function NpcHandler:setCallback(id, callback)
		if (self.callbackFunctions ~= nil) then
			self.callbackFunctions[id] = callback
		end
	end

	-- Adds a module to this npchandler and inits it.
	function NpcHandler:addModule(module)
		if (self.modules == nil or module == nil) then
			return false
		end

		module:init(self)
		if (module.parseParameters ~= nil) then
			module:parseParameters()
		end

		table.insert(self.modules, module)
		return true
	end

	-- Calls the callback function represented by id for all modules added to this npchandler with the given arguments.
	function NpcHandler:processModuleCallback(id, ...)
		local ret = true
		for i, module in pairs(self.modules) do
			local tmpRet = true
			if (id == CALLBACK_CREATURE_APPEAR and module.callbackOnCreatureAppear ~= nil) then
				tmpRet = module:callbackOnCreatureAppear(unpack(arg))
			elseif (id == CALLBACK_CREATURE_DISAPPEAR and module.callbackOnCreatureDisappear ~= nil) then
				tmpRet = module:callbackOnCreatureDisappear(unpack(arg))
			elseif (id == CALLBACK_CREATURE_SAY and module.callbackOnCreatureSay ~= nil) then
				tmpRet = module:callbackOnCreatureSay(unpack(arg))
			elseif (id == CALLBACK_PLAYER_ENDTRADE and module.callbackOnPlayerEndTrade ~= nil) then
				tmpRet = module:callbackOnPlayerEndTrade(unpack(arg))
			elseif (id == CALLBACK_PLAYER_CLOSECHANNEL and module.callbackOnPlayerCloseChannel ~= nil) then
				tmpRet = module:callbackOnPlayerCloseChannel(unpack(arg))
			elseif (id == CALLBACK_ONBUY and module.callbackOnBuy ~= nil) then
				tmpRet = module:callbackOnBuy(unpack(arg))
			elseif (id == CALLBACK_ONSELL and module.callbackOnSell ~= nil) then
				tmpRet = module:callbackOnSell(unpack(arg))
			elseif (id == CALLBACK_ONTHINK and module.callbackOnThink ~= nil) then
				tmpRet = module:callbackOnThink(unpack(arg))
			elseif (id == CALLBACK_GREET and module.callbackOnGreet ~= nil) then
				tmpRet = module:callbackOnGreet(unpack(arg))
			elseif (id == CALLBACK_FAREWELL and module.callbackOnFarewell ~= nil) then
				tmpRet = module:callbackOnFarewell(unpack(arg))
			elseif (id == CALLBACK_MESSAGE_DEFAULT and module.callbackOnMessageDefault ~= nil) then
				tmpRet = module:callbackOnMessageDefault(unpack(arg))
			elseif (id == CALLBACK_MODULE_RESET and module.callbackOnModuleReset ~= nil) then
				tmpRet = module:callbackOnModuleReset(unpack(arg))
			end

			if (not tmpRet) then
				ret = false
				break
			end
		end

		return ret
	end

	-- Returns the message represented by id.
	function NpcHandler:getMessage(id)
		local ret = nil
		if (self.messages ~= nil) then
			ret = self.messages[id]
		end

		return ret
	end

	-- Changes the default response message with the specified id to newMessage.
	function NpcHandler:setMessage(id, newMessage)
		if (self.messages ~= nil) then
			self.messages[id] = newMessage
		end
	end

	-- Translates all message tags found in msg using parseInfo
	function NpcHandler:parseMessage(msg, parseInfo)
		local ret = msg
		for search, replace in pairs(parseInfo) do
			ret = string.gsub(ret, search, replace)
		end

		return ret
	end

	-- Makes sure the npc un-focuses the currently focused player
	function NpcHandler:unGreet(cid)
		if (not self:isFocused(cid)) then
			return
		end

		local callback = self:getCallback(CALLBACK_FAREWELL)
		if (callback == nil or callback(cid)) then
			if (self:processModuleCallback(CALLBACK_FAREWELL)) then
				if (self.queue == nil or not self.queue:greetNext()) then
					local msg = self:getMessage(MESSAGE_FAREWELL)
					local parseInfo = { [TAG_PLAYERNAME] = getPlayerName(cid) }
					msg = self:parseMessage(msg, parseInfo)

					self:say(msg, cid)
					self:releaseFocus(cid)
					self:say(msg)
				end
			end
		end
	end

	-- Greets a new player.
	function NpcHandler:greet(cid)
		if (cid ~= 0) then
			local callback = self:getCallback(CALLBACK_GREET)
			if (callback == nil or callback(cid)) then
				if (self:processModuleCallback(CALLBACK_GREET, cid)) then
					local msg = self:getMessage(MESSAGE_GREET)
					local parseInfo = { [TAG_PLAYERNAME] = getCreatureName(cid) }
					msg = self:parseMessage(msg, parseInfo)

					self:say(msg)
					self:addFocus(cid)
					self:say(msg, cid)
				end
			end
		end
	end

	-- Handles onCreatureAppear events. If you with to handle this yourself, please use the CALLBACK_CREATURE_APPEAR callback.
	function NpcHandler:onCreatureAppear(cid)
		local callback = self:getCallback(CALLBACK_CREATURE_APPEAR)
		if (callback == nil or callback(cid)) then
			if (self:processModuleCallback(CALLBACK_CREATURE_APPEAR, cid)) then
				--
			end
		end
	end

	-- Handles onCreatureDisappear events. If you with to handle this yourself, please use the CALLBACK_CREATURE_DISAPPEAR callback.
	function NpcHandler:onCreatureDisappear(cid)
		local callback = self:getCallback(CALLBACK_CREATURE_DISAPPEAR)
		if (callback == nil or callback(cid)) then
			if (self:processModuleCallback(CALLBACK_CREATURE_DISAPPEAR, cid)) then
				if (self:isFocused(cid)) then
					self:unGreet(cid)
				end
			end
		end
	end

	-- Handles onCreatureSay events. If you with to handle this yourself, please use the CALLBACK_CREATURE_SAY callback.
	function NpcHandler:onCreatureSay(cid, class, msg)
		local callback = self:getCallback(CALLBACK_CREATURE_SAY)
		if (callback == nil or callback(cid, class, msg)) then
			if (self:processModuleCallback(CALLBACK_CREATURE_SAY, cid, class, msg)) then
				if (not self:isInRange(cid)) then
					return
				end

				if (self.keywordHandler ~= nil) then
					if ((self:isFocused(cid) and (class == TALKTYPE_PRIVATE_PN or NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT)) or not self:isFocused(cid)) then
						local ret = self.keywordHandler:processMessage(cid, msg)
						if (not ret) then
							local callback = self:getCallback(CALLBACK_MESSAGE_DEFAULT)
							if (callback ~= nil and callback(cid, class, msg)) then
								if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
									self.talkStart[cid] = os.time()
								else
									self.talkStart = os.time()
								end
							end
						else
							if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
								self.talkStart[cid] = os.time()
							else
								self.talkStart = os.time()
							end
						end
					end
				end
			end
		end
	end

	-- Handles onPlayerEndTrade events. If you wish to handle this yourself, use the CALLBACK_PLAYER_ENDTRADE callback.
	function NpcHandler:onPlayerEndTrade(cid)
		local callback = self:getCallback(CALLBACK_PLAYER_ENDTRADE)
		if (callback == nil or callback(cid)) then
			if (self:processModuleCallback(CALLBACK_PLAYER_ENDTRADE, cid, class, msg)) then
				if (self:isFocused(cid)) then
					local parseInfo = { [TAG_PLAYERNAME] = getPlayerName(cid) }
					local msg = self:parseMessage(self:getMessage(MESSAGE_ONCLOSESHOP), parseInfo)
					self:say(msg, cid)
				end
			end
		end
	end

	-- Handles onPlayerCloseChannel events. If you wish to handle this yourself, use the CALLBACK_PLAYER_CLOSECHANNEL callback.
	function NpcHandler:onPlayerCloseChannel(cid)
		local callback = self:getCallback(CALLBACK_PLAYER_CLOSECHANNEL)
		if (callback == nil or callback(cid)) then
			if (self:processModuleCallback(CALLBACK_PLAYER_CLOSECHANNEL, cid, class, msg)) then
				if (self:isFocused(cid)) then
					self:unGreet(cid)
				end
			end
		end
	end

	-- Handles onBuy events. If you wish to handle this yourself, use the CALLBACK_ONBUY callback.
	function NpcHandler:onBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks)
		local callback = self:getCallback(CALLBACK_ONBUY)
		if (callback == nil or callback(cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
			if (self:processModuleCallback(CALLBACK_ONBUY, cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
				--
			end
		end
	end

	-- Handles onSell events. If you wish to handle this yourself, use the CALLBACK_ONSELL callback.
	function NpcHandler:onSell(cid, itemid, subType, amount, ignoreCap, inBackpacks)
		local callback = self:getCallback(CALLBACK_ONSELL)
		if (callback == nil or callback(cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
			if (self:processModuleCallback(CALLBACK_ONSELL, cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
				--
			end
		end
	end

	-- Handles onThink events. If you wish to handle this yourself, please use the CALLBACK_ONTHINK callback.
	function NpcHandler:onThink()
		local callback = self:getCallback(CALLBACK_ONTHINK)
		if (callback == nil or callback()) then
			if (NPCHANDLER_TALKDELAY == TALKDELAY_ONTHINK) then
				if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
					for cid, talkDelay in pairs(self.talkDelay) do
						if (talkDelay.time ~= nil and talkDelay.message ~= nil and os.time() >= talkDelay.time) then
							selfSay(talkDelay.message, cid)
							self.talkDelay[cid] = nil
						end
					end
				elseif (self.talkDelay.time ~= nil and self.talkDelay.message ~= nil and os.time() >= self.talkDelay.time) then
					selfSay(self.talkDelay.message)
					self.talkDelay.time = nil
					self.talkDelay.message = nil
				end
			end

			if (self:processModuleCallback(CALLBACK_ONTHINK)) then
				if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
					for pos, focus in pairs(self.focuses) do
						if (focus ~= nil) then
							if (not self:isInRange(focus)) then
								self:onWalkAway(focus)
							elseif ((os.time() - self.talkStart[focus]) > self.idleTime) then
								self:unGreet(focus)
							else
								self:updateFocus()
							end
						end
					end
				elseif (self.focuses ~= 0) then
					if (not self:isInRange(self.focuses)) then
						self:onWalkAway(self.focuses)
					elseif (os.time() - self.talkStart > self.idleTime) then
						self:unGreet(self.focuses)
					else
						self:updateFocus()
					end
				end
			end
		end
	end

	-- Tries to greet the player with the given cid.
	function NpcHandler:onGreet(cid)
		if (self:isInRange(cid)) then
			if (NPCHANDLER_CONVBEHAVIOR == CONVERSATION_PRIVATE) then
				if (not self:isFocused(cid)) then
					self:greet(cid)
					return
				end
			elseif (NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT) then
				if (self.focuses == 0) then
					self:greet(cid)
				elseif (self.focuses == cid) then
					local msg = self:getMessage(MESSAGE_ALREADYFOCUSED)
					local parseInfo = { [TAG_PLAYERNAME] = getCreatureName(cid) }
					msg = self:parseMessage(msg, parseInfo)
					self:say(msg)
				else
					if (not self.queue:isInQueue(cid)) then
						self.queue:push(cid)
					end

					local msg = self:getMessage(MESSAGE_PLACEDINQUEUE)
					local parseInfo = { [TAG_PLAYERNAME] = getCreatureName(cid), [TAG_QUEUESIZE] = self.queue:getSize() }
					msg = self:parseMessage(msg, parseInfo)
					self:say(msg)
				end
			end
		end
	end

	-- Simply calls the underlying unGreet function.
	function NpcHandler:onFarewell(cid)
		self:unGreet(cid)
	end

	-- Should be called on this npc's focus if the distance to focus is greater then talkRadius.
	function NpcHandler:onWalkAway(cid)
		if (self:isFocused(cid)) then
			local callback = self:getCallback(CALLBACK_CREATURE_DISAPPEAR)
			if (callback == nil or callback(cid)) then
				if (self:processModuleCallback(CALLBACK_CREATURE_DISAPPEAR, cid)) then
					if (self.queue == nil or not self.queue:greetNext()) then
						local msg = self:getMessage(MESSAGE_WALKAWAY)
						local parseInfo = { [TAG_PLAYERNAME] = getPlayerName(cid) }
						msg = self:parseMessage(msg, parseInfo)

						self:say(msg, cid)
						self:releaseFocus(cid)
						self:say(msg)
					end
				end
			end
		end
	end

	-- Returns true if cid is within the talkRadius of this npc.
	function NpcHandler:isInRange(cid)
		local distance = getDistanceBetween(getCreaturePosition(getNpcCid()), getCreaturePosition(cid))
		if (distance == -1) then
			return false
		end

		return (distance <= self.talkRadius)
	end

	-- Resets the npc into it's initial state (in regard of the keyrodhandler).
	--	All modules are also receiving a reset call through their callbackOnModuleReset function.
	function NpcHandler:resetNpc()
		if (self:processModuleCallback(CALLBACK_MODULE_RESET)) then
			self.keywordHandler:reset()
		end
	end

	-- Makes the npc represented by this instance of NpcHandler say something.
	--	This implements the currently set type of talkdelay.
	--	shallDelay is a boolean value. If it is false, the message is not delayed. Default value is false.
	function NpcHandler:say(message, focus, shallDelay)
		local shallDelay = shallDelay or false
		if (NPCHANDLER_TALKDELAY == TALKDELAY_NONE or not shallDelay) then
			if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
				selfSay(message, focus)
				return
			else
				selfSay(message)
				return
			end
		end

		--TODO: Add an event handling method for delayed messages
		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
			self.talkDelay[focus] = {
				message = message,
				time = os.time() + self.talkDelayTime,
			}
		else
			self.talkDelay = {
				message = message,
				time = os.time() + self.talkDelayTime
			}
		end
	end
end




-- -- Advanced NPC System (Created by Jiddo),
-- -- Modified by Talaturen.

-- if (NpcHandler == nil) then
-- 	-- Constant talkdelay behaviors.
-- 	TALKDELAY_NONE               = 0 -- No talkdelay. Npc will reply immedeatly.
-- 	TALKDELAY_ONTHINK            = 1 -- Talkdelay handled through the onThink callback function. (Default)
-- 	TALKDELAY_EVENT              = 2 -- Not yet implemented

-- 	-- Currently applied talkdelay behavior. TALKDELAY_ONTHINK is default.
-- 	NPCHANDLER_TALKDELAY         = TALKDELAY_ONTHINK

-- 	-- Constant conversation behaviors.
-- 	CONVERSATION_DEFAULT         = 0 -- Conversation through default window, like it was before 8.2 update.
-- 	CONVERSATION_PRIVATE         = 1 -- Conversation through NPCs chat window, as of 8.2 update. (Default)
-- 	--Small Note: Private conversations also means the NPC will use multi-focus system.

-- 	-- Currently applied conversation behavior. CONVERSATION_PRIVATE is default.
-- 	NPCHANDLER_CONVBEHAVIOR      = CONVERSATION_PRIVATE

-- 	-- Constant indexes for defining default messages.
-- 	MESSAGE_GREET                = 1 -- When the player greets the npc.
-- 	MESSAGE_FAREWELL             = 2 -- When the player unGreets the npc.
-- 	MESSAGE_BUY                  = 3 -- When the npc asks the player if he wants to buy something.
-- 	MESSAGE_ONBUY                = 4 -- When the player successfully buys something via talk.
-- 	MESSAGE_BOUGHT               = 5 -- When the player bought something through the shop window.
-- 	MESSAGE_SELL                 = 6 -- When the npc asks the player if he wants to sell something.
-- 	MESSAGE_ONSELL               = 7 -- When the player successfully sells something via talk.
-- 	MESSAGE_SOLD                 = 8 -- When the player sold something through the shop window.
-- 	MESSAGE_MISSINGMONEY         = 9 -- When the player does not have enough money.
-- 	MESSAGE_NEEDMONEY            = 10 -- Same as above, used for shop window.
-- 	MESSAGE_MISSINGITEM          = 11 -- When the player is trying to sell an item he does not have.
-- 	MESSAGE_NEEDITEM             = 12 -- Same as above, used for shop window.
-- 	MESSAGE_NEEDSPACE            = 13 -- When the player don't have any space to buy an item
-- 	MESSAGE_NEEDMORESPACE        = 14 -- When the player has some space to buy an item, but not enough space
-- 	MESSAGE_IDLETIMEOUT          = 15 -- When the player has been idle for longer then idleTime allows.
-- 	MESSAGE_WALKAWAY             = 16 -- When the player walks out of the talkRadius of the npc.
-- 	MESSAGE_DECLINE              = 17 -- When the player says no to something.
-- 	MESSAGE_SENDTRADE            = 18 -- When the npc sends the trade window to the player
-- 	MESSAGE_NOSHOP               = 19 -- When the npc's shop is requested but he doesn't have any
-- 	MESSAGE_ONCLOSESHOP          = 20 -- When the player closes the npc's shop window
-- 	MESSAGE_ALREADYFOCUSED       = 21 -- When the player already has the focus of this npc.
-- 	MESSAGE_PLACEDINQUEUE        = 22 -- When the player has been placed in the costumer queue.

-- 	-- Constant indexes for callback functions. These are also used for module callback ids.
-- 	CALLBACK_CREATURE_APPEAR     = 1
-- 	CALLBACK_CREATURE_DISAPPEAR  = 2
-- 	CALLBACK_CREATURE_SAY        = 3
-- 	CALLBACK_ONTHINK             = 4
-- 	CALLBACK_GREET               = 5
-- 	CALLBACK_FAREWELL            = 6
-- 	CALLBACK_MESSAGE_DEFAULT     = 7
-- 	CALLBACK_PLAYER_ENDTRADE     = 8
-- 	CALLBACK_PLAYER_CLOSECHANNEL = 9
-- 	CALLBACK_ONBUY               = 10
-- 	CALLBACK_ONSELL              = 11
-- 	CALLBACK_ONTRADEREQUEST      = 20

-- 	-- Addidional module callback ids
-- 	CALLBACK_MODULE_INIT         = 12
-- 	CALLBACK_MODULE_RESET        = 13

-- 	-- Constant strings defining the keywords to replace in the default messages.
-- 	TAG_PLAYERNAME               = '|PLAYERNAME|'
-- 	TAG_ITEMCOUNT                = '|ITEMCOUNT|'
-- 	TAG_TOTALCOST                = '|TOTALCOST|'
-- 	TAG_ITEMNAME                 = '|ITEMNAME|'
-- 	TAG_QUEUESIZE                = '|QUEUESIZE|'

-- 	NpcHandler                   = {
-- 		keywordHandler = nil,
-- 		focuses = nil,
-- 		talkStart = nil,
-- 		idleTime = 90,
-- 		talkRadius = 4,
-- 		talkDelayTime = 1, -- Seconds to delay outgoing messages.
-- 		queue = nil,
-- 		talkDelay = nil,
-- 		callbackFunctions = nil,
-- 		modules = nil,
-- 		shopItems = nil, -- They must be here since ShopModule uses "static" functions
-- 		messages = {
-- 			-- These are the default replies of all npcs. They can/should be changed individually for each npc.
-- 			[MESSAGE_GREET]          = 'Welcome, |PLAYERNAME|! I have been expecting you.',
-- 			[MESSAGE_FAREWELL]       = 'Good bye, |PLAYERNAME|!',
-- 			[MESSAGE_BUY]            = 'Do you want to buy |ITEMCOUNT| |ITEMNAME| for |TOTALCOST| gold coins?',
-- 			[MESSAGE_ONBUY]          = 'It was a pleasure doing business with you.',
-- 			[MESSAGE_BOUGHT]         = 'Bought |ITEMCOUNT|x |ITEMNAME| for |TOTALCOST| gold.',
-- 			[MESSAGE_SELL]           = 'Do you want to sell |ITEMCOUNT| |ITEMNAME| for |TOTALCOST| gold coins?',
-- 			[MESSAGE_ONSELL]         = 'Thank you for this |ITEMNAME|, |PLAYERNAME| gold.',
-- 			[MESSAGE_SOLD]           = 'Sold |ITEMCOUNT|x |ITEMNAME| for |TOTALCOST| gold.',
-- 			[MESSAGE_MISSINGMONEY]   = 'Sorry, you don\'t have enough money.',
-- 			[MESSAGE_NEEDMONEY]      = 'You do not have enough money.',
-- 			[MESSAGE_MISSINGITEM]    = 'You don\'t even have that item, |PLAYERNAME|!',
-- 			[MESSAGE_NEEDITEM]       = 'You do not have this object.',
-- 			[MESSAGE_NEEDSPACE]      = 'You do not have enough capacity.',
-- 			[MESSAGE_NEEDMORESPACE]  = 'You do not have enough capacity for all items.',
-- 			[MESSAGE_IDLETIMEOUT]    = 'Next, please!',
-- 			[MESSAGE_WALKAWAY]       = 'How rude!',
-- 			[MESSAGE_DECLINE]        = 'Not good enough, is it... ?',
-- 			[MESSAGE_SENDTRADE]      = 'Here\'s my offer, |PLAYERNAME|. Don\'t you like it?',
-- 			[MESSAGE_NOSHOP]         = 'Sorry, I\'m not offering anything.',
-- 			[MESSAGE_ONCLOSESHOP]    = 'Thank you, come back when you want something more.',
-- 			[MESSAGE_ALREADYFOCUSED] = '|PLAYERNAME|! I am already talking to you...',
-- 			[MESSAGE_PLACEDINQUEUE]  = '|PLAYERNAME|, please wait for your turn. There are |QUEUESIZE| customers before you.'
-- 		}
-- 	}

-- 	-- Creates a new NpcHandler with an empty callbackFunction stack.
-- 	function NpcHandler:new(keywordHandler)
-- 		local obj = {}
-- 		obj.callbackFunctions = {}
-- 		obj.modules = {}
-- 		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 			obj.focuses = {}
-- 			obj.talkStart = {}
-- 		else
-- 			obj.queue = Queue:new(obj)
-- 			obj.focuses = 0
-- 			obj.talkStart = 0
-- 		end
-- 		obj.talkDelay = {}
-- 		obj.keywordHandler = keywordHandler
-- 		obj.messages = {}
-- 		obj.shopItems = {}

-- 		setmetatable(obj.messages, self.messages)
-- 		self.messages.__index = self.messages

-- 		setmetatable(obj, self)
-- 		self.__index = self
-- 		return obj
-- 	end

-- 	-- Re-defines the maximum idle time allowed for a player when talking to this npc.
-- 	function NpcHandler:setMaxIdleTime(newTime)
-- 		self.idleTime = newTime
-- 	end

-- 	-- Attackes a new keyword handler to this npchandler
-- 	function NpcHandler:setKeywordHandler(newHandler)
-- 		self.keywordHandler = newHandler
-- 	end

-- 	-- Function used to change the focus of this npc.
-- 	function NpcHandler:addFocus(newFocus)
-- 		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 			if (self:isFocused(newFocus)) then
-- 				return
-- 			end

-- 			table.insert(self.focuses, newFocus)
-- 		else
-- 			self.focuses = newFocus
-- 		end

-- 		self:updateFocus()
-- 	end

-- 	NpcHandler.changeFocus = NpcHandler.addFocus --"changeFocus" looks better for CONVERSATION_DEFAULT

-- 	-- Function used to verify if npc is focused to certain player
-- 	function NpcHandler:isFocused(focus)
-- 		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 			for k, v in pairs(self.focuses) do
-- 				if v == focus then
-- 					return true
-- 				end
-- 			end

-- 			return false
-- 		end

-- 		return (self.focuses == focus)
-- 	end

-- 	-- This function should be called on each onThink and makes sure the npc faces the player it is talking to.
-- 	--	Should also be called whenever a new player is focused.
-- 	function NpcHandler:updateFocus()
-- 		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 			for pos, focus in pairs(self.focuses) do
-- 				if (focus ~= nil) then
-- 					doNpcSetCreatureFocus(focus)
-- 					return
-- 				end
-- 			end

-- 			doNpcSetCreatureFocus(0)
-- 		else
-- 			doNpcSetCreatureFocus(self.focuses)
-- 		end
-- 	end

-- 	-- Used when the npc should un-focus the player.
-- 	function NpcHandler:releaseFocus(focus)
-- 		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 			if (not self:isFocused(focus)) then
-- 				return
-- 			end

-- 			local pos = nil
-- 			for k, v in pairs(self.focuses) do
-- 				if v == focus then
-- 					pos = k
-- 				end
-- 			end
-- 			table.remove(self.focuses, pos)
-- 			self.talkStart[focus] = nil
-- 			closeShopWindow(focus) --Even if it can not exist, we need to prevent it.
-- 			self:updateFocus()
-- 		else
-- 			closeShopWindow(focus)
-- 			self:changeFocus(0)
-- 		end
-- 	end

-- 	-- Returns the callback function with the specified id or nil if no such callback function exists.
-- 	function NpcHandler:getCallback(id)
-- 		local ret = nil
-- 		if (self.callbackFunctions ~= nil) then
-- 			ret = self.callbackFunctions[id]
-- 		end

-- 		return ret
-- 	end

-- 	-- Changes the callback function for the given id to callback.
-- 	function NpcHandler:setCallback(id, callback)
-- 		if (self.callbackFunctions ~= nil) then
-- 			self.callbackFunctions[id] = callback
-- 		end
-- 	end

-- 	-- Adds a module to this npchandler and inits it.
-- 	function NpcHandler:addModule(module)
-- 		if (self.modules == nil or module == nil) then
-- 			return false
-- 		end

-- 		module:init(self)
-- 		if (module.parseParameters ~= nil) then
-- 			module:parseParameters()
-- 		end

-- 		table.insert(self.modules, module)
-- 		return true
-- 	end

-- 	-- Calls the callback function represented by id for all modules added to this npchandler with the given arguments.
-- 	function NpcHandler:processModuleCallback(id, ...)
-- 		local ret = true
-- 		for i, module in pairs(self.modules) do
-- 			local tmpRet = true
-- 			if (id == CALLBACK_CREATURE_APPEAR and module.callbackOnCreatureAppear ~= nil) then
-- 				tmpRet = module:callbackOnCreatureAppear(unpack(arg))
-- 			elseif (id == CALLBACK_CREATURE_DISAPPEAR and module.callbackOnCreatureDisappear ~= nil) then
-- 				tmpRet = module:callbackOnCreatureDisappear(unpack(arg))
-- 			elseif (id == CALLBACK_CREATURE_SAY and module.callbackOnCreatureSay ~= nil) then
-- 				tmpRet = module:callbackOnCreatureSay(unpack(arg))
-- 			elseif (id == CALLBACK_PLAYER_ENDTRADE and module.callbackOnPlayerEndTrade ~= nil) then
-- 				tmpRet = module:callbackOnPlayerEndTrade(unpack(arg))
-- 			elseif (id == CALLBACK_PLAYER_CLOSECHANNEL and module.callbackOnPlayerCloseChannel ~= nil) then
-- 				tmpRet = module:callbackOnPlayerCloseChannel(unpack(arg))
-- 			elseif (id == CALLBACK_ONBUY and module.callbackOnBuy ~= nil) then
-- 				tmpRet = module:callbackOnBuy(unpack(arg))
-- 			elseif (id == CALLBACK_ONSELL and module.callbackOnSell ~= nil) then
-- 				tmpRet = module:callbackOnSell(unpack(arg))
-- 			elseif (id == CALLBACK_ONTRADEREQUEST and module.callbackOnTradeRequest ~= nil) then
-- 				tmpRet = module:callbackOnTradeRequest(unpack(arg))
-- 			elseif (id == CALLBACK_ONTHINK and module.callbackOnThink ~= nil) then
-- 				tmpRet = module:callbackOnThink(unpack(arg))
-- 			elseif (id == CALLBACK_GREET and module.callbackOnGreet ~= nil) then
-- 				tmpRet = module:callbackOnGreet(unpack(arg))
-- 			elseif (id == CALLBACK_FAREWELL and module.callbackOnFarewell ~= nil) then
-- 				tmpRet = module:callbackOnFarewell(unpack(arg))
-- 			elseif (id == CALLBACK_MESSAGE_DEFAULT and module.callbackOnMessageDefault ~= nil) then
-- 				tmpRet = module:callbackOnMessageDefault(unpack(arg))
-- 			elseif (id == CALLBACK_MODULE_RESET and module.callbackOnModuleReset ~= nil) then
-- 				tmpRet = module:callbackOnModuleReset(unpack(arg))
-- 			end

-- 			if (not tmpRet) then
-- 				ret = false
-- 				break
-- 			end
-- 		end

-- 		return ret
-- 	end

-- 	-- Returns the message represented by id.
-- 	function NpcHandler:getMessage(id)
-- 		local ret = nil
-- 		if (self.messages ~= nil) then
-- 			ret = self.messages[id]
-- 		end

-- 		return ret
-- 	end

-- 	-- Changes the default response message with the specified id to newMessage.
-- 	function NpcHandler:setMessage(id, newMessage)
-- 		if (self.messages ~= nil) then
-- 			self.messages[id] = newMessage
-- 		end
-- 	end

-- 	-- Translates all message tags found in msg using parseInfo
-- 	function NpcHandler:parseMessage(msg, parseInfo)
-- 		local ret = msg
-- 		for search, replace in pairs(parseInfo) do
-- 			ret = string.gsub(ret, search, replace)
-- 		end

-- 		return ret
-- 	end

-- 	-- Makes sure the npc un-focuses the currently focused player
-- 	function NpcHandler:unGreet(cid)
-- 		if (not self:isFocused(cid)) then
-- 			return
-- 		end

-- 		local callback = self:getCallback(CALLBACK_FAREWELL)
-- 		if (callback == nil or callback(cid)) then
-- 			if (self:processModuleCallback(CALLBACK_FAREWELL)) then
-- 				if (self.queue == nil or not self.queue:greetNext()) then
-- 					local msg = self:getMessage(MESSAGE_FAREWELL)
-- 					local parseInfo = { [TAG_PLAYERNAME] = getPlayerName(cid) }
-- 					msg = self:parseMessage(msg, parseInfo)

-- 					self:say(msg, cid)
-- 					self:releaseFocus(cid)
-- 					self:say(msg)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Greets a new player.
-- 	function NpcHandler:greet(cid)
-- 		if (cid ~= 0) then
-- 			local callback = self:getCallback(CALLBACK_GREET)
-- 			if (callback == nil or callback(cid)) then
-- 				if (self:processModuleCallback(CALLBACK_GREET, cid)) then
-- 					local msg = self:getMessage(MESSAGE_GREET)
-- 					local parseInfo = { [TAG_PLAYERNAME] = getCreatureName(cid) }
-- 					msg = self:parseMessage(msg, parseInfo)

-- 					self:say(msg)
-- 					self:addFocus(cid)
-- 					self:say(msg, cid)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Handles onCreatureAppear events. If you with to handle this yourself, please use the CALLBACK_CREATURE_APPEAR callback.
-- 	function NpcHandler:onCreatureAppear(cid)
-- 		local callback = self:getCallback(CALLBACK_CREATURE_APPEAR)
-- 		if (callback == nil or callback(cid)) then
-- 			if (self:processModuleCallback(CALLBACK_CREATURE_APPEAR, cid)) then
-- 				--
-- 			end
-- 		end
-- 	end

-- 	-- Handles onCreatureDisappear events. If you with to handle this yourself, please use the CALLBACK_CREATURE_DISAPPEAR callback.
-- 	function NpcHandler:onCreatureDisappear(cid)
-- 		local callback = self:getCallback(CALLBACK_CREATURE_DISAPPEAR)
-- 		if (callback == nil or callback(cid)) then
-- 			if (self:processModuleCallback(CALLBACK_CREATURE_DISAPPEAR, cid)) then
-- 				if (self:isFocused(cid)) then
-- 					self:unGreet(cid)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Handles onCreatureSay events. If you with to handle this yourself, please use the CALLBACK_CREATURE_SAY callback.
-- 	function NpcHandler:onCreatureSay(cid, class, msg)
-- 		local callback = self:getCallback(CALLBACK_CREATURE_SAY)
-- 		if (callback == nil or callback(cid, class, msg)) then
-- 			if (self:processModuleCallback(CALLBACK_CREATURE_SAY, cid, class, msg)) then
-- 				if (not self:isInRange(cid)) then
-- 					return
-- 				end

-- 				if (self.keywordHandler ~= nil) then
-- 					if ((self:isFocused(cid) and (class == TALKTYPE_PRIVATE_PN or NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT)) or not self:isFocused(cid)) then
-- 						local ret = self.keywordHandler:processMessage(cid, msg)
-- 						if (not ret) then
-- 							local callback = self:getCallback(CALLBACK_MESSAGE_DEFAULT)
-- 							if (callback ~= nil and callback(cid, class, msg)) then
-- 								if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 									self.talkStart[cid] = os.time()
-- 								else
-- 									self.talkStart = os.time()
-- 								end
-- 							end
-- 						else
-- 							if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 								self.talkStart[cid] = os.time()
-- 							else
-- 								self.talkStart = os.time()
-- 							end
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Handles onPlayerEndTrade events. If you wish to handle this yourself, use the CALLBACK_PLAYER_ENDTRADE callback.
-- 	function NpcHandler:onPlayerEndTrade(cid)
-- 		local callback = self:getCallback(CALLBACK_PLAYER_ENDTRADE)
-- 		if (callback == nil or callback(cid)) then
-- 			if (self:processModuleCallback(CALLBACK_PLAYER_ENDTRADE, cid, class, msg)) then
-- 				if (self:isFocused(cid)) then
-- 					local parseInfo = { [TAG_PLAYERNAME] = getPlayerName(cid) }
-- 					local msg = self:parseMessage(self:getMessage(MESSAGE_ONCLOSESHOP), parseInfo)
-- 					self:say(msg, cid)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Handles onPlayerCloseChannel events. If you wish to handle this yourself, use the CALLBACK_PLAYER_CLOSECHANNEL callback.
-- 	function NpcHandler:onPlayerCloseChannel(cid)
-- 		local callback = self:getCallback(CALLBACK_PLAYER_CLOSECHANNEL)
-- 		if (callback == nil or callback(cid)) then
-- 			if (self:processModuleCallback(CALLBACK_PLAYER_CLOSECHANNEL, cid, class, msg)) then
-- 				if (self:isFocused(cid)) then
-- 					self:unGreet(cid)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Handles onBuy events. If you wish to handle this yourself, use the CALLBACK_ONBUY callback.
-- 	function NpcHandler:onBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks)
-- 		local callback = self:getCallback(CALLBACK_ONBUY)
-- 		if (callback == nil or callback(cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
-- 			if (self:processModuleCallback(CALLBACK_ONBUY, cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
-- 				--
-- 			end
-- 		end
-- 	end

-- 	-- Handles onSell events. If you wish to handle this yourself, use the CALLBACK_ONSELL callback.
-- 	function NpcHandler:onSell(cid, itemid, subType, amount, ignoreCap, inBackpacks)
-- 		local callback = self:getCallback(CALLBACK_ONSELL)
-- 		if (callback == nil or callback(cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
-- 			if (self:processModuleCallback(CALLBACK_ONSELL, cid, itemid, subType, amount, ignoreCap, inBackpacks)) then
-- 				--
-- 			end
-- 		end
-- 	end

-- 	-- Handles onTradeRequest events. If you wish to handle this yourself, use the CALLBACK_ONTRADEREQUEST callback.
-- 	function NpcHandler:onTradeRequest(cid)
-- 		local callback = self:getCallback(CALLBACK_ONTRADEREQUEST)
-- 		if (callback == nil or callback(cid)) then
-- 			if (self:processModuleCallback(CALLBACK_ONTRADEREQUEST, cid)) then
-- 				return true
-- 			end
-- 		end
-- 		return false
-- 	end

-- 	-- Handles onThink events. If you wish to handle this yourself, please use the CALLBACK_ONTHINK callback.
-- 	function NpcHandler:onThink()
-- 		local callback = self:getCallback(CALLBACK_ONTHINK)
-- 		if (callback == nil or callback()) then
-- 			if (NPCHANDLER_TALKDELAY == TALKDELAY_ONTHINK) then
-- 				if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 					for cid, talkDelay in pairs(self.talkDelay) do
-- 						if (talkDelay.time ~= nil and talkDelay.message ~= nil and os.time() >= talkDelay.time) then
-- 							selfSay(talkDelay.message, cid)
-- 							self.talkDelay[cid] = nil
-- 						end
-- 					end
-- 				elseif (self.talkDelay.time ~= nil and self.talkDelay.message ~= nil and os.time() >= self.talkDelay.time) then
-- 					selfSay(self.talkDelay.message)
-- 					self.talkDelay.time = nil
-- 					self.talkDelay.message = nil
-- 				end
-- 			end

-- 			if (self:processModuleCallback(CALLBACK_ONTHINK)) then
-- 				if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 					for pos, focus in pairs(self.focuses) do
-- 						if (focus ~= nil) then
-- 							if (not self:isInRange(focus)) then
-- 								self:onWalkAway(focus)
-- 							elseif ((os.time() - self.talkStart[focus]) > self.idleTime) then
-- 								self:unGreet(focus)
-- 							else
-- 								self:updateFocus()
-- 							end
-- 						end
-- 					end
-- 				elseif (self.focuses ~= 0) then
-- 					if (not self:isInRange(self.focuses)) then
-- 						self:onWalkAway(self.focuses)
-- 					elseif (os.time() - self.talkStart > self.idleTime) then
-- 						self:unGreet(self.focuses)
-- 					else
-- 						self:updateFocus()
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Tries to greet the player with the given cid.
-- 	function NpcHandler:onGreet(cid)
-- 		if (self:isInRange(cid)) then
-- 			if (NPCHANDLER_CONVBEHAVIOR == CONVERSATION_PRIVATE) then
-- 				if (not self:isFocused(cid)) then
-- 					self:greet(cid)
-- 					return
-- 				end
-- 			elseif (NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT) then
-- 				if (self.focuses == 0) then
-- 					self:greet(cid)
-- 				elseif (self.focuses == cid) then
-- 					local msg = self:getMessage(MESSAGE_ALREADYFOCUSED)
-- 					local parseInfo = { [TAG_PLAYERNAME] = getCreatureName(cid) }
-- 					msg = self:parseMessage(msg, parseInfo)
-- 					self:say(msg)
-- 				else
-- 					if (not self.queue:isInQueue(cid)) then
-- 						self.queue:push(cid)
-- 					end

-- 					local msg = self:getMessage(MESSAGE_PLACEDINQUEUE)
-- 					local parseInfo = { [TAG_PLAYERNAME] = getCreatureName(cid), [TAG_QUEUESIZE] = self.queue:getSize() }
-- 					msg = self:parseMessage(msg, parseInfo)
-- 					self:say(msg)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Simply calls the underlying unGreet function.
-- 	function NpcHandler:onFarewell(cid)
-- 		self:unGreet(cid)
-- 	end

-- 	-- Should be called on this npc's focus if the distance to focus is greater then talkRadius.
-- 	function NpcHandler:onWalkAway(cid)
-- 		if (self:isFocused(cid)) then
-- 			local callback = self:getCallback(CALLBACK_CREATURE_DISAPPEAR)
-- 			if (callback == nil or callback(cid)) then
-- 				if (self:processModuleCallback(CALLBACK_CREATURE_DISAPPEAR, cid)) then
-- 					if (self.queue == nil or not self.queue:greetNext()) then
-- 						local msg = self:getMessage(MESSAGE_WALKAWAY)
-- 						local parseInfo = { [TAG_PLAYERNAME] = getPlayerName(cid) }
-- 						msg = self:parseMessage(msg, parseInfo)

-- 						self:say(msg, cid)
-- 						self:releaseFocus(cid)
-- 						self:say(msg)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- Returns true if cid is within the talkRadius of this npc.
-- 	function NpcHandler:isInRange(cid)
-- 		local player = Player(cid)
-- 		if not player then
-- 			return false
-- 		end
-- 		local playerPos = player:getPosition()
-- 		if not playerPos then
-- 			return false
-- 		end

-- 		local npc = Creature(self.npc)
-- 		if not npc then
-- 			return false
-- 		end
-- 		local npcPos = npc:getPosition()
-- 		if not npcPos then
-- 			return false
-- 		end

-- 		local dx = math.abs(npcPos.x - playerPos.x)
-- 		local dy = math.abs(npcPos.y - playerPos.y)
-- 		local dz = math.abs(npcPos.z - playerPos.z)
-- 		local dist = math.sqrt(dx * dx + dy * dy)

-- 		return dist <= (self.talkRadius or 4) and dz == 0
-- 	end

-- 	-- Resets the npc into it's initial state (in regard of the keyrodhandler).
-- 	--	All modules are also receiving a reset call through their callbackOnModuleReset function.
-- 	function NpcHandler:resetNpc()
-- 		if (self:processModuleCallback(CALLBACK_MODULE_RESET)) then
-- 			self.keywordHandler:reset()
-- 		end
-- 	end

-- 	-- Makes the npc represented by this instance of NpcHandler say something.
-- 	--	This implements the currently set type of talkdelay.
-- 	--	shallDelay is a boolean value. If it is false, the message is not delayed. Default value is false.
-- 	function NpcHandler:say(message, focus, shallDelay)
-- 		local shallDelay = shallDelay or false
-- 		if (NPCHANDLER_TALKDELAY == TALKDELAY_NONE or not shallDelay) then
-- 			if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 				selfSay(message, focus)
-- 				return
-- 			else
-- 				selfSay(message)
-- 				return
-- 			end
-- 		end

-- 		-- TODO: Add an event handling method for delayed messages
-- 		if (NPCHANDLER_CONVBEHAVIOR ~= CONVERSATION_DEFAULT) then
-- 			self.talkDelay[focus] = {
-- 				message = message,
-- 				time = os.time() + self.talkDelayTime,
-- 			}
-- 		else
-- 			self.talkDelay = {
-- 				message = message,
-- 				time = os.time() + self.talkDelayTime
-- 			}
-- 		end
-- 	end
-- end
