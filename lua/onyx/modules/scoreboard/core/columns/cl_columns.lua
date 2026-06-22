-- by p1ng :D

net.Receive('onyx.scoreboard:SyncColumns', function()
    local amount = net.ReadUInt(8)

    onyx.scoreboard.columnsCustomizable = {}

    for _ = 1, amount do
        local index = net.ReadUInt(8)
        local id = net.ReadString()
        onyx.scoreboard.columnsCustomizable[index] = id
    end

    onyx.scoreboard:Print('Synchronized # columns.', amount)

    hook.Run('onyx.scoreboard.SyncedColumns')
end)