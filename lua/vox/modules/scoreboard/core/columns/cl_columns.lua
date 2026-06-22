-- by p1ng :D

net.Receive('vox.scoreboard:SyncColumns', function()
    local amount = net.ReadUInt(8)

    vox.scoreboard.columnsCustomizable = {}

    for _ = 1, amount do
        local index = net.ReadUInt(8)
        local id = net.ReadString()
        vox.scoreboard.columnsCustomizable[index] = id
    end

    vox.scoreboard:Print('Synchronized # columns.', amount)

    hook.Run('vox.scoreboard.SyncedColumns')
end)
