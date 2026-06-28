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

function vox.admin.ParseReasonDuration(value, fallbackReason, fallbackDuration)
    value = tostring(value or ''):Trim()

    local duration = tonumber(value:match('%s(%d+)$') or value:match('^(%d+)$')) or fallbackDuration or 0
    local reason = value

    if duration > 0 then
        reason = value:gsub('%s*%d+$', ''):Trim()
    end

    if reason == '' then
        reason = fallbackReason or 'No reason provided'
    end

    return reason, duration
end

function vox.admin.RunPlayerAction(actionID, ply, reason, duration)
    if not IsValid(ply) then return end

    RunConsoleCommand('vox_admin_action', actionID, ply:SteamID(), tostring(reason or ''), tostring(duration or 0))
end

local function getAdminPromptColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}

    return {
        bg = colors.primary or Color(5, 15, 31),
        panel = colors.secondary or Color(8, 25, 47),
        card = colors.tertiary or Color(11, 35, 65),
        accent = colors.accent or Color(0, 174, 255),
        text = colors.textPrimary or color_white,
        muted = colors.textSecondary or Color(155, 172, 195),
        negative = colors.negative or Color(255, 75, 95)
    }
end

local function notifyPromptError(text)
    if notification and notification.AddLegacy then
        notification.AddLegacy(text, NOTIFY_ERROR, 4)
    end
end

local function addPromptLabel(parent, text, color)
    local label = parent:Add('vox.Label')
    label:Dock(TOP)
    label:SetTall(vox.ScaleTall(18))
    label:Font('Comfortaa Bold@12')
    label:SetText(text)
    label:SetTextColor(color)
    return label
end

local function paintPromptEntry(entry, colors)
    entry:SetTextColor(colors.text)
    entry:SetPlaceholderColor(ColorAlpha(colors.muted, 190))
    entry:SetColorIdle(ColorAlpha(colors.bg, 248))
    entry:SetColorHover(ColorAlpha(colors.bg, 248))
end

local function addReasonChip(parent, label, value, reasonEntry, colors)
    local chip = parent:Add('DButton')
    chip:Dock(LEFT)
    chip:DockMargin(0, 0, vox.ScaleWide(6), 0)
    chip:SetWide(vox.ScaleWide(72))
    chip:SetText('')
    chip.Paint = function(panel, w, h)
        draw.RoundedBox(7, 0, 0, w, h, ColorAlpha(colors.accent, panel:IsHovered() and 52 or 24))
        surface.SetDrawColor(ColorAlpha(colors.accent, panel:IsHovered() and 145 or 72))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText(label, vox.Font('Comfortaa Bold@11'), w * .5, h * .5, colors.text, 1, 1)
    end
    chip.DoClick = function()
        reasonEntry:SetValue(value)
        if reasonEntry.textEntry and reasonEntry.textEntry.RequestFocus then
            reasonEntry.textEntry:RequestFocus()
        end
    end
end

