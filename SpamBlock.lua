--[[

Copyright © 2026, DTR, Chiaia, Lili
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of this addon nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'SpamBlock'
_addon.version = '1.5.30'
_addon.author = 'DTR, original code by Chiaia'
_addon.commands = {'sbl','spamblock'}

require('luau')
packets = require('packets')
local config = require('config')

-- Default settings
local default = { 
    rmt = true,
    books = true,
    autoupdate = true,
    blist = true,
    custom_blist = T{},
    custom_words = T{},
    update_interval = 15
}

local register_event = windower.register_event
local add_to_chat = windower.add_to_chat
local settings = config.load(default)
local send_command = windower.send_command
local convert_auto_trans = windower.convert_auto_trans
local addon_path = windower.addon_path
local last_update_check = 0
-- Version comparison functions
local function _sanitize_version(v)
    local s = ''
    if v ~= nil then
        s = tostring(v):match("([%d%.]+)") or ''
    end
    local parts = {}
    for seg in s:gmatch('%d+') do
        parts[#parts+1] = tonumber(seg) or 0
    end
    return parts
end

local function compare_versions(a, b)
    local pa, pb = _sanitize_version(a), _sanitize_version(b)
    local n = math.max(#pa, #pb)
    for i = 1, n do
        local va = pa[i] or 0
        local vb = pb[i] or 0
        if va ~= vb then
            return (va > vb) and 1 or -1
        end
    end
    return 0
end

-- Auto-updating check
function check_for_update(manual, force)
    if not settings.autoupdate and not manual then return end
    if not force and _addon.version:endswith('dev') then return end
    if not manual and os.time() - last_update_check < 600 then return end
    last_update_check = os.time()

    local prefix = ('['):color(36)..('SpamBlock'):color(38)..('] '):color(36)

    -- Handling incase someone's Windower install is borked
    local ok_ltn12, ltn12 = pcall(require, 'ltn12')
    local ok_https, https = pcall(require, 'ssl.https')
    if not ok_ltn12 or not ok_https or not https then
        if manual then
            add_to_chat(123, prefix .. 'Update check failed. Your Windower installation is missing required libraries.')
        end
        return
    end

    local version_url = "https://raw.githubusercontent.com/Daleterrence/SpamBlock/main/SpamBlock.lua"
    local version_pattern = "_addon.version%s*=%s*['\"](.-)['\"]"
    local file_path = addon_path .. "SpamBlock.lua"

    if manual then
        add_to_chat(36, prefix .. 'Checking for updates...')
    end

    coroutine.schedule(function()
        local buffer = {}
        local _, code = https.request{
            url = version_url,
            method = "GET",
            headers = { ['User-Agent'] = 'SpamBlock/' .. tostring(_addon.version), Range = "bytes=0-2047" },
            sink = ltn12.sink.table(buffer)
        }

        if code ~= 200 and code ~= 206 then
            if manual then
                add_to_chat(123, prefix .. 'Update check failed. Unable to reach GitHub.')
            end
            return
        end

    local body = table.concat(buffer)
    local remote_version = body:match(version_pattern)

        if not remote_version then
            if manual then add_to_chat(123, prefix .. 'Update check failed. Unable to read GitHub version.') end
            return
        end

        if manual then
            add_to_chat(36, prefix .. ('Comparing github file (v%s) to your local file (v%s)...'):format(remote_version or 'n/a', _addon.version or 'n/a'))
        end

        local should_update = force or (compare_versions(remote_version, _addon.version) == 1)

        if should_update then
            if force then
                add_to_chat(36, prefix .. ('Force updating to GitHub version (v%s).'):format(remote_version or 'unknown'))
            else
                add_to_chat(36, prefix .. ('New version found (v%s), updating from v%s.'):format(remote_version, _addon.version))
            end

            local file_buffer = {}
            local _, full_code = https.request{
                url = version_url,
                method = "GET",
                headers = { ['User-Agent'] = 'SpamBlock/' .. tostring(_addon.version) },
                sink = ltn12.sink.table(file_buffer)
            }

            if full_code == 200 then
                local file_data = table.concat(file_buffer)

                -- Sanity checking to prevent network issues breaking the addon
                if #file_data < 1000 then
                    add_to_chat(123, prefix .. ('Update aborted! The downloaded file is too small. Please try again with'):color(123).. ('//sbl update'):color(206))
                    return
                end

                local f = io.open(file_path, "w")
                if f then
                    f:write(file_data)
                    f:close()
                    add_to_chat(36, prefix .. 'Update successful, reloading...')
                    send_command('@wait 0.5;lua reload ' .. _addon.name)
                    return
                else
                    add_to_chat(123, prefix .. ('Update failed. Cannot write: '):color(123).. file_path)
                end
            else
                add_to_chat(123, prefix .. 'Update failed. Github cannot be reached at this time.')
            end
        elseif manual then
            add_to_chat(36, prefix .. ('You are running the latest version (v%s).'):format(_addon.version))
        end
    end, 0)
end

-- Background auto-update check
register_event('load', function()
    check_for_update(false)
    coroutine.schedule(function()
        while true do
            local interval = tonumber(settings.update_interval) or 15
            if interval < 5 then interval = 5 end
            coroutine.sleep(interval * 60)
            check_for_update(false)
        end
    end, 0)
end)
local blacklist

add_to_chat(36, ('['):color(36)..('SpamBlock'):color(38)..('] '):color(36)..('Addon successfully loaded.'):color(36))

-- Wildcard matching because I'm tired of writing the same names over and over with a slight change
local function _normalize_name(value)
    if value == nil then return '' end
    return tostring(value):lower()
end

local function _name_matches_pattern(name, pattern)
    local n = _normalize_name(name)
    local p = _normalize_name(pattern)
    if p == '' then return false end

    local wildcard_start = (p:sub(1, 1) == '*')
    local wildcard_end = (p:sub(-1) == '*')

    if wildcard_start then p = p:sub(2) end
    if wildcard_end then p = p:sub(1, -2) end
    if p == '' then return false end

    if wildcard_start and wildcard_end then
        return n:find(p, 1, true) ~= nil
    end
    if wildcard_start then
        return (#p <= #n) and (n:sub(-#p) == p)
    end
    if wildcard_end then
        return (#p <= #n) and (n:sub(1, #p) == p)
    end
    return n == p
end

local function _name_in_blacklist(name, list)
    if not list then return false end
    for _, pattern in ipairs(list) do
        if _name_matches_pattern(name, pattern) then
            return true
        end
    end
    return false
end

local function _is_sender_blacklisted(name)
    if _name_in_blacklist(name, blacklist) then
        return true
    end

-- Custom blacklist behavior is intentionally exact-match only (no wildcards)
    return settings.custom_blist and settings.custom_blist:contains(name)
end

-- Filtered characters you will not see in any chat if blist option is enabled in settings.
blacklist = T{'Aboschitt','Aeonic*','Attkins','Bahcun','Bazzarcat','Boamna','Chirich','Comedie','Criofan','Deshutzn','Jamiei','Justchao','Kettica','Killera','Killerfa','Killerfd','Killerfg','Lowesquadone','Noke','Pangge','Panggeb','Pudwanker','Pockit','Thanatoss','Woohooc','Wooohoo','Xxzagorun','Xxzzgorun','Yagwic*','Leonardodicapri'}
-- Filters a shout or yell if they contain any of these strings, if the rmt option is enabled in settings.
local black_listed_words = T{string.char(0x81,0x69),string.char(0x81,0x99),string.char(0x81,0x9A),'CP500p','2100p','ML0-20/15m','New2025','V0toV25','3M/run','3M/hour','Aeonic Weapon*.*Mind','2100/20M','T1T2T3T4','3 Area Clear Mind','OdysseyNM','DYD W3','Dynamis*.*Buy?','unity.Master','43K+','Ambuscade*.*10M/run','DYDW3Clear.HTBC.VD.do you need it?buy?','OmenOdysseySeg11k','DYDW3Clear','Sortie40k+','50mil Time Remaining','80,85.90'}
-- Filters an item use message if it matches any of the IDs below, and the books option is enabled in settings.
local black_listed_skill_pages = T{'6147','6148','6149','6150','6151','6152','6153','6154','6155','6156','6157','6158','6159','6160','6161','6162','6163','6164','6165','6166','6167','6168','6169','6170','6171','6172','6173','6174','6175','6176','6177','6178','6179','6180','6181','6182','6183','6184','6185'}

--Packet changes for incoming chat and item-use
register_event('incoming chunk', function(id, data)
    if id == 0x017 then
        local chat = packets.parse('incoming', data)
        local cleaned = convert_auto_trans(chat['Message']):lower()

        if settings.blist and _is_sender_blacklisted(chat['Sender Name']) then
            return true
        end

        if (chat['Mode'] == 1 or chat['Mode'] == 26) and settings.rmt then
            for _, v in ipairs(black_listed_words) do
                if cleaned:match(v:lower()) then return true end
            end
            for _, v in ipairs(settings.custom_words) do
                if cleaned:match(v:lower()) then return true end
            end
        end

    elseif id == 0x028 and settings.books then
        local data = packets.parse('incoming', data)
        if black_listed_skill_pages:contains(data['Target 1 Action 1 Param']) then
            return true
        end
    end
end)

-- Addon Commands
windower.register_event('addon command', function(command, ...)
    local args = {...}
    command = command and command:lower() or ''
    local prefix = ('['):color(36)..('SpamBlock'):color(38)..('] '):color(36)

    if command == 'help' or command == '' then
        add_to_chat(36, prefix .. ('Commands, using '):color(36).. ('//sbl'):color(206)..(' or '):color(36)..('//spamblock'):color(206))
        add_to_chat(36, ('- '):color(36)..('blist '):color(206).. ('<player> '):color(160)..('- Adds player to blacklist.'):color(36))
        add_to_chat(36, ('- '):color(36)..('unblist '):color(206).. ('<player> '):color(160)..('Remove player from blacklist.'):color(36))
        add_to_chat(36, ('- '):color(36)..('addword '):color(206).. ('<word> '):color(160)..('- Adds phrase/word to filter list.'):color(36))
        add_to_chat(36, ('- '):color(36)..('delword '):color(206).. ('<word> '):color(160)..('- Removes phrase/word from filter list.'):color(36))
        add_to_chat(36, ('- '):color(36)..('list '):color(206)..('- Lists your blacklist and filter list.'):color(36))
        add_to_chat(36, ('- '):color(36)..('autoupdate '):color(206)..('- Toggles autoupdates on/off.'):color(36))
		add_to_chat(36, ('- '):color(36)..('update '):color(206)..('- Manually checks for updates.'):color(36))
        add_to_chat(36, ('- '):color(36)..('forceupdate '):color(206)..('- Force download the latest version.'):color(36))
        add_to_chat(36, ('- '):color(36)..('interval '):color(206).. ('<min> '):color(160)..('- Changes how often SpamBlock looks for updates, minimum of 5'):color(36))
        return
    end

    if command == 'update' then
        check_for_update(true, false)
        return
    end

    if command == 'forceupdate' then
        check_for_update(true, true)
        return
    end

    if command == 'interval' and args[1] then
        local new_int = tonumber(args[1])
        if new_int and new_int >= 5 then
            settings.update_interval = new_int
            config.save(settings)
            add_to_chat(36, prefix .. ('Auto-update interval set to %d minutes.'):format(new_int))
        else
            add_to_chat(123, prefix .. 'Please specify a valid number of minutes (minimum 5).')
        end
        return
    end

    if command == 'autoupdate' then
        settings.autoupdate = not settings.autoupdate
        config.save(settings)
        if settings.autoupdate then
            add_to_chat(36, prefix .. ('Auto-Update:'):color(36)..(' Enabled'):color(215)..('.'):color(36))
        else
            add_to_chat(36, prefix .. ('Auto-Update:'):color(36)..(' Disabled'):color(123)..('.'):color(36))
        end
        return
    end

    if command == 'blist' and args[1] then
        local name = args[1]
        local already = false
        for _, v in ipairs(settings.custom_blist) do
            if _normalize_name(v) == _normalize_name(name) then
                already = true
                break
            end
        end

        if not already then
            settings.custom_blist:append(name)
            config.save(settings)
            add_to_chat(36, prefix .. ('Added "%s" to custom blacklist.'):format(name))
        else
            add_to_chat(123, prefix .. ('"%s" is already in your custom blacklist.'):format(name))
        end

    elseif command == 'unblist' and args[1] then
        local name = args[1]
        local removed = false
        for i, v in ipairs(settings.custom_blist) do
            if _normalize_name(v) == _normalize_name(name) then
                table.remove(settings.custom_blist, i)
                removed = true
                break
            end
        end
        if removed then
            config.save(settings)
            add_to_chat(36, prefix .. ('Removed "%s" from custom blacklist.'):format(name))
        else
            add_to_chat(123, prefix .. ('"%s" not found in custom blacklist.'):format(name))
        end

    elseif command == 'addword' and args[1] then
        local word = table.concat(args, ' ')
        local exists = false
        for _, v in ipairs(settings.custom_words) do
            if v:lower() == word:lower() then
                exists = true
                break
            end
        end
        if not exists then
            settings.custom_words:append(word)
            config.save(settings)
            add_to_chat(36, prefix .. ('Added custom word "%s" to filter list.'):format(word))
        else
            add_to_chat(123, prefix .. ('"%s" already exists in filter list.'):format(word))
        end

    elseif command == 'delword' and args[1] then
        local word = table.concat(args, ' ')
        local removed = false
        for i, v in ipairs(settings.custom_words) do
            if v:lower() == word:lower() then
                table.remove(settings.custom_words, i)
                removed = true
                break
            end
        end
        if removed then
            config.save(settings)
            add_to_chat(36, prefix .. ('Removed "%s" from filter list.'):format(word))
        else
            add_to_chat(123, prefix .. ('"%s" not found in filter list.'):format(word))
        end
    elseif command == 'list' then
        add_to_chat(36, prefix .. 'Custom blacklisted players:')
        if #settings.custom_blist > 0 then
            for _, name in ipairs(settings.custom_blist) do add_to_chat(122, '  ' .. name) end
        else
            add_to_chat(123, 'Nobody has been added to your custom blacklist yet.')
        end

        add_to_chat(36, prefix .. 'Custom filtered words:')
        if #settings.custom_words > 0 then
            for _, word in ipairs(settings.custom_words) do add_to_chat(122, '  ' .. word) end
        else
            add_to_chat(123, 'Nothing has been added to your custom filter list yet.')
        end
    else
        add_to_chat(123, prefix .. ('Unknown command. Use'):color(123).. (' //sbl help '):color(206).. ('for a list of commands.'):color(123))
    end
end)
