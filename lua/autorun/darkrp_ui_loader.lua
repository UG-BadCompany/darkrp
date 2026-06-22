-- DarkRP Premium UI Suite bootstrap loader.
DarkRPUI = DarkRPUI or {}
DarkRPUI.Version = "1.2.0"
DarkRPUI.AddonName = "DarkRP Premium UI Suite"

local sharedFiles = {
    "darkrp_ui/shared/sh_config.lua", "darkrp_ui/shared/sh_utils.lua", "darkrp_ui/shared/sh_theme.lua",
    "darkrp_ui/shared/sh_fonts.lua", "darkrp_ui/shared/sh_modules.lua",
    "darkrp_ui/shared/scoreboard/sh_scoreboard_columns.lua", "darkrp_ui/shared/scoreboard/sh_scoreboard_ranks.lua"
}
local clientFiles = {
    "darkrp_ui/client/cl_safearea.lua", "darkrp_ui/client/cl_theme.lua", "darkrp_ui/client/cl_fonts.lua", "darkrp_ui/client/cl_materials.lua",
    "darkrp_ui/client/cl_components.lua",
    "darkrp_ui/client/ui/cl_ui_core.lua", "darkrp_ui/client/ui/cl_ui_frame.lua", "darkrp_ui/client/ui/cl_ui_sidebar.lua",
    "darkrp_ui/client/ui/cl_ui_buttons.lua", "darkrp_ui/client/ui/cl_ui_cards.lua", "darkrp_ui/client/ui/cl_ui_rows.lua",
    "darkrp_ui/client/ui/cl_ui_inputs.lua", "darkrp_ui/client/ui/cl_ui_dropdown.lua", "darkrp_ui/client/ui/cl_ui_toggle.lua",
    "darkrp_ui/client/ui/cl_ui_slider.lua", "darkrp_ui/client/ui/cl_ui_scroll.lua", "darkrp_ui/client/ui/cl_ui_modals.lua",
    "darkrp_ui/client/ui/cl_ui_context_menu.lua", "darkrp_ui/client/ui/cl_ui_model_preview.lua", "darkrp_ui/client/ui/cl_ui_stat_ring.lua", "darkrp_ui/client/ui/cl_ui_badges.lua",
    "darkrp_ui/client/cl_storage.lua", "darkrp_ui/client/cl_settings.lua", "darkrp_ui/client/cl_networking.lua",
    "darkrp_ui/client/hud/cl_hud_core.lua", "darkrp_ui/client/hud/cl_hud_main.lua", "darkrp_ui/client/hud/cl_hud_ammo.lua",
    "darkrp_ui/client/hud/cl_hud_agenda.lua", "darkrp_ui/client/hud/cl_hud_alerts.lua", "darkrp_ui/client/hud/cl_hud_notifications.lua",
    "darkrp_ui/client/hud/cl_hud_door_info.lua", "darkrp_ui/client/hud/cl_hud_door_radial.lua", "darkrp_ui/client/hud/cl_hud_overhead.lua",
    "darkrp_ui/client/hud/cl_hud_pickup_history.lua", "darkrp_ui/client/hud/cl_hud_status.lua", "darkrp_ui/client/hud/cl_hud_timeout.lua",
    "darkrp_ui/client/hud/cl_hud_vehicle.lua", "darkrp_ui/client/hud/cl_hud_voice.lua", "darkrp_ui/client/hud/cl_hud_votes.lua",
    "darkrp_ui/client/hud/cl_hud_weapon_selector.lua", "darkrp_ui/client/hud/cl_hud_settings.lua",
    "darkrp_ui/client/f4/cl_f4_actions.lua", "darkrp_ui/client/f4/cl_f4_item_card.lua", "darkrp_ui/client/f4/cl_f4_job_detail.lua",
    "darkrp_ui/client/f4/cl_f4_dashboard.lua", "darkrp_ui/client/f4/cl_f4_jobs.lua", "darkrp_ui/client/f4/cl_f4_shop.lua",
    "darkrp_ui/client/f4/cl_f4_admin_stats.lua", "darkrp_ui/client/f4/cl_f4_player_upgrades.lua", "darkrp_ui/client/f4/cl_f4_sidebar.lua", "darkrp_ui/client/f4/cl_f4_frame.lua",
    "darkrp_ui/client/scoreboard/cl_scoreboard_actions.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_columns.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_ranks.lua",
    "darkrp_ui/client/scoreboard/cl_scoreboard_player_row.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_player_inspector.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_player_list.lua",
    "darkrp_ui/client/scoreboard/cl_scoreboard_column_editor.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_rank_editor.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_settings.lua", "darkrp_ui/client/scoreboard/cl_scoreboard_frame.lua",
    "darkrp_ui/client/cl_admin.lua", "darkrp_ui/client/cl_notifications.lua", "darkrp_ui/client/cl_context_menu.lua", "darkrp_ui/client/cl_modals.lua", "darkrp_ui/client/cl_premium_overlays.lua"
}
local serverFiles = {
    "darkrp_ui/server/sv_networking.lua", "darkrp_ui/server/sv_settings.lua", "darkrp_ui/server/sv_admin.lua", "darkrp_ui/server/sv_admin_actions.lua",
    "darkrp_ui/server/scoreboard/sv_scoreboard_columns.lua", "darkrp_ui/server/scoreboard/sv_scoreboard_ranks.lua"
}
local function includeShared(path) if SERVER then AddCSLuaFile(path) end include(path) end
local function includeClient(path) if SERVER then AddCSLuaFile(path) else include(path) end end
local function includeServer(path) if SERVER then include(path) end end
for _, path in ipairs(sharedFiles) do includeShared(path) end
for _, path in ipairs(clientFiles) do includeClient(path) end
for _, path in ipairs(serverFiles) do includeServer(path) end
hook.Run("DarkRPUI.Loaded", DarkRPUI.Version)
