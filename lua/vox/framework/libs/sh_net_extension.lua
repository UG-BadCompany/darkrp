vox.net = {}

function vox.net.WriteTable(tbl)
    assert(tbl, 'missing table')
    assert(istable(tbl), 'the provided argument must be a table')

    local encoded = pon.encode(tbl)
    local len = #encoded

    net.WriteUInt(len, 32)
    net.WriteData(encoded, len)
end

function vox.net.ReadTable()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    local success, decoded = pcall(pon.decode, data)

    if (success) then
        return decoded
    end

    return {}
end

function vox.net.Send(ply)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

if (SERVER) then
    local function GetHookName(ply)
        return ('vox.NetReadyCheck_' .. ply:SteamID64())
    end

    hook.Add('PlayerInitialSpawn', 'vox.GetNetworkReady', function(ply)
        hook.Add('SetupMove', GetHookName(ply), function(ply2, mvd, cmd)
            if ply == ply2 and not cmd:IsForced() then
                hook.Remove('SetupMove', GetHookName(ply2))
                hook.Run('vox.PlayerNetworkReady', ply2)
                hook.Run('vox.PostPlayerNetworkReady', ply2) -- required for netvar library and etc.
                ply2:SetVar('vox_NetReady', true)
            end
        end)
    end)
end
