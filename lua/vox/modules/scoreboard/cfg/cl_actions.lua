--[[

Author: tochnonement
Email: tochnonement@gmail.com

02/03/2024

--]]

--[[------------------------------
**WARNING**
This is an advanced config.
Most of the things you need should be configurable through the game.
Do not edit anything if you do not understand what you are doing.
--------------------------------]]

vox.scoreboard.Buttons = {}
vox.scoreboard.adminHandler = nil

local adminHandlers = {}

local TYPE_NAME = 1
local TYPE_STEAMID64 = 2
local TYPE_STEAMID32 = 3

local function adminModeHandler(uniqueID, priority, validator, data)
    table.insert(adminHandlers, {
        uniqueID = uniqueID,
        priority = priority,
        validator = validator,
        data = data
    })
end

local function registerAdminButton(cmd, cmdData)
    vox.scoreboard:RegisterButton(cmd, {
        callback = function(ply)
            local handler = vox.scoreboard.adminHandler
            local data = handler.data
            local command = cmdData.getCommand and cmdData.getCommand(ply) or cmd

            local targetID
            if (data.idFormat == TYPE_STEAMID32) then
                targetID = ply:SteamID()
            elseif (data.idFormat == TYPE_STEAMID64) then
                targetID = ply:SteamID64()
            else
                targetID = ply:Name()
            end

            if ( handler.uniqueID == 'vox_admin_action' ) then
                RunConsoleCommand('vox_admin_action', command == 'return' and 'returnply' or command, ply:SteamID())
            else
                RunConsoleCommand(handler.uniqueID, command, targetID)
            end
        end,
        getVisible = function(client)
            local handler = vox.scoreboard.adminHandler
            if (not handler) then return false end

            local data = handler.data
            return data.hasPermission(client, cmd)
        end
    })
end

--[[------------------------------
Common actions
--------------------------------]]
vox.scoreboard:RegisterButton('profile', {
    callback = function(ply)
        gui.OpenURL('https://steamcommunity.com/profiles/' .. ply:SteamID64())
    end
})

--[[------------------------------
FSpectate
--------------------------------]]
vox.scoreboard:RegisterButton('spectate', {
    callback = function(ply)
        if (ply ~= LocalPlayer()) then
            net.Start("FSpectateTarget")
                net.WriteEntity(ply)
            net.SendToServer()
        end
    end,
    getVisible = function(client)
        local success, bHasAccess = pcall(CAMI.PlayerHasAccess, client, 'FSpectate')
        if (not success) then
            bHasAccess = client:IsSuperAdmin()
        end
        return (FSpectate ~= nil and (success and bHasAccess))
    end
})

--[[------------------------------
Admin actions
--------------------------------]]
registerAdminButton('freeze', {
    getCommand = function(target)
        return (target:IsFlagSet(FL_FROZEN) and 'unfreeze' or 'freeze')
    end
})

registerAdminButton('goto', {})
registerAdminButton('bring', {})
registerAdminButton('return', {})
registerAdminButton('respawn', {})
registerAdminButton('slay', {})
registerAdminButton('kick', {})
registerAdminButton('warn', {})

--[[------------------------------
Admin modes
--------------------------------]]
adminModeHandler('sam', 100, function()
    return sam
end, {
    idFormat = TYPE_STEAMID64,
    hasPermission = function(client, cmd)
        return client:HasPermission(cmd)
    end
})

do
    local DISABLED = {
        ['respawn'] = true,
    }

    adminModeHandler('ulx', 100, function()
        return ulx
    end, {
        idFormat = TYPE_NAME,
        hasPermission = function(client, cmd)
            return (client:query('ulx ' .. cmd) == true and not DISABLED[cmd])
        end
    })
end

do
    local DISABLED = {
        ['respawn'] = true,
        ['return'] = true,
    }

    adminModeHandler('fadmin', 1, function()
        return FAdmin
    end, {
        idFormat = TYPE_STEAMID32,
        hasPermission = function(client, cmd)
            return (client:IsAdmin() and not DISABLED[cmd])
        end
    })
end

--[[------------------------------
Fetch admin mode
--------------------------------]]
vox.WaitForGamemode('vox.scoreboard.InitButtons', function()
    table.sort(adminHandlers, function(a, b)
        return a.priority > b.priority
    end)

    for _, handler in ipairs(adminHandlers) do
        if (handler.validator()) then
            vox.scoreboard.adminHandler = handler
            break
        end
    end

    if (vox.scoreboard.adminHandler) then
        vox.scoreboard:PrintSuccess('Found admin handler: ' .. vox.scoreboard.adminHandler.uniqueID)
    else
        vox.scoreboard.adminHandler = {
            uniqueID = 'vox_admin_action',
            data = {
                idFormat = TYPE_STEAMID32,
                hasPermission = function(client, cmd)
                    return IsValid(client) and client:IsAdmin()
                end
            }
        }
        vox.scoreboard:PrintSuccess('Using built-in Vox Admin fallback.')
    end
end)
