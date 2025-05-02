function timeString(timeDiff)
  local dateFormat = {
    { "day",    timeDiff / 60 / 60 / 24 },
    { "hour",   timeDiff / 60 / 60 % 24 },
    { "minute", timeDiff / 60 % 60 },
    { "second", timeDiff % 60 }
  }

  local out = {}
  for k, t in ipairs(dateFormat) do
    local v = math.floor(t[2])
    if (v > 0) then
      table.insert(out,
        (k < #dateFormat and (#out > 0 and ', ' or '') or ' and ') .. v .. ' ' .. t[1] .. (v ~= 1 and 's' or ''))
    end
  end
  local ret = table.concat(out)
  if ret:len() < 16 and ret:find("second") then
    local a, b = ret:find(" and ")
    ret = ret:sub(b + 1)
  end

  return ret
end

function onAdvance(player, skill, oldlevel, newlevel)
  if skill ~= SKILL_LEVEL then
    return true
  end

  oldtime = player:getStorageValue(3499)
  timenow = os.time()
  if oldtime == -1 then
    player:setStorageValue(3499, timenow)
  else
    player:sendTextMessage(MESSAGE_INFO_DESCR,
      "It took you " .. timeString(timenow - oldtime) .. " to advance in level from your last advance.")
    player:setStorageValue(3499, timenow)
  end
  return true
end
