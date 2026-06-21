--[[
    DarkRP Premium UI Suite
    Bootstrap loader for client/server/shared modules.
]]

DarkRPUI = DarkRPUI or {}
DarkRPUI.Version = "1.0.0"
DarkRPUI.AddonName = "DarkRP Premium UI Suite"

local function IncludeShared(path)
    if SERVER then AddCSLuaFile(path) end
    include(path)
end

local function IncludeClient(path)
    if SERVER then AddCSLuaFile(path) else include(path) end
end

local function IncludeServer(path)
    if SERVER then include(path) end
end

IncludeShared("darkrp_ui/shared/sh_config.lua")
IncludeShared("darkrp_ui/shared/sh_utils.lua")
IncludeShared("darkrp_ui/shared/sh_theme.lua")
IncludeShared("darkrp_ui/shared/sh_fonts.lua")
IncludeShared("darkrp_ui/shared/sh_modules.lua")

IncludeServer("darkrp_ui/server/sv_networking.lua")
IncludeServer("darkrp_ui/server/sv_settings.lua")
IncludeServer("darkrp_ui/server/sv_admin.lua")

IncludeClient("darkrp_ui/client/cl_materials.lua")
IncludeClient("darkrp_ui/client/cl_theme.lua")
IncludeClient("darkrp_ui/client/cl_fonts.lua")
IncludeClient("darkrp_ui/client/cl_storage.lua")
IncludeClient("darkrp_ui/client/cl_networking.lua")
IncludeClient("darkrp_ui/client/cl_components.lua")
IncludeClient("darkrp_ui/client/cl_notifications.lua")
IncludeClient("darkrp_ui/client/cl_hud.lua")
IncludeClient("darkrp_ui/client/cl_f4.lua")
IncludeClient("darkrp_ui/client/cl_scoreboard.lua")
IncludeClient("darkrp_ui/client/cl_settings.lua")
IncludeClient("darkrp_ui/client/cl_admin.lua")
