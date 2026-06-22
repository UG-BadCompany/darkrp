--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/05/2023

--]]

--[[------------------------------
Requires `sh_net_extension.lua`, though doesn't need to be loaded before that
--------------------------------]]

if (SERVER) then
    util.AddNetworkString('onyx.netvar:Sync')
    util.AddNetworkString('onyx.netvar:Clear')
    util.AddNetworkString('onyx.netvar:DeleteEntity')
end

onyx.netvar = onyx.netvar or {}
onyx.netvar.list = onyx.netvar.list or {}
onyx.netvar.data = onyx.netvar.data or {}
onyx.netvar.public = onyx.netvar.public or {}

local netvar = onyx.netvar
local types = {
    [TYPE_BOOL] = {write = net.WriteBool, read = net.ReadBool},
    [TYPE_NUMBER] = {
        write = function(value, bits, unsigned)
            if (unsigned) then
                net.WriteUInt(value, bits)
            else
                net.WriteInt(value, bits)
            end
        end,
        read = function(bits, unsigned)
            if (unsigned) then
                return net.ReadUInt(bits)
            else
                return net.ReadInt(bits)
            end
        end
    },
    [TYPE_STRING] = {
        write = net.WriteString,
        read = net.ReadString,
    }
}

local function syncNetVar(entIndex, data, id, value, receiver)
    local write = types[data.type].write

    net.Start('onyx.netvar:Sync')

    net.WriteUInt(entIndex, 16)
    net.WriteString(id)
    write(value, data.bits, data.unsigned)

    -- could be invalid player
    if (receiver == nil) then
        net.Broadcast()
    else
        -- 100% is a player
        net.Send(receiver)
    end
end

function netvar:Register(id, data)
    data.id = id
    self.list[id] = data

    if (data.public) then
        self.public[id] = value
    end
end

do
    local ENTITY = FindMetaTable('Entity')

    function ENTITY:onyx_SetNetVar(id, value)
        if (CLIENT) then return end

        assert(isstring(id), Format('bad argument #1 to `onyx_SetNetVar` (expected string, got %s)', type(id)))
        assert(value ~= nil, 'bad argument #2 to `onyx_SetNetVar` (expected anything, got nil)')

        local data = netvar.list[id]

        assert(data, string.format('trying to set invalid netvar \'%s\' to %s', tostring(id), tostring(self)))

        local entIndex = self:EntIndex()

        netvar.data[entIndex] = netvar.data[entIndex] or {}
        netvar.data[entIndex][id] = value

        syncNetVar(entIndex, data, id, value, (not data.public and self or nil))
    end

    function ENTITY:onyx_ClearNetVar(id)
        if (CLIENT) then return end

        local entIndex = self:EntIndex()

        if (not netvar.data[entIndex]) then return end

        local data = netvar.list[id]

        netvar.data[entIndex][id] = nil

        net.Start('onyx.netvar:Clear')

        net.WriteUInt(entIndex, 16)
        net.WriteString(id)

        if (data.public) then
            net.Broadcast()
        else
            net.Send(self) -- must be a player
        end
    end

    function ENTITY:onyx_GetNetVar(id, fallback)
        local storage = netvar.data[self:EntIndex()]
        if (storage) then
            return (storage[id] or fallback)
        end
    end
end

if (CLIENT) then
    net.Receive('onyx.netvar:Sync', function(len)
        local entIndex = net.ReadUInt(16)

        local id = net.ReadString()
        local data = netvar.list[id]
        local read = types[data.type].read
        local value = read(data.bits, data.unsigned)

        netvar.data[entIndex] = netvar.data[entIndex] or {}
        netvar.data[entIndex][id] = value
    end)
else
    hook.Add('onyx.PlayerNetworkReady', 'onyx.netvar', function(ply)
        for entIndex, storage in pairs(netvar.data) do

            local isClient = (ply:EntIndex() == entIndex)

            for id, value in pairs(storage) do
                local data = netvar.list[id]
                if (data.public or isClient) then
                    syncNetVar(entIndex, data, id, value, ply)
                end
            end

        end
    end)
end

if (SERVER) then
    hook.Add('EntityRemoved', 'onyx.netvar', function(ent)
        -- lol it gets called by engine on clientside for all entities after data has been synced
        local entIndex = ent:EntIndex()

        netvar.data[entIndex] = nil

        net.Start('onyx.netvar:DeleteEntity')
            net.WriteUInt(entIndex, 16)
        net.Broadcast()
    end)
else
    net.Receive('onyx.netvar:DeleteEntity', function(len)
        local entIndex = net.ReadUInt(16)

        netvar.data[entIndex] = nil
    end)

    net.Receive('onyx.netvar:Clear', function(len)
        local entIndex = net.ReadUInt(16)
        local netvarID = net.ReadString()

        if (netvar.data[entIndex]) then
            netvar.data[entIndex][netvarID] = nil
        end
    end)
end


-- print(Entity(1):EntIndex())
-- PrintTable(netvar.data)
-- Entity(1):onyx_SetNetVar('store_loaded', true)