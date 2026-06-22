concommand.Add( 'vox_reload', function()
    RunConsoleCommand( 'lua_openscript_cl', 'autorun/vox_autorun.lua' )
    if notification and notification.AddLegacy then notification.AddLegacy( 'Vox UI reload requested.', NOTIFY_GENERIC, 4 ) end
end )

concommand.Add( 'vox_reset_settings', function()
    for _, cvar in ipairs( {
        'cl_vox_hud_theme_id', 'cl_vox_hud_compact', 'cl_vox_hud_3d_models', 'cl_vox_hud_show_help'
    } ) do
        if GetConVar( cvar ) then RunConsoleCommand( cvar, GetConVar( cvar ):GetDefault() or '0' ) end
    end
    if vox and vox.inconfig and vox.inconfig.Reset then vox.inconfig.Reset() end
    if notification and notification.AddLegacy then notification.AddLegacy( 'Vox Settings reset to defaults.', NOTIFY_GENERIC, 5 ) end
end )

concommand.Add( 'vox_debug_safearea', function()
    vox.hud.DebugSafeAreaUntil = CurTime() + 10
    if notification and notification.AddLegacy then notification.AddLegacy( 'Vox safe-area debug enabled for 10 seconds.', NOTIFY_HINT, 5 ) end
end )

concommand.Add( 'vox_test_notification', function()
    if not notification or not notification.AddLegacy then return end
    notification.AddLegacy( 'Vox info notification preview.', NOTIFY_GENERIC, 5 )
    notification.AddLegacy( 'Vox success notification preview.', NOTIFY_UNDO, 5 )
    notification.AddLegacy( 'Vox warning notification preview.', NOTIFY_HINT, 5 )
    notification.AddLegacy( 'Vox error notification preview.', NOTIFY_ERROR, 5 )
end )

concommand.Add( 'vox_open_admin', function()
    if vox.admin and vox.admin.Open then vox.admin.Open() return end
    if vox.f4 and vox.f4.OpenAdminSettings then vox.f4.OpenAdminSettings() end
end )

concommand.Add( 'vox_open_hud_settings', function()
    if vox.hud and vox.hud.OpenSettings then vox.hud.OpenSettings() return end
    RunConsoleCommand( 'say', '!hud' )
end )
