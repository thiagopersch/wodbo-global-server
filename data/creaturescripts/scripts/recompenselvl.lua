function onAdvance(cid, skill, oldlevel, newlevel)
	if skill ~= SKILL__LEVEL then return true end

	local rewards = {
		[50] = { storage = 99960, gold = 5 },
		[100] = { storage = 99961, gold = 10 },
		[150] = { storage = 99962, gold = 20 },
		[200] = { storage = 99963, gold = 30 },
		[250] = { storage = 99964, gold = 40 },
		[300] = { storage = 99965, gold = 50 },
		[400] = { storage = 99966, gold = 100 },
		[500] = { storage = 99966, gold = 200 },
		[600] = { storage = 99966, gold = 300 },
		[700] = { storage = 99966, gold = 400 },
		[800] = { storage = 99966, gold = 500 },
		[900] = { storage = 99966, gold = 600 },
		[1000] = { storage = 99966, gold = 700 },
	}

	local reward = rewards[newlevel]
	if reward and getPlayerStorageValue(cid, reward.storage) ~= 1 then
		doPlayerAddItem(cid, 2160, reward.gold)
		setPlayerStorageValue(cid, reward.storage, 1)
		doPlayerSendTextMessage(cid, 22, string.format("Voce ganhou %d golds por chegar ao level %d.", reward.gold, newlevel))
	end

	return true
end
