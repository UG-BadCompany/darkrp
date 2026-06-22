netchunk.Callback('vox.f4:SendStats', function(data)
    hook.Run('vox.f4.StatsReceived', data)
end)
