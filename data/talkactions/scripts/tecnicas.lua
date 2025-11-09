function onSay(cid, words, param)
    local opcodeOpenSpellList = 123
    doPlayerSendExtendedOpcode(cid, opcodeOpenSpellList, "")
    return TRUE
end

-- function onSay(cid, words, param)
--     local count = getPlayerInstantSpellCount(cid)
--     local text = ""
--     local t = {}
--     for i = 0, count - 1 do
--         local spell = getPlayerInstantSpellInfo(cid, i)
--         if spell.level ~= 0 then
--             if spell.manapercent > 0 then
--                 spell.mana = spell.manapercent .. "%"
--             end
--             table.insert(t, spell)
--         end
--     end
--     table.sort(t, function(a, b) return a.level < b.level end)
--     local prevLevel = -1
--     for i, spell in ipairs(t) do
--         local line = ""
--         local premium = ""
--         if spell.prem == 1 then
--             premium = "Premium"
--         else
--             premium = "Free"
--         end
--         if prevLevel ~= spell.level then
--             if i ~= 1 then line = "\n" end
--             line = line .. "Spells from level " .. spell.level .. "\n"
--             prevLevel = spell.level
--         end
--         text = text .. line .. "     " .. spell.words .. " - Reiatsu: " .. spell.mana .. " | " .. premium .. "\n"
--     end
--     doShowTextDialog(cid, 2288, text)
--     return TRUE
-- end
