function doShowTimeByPos(uid, pos, duration, type, effectId)
  type = type or 20
  effectId = effectId or CONST_ME_SMOKE
  local steps = duration * 10
  for i = 0, steps do
    addEvent(function()
      if isCreature(uid) then
        local remaining = duration - (i / 10)
        if remaining >= 0 then
          doSendAnimatedText(pos, string.format("%.1f", remaining), TEXTCOLOR_BLUE)
        end
      end
    end, i * 100)
  end
  addEvent(function()
    if isCreature(uid) then
      doSendMagicEffect(pos, effectId)
    end
  end, duration * 1000)
  return true
end
