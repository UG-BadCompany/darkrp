--[[

Author: tochnonement
Email: tochnonement@gmail.com

03/05/2023

--]]

if (netchunk == nil) then
    include('sh_netchunk.lua')
end

netchunk.Register('vox:SyncConfig')

vox.inconfig = vox.inconfig or {}
vox.inconfig.options = vox.inconfig.options or {}
vox.inconfig.values = vox.inconfig.values or {}
vox.inconfig.index = vox.inconfig.index or {}

local inconfig = vox.inconfig

function inconfig:Register(id, data)
    assert(isstring(id), 'bad argument #1 to \'inconfig:Register\' (string expected, got ' .. type(id) .. ')')
    assert(istable(data), 'bad argument #2 to \'inconfig:Register\' (table expected, got ' .. type(data) .. ')')
    assert(data.type, 'you must provide type in option data (' .. id .. ')')
    assert(data.default ~= nil, 'you must provide default value in option data (' .. id .. ')')
    assert(isstring(data.cami), Format('bad field \"cami\"\'s value in option \"%s\" (expected string, got %s)', id, type(data.cami)))                                                                                                                                             -- {{ user_uuid }} | {{ product_id }}
    data.id = id
    if (SERVER) then
        data.title = nil
        data.desc = nil
    end
    if (not self.options[id]) then
        data.index = table.insert(inconfig.index, id)
    end
    self.options[id] = data
    return data
end

function inconfig:Get(id)
    local value = self.values[id]
    if (value ~= nil) then
        return value
    else
        local option = self.options[id]
        assert(option, 'trying to get value from unregistered option (' .. id .. ')')
        return option.default
    end
end

do
    inconfig.Error = {
        INVALID_VALUE = 0x0,
        NUMBER_EXPECTED = 0x1,
        STRING_EXPECTED = 0x2,
        MIN_CHARS = 0x3,
        MAX_CHARS = 0x4,
        MIN_NUMBER = 0x5,
        MAX_NUMBER = 0x6,
        INVALID_MODEL = 0x7
    }

    local types = {}
    types['bool'] = function(option, value)
        return isbool(value)
    end
    types['int'] = function(option, value)
        if (not isnumber(value)) then
            return false, inconfig.Error.NUMBER_EXPECTED
        end

        if (option.min and value < option.min) then
            return false, inconfig.Error.MIN_NUMBER, option.min
        end

        if (option.max and value > option.max) then
            return false, inconfig.Error.MAX_NUMBER, option.max
        end

        return true
    end
    types['string'] = function(option, value)
        if (not isstring(value)) then
            return false, inconfig.Error.STRING_EXPECTED
        end

        value = value:Trim()

        local len = utf8.len(value)

        if (option.min and len < option.min) then
            return false, inconfig.Error.MIN_CHARS
        end

        if (option.max and len > option.max) then
            return false, inconfig.Error.MAX_CHARS
        end

        return true
    end
    types['model'] = function(option, value)
        if (not isstring(value)) then
            return false, inconfig.Error.STRING_EXPECTED
        end

        value = value:Trim()

        local validModel = value:Right(4) == '.mdl'

        return validModel, inconfig.Error.INVALID_MODEL
    end

    function inconfig:CheckValue(id, value)
        local option = self.options[id]
        if (value == nil) then return false, inconfig.Error.INVALID_VALUE end

        local check = types[option.type]

        assert(check, 'invalid type (' .. option.type .. ') for option (' .. id .. ')')

        local allowed, enumError, argument = check(option, value)

        if (allowed and option.check) then
            return option.check(value)
        end

        return allowed, enumError, argument
    end
end

if (SERVER) then
    util.AddNetworkString('vox.inconfig:Set')
    util.AddNetworkString('vox.inconfig:SetTable')
    util.AddNetworkString('vox.inconfig:SyncSingle')

    function inconfig:Set(id, value, bIgnoreOnSet)
        local option = self.options[id]
        assert(option, 'invalid option (' .. id .. ')')

        self.values[id] = value

        if (not bIgnoreOnSet and option.onSet) then
            option.onSet(value)
        end

        net.Start('vox.inconfig:SyncSingle')
            net.WriteString(id)
            net.WriteString(vox.TypeToString(value))
        net.Broadcast()

        hook.Run('vox.inconfig.OnValueChange', id, value)
    end

    function inconfig:Sync(ply)
        netchunk.Send(ply, 'vox:SyncConfig', self.values)
    end

    net.Receive('vox.inconfig:Set', function(len, ply)
        local optionID = net.ReadString()
        local optionTable = inconfig.options[optionID]
        if (not optionTable) then return end
        if (ply:GetVar('vox_inconfigRequestDelay', 0) > CurTime()) then return end

        ply:SetVar('vox_inconfigRequestDelay', CurTime() + 1)

        local valueStr = net.ReadString() -- I guess that would be better than net.ReadType
        local success, valueParsed = pcall(vox.StringToType, valueStr) -- in case someone tries to throw errors
        if (not success) then return end

        if (not inconfig:CheckValue(optionID, valueParsed)) then
            return
        end

        CAMI.PlayerHasAccess(ply, optionTable.cami, function(bAllowed)
            if (bAllowed) then
                inconfig:Set(optionID, valueParsed)
            end
        end)
    end)

    net.Receive('vox.inconfig:SetTable', function(len, ply)
        -- local optionID = net.ReadString()
        if (ply:GetVar('vox_inconfigRequestDelay', 0) > CurTime()) then return end

        ply:SetVar('vox_inconfigRequestDelay', CurTime() + 1)

        local amount = net.ReadUInt(6)
        for index = 1, amount do
            local optionID = net.ReadString()
            local optionTable = inconfig.options[optionID]
            if (not optionTable) then return end -- not continue, just return, how can a player request to set invalid option without sending fake net messages :\

            local valueStr = net.ReadString() -- I guess that would be better than net.ReadType
            local success, valueParsed = pcall(vox.StringToType, valueStr) -- in case someone tries to throw errors
            if (not success) then continue end -- just in case

            if (not inconfig:CheckValue(optionID, valueParsed)) then
                continue
            end

            CAMI.PlayerHasAccess(ply, optionTable.cami, function(bAllowed) -- every option may have own cami privilege
                if (bAllowed) then
                    inconfig:Set(optionID, valueParsed)
                end
            end)
        end
    end)

    hook.Add('vox.PlayerNetworkReady', 'vox.inconfig.Sync', function(ply)
        inconfig:Sync(ply)
    end)
else
    netchunk.Callback('vox:SyncConfig', function(data)
        vox.inconfig.values = data
        vox:Print('Synchronized settings.')
        hook.Run('vox.inconfig.Synchronized')
    end)

    net.Receive('vox.inconfig:SyncSingle', function()
        local optionID = net.ReadString()
        local value = net.ReadString()
        local optionValue = vox.StringToType(value)
        local oldValue = vox.inconfig.values[optionID]

        vox:Print('Updated option #, new value: #', optionID, value)
        vox.inconfig.values[optionID] = optionValue

        hook.Run('vox.inconfig.Updated', optionID, oldValue, optionValue)
    end)
end
