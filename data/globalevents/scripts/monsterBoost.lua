local monsterPosition = { x = 31910, y = 32211, z = 7 }
local lootBoostPosition = { x = 31911, y = 32212, z = 7 }
local expBoostPosition = { x = 31909, y = 32212, z = 7 }

local BOOST_SYSTEM_MONSTER_NAME_STORAGE = 12380
local BOOST_SYSTEM_LOOT_BONUS_STORAGE = 12381
local BOOST_SYSTEM_EXP_BONUS_STORAGE = 12382

string.upperAllFirst = string.upperAllFirst or function(str)
	return string.gsub(' ' .. str, '%W%l', string.upper):sub(2)
end

local days = {
	["Sunday"]    = { "Rat", "Rotworm", "Demon" },
	["Monday"]    = { "Rat", "Rotworm", "Demon" },
	["Tuesday"]   = { "Rat", "Rotworm", "Demon" },
	["Wednesday"] = { "Rat", "Rotworm", "Demon" },
	["Thursday"]  = { "Rat", "Rotworm", "Demon" },
	["Friday"]    = { "Rat", "Rotworm", "Demon" },
	["Saturday"]  = { "Rat", "Rotworm", "Demon" },
}

function onStartup()
	local monster = days[os.date("%A")]
	if not monster then
		return true
	end
	local monsterToday = monster[math.random(1, #monster)]
	doSetStorage(BOOST_SYSTEM_MONSTER_NAME_STORAGE, string.upperAllFirst(monsterToday))
	doSetStorage(BOOST_SYSTEM_LOOT_BONUS_STORAGE, math.random(10, 50))
	doSetStorage(BOOST_SYSTEM_EXP_BONUS_STORAGE, math.random(25, 50))
	local getMonster = doCreateMonster(monsterToday, monsterPosition, false, true)
	doCreatureSetLookDirection(getMonster, SOUTH)
	db.query("INSERT INTO monster_boost (monster, loot, exp) VALUES ('" ..
		monsterToday ..
		"', '" .. getStorage(BOOST_SYSTEM_LOOT_BONUS_STORAGE) .. "', '" .. getStorage(BOOST_SYSTEM_EXP_BONUS_STORAGE) .. "')")
	return true
end

function onThink()
	local monsterName = getStorage(BOOST_SYSTEM_MONSTER_NAME_STORAGE)
	if monsterName == EMPTY_STORAGE then
		return true
	end

	local creature = getTopCreature(monsterPosition)
	if not creature or creature.uid == 0 then
		local getMonster = doCreateMonster(monsterName, monsterPosition, false, true)
		doCreatureSetLookDirection(getMonster, SOUTH)
	elseif getCreatureName(creature.uid):lower() ~= monsterName then
		doRemoveCreature(creature.uid)
		local getMonster = doCreateMonster(monsterName, monsterPosition, false, true)
		doCreatureSetLookDirection(getMonster, SOUTH)
	end

	doSendAnimatedText(lootBoostPosition, "Loot +" .. getStorage(BOOST_SYSTEM_LOOT_BONUS_STORAGE) .. "%", 194)
	doSendAnimatedText(expBoostPosition, "Exp +" .. getStorage(BOOST_SYSTEM_EXP_BONUS_STORAGE) .. "%", 194)

	return true
end
