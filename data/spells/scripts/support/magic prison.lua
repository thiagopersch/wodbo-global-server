local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
setCombatParam(combat, COMBAT_PARAM_CREATEITEM, 1497)

function onCastSpell(cid, var)
	doShowTimeByPos(cid, variantToPosition(var), 20, 20, 2)
	return doCombat(cid, combat, var)
end
