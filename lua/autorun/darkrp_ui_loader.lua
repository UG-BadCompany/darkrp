-- DarkRP Premium UI Suite bootstrap loader.
DarkRPUI = DarkRPUI or {}
DarkRPUI.Version = "1.1.0"
DarkRPUI.AddonName = "DarkRP Premium UI Suite"

local sharedFiles = {
    "darkrp_ui/shared/sh_config.lua", "darkrp_ui/shared/sh_utils.lua", "darkrp_ui/shared/sh_theme.lua",
    "darkrp_ui/shared/sh_fonts.lua", "darkrp_ui/shared/sh_modules.lua"
}
local serverFiles = { "darkrp_ui/server/sv_networking.lua", "darkrp_ui/server/sv_settings.lua", "darkrp_ui/server/sv_admin.lua", "darkrp_ui/server/sv_admin_actions.lua" }
local clientFiles = {
    "darkrp_ui/client/cl_materials.lua", "darkrp_ui/client/cl_theme.lua", "darkrp_ui/client/cl_fonts.lua",
    "darkrp_ui/client/cl_safearea.lua",
    "darkrp_ui/client/cl_storage.lua", "darkrp_ui/client/cl_networking.lua", "darkrp_ui/client/cl_components.lua",
    "darkrp_ui/client/cl_notifications.lua", "darkrp_ui/client/cl_weapon_selector.lua", "darkrp_ui/client/cl_radial_menu.lua",
    "darkrp_ui/client/cl_door_ui.lua", "darkrp_ui/client/cl_entity_display.lua", "darkrp_ui/client/cl_modals.lua", "darkrp_ui/client/cl_context_menu.lua",
    "darkrp_ui/client/cl_hud.lua", "darkrp_ui/client/cl_f4.lua",
    "darkrp_ui/client/cl_scoreboard.lua", "darkrp_ui/client/cl_settings.lua", "darkrp_ui/client/cl_admin.lua",
    "darkrp_ui/client/cl_premium_overlays.lua"
}

local function includeShared(path) if SERVER then AddCSLuaFile(path) end include(path) end
local function includeClient(path) if SERVER then AddCSLuaFile(path) else include(path) end end
local function includeServer(path) if SERVER then include(path) end end
for _, path in ipairs(sharedFiles) do includeShared(path) end
for _, path in ipairs(serverFiles) do includeServer(path) end
for _, path in ipairs(clientFiles) do includeClient(path) end
hook.Run("DarkRPUI.Loaded", DarkRPUI.Version)
