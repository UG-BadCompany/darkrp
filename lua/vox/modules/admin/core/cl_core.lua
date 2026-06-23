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

    local frame = vgui.Create( 'VoxRootFrame' )
    vox.admin.Frame = frame
    frame:SetSize( ScrW() * .82, ScrH() * .82 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( 'Vox Admin' )

    local p = vox.PremiumPalette and vox.PremiumPalette() or {}
    local accent = p.accent or Color( 0, 188, 255 )
    local muted = p.muted or Color( 150, 164, 188 )
    local text = p.text or color_white

    local shell = frame:Add( 'DPanel' )
    shell:Dock( FILL )
    shell:DockPadding( 22, 76, 22, 22 )
    shell.Paint = function( _, w, h )
        draw.SimpleText( 'STAFF CONTROL PANEL', vox.Font and vox.Font( 'Comfortaa Bold@18' ) or 'DermaDefaultBold', 30, 48, ColorAlpha( accent, 235 ) )
        draw.SimpleText( 'players • reports • punishments • economy • logs • server tools', 'DermaDefault', 220, 50, muted )
    end

    local rail = shell:Add( 'DPanel' )
    rail:Dock( LEFT )
    rail:SetWide( 196 )
    rail:DockMargin( 0, 0, 18, 0 )
    rail.Paint = function( _, w, h ) vox.DrawVoxGlass( 0, 0, w, h, { radius = 18, alpha = 226, accent = accent } ) end
    rail:DockPadding( 12, 14, 12, 14 )

    local inspector = shell:Add( 'VoxGlassFrame' )
    inspector:Dock( RIGHT )
    inspector:SetWide( 270 )
    inspector:DockMargin( 18, 0, 0, 0 )
    inspector:DockPadding( 16, 18, 16, 16 )
    inspector.PaintOver = function( _, w, h )
        draw.SimpleText( 'PLAYER INSPECTOR', 'DermaDefaultBold', 18, 20, text )
        draw.SimpleText( 'Select a player and execute validated staff actions.', 'DermaDefault', 18, 42, muted )
    end

    local targetBox = inspector:Add( 'VoxDropdown' )
    targetBox:Dock( TOP ); targetBox:DockMargin( 0, 62, 0, 10 ); targetBox:SetTall( 38 ); targetBox:SetValue( 'Select target player' )
    for _, ply in ipairs( player.GetAll() ) do targetBox:AddChoice( ply:Nick() .. ' • ' .. ply:SteamID(), ply:SteamID() ) end

    local reason = inspector:Add( 'VoxInput' )
    reason:Dock( TOP ); reason:DockMargin( 0, 0, 0, 14 ); reason:SetTall( 42 ); reason:SetPlaceholderText( 'Reason / audit note' )

    local logBtn = inspector:Add( 'VoxActionButton' )
    logBtn:Dock( TOP ); logBtn:SetTall( 40 ); logBtn:SetText( 'Fetch Audit Logs' ); logBtn.DoClick = function() RunConsoleCommand( 'vox_admin_logs' ) end

    local content = shell:Add( 'DPanel' )
    content:Dock( FILL )
    content.Paint = nil

    local top = content:Add( 'DPanel' )
    top:Dock( TOP ); top:SetTall( 120 ); top:DockMargin( 0, 0, 0, 14 ); top.Paint = nil
    local stats = { { 'ONLINE', #player.GetAll() }, { 'ACTIONS', #getQuickActions() }, { 'REPORTS', 'READY' } }
    for _, stat in ipairs( stats ) do
        local card = top:Add( 'VoxStatTile' ); card:Dock( LEFT ); card:SetWide( 160 ); card:DockMargin( 0, 0, 12, 0 )
        card.PaintOver = function( _, w, h ) draw.SimpleText( stat[1], 'DermaDefaultBold', 18, 22, muted ); draw.SimpleText( tostring( stat[2] ), vox.Font and vox.Font( 'Comfortaa Bold@28' ) or 'DermaLarge', 18, 58, text ) end
    end

    local grid = content:Add( 'DIconLayout' )
    grid:Dock( FILL ); grid:SetSpaceX( 12 ); grid:SetSpaceY( 12 )

    for _, actionData in ipairs( getQuickActions() ) do
        local action = actionData.id
        local btn = grid:Add( 'VoxActionButton' )
        btn:SetSize( 180, 70 ); btn:SetText( '' )
        btn.PaintOver = function( panel, w, h )
            draw.SimpleText( string.upper( actionData.name or action ), 'DermaDefaultBold', 18, 22, text )
            draw.SimpleText( actionData.category or 'General', 'DermaDefault', 18, 46, muted )
        end
        btn.DoClick = function()
            local _, steamid = targetBox:GetSelected()
            RunConsoleCommand( 'vox_admin_action', action, steamid or LocalPlayer():SteamID(), reason:GetValue() or '', '0' )
        end
    end

    for _, name in ipairs( sections ) do
        local btn = rail:Add( 'VoxSidebarItem' ); btn:Dock( TOP ); btn:DockMargin( 0, 0, 0, 8 ); btn:SetTall( 38 ); btn:SetText( name )
    end
end

concommand.Add( 'vox_admin', vox.admin.Open )