function vox.admin.OpenDRCJailPrompt(ply, actionID, options)
    if not IsValid(ply) then return end

    options = options or {}
    local colors = getAdminPromptColors()
    local frameW = math.min(vox.ScaleWide(560), ScrW() - vox.ScaleWide(80))
    local frameH = math.min(vox.ScaleTall(300), ScrH() - vox.ScaleTall(80))
    local margin = vox.ScaleTall(18)
    local gap = vox.ScaleTall(10)

    if IsValid(vox.admin.DRCJailPrompt) then
        vox.admin.DRCJailPrompt:Remove()
    end

    local frame = vgui.Create('vox.Frame')
    vox.admin.DRCJailPrompt = frame
    frame:SetTitle('DRC Compliance (Jail)')
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:Focus()
    frame.Paint = function(panel, w, h)
        draw.RoundedBox(10, 0, 0, w, h, ColorAlpha(colors.bg, 248))
        draw.RoundedBox(10, 1, 1, w - 2, h - 2, ColorAlpha(colors.panel, 220))
        if vox.DrawMatGradient then
            vox.DrawMatGradient(1, 1, w - 2, h - 2, RIGHT, ColorAlpha(colors.accent, 26))
        end
        surface.SetDrawColor(ColorAlpha(colors.accent, 150))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local content = frame:Add('Panel')
    content:Dock(FILL)
    content:DockMargin(margin, margin, margin, margin)

    local header = content:Add('Panel')
    header:Dock(TOP)
    header:SetTall(vox.ScaleTall(46))
    header:DockMargin(0, 0, 0, gap)
    header.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(colors.bg, 185))
        surface.SetDrawColor(ColorAlpha(colors.accent, 70))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText('TARGET', vox.Font('Comfortaa Bold@10'), vox.ScaleWide(14), vox.ScaleTall(9), colors.muted, 0, 0)
        draw.SimpleText(ply:Nick(), vox.Font('Comfortaa Bold@16'), vox.ScaleWide(14), vox.ScaleTall(25), colors.text, 0, 1)
        draw.SimpleText(ply:SteamID(), vox.Font('Comfortaa@11'), w - vox.ScaleWide(14), vox.ScaleTall(25), colors.muted, 2, 1)
    end

    local fields = content:Add('Panel')
    fields:Dock(TOP)
    fields:SetTall(vox.ScaleTall(66))
    fields:DockMargin(0, 0, 0, gap)

    local durationWrap = fields:Add('Panel')
    durationWrap:Dock(RIGHT)
    durationWrap:SetWide(vox.ScaleWide(124))

    addPromptLabel(durationWrap, 'Time', colors.muted)
    local durationEntry = durationWrap:Add('vox.TextEntry')
    durationEntry:Dock(FILL)
    durationEntry:SetPlaceholderText('180')
    durationEntry:SetValue(tostring(options.fallbackDuration or 180))
    durationEntry:SetNumeric(true)
    paintPromptEntry(durationEntry, colors)

    local reasonWrap = fields:Add('Panel')
    reasonWrap:Dock(FILL)
    reasonWrap:DockMargin(0, 0, vox.ScaleWide(10), 0)

    addPromptLabel(reasonWrap, 'Reason', colors.muted)
    local reasonEntry = reasonWrap:Add('vox.TextEntry')
    reasonEntry:Dock(FILL)
    reasonEntry:SetPlaceholderText('failrp, rdm, nlr, prop, mic, general')
    reasonEntry:SetValue(options.fallbackReason or 'general')
    paintPromptEntry(reasonEntry, colors)

    local chips = content:Add('Panel')
    chips:Dock(TOP)
    chips:SetTall(vox.ScaleTall(28))
    chips:DockMargin(0, 0, 0, gap)
    addReasonChip(chips, 'FailRP', 'failrp', reasonEntry, colors)
    addReasonChip(chips, 'RDM', 'rdm', reasonEntry, colors)
    addReasonChip(chips, 'NLR', 'nlr', reasonEntry, colors)
    addReasonChip(chips, 'Props', 'prop', reasonEntry, colors)
    addReasonChip(chips, 'Mic', 'mic', reasonEntry, colors)
    addReasonChip(chips, 'General', 'general', reasonEntry, colors)

    local footer = content:Add('Panel')
    footer:Dock(BOTTOM)
    footer:SetTall(vox.ScaleTall(36))

    local cancel = footer:Add('vox.Button')
    cancel:Dock(RIGHT)
    cancel:SetWide(vox.ScaleWide(150))
    cancel:SetText('Cancel')
    cancel:Font('Comfortaa Bold@14')
    cancel:SetColorIdle(ColorAlpha(colors.bg, 235))
    cancel:SetColorHover(ColorAlpha(colors.card, 245))
    cancel.DoClick = function()
        frame:Remove()
    end

    local confirm = footer:Add('vox.Button')
    confirm:Dock(FILL)
    confirm:DockMargin(0, 0, vox.ScaleWide(10), 0)
    confirm:SetText('Send to DRC')
    confirm:Font('Comfortaa Bold@14')
    confirm:SetMasking(true)
    confirm:SetGradientColor(ColorAlpha(colors.accent, 180))
    confirm:SetColorIdle(ColorAlpha(colors.accent, 225))

    local function submit()
        local reason = tostring(reasonEntry:GetValue() or ''):Trim()
        local durationText = tostring(durationEntry:GetValue() or ''):Trim()
        local duration = durationText ~= '' and tonumber(durationText) or tonumber(options.fallbackDuration) or 180

        if reason == '' then reason = options.fallbackReason or 'general' end
        if not duration or duration <= 0 then
            durationEntry:Highlight(colors.negative, 2)
            notifyPromptError('Enter a DRC jail time in seconds.')
            return false
        end

        duration = math.Clamp(math.floor(duration), 10, 3600)
        vox.admin.RunPlayerAction(actionID, ply, reason, duration)
        frame:Remove()
    end

    confirm.DoClick = submit
    reasonEntry.OnEnter = submit
    durationEntry.OnEnter = submit

    if reasonEntry.textEntry and reasonEntry.textEntry.RequestFocus then
        reasonEntry.textEntry:RequestFocus()
    end

    return frame
end

function vox.admin.OpenPlayerAction(ply, actionID, options)
    if not IsValid(ply) then return end

    options = options or {}

    if not options.prompt then
        vox.admin.RunPlayerAction(actionID, ply, options.reason or '', options.duration or 0)
        return
    end

    if actionID == 'drc_compliance' then
        return vox.admin.OpenDRCJailPrompt(ply, actionID, options)
    end

    local title = options.title or 'Player Action'
    local desc = options.desc or ('Enter a reason for ' .. ply:Nick() .. '.')

    vox.SimpleQuery(title, desc, true, function(value)
        local reason, duration = vox.admin.ParseReasonDuration(value, options.fallbackReason, options.fallbackDuration)
        vox.admin.RunPlayerAction(actionID, ply, reason, duration)
    end, options.acceptText or title, nil, 'Cancel')
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
