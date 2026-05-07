local t = {
  access = 3, -- acesso mínimo para sair o efeito
  text = "STAFF",
  textcolor = TEXTCOLOR_ORANGE,
  effect = 867,
  interval = 3
}


function onLogin(cid)
  if getPlayerAccess(cid) >= t.access then
    SendEffect(cid, t.effect, t.text, t.interval, t.textcolor)
  end
  return true
end

function SendEffect(cid, effect, text, time, color)
  if isPlayer(cid) then
    doSendMagicEffect(getPlayerPosition(cid), effect)
    doSendAnimatedText(getPlayerPosition(cid), text, color)
    addEvent(SendEffect, time * 1000, cid, effect, text, time, color)
  end
  return true
end
