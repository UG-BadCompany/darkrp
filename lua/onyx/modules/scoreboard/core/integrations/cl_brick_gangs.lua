--[[

Author: tochnonement
Email: tochnonement@gmail.com

12/03/2024

--]]

local stored = {}

function onyx.scoreboard.GetBricksGangName(gangID)
    return (stored[gangID] or '')
end

net.Receive('onyx.scoreboard(Bricks.Gangs):Replace', function(len)
    local id = net.ReadUInt(16)
    local name = net.ReadString()
    stored[id] = name
end)

net.Receive('onyx.scoreboard(Bricks.Gangs):Remove', function(len)
    stored[net.ReadUInt(16)] = nil
end)

netchunk.Callback('onyx.scoreboard:SyncBrickGangs', function(data, len)
    stored = data
    onyx.scoreboard:Print('Synchronized brick\'s gangs (#)', len)
end)