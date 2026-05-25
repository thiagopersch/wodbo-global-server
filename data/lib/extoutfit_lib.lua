if extoutfit and extoutfit.__loaded then
  return
end

extoutfit = {}
extoutfit.__loaded = true

local types = {"wing", "aura", "shader", "healthbar", "manabar"}

function extoutfit.addUnlock(cid, type, id)
  if not isPlayer(cid) then return false end
  return doPlayerAddExtoutfitUnlock(cid, type, id)
end

function extoutfit.removeUnlock(cid, type, id)
  if not isPlayer(cid) then return false end
  return doPlayerRemoveExtoutfitUnlock(cid, type, id)
end

function extoutfit.hasUnlock(cid, type, id)
  if not isPlayer(cid) then return false end
  return doPlayerHasExtoutfitUnlock(cid, type, id)
end

function extoutfit.getUnlocks(cid, type)
  if not isPlayer(cid) then return {} end
  return doPlayerGetExtoutfitUnlocks(cid, type)
end

function extoutfit.isValidType(type)
  for _, t in ipairs(types) do
    if t == type then return true end
  end
  return false
end

function extoutfit.addWing(cid, id)
  return extoutfit.addUnlock(cid, "wing", id)
end

function extoutfit.removeWing(cid, id)
  return extoutfit.removeUnlock(cid, "wing", id)
end

function extoutfit.hasWing(cid, id)
  return extoutfit.hasUnlock(cid, "wing", id)
end

function extoutfit.getWings(cid)
  return extoutfit.getUnlocks(cid, "wing")
end

function extoutfit.addAura(cid, id)
  return extoutfit.addUnlock(cid, "aura", id)
end

function extoutfit.removeAura(cid, id)
  return extoutfit.removeUnlock(cid, "aura", id)
end

function extoutfit.hasAura(cid, id)
  return extoutfit.hasUnlock(cid, "aura", id)
end

function extoutfit.getAuras(cid)
  return extoutfit.getUnlocks(cid, "aura")
end

function extoutfit.addShader(cid, id)
  return extoutfit.addUnlock(cid, "shader", id)
end

function extoutfit.removeShader(cid, id)
  return extoutfit.removeUnlock(cid, "shader", id)
end

function extoutfit.hasShader(cid, id)
  return extoutfit.hasUnlock(cid, "shader", id)
end

function extoutfit.getShaders(cid)
  return extoutfit.getUnlocks(cid, "shader")
end

function extoutfit.addHealthBar(cid, id)
  return extoutfit.addUnlock(cid, "healthbar", id)
end

function extoutfit.removeHealthBar(cid, id)
  return extoutfit.removeUnlock(cid, "healthbar", id)
end

function extoutfit.hasHealthBar(cid, id)
  return extoutfit.hasUnlock(cid, "healthbar", id)
end

function extoutfit.getHealthBars(cid)
  return extoutfit.getUnlocks(cid, "healthbar")
end

function extoutfit.addManaBar(cid, id)
  return extoutfit.addUnlock(cid, "manabar", id)
end

function extoutfit.removeManaBar(cid, id)
  return extoutfit.removeUnlock(cid, "manabar", id)
end

function extoutfit.hasManaBar(cid, id)
  return extoutfit.hasUnlock(cid, "manabar", id)
end

function extoutfit.getManaBars(cid)
  return extoutfit.getUnlocks(cid, "manabar")
end

function extoutfit.equip(cid, extraType, extraId)
  if not isPlayer(cid) then return false end
  local outfit = getCreatureOutfit(cid)
  if extraType == "wing" then
    outfit.wings = extraId
  elseif extraType == "aura" then
    outfit.aura = extraId
  elseif extraType == "shader" then
    outfit.shader = extraId
  elseif extraType == "healthbar" then
    outfit.healthBar = extraId
  elseif extraType == "manabar" then
    outfit.manaBar = extraId
  else
    return false
  end
  doCreatureChangeOutfit(cid, outfit)
  doPlayerSave(cid)
  return true
end

return extoutfit