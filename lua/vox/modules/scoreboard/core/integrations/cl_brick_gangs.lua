local stored = {}

function vox.scoreboard.GetBricksGangName(gangID)
    return (stored[gangID] or '')
end

net.Receive('vox.scoreboard(Bricks.Gangs):Replace', function(len)
    local id = net.ReadUInt(16)
    local name = net.ReadString()
    stored[id] = name
end)

net.Receive('vox.scoreboard(Bricks.Gangs):Remove', function(len)
    stored[net.ReadUInt(16)] = nil
end)

netchunk.Callback('vox.scoreboard:SyncBrickGangs', function(data, len)
    stored = data
    vox.scoreboard:Print('Synchronized brick\'s gangs (#)', len)
end)
