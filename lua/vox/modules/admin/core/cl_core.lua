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

local function getQuickActions()
    if vox.admin and vox.admin.GetSortedActions then
        return vox.admin:GetSortedActions()
    end

    return {}
end

net.Receive( 'VoxUI.Admin.Logs', function()
    local rows = net.ReadUInt( 8 )
    local lines = {}
    for i = 1, rows do
        local row = util.JSONToTable( net.ReadString() ) or {}
        lines[#lines + 1] = os.date( '%H:%M:%S', row.time or os.time() ) .. '  ' .. tostring( row.admin ) .. ' -> ' .. tostring( row.action ) .. ' -> ' .. tostring( row.target ) .. '  ' .. tostring( row.reason or '' )
    end
    chat.AddText( Color( 0, 174, 255 ), '[Vox Admin Logs] ', color_white, table.concat( lines, '\n' ) )
end )

function vox.admin.Open()
    if IsValid( vox.admin.Frame ) then vox.admin.Frame:Remove() end

    local frame = vgui.Create( 'vox.Frame' )
    vox.admin.Frame = frame
    frame:SetSize( ScrW() * .72, ScrH() * .74 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( 'Vox Admin' )

    local colors = vox.GetThemeColors and vox.GetThemeColors() or {}
    colors.primary = colors.primary or Color( 20, 22, 28, 240 )
    colors.secondary = colors.secondary or Color( 30, 34, 44, 240 )
    colors.tertiary = colors.tertiary or Color( 45, 50, 62, 240 )
    colors.accent = colors.accent or Color( 0, 174, 255 )
    colors.textPrimary = colors.textPrimary or color_white
    colors.textSecondary = colors.textSecondary or Color( 180, 190, 205 )

    local shell = frame:Add( 'DPanel' )
    shell:Dock( FILL )
    shell:DockPadding( 14, 14, 14, 14 )
    shell.Paint = function( _, w, h )
        if vox.DrawVoxPanel then vox.DrawVoxPanel( 0, 0, w, h, colors, 8 ) else draw.RoundedBox( 8, 0, 0, w, h, colors.primary ) end
        if vox.DrawVoxBlade then vox.DrawVoxBlade( 12, 14, 7, h - 28, colors.accent ) end
        vox.DrawVoxScanlines( 26, 10, w - 52, h - 20, ColorAlpha( colors.accent, 9 ), 9 )
        vox.DrawVoxCornerTicks( 18, 12, w - 36, h - 24, ColorAlpha( colors.accent, 125 ), 20 )
        draw.SimpleText( 'VOX ADMIN // OPS MODULE', 'DermaDefaultBold', 30, 18, colors.textPrimary or color_white )
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
        vox.DrawVoxBlade( 10, 14, 6, h - 28, colors.accent )
        vox.DrawVoxCornerTicks( 18, 14, w - 36, h - 28, ColorAlpha( colors.accent, 80 ), 16 )
        draw.SimpleText( 'Vox Admin Quick Dispatch', 'DermaDefaultBold', 28, 18, colors.textPrimary or color_white )
        draw.SimpleText( 'Server-validated actions with CAMI permissions, hierarchy checks, cooldowns, and staff notifications.', 'DermaDefault', 28, 42, colors.textSecondary or color_white )
    end

    local targetBox = content:Add( 'DComboBox' )
    targetBox:Dock( TOP )
    targetBox:DockMargin( 24, 72, 24, 10 )
    targetBox:SetTall( 30 )
    targetBox:SetValue( 'Select target player' )
    for _, ply in ipairs( player.GetAll() ) do
        targetBox:AddChoice( ply:Nick() .. ' • ' .. ply:SteamID(), ply:SteamID() )
    end

    local reason = content:Add( 'DTextEntry' )
    reason:Dock( TOP )
    reason:DockMargin( 24, 0, 24, 12 )
    reason:SetTall( 30 )
    reason:SetPlaceholderText( 'Reason / note for audit log' )

    local grid = content:Add( 'DIconLayout' )
    grid:Dock( FILL )
    grid:DockMargin( 24, 0, 24, 24 )
    grid:SetSpaceX( 8 )
    grid:SetSpaceY( 8 )

    for _, actionData in ipairs( getQuickActions() ) do
        local action = actionData.id
        local btn = grid:Add( 'DButton' )
        btn:SetSize( 112, 34 )
        btn:SetText( '' )
        btn.Paint = function( panel, w, h )
            local hover = panel:IsHovered()
            draw.RoundedBox( 6, 0, 0, w, h, ColorAlpha( hover and colors.tertiary or colors.primary, hover and 240 or 215 ) )
            vox.DrawVoxBlade( 0, 6, 5, h - 12, colors.accent )
            draw.SimpleText( string.upper( actionData.name or action ), 'DermaDefaultBold', 16, h * .5, colors.textPrimary or color_white, 0, 1 )
            draw.SimpleText( actionData.category or 'General', 'DermaDefault', w - 8, h * .5, colors.textSecondary or color_white, 2, 1 )
        end
        btn.DoClick = function()
            local _, steamid = targetBox:GetSelected()
            RunConsoleCommand( 'vox_admin_action', action, steamid or LocalPlayer():SteamID(), reason:GetValue() or '', '0' )
        end
    end

    local logs = rail:Add( 'DButton' )
    logs:Dock( TOP )
    logs:DockMargin( 0, 0, 0, 10 )
    logs:SetTall( 36 )
    logs:SetText( 'FETCH AUDIT LOGS' )
    logs.DoClick = function() RunConsoleCommand( 'vox_admin_logs' ) end

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
