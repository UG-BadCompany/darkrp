B4DUI = B4DUI or {}
B4DUI.Name = "B4D UI"
B4DUI.Version = "1.0.0"
B4DUI.Root = "b4d_ui/"

local sharedFiles = {
    "shared/sh_config.lua", "shared/sh_theme.lua", "shared/sh_fonts.lua",
    "shared/sh_utils.lua", "shared/sh_permissions.lua", "shared/sh_admin.lua"
}
local serverFiles = {
    "server/sv_networking.lua", "server/sv_settings.lua", "server/sv_admin.lua",
    "server/sv_admin_actions.lua", "server/sv_admin_logs.lua"
}
local clientCore = {
    "client/core/cl_safearea.lua", "client/core/cl_theme.lua", "client/core/cl_fonts.lua",
    "client/core/cl_materials.lua", "client/core/cl_storage.lua", "client/core/cl_networking.lua",
    "client/core/cl_animation.lua"
}
local clientUI = {
    "client/ui/cl_ui_core.lua", "client/ui/cl_ui_frame.lua", "client/ui/cl_ui_sidebar.lua",
    "client/ui/cl_ui_buttons.lua", "client/ui/cl_ui_cards.lua", "client/ui/cl_ui_rows.lua",
    "client/ui/cl_ui_inputs.lua", "client/ui/cl_ui_dropdown.lua", "client/ui/cl_ui_toggle.lua",
    "client/ui/cl_ui_slider.lua", "client/ui/cl_ui_scroll.lua", "client/ui/cl_ui_modals.lua",
    "client/ui/cl_ui_context_menu.lua", "client/ui/cl_ui_model_preview.lua",
    "client/ui/cl_ui_stat_ring.lua", "client/ui/cl_ui_badges.lua", "client/ui/cl_ui_tooltips.lua"
}
local clientHUD = {
    "client/hud/cl_hud_core.lua", "client/hud/cl_hud_main.lua", "client/hud/cl_hud_ammo.lua",
    "client/hud/cl_hud_agenda.lua", "client/hud/cl_hud_alerts.lua", "client/hud/cl_hud_notifications.lua",
    "client/hud/cl_hud_door_info.lua", "client/hud/cl_hud_door_radial.lua", "client/hud/cl_hud_overhead.lua",
    "client/hud/cl_hud_pickup_history.lua", "client/hud/cl_hud_status.lua", "client/hud/cl_hud_timeout.lua",
    "client/hud/cl_hud_vehicle.lua", "client/hud/cl_hud_voice.lua", "client/hud/cl_hud_votes.lua",
    "client/hud/cl_hud_weapon_selector.lua", "client/hud/cl_hud_settings.lua"
}
local clientF4 = {
    "client/f4/cl_f4_core.lua", "client/f4/cl_f4_frame.lua", "client/f4/cl_f4_sidebar.lua",
    "client/f4/cl_f4_dashboard.lua", "client/f4/cl_f4_jobs.lua", "client/f4/cl_f4_job_detail.lua",
    "client/f4/cl_f4_shop.lua", "client/f4/cl_f4_item_card.lua", "client/f4/cl_f4_actions.lua",
    "client/f4/cl_f4_player_upgrades.lua", "client/f4/cl_f4_settings.lua", "client/f4/cl_f4_admin_stats.lua"
}
local clientScoreboard = {
    "client/scoreboard/cl_scoreboard_core.lua", "client/scoreboard/cl_scoreboard_frame.lua",
    "client/scoreboard/cl_scoreboard_player_list.lua", "client/scoreboard/cl_scoreboard_player_row.lua",
    "client/scoreboard/cl_scoreboard_player_inspector.lua", "client/scoreboard/cl_scoreboard_actions.lua",
    "client/scoreboard/cl_scoreboard_columns.lua", "client/scoreboard/cl_scoreboard_column_editor.lua",
    "client/scoreboard/cl_scoreboard_ranks.lua", "client/scoreboard/cl_scoreboard_rank_editor.lua",
    "client/scoreboard/cl_scoreboard_settings.lua"
}
local clientAdmin = {
    "client/admin/cl_admin_core.lua", "client/admin/cl_admin_frame.lua", "client/admin/cl_admin_dashboard.lua",
    "client/admin/cl_admin_players.lua", "client/admin/cl_admin_player_inspector.lua", "client/admin/cl_admin_actions.lua",
    "client/admin/cl_admin_logs.lua", "client/admin/cl_admin_reports.lua", "client/admin/cl_admin_settings.lua"
}
local function loadShared(path) AddCSLuaFile(B4DUI.Root .. path) include(B4DUI.Root .. path) end
local function sendClient(path) AddCSLuaFile(B4DUI.Root .. path) end
local function loadClient(path) if CLIENT then include(B4DUI.Root .. path) end end
local function loadServer(path) if SERVER then include(B4DUI.Root .. path) end end
for _, path in ipairs(sharedFiles) do loadShared(path) end
for _, group in ipairs({clientCore, clientUI, clientHUD, clientF4, clientScoreboard, clientAdmin}) do for _, path in ipairs(group) do sendClient(path) end end
if SERVER then for _, path in ipairs(serverFiles) do loadServer(path) end end
if CLIENT then for _, group in ipairs({clientCore, clientUI, clientHUD, clientF4, clientScoreboard, clientAdmin}) do for _, path in ipairs(group) do loadClient(path) end end end
