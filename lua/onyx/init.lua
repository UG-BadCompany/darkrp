--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

local Run = hook.Run
local IncludeFolder = onyx.IncludeFolder

if (SERVER) then
    resource.AddWorkshop('852839002')
end

Run('PreOnyxLoad')

-- non recursive
IncludeFolder('onyx/framework/')
IncludeFolder('onyx/ui/')

-- init modules
do
    local Find = file.Find
    local path = 'onyx/modules/'
    local _, folders = Find(path .. '*', 'LUA')
    for _, name in ipairs(folders) do
        onyx.Include(path .. name .. '/sh_init.lua')
    end
end

Run('PostOnyxLoad')