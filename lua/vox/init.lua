local Run = hook.Run
local IncludeFolder = vox.IncludeFolder

if (SERVER) then
    resource.AddWorkshop('852839002')
end

Run('PreVoxLoad')

-- non recursive
IncludeFolder('vox/framework/')
IncludeFolder('vox/ui/')

-- init modules
do
    local Find = file.Find
    local path = 'vox/modules/'
    local _, folders = Find(path .. '*', 'LUA')
    for _, name in ipairs(folders) do
        vox.Include(path .. name .. '/sh_init.lua')
    end
end

Run('PostVoxLoad')
