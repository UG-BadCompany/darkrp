--[[

Author: tochnonement
Email: tochnonement@gmail.com

01/05/2023

--]]

do
    local events = {}
    local processed = false
    local wasError = false

    local function executeEvent(id, fn)
        local status, errorText = pcall(fn)
        if (not status) then
            wasError = true
            ErrorNoHalt('Error in vox.WaitForGamemode hook \'' .. id .. '\': ' .. ( errorText or '' ) .. '\n')
        end
    end

    local function processEvents()
        for id, fn in pairs(events) do
            executeEvent(id, fn)
        end

        events = {}
    end

    function vox.WaitForGamemode(id, fn)
        assert(isstring(id), 'bad argument #1 to \'vox.WaitForGamemode\' (expected string, got ' .. type(id) .. ')')
        assert(isfunction(fn), 'bad argument #2 to \'vox.WaitForGamemode\' (expected function, got ' .. type(fn) .. ')')
        if ( GM or GAMEMODE ) then
            executeEvent(id, fn)
        else
            events[id] = fn
        end
    end

    -- 'PostGamemodeLoaded' ain't called on CLIENT with uLib
    -- I hate ULX lol (`InitPostEntity` doesn't get called on serverside :\\\\)
    hook.Add((SERVER and 'PostGamemodeLoaded' or 'InitPostEntity'), 'vox.WaitForGamemode', function()
        if (not processed) then
            processed = true
            processEvents()
        end
    end)

    hook.Add('Think', 'vox.WaitForGamemode', function()
        hook.Remove('Think', 'vox.WaitForGamemode')
        if (wasError) then
            vox:PrintError('Some vox.WaitForGamemode hooks failed to execute. Please contact the addon creator.')
        elseif (processed) then
            vox:PrintSuccess('All vox.WaitForGamemode hooks have been processed successfully.')
        else
            processEvents()
            processed = true

            if (wasError) then
                vox:PrintError('[DELAYED] Some vox.WaitForGamemode hooks failed to execute. Please contact the addon creator.')
            else
                vox:PrintWarning('vox.WaitForGamemode hooks have been processed late.')
            end
        end
    end)
end

function vox.AssertType(variable, expected, funcname, pos)
    local given = type(variable)
    assert(given == expected, string.format('bad argument #%i to \'%s\' (expected %s, got %s)', pos, funcname, expected, given))
end

function vox.ColorToHex(color)
    local r = bit.tohex(color.r, 2)
    local g = bit.tohex(color.g, 2)
    local b = bit.tohex(color.b, 2)

    return ('#' .. r .. g .. b)
end

function vox.HexToColor(color)
    color = color:gsub('#', '')

    local r = tonumber('0x' .. color:sub(1, 2))
    local g = tonumber('0x' .. color:sub(3, 4))
    local b = tonumber('0x' .. color:sub(5, 6))

    return Color(r, g, b)
end

function vox.MultiArg(arg, amount)
    local tbl = {}
    for i = 1, amount do
        tbl[i] = arg
    end
    return unpack(tbl)
end

do
    local replacements = {
        TypeToString = {
            ['boolean'] = 'b',
            ['number'] = 'n',
            ['string'] = 's',
            ['Vector'] = 'v',
            ['Angle'] = 'a',
        },
        StringToType = {
            ['b'] = 'bool',
            ['n'] = 'int',
            ['s'] = 'string',
            ['v'] = 'vector',
            ['a'] = 'angle',
            ['f'] = 'float'
        },
    }

    function vox.TypeToString(any)
        local name = replacements.TypeToString[type(any)]
        assert(name, 'wrong type (' .. type(any) .. ')')
        local str = util.TypeToString(any)
        if (name == 'n' and (any % 1) ~= 0) then
            name = 'f'
        end
        local full = name .. '!' .. str
        return full
    end

    function vox.StringToType(str)
        local typeShort = str:match('%w!-')
        local value = str:gsub(typeShort .. '!', '', 1)
        local typeFull = replacements.StringToType[typeShort]
        return util.StringToType(value, typeFull)
    end
end

if (SERVER) then
    util.AddNetworkString('vox:Notify')

    function vox.Notify(ply, text, notificationType, length)
        assert(IsEntity(ply), Format('bad argument #1 to `vox.Notify` (expected player, got %s)', type(ply)))
        assert(isstring(text), Format('bad argument #2 to `vox.Notify` (expected string, got %s)', type(text)))

        net.Start('vox:Notify')
            net.WriteString(text)
            net.WriteUInt(notificationType or 0, 3)
            net.WriteUInt(length or 3, 4)
            net.WriteBool(false)
        net.Send(ply)
    end

    function vox.NotifyLocalized(ply, text, args, notificationType, length)
        assert(IsEntity(ply), Format('bad argument #1 to `vox.NotifyLocalized` (expected player, got %s)', type(ply)))
        assert(isstring(text), Format('bad argument #2 to `vox.NotifyLocalized` (expected string, got %s)', type(text)))
        assert(istable(args), Format('bad argument #3 to `vox.NotifyLocalized` (expected table, got %s)', type(args)))

        net.Start('vox:Notify')
            net.WriteString(text)
            net.WriteUInt(notificationType or 0, 3)
            net.WriteUInt(length or 3, 4)
            net.WriteBool(true)
            vox.net.WriteTable(args)
        net.Send(ply)
    end
else
    net.Receive('vox:Notify', function(len)
        local text = net.ReadString()
        local notificationType = net.ReadUInt(3)
        local length = net.ReadUInt(4)
        local bLocalized = net.ReadBool()
        local arguments = bLocalized and vox.net.ReadTable()

        if (bLocalized) then
            text = vox.lang:Get(text, arguments)
        end

        notification.AddLegacy(text, notificationType, length)
    end)
end
