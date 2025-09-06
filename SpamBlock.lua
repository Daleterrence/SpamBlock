_addon.name = 'SpamBlock'
_addon.version = '0.01'
_addon.author = 'DTR, original code by Chiaia'
_addon.commands = {'spamblock','sbl'} -- Unused currently.

--TODO: Add settings file and commands.

require('luau')
packets = require('packets')

local block_skillup = true -- Setting to true blocks item-use events from skill-up book items. 
local blacklist = T{'Frededde','Comedie','Boamna','Thanatoss','Lowesquadone','Justchao','Jamiei','Bazzarcat','Aboschitt','Wooohoo','Aeoniczaca'} -- Blocks all messages from defined player-characters entered here, E.G. 'Spammerguy','Badguy', etc. 

-- Blacklist Reasons:
-- Frededde - Racist, sexist, asshole.
-- Comedie, Boamna, Thanatoss, Lowesquadone, Justchao, Jamiei, Bazzarcat, Aboschitt, Wooohoo, Aeoniczaca - Mercing

local black_listed_words = T{string.char(0x81,0x69),string.char(0x81,0x99),string.char(0x81,0x9A),'CP500p','2100p','ML0-20/15m','New2025','V0toV25', '3M/run', '3M/hour', 'Aeonic Weapon*.*Mind'} -- Be careful adding terms unless you want to accidentally neuter shout and yell chat.
-- {string.char(0x81,0x69),string.char(0x81,0x99),string.char(0x81,0x9A),'1%-99','Job Points.*2100','Job Points.*500','Job Points.*4m','JP.*2100','JP.*500','Capacity Points.*2100','Capacity Points.*500','CPS*.*2100','CPS*.*500','ｆｆｘｉｓｈｏｐ','Jinpu 99999','Jinpu99999','This is IGXE','Clear Mind*.*15mins rdy start','Reisenjima*.*Helms*.*T4*.*Buy','Aeonic Weapon*.*3zone*.*Buy','Tumult Curator*.*Kill','Aeonic Weapon*.*Mind',.*Buy','Selling Aeonic','Empy Weapons Abyssea','50 50 75'} - First two are '☆' and '★' symbols. Currently unused terms, only grab the lot if you're on Asura. 
local black_listed_skill_pages = T{'6147','6148','6149','6150','6151','6152','6153','6154','6155','6156','6157','6158','6159','6160','6161','6162','6163','6164','6165','6166','6167','6168','6169','6170','6171','6172','6173','6174','6175','6176','6177','6178','6179','6180','6181','6182','6183','6184','6185'} -- IDs to block item-use events for, add to this by finding item IDs in resources/items.

windower.register_event('incoming chunk', function(id,data)
    if id == 0x017 then -- Incoming chat packet.
        local chat = packets.parse('incoming', data)
        local cleaned = windower.convert_auto_trans(chat['Message']):lower()

		if blacklist:contains(chat['Sender Name']) then -- Blocks any messages from defined player-characters above, in any chat mode.
			return true
		elseif (chat['Mode'] == 1 or chat['Mode'] == 26) then -- Blocks RMT spam in shout (1) and yell (26) chat modes.
			for k,v in ipairs(black_listed_words) do
				if cleaned:match(v:lower()) then
					return true
				end
			end
        end
    elseif id == 0x028 and block_skillup then -- Blocks skill-up book spam.
        local data = packets.parse('incoming', data)
        if black_listed_skill_pages:contains(data['Target 1 Action 1 Param']) then
            return true
        end
	end
end)