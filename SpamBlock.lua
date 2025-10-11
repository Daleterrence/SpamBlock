_addon.name = 'SpamBlock'
_addon.version = '1.3.75'
_addon.author = 'DTR, original code by Chiaia'
_addon.commands = {'sbl','spamblock'} -- To be used for upcoming commands.

--TODO: Add commands.

require('luau')
packets = require('packets')
local config = require('config')

local default = { 
    rmt = true,
    books = true,
    autoupdate = true,
	blist = true,
}

local register_event = windower.register_event
local add_to_chat = windower.add_to_chat
local settings = config.load(default)
local send_command = windower.send_command
local windower_path = windower.windower_path
local convert_auto_trans = windower.convert_auto_trans
local addon_path = windower.addon_path

--Auto-update
function check_for_update()
    if settings.autoupdate and not _addon.version:endswith('dev') then
        local ltn12 = require('ltn12')
        local https = require('ssl.https')
        function get_txt(url, callback)
            if type(callback) ~= 'function' then return end
            coroutine.schedule(function()
                local body = {}
                response, code = https.request{ url = url, sink = ltn12.sink.table(body), }
                body = table.concat(body)
                callback(response, code, body)
            end, 1)
        end
        local version_url = "https://raw.githubusercontent.com/Daleterrence/SpamBlock/refs/heads/main/SpamBlock.lua"
        local version_pattern = "_addon.version *= *['\"](.-)['\"]"
        local file_path = addon_path .. "SpamBlock.lua"
        get_txt(version_url, function(response, code, body)
            if code == 200 then
                version = body:match(version_pattern)
                    if version and version > _addon.version then
                    add_to_chat(36,('['):color(36)..('SpamBlock'):color(38)..('] '):color(36).. 'New version found (v%s), updating from v%s.':format(version, _addon.version))
                    -- Open the file in write mode
                    local file = io.open(file_path, "w")
                    -- Check if the file was opened successfully
                    if file then
                        file:write(body)  -- Write the content to the file
                        file:close()         -- Close the file
                        add_to_chat(3,('['):color(36)..('SpamBlock'):color(38)..('] '):color(36).. 'Update successful, reloading.':color(36))
                        send_command('@wait 0.5;lua reload ' .. _addon.name)
                        return
                    else
						add_to_chat(36,('['):color(36)..('SpamBlock'):color(38)..('] '):color(36).. 'Update failed. Cannot read:':color(39).. file_path)
                    end
                end
            else
                add_to_chat(36,('['):color(36)..('SpamBlock'):color(38)..('] '):color(36).. 'Update failed. Github cannot be reached at this time.':color(39))
            end
        end)
    end
end
register_event('load', check_for_update)
	add_to_chat(3,('['):color(36)..('SpamBlock'):color(38)..('] '):color(36)..('Addon successfully loaded.'):color(36))
register_event('login', check_for_update)
register_event('lose focus', check_for_update)
register_event('gain focus', check_for_update)
register_event('weather change', check_for_update)

local blacklist = T{'Noke','Panggeb','Comedie','Boamna','Thanatoss','Lowesquadone','Justchao','Jamiei','Bazzarcat','Aboschitt','Wooohoo','Aeoniczaca','Aeoniczzzcq','Yagwick','Criofan','Attkins','Yagwica','Killera','Killerfa','Xxzzgorun','Deshutzn','Pangge','Yagwicc','Killerfd','Chirich','Kettica','Woohooc','Xxzagorun','Yagwicb','Killerfg'} -- Blocks all messages from defined player-characters entered here, E.G. 'Spammerguy','Badguy', etc. 

local black_listed_words = T{string.char(0x81,0x69),string.char(0x81,0x99),string.char(0x81,0x9A),'CP500p','2100p','ML0-20/15m','New2025','V0toV25', '3M/run','3M/hour','Aeonic Weapon*.*Mind','2100/20M','T1T2T3T4','3 Area Clear Mind','OdysseyNM','DYD W3','Dynamis*.*Buy?','unity.Master','43K+','Ambuscade*.*10M/run','DYDW3Clear.HTBC.VD.do you need it?buy?','OmenOdysseySeg11k','DYDW3Clear'} -- Strings the addon will look for in yell and shout chat, and block appropriately.

-- Example Strings:
 --'1%-99','Job Points.*2100','Job Points.*500','Job Points.*4m','JP.*2100','JP.*500','Capacity Points.*2100','Capacity Points.*500','CPS*.*2100','CPS*.*500','ｆｆｘｉｓｈｏｐ','Jinpu 99999','Jinpu99999','This is IGXE','Clear Mind*.*15mins rdy start','Reisenjima*.*Helms*.*T4*.*Buy','Aeonic Weapon*.*3zone*.*Buy','Tumult Curator*.*Kill','Aeonic Weapon*.*Mind',.*Buy','Selling Aeonic','Empy Weapons Abyssea','50 50 75' - First two are '☆' and '★' symbols.
 
local black_listed_skill_pages = T{'6147','6148','6149','6150','6151','6152','6153','6154','6155','6156','6157','6158','6159','6160','6161','6162','6163','6164','6165','6166','6167','6168','6169','6170','6171','6172','6173','6174','6175','6176','6177','6178','6179','6180','6181','6182','6183','6184','6185'} -- IDs to block item-use chatlog events for, add to this by finding item IDs in resources/items.

register_event('incoming chunk', function(id,data)
    if id == 0x017 then -- Incoming chat packet.
        local chat = packets.parse('incoming', data)
        local cleaned = convert_auto_trans(chat['Message']):lower()

		if blacklist:contains(chat['Sender Name']) and settings.blist then -- Blocks any messages from defined player-characters above, in any chat mode.
			return true
		elseif (chat['Mode'] == 1 or chat['Mode'] == 26) and settings.rmt then -- Blocks RMT spam in shout (1) and yell (26) chat modes.
			for k,v in ipairs(black_listed_words) do
				if cleaned:match(v:lower()) then
					return true
				end
			end
        end
    elseif id == 0x028 and settings.books then -- Blocks skill-up book spam.
        local data = packets.parse('incoming', data)
        if black_listed_skill_pages:contains(data['Target 1 Action 1 Param']) then
            return true
        end
	end
end)