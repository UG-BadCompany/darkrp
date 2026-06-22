--[[

Author: tochnonement
Email: tochnonement@gmail.com

03/01/2024

--]]

netchunk.Callback('vox.f4:SendStats', function(data)
    hook.Run('vox.f4.StatsReceived', data)
end)
