--[[

Author: tochnonement
Email: tochnonement@gmail.com

12/03/2024

--]]

local stored = {}

util.AddNetworkString('vox.scoreboard(Bricks.Gangs):Replace')
util.AddNetworkString('vox.scoreboard(Bricks.Gangs):Remove')
util.AddNetworkString('vox.scoreboard(Bricks.Gangs):SyncAll')

local function updateGang(id, name)
    stored[id] = name

    net.Start('vox.scoreboard(Bricks.Gangs):Replace')
        net.WriteUInt(id, 16)
        net.WriteString(name)
    net.Broadcast()
end

local function delGang(id)
    stored[id] = nil

    net.Start('vox.scoreboard(Bricks.Gangs):Remove')
        net.WriteUInt(id, 16)
    net.Broadcast()
end

local function handle()
    local gangs = BRICKS_SERVER_GANGS or {}

    -- unload non existent
    for id in pairs(stored) do
        if (not gangs[id]) then
            delGang(id)
        end
    end

    -- add
    for id, data in pairs(gangs) do
        local name = data.Name
        if (name and (not stored[id] or stored[id] ~= name)) then
            updateGang(id, name)
        end
    end
end

local function syncAll(ply)
    netchunk.Send(ply, 'vox.scoreboard:SyncBrickGangs', stored)
end

vox.WaitForGamemode('vox.scoreboard.Support:Bricks.Gangs', function()
    if (BRICKS_SERVER and BRICKS_SERVER.GANGS) then
        timer.Create('scoreboard.Support:Bricks.Gangs', 1, 0, function()
            xpcall(handle, function(errText)
                vox.scoreboard:PrintError('Error during Brick\'s Gang controller: ', errText)
            end)
        end)

        hook.Add('vox.PlayerNetworkReady', 'vox.scoreboard(Bricks.Gangs)', syncAll)
    end
end)
