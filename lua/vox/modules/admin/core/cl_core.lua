net.Receive( 'VoxUI.Admin.Notify', function()
    local ok = net.ReadBool()
    local msg = net.ReadString()
    if notification and notification.AddLegacy then
        notification.AddLegacy( msg, ok and NOTIFY_GENERIC or NOTIFY_ERROR, 5 )
    end
    surface.PlaySound( ok and 'buttons/button15.wav' or 'buttons/button10.wav' )
end )

local sections = {
    'Dashboard', 'Players', 'Inspector', 'Logs', 'Reports', 'Movement', 'Punishments', 'Server Tools', 'Economy', 'Settings'
}

function vox.admin.Open()
    if IsValid( vox.admin.Frame ) then vox.admin.Frame:Remove() end

    local frame = vgui.Create( 'vox.Frame' )
    vox.admin.Frame = frame
    frame:SetSize( ScrW() * .72, ScrH() * .74 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( 'Vox Admin' )

    local theme = vox.hud and vox.hud:GetCurrentTheme()
    local colors = theme and theme.colors or vox:Config( 'colors' )

    local shell = frame:Add( 'DPanel' )
    shell:Dock( FILL )
    shell:DockPadding( 14, 14, 14, 14 )
    shell.Paint = function( _, w, h )
        if vox.DrawVoxPanel then vox.DrawVoxPanel( 0, 0, w, h, colors, 8 ) else draw.RoundedBox( 8, 0, 0, w, h, colors.primary ) end
        if vox.DrawVoxBlade then vox.DrawVoxBlade( 12, 14, 7, h - 28, colors.accent ) end
        draw.SimpleText( 'VOX ADMIN CONTROL CENTER', 'DermaDefaultBold', 30, 18, colors.textPrimary or color_white )
        draw.SimpleText( 'validated actions • CAMI permissions • hierarchy protection • audit logs', 'DermaDefault', 30, 38, colors.textSecondary or color_white )
    end

    local rail = shell:Add( 'DPanel' )
    rail:Dock( LEFT )
    rail:SetWide( 160 )
    rail:DockMargin( 0, 56, 14, 0 )
    rail.Paint = nil

    local content = shell:Add( 'DPanel' )
    content:Dock( FILL )
    content:DockMargin( 0, 56, 0, 0 )
    content.Paint = function( _, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, ColorAlpha( colors.secondary or color_black, 205 ) )
        draw.SimpleText( 'Select a player row in Vox Scoreboard or run vox_admin_action from trusted UI controls.', 'DermaDefaultBold', 18, 18, colors.textPrimary or color_white )
        draw.SimpleText( 'Actions: bring, goto, return, freeze, unfreeze, spectate, strip, respawn, slay, kick, warn, noclip, god, cloak, plus integration-ready ban/jail/economy hooks.', 'DermaDefault', 18, 42, colors.textSecondary or color_white )
    end

    for _, name in ipairs( sections ) do
        local btn = rail:Add( 'DButton' )
        btn:Dock( TOP )
        btn:DockMargin( 0, 0, 0, 7 )
        btn:SetTall( 34 )
        btn:SetText( '' )
        btn.Paint = function( panel, w, h )
            local hover = panel:IsHovered()
            draw.RoundedBox( 6, 0, 0, w, h, ColorAlpha( hover and colors.tertiary or colors.secondary, hover and 235 or 185 ) )
            if hover and vox.DrawVoxBlade then vox.DrawVoxBlade( 0, 6, 5, h - 12, colors.accent ) end
            draw.SimpleText( name, 'DermaDefaultBold', 18, h * .5, colors.textPrimary or color_white, 0, 1 )
        end
    end
end

concommand.Add( 'vox_admin', vox.admin.Open )
