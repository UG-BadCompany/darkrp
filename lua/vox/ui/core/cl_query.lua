function vox.SimpleQuery(title, desc, showTextEntry, acceptCallback, acceptText, cancelCallback, cancelText)
    local margin = vox.ScaleTall(25)
    local space = vox.ScaleTall(10)
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    local primary = colors.primary or Color( 5, 17, 33 )
    local secondary = colors.secondary or Color( 9, 30, 52 )
    local accent = colors.accent or Color( 21, 158, 255 )
    local textPrimary = colors.textPrimary or color_white
    local textSecondary = colors.textSecondary or Color( 160, 178, 201 )
    local danger = Color( 238, 72, 82 )
    local isDanger = string.find( string.lower( acceptText or title or '' ), 'kick', 1, true ) or string.find( string.lower( acceptText or title or '' ), 'delete', 1, true ) or string.find( string.lower( acceptText or title or '' ), 'remove', 1, true )

    local frame = vgui.Create('vox.Frame')
    frame:SetTitle(title)
    frame:SetSize(ScrW() * .33, ScrH() * (showTextEntry and .225 or .175))
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:Focus(true)
    frame.Paint = function(panel, w, h)
        draw.RoundedBox( 10, 0, 0, w, h, Color( primary.r, primary.g, primary.b, 244 ) )
        draw.RoundedBox( 10, 1, 1, w - 2, h - 2, Color( secondary.r, secondary.g, secondary.b, 178 ) )
        surface.SetDrawColor( ( isDanger and danger or accent ).r, ( isDanger and danger or accent ).g, ( isDanger and danger or accent ).b, 150 )
        surface.DrawOutlinedRect( 0, 0, w, h, 1 )
    end

    local content = frame:Add('Panel')
    content:Dock(FILL)
    content:DockMargin(margin, margin, margin, margin)

    local lblDesc = content:Add('vox.Label')
    lblDesc:SetContentAlignment(5)
    lblDesc:SetTextColor(textSecondary)
    lblDesc:Dock(TOP)
    lblDesc:Font('Comfortaa@20')
    lblDesc:SetText(desc)
    lblDesc:SetAutoStretchVertical(true)
    lblDesc:DockMargin(0, 0, 0, space)
    frame.lblDesc = lblDesc

    local textEntry = content:Add('vox.TextEntry')
    textEntry:Dock(TOP)
    textEntry:SetPlaceholderText('')
    textEntry:SetTall(vox.ScaleTall(30))
    textEntry:DockMargin(0, 0, 0, space)
    textEntry:SetVisible(showTextEntry)
    frame.textEntry = textEntry

    local btnConfirm, btnDeny

    local footer = content:Add('Panel')
    footer:Dock(BOTTOM)
    footer:SetTall(vox.ScaleTall(30))
    footer.PerformLayout = function(panel, w, h)
        btnConfirm:SetWide(w * .5)
        btnConfirm:Dock(LEFT)
        btnConfirm:DockMargin(0, 0, vox.ScaleTall(5), 0)

        btnDeny:Dock(FILL)
        btnDeny:DockMargin(vox.ScaleTall(5), 0, 0, 0)
    end

    -- localized above
    btnConfirm = footer:Add('vox.Button')
    btnConfirm:SetText(acceptText or 'CONFIRM')
    btnConfirm:SetMasking(true)
    btnConfirm:SetGradientColor(isDanger and Color(255, 121, 126) or accent)
    btnConfirm:SetColorIdle(isDanger and danger or Color(accent.r, accent.g, accent.b, 210))
    btnConfirm:Font('Comfortaa Bold@16')
    btnConfirm.DoClick = function(panel)
        if (acceptCallback(textEntry:GetValue()) ~= false) then
            frame:Remove()
        end
    end

    btnDeny = footer:Add('vox.Button')
    btnDeny:SetText(cancelText or 'CANCEL')
    btnDeny:SetMasking(true)
    btnDeny:SetGradientColor(Color(textPrimary.r, textPrimary.g, textPrimary.b, 70))
    btnDeny:SetColorIdle(Color(primary.r, primary.g, primary.b, 230))
    btnDeny:Font('Comfortaa Bold@16')
    btnDeny.DoClick = function(panel)
        frame:Remove()
        if (cancelCallback) then
            cancelCallback()
        end
    end

    return frame
end

function vox.ChoosePlayer(title, desc, func, bIncludeClient, filter)
    local margin = vox.ScaleTall(25)
    local space = vox.ScaleTall(10)
    local client = LocalPlayer()
    local players = {}

    local colorTertiary = vox:Config('colors.tertiary')

    local padding = vox.ScaleTall(5)

    for _, ply in ipairs(player.GetAll()) do
        if (not bIncludeClient and ply == client) then continue end
        if (filter and not filter(ply)) then continue end

        table.insert(players, ply)
    end

    local frame = vgui.Create('vox.Frame')
    frame:SetTitle(title)
    frame:SetSize(ScrW() * .25, ScrH() * .5)
    frame:Center()
    frame:MakePopup()
    frame:Focus(true)
    frame.buttons = {}

    local content = frame:Add('vox.ScrollPanel')
    content:Dock(FILL)
    content:DockMargin(margin, margin, margin, margin)

    local lblDesc = content:Add('vox.Label')
    lblDesc:SetContentAlignment(5)
    lblDesc:Dock(TOP)
    lblDesc:Font('Comfortaa@20')
    lblDesc:SetText(desc)
    lblDesc:SetAutoStretchVertical(true)
    lblDesc:DockMargin(0, 0, 0, space)
    frame.lblDesc = lblDesc

    for _, ply in ipairs(players) do
        local panel = content:Add('vox.Button')
        panel:SetText('')
        panel:SetTall(vox.ScaleTall(40))
        panel:SetColorIdle(vox:Config('colors.primary'))
        panel:SetColorHover(vox:Config('colors.secondary'))
        panel:DockPadding(padding, padding, padding, padding)
        panel.colorTertiary = colorTertiary
        panel.Paint = function(panel, w, h)
            draw.RoundedBox(8, 0, 0, w, h, panel.colorTertiary)
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, panel.backgroundColor)
        end
        panel.DoClick = function()
            frame:Remove()
            if (func and IsValid(ply)) then
                func(ply)
            end
        end

        table.insert(frame.buttons, panel)

        local avatar = panel:Add('vox.RoundedAvatar')
        avatar:Dock(LEFT)
        avatar:SetWide(panel:GetTall() - padding * 2)
        avatar:SetPlayer(ply, 64)
        avatar:DockMargin(0, 0, vox.ScaleTall(7.5), 0)

        local lblTitle = panel:Add('vox.Label')
        lblTitle:SetText(ply:Name())
        lblTitle:Font('Comfortaa Bold@16')
        lblTitle:Dock(TOP)
        lblTitle:SetTall(avatar:GetWide() / 2)
        panel.lblTitle = lblTitle

        local plyTeam = ply:Team()
        local lblSubTitle = panel:Add('vox.Label')
        lblSubTitle:SetText(team.GetName(plyTeam))
        lblSubTitle:SetTextColor(team.GetColor(plyTeam))
        lblSubTitle:Font('Comfortaa@16')
        lblSubTitle:Dock(TOP)
        panel.lblSubTitle = lblSubTitle
    end

    return frame
end
