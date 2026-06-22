--[[

Author: tochnonement
Email: tochnonement@gmail.com

23/04/2023

--]]

onyx.net = {}

function onyx.net.WriteTable(tbl)
    assert(tbl, 'missing table')
    assert(istable(tbl), 'the provided argument must be a table')

    local encoded = pon.encode(tbl)
    local len = #encoded

    net.WriteUInt(len, 32)
    net.WriteData(encoded, len)
end

function onyx.net.ReadTable()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    local success, decoded = pcall(pon.decode, data)

    if (success) then
        return decoded
    end

    return {}
end

function onyx.net.Send(ply)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

if (SERVER) then
    local function GetHookName(ply)
        return ('onyx.NetReadyCheck_' .. ply:SteamID64())
    end

    hook.Add('PlayerInitialSpawn', 'onyx.GetNetworkReady', function(ply)
        hook.Add('SetupMove', GetHookName(ply), function(ply2, mvd, cmd)
            if ply == ply2 and not cmd:IsForced() then
                hook.Remove('SetupMove', GetHookName(ply2))
                hook.Run('onyx.PlayerNetworkReady', ply2)
                hook.Run('onyx.PostPlayerNetworkReady', ply2) -- required for netvar library and etc.
                ply2:SetVar('onyx_NetReady', true)
            end
        end)
    end)
end