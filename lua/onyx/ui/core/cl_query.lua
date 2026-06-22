--[[

Author: tochnonement
Email: tochnonement@gmail.com

04/01/2024

--]]

function onyx.SimpleQuery(title, desc, showTextEntry, acceptCallback, acceptText, cancelCallback, cancelText)
    local margin = onyx.ScaleTall(25)
    local space = onyx.ScaleTall(10)

    local frame = vgui.Create('onyx.Frame')
    frame:SetTitle(title)
    frame:SetSize(ScrW() * .33, ScrH() * (showTextEntry and .225 or .175))
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:Focus(true)

    local content = frame:Add('Panel')
    content:Dock(FILL)
    content:DockMargin(margin, margin, margin, margin)

    local lblDesc = content:Add('onyx.Label')
    lblDesc:SetContentAlignment(5)
    lblDesc:Dock(TOP)
    lblDesc:Font('Comfortaa@20')
    lblDesc:SetText(desc)
    lblDesc:SetAutoStretchVertical(true)
    lblDesc:DockMargin(0, 0, 0, space)
    frame.lblDesc = lblDesc

    local textEntry = content:Add('onyx.TextEntry')
    textEntry:Dock(TOP)
    textEntry:SetPlaceholderText('')
    textEntry:SetTall(onyx.ScaleTall(30))
    textEntry:DockMargin(0, 0, 0, space)
    textEntry:SetVisible(showTextEntry)
    frame.textEntry = textEntry

    local btnConfirm, btnDeny

    local footer = content:Add('Panel')
    footer:Dock(BOTTOM)
    footer:SetTall(onyx.ScaleTall(30))
    footer.PerformLayout = function(panel, w, h)
        btnConfirm:SetWide(w * .5)
        btnConfirm:Dock(LEFT)
        btnConfirm:DockMargin(0, 0, onyx.ScaleTall(5), 0)

        btnDeny:Dock(FILL)
        btnDeny:DockMargin(onyx.ScaleTall(5), 0, 0, 0)
    end

    -- localized above
    btnConfirm = footer:Add('onyx.Button')
    btnConfirm:SetText(acceptText or 'CONFIRM')
    btnConfirm:SetMasking(true)
    btnConfirm:SetGradientColor(Color(131, 255, 133))
    btnConfirm:SetColorIdle(Color(59, 161, 61))
    btnConfirm:Font('Comfortaa Bold@16')
    btnConfirm.DoClick = function(panel)
        if (acceptCallback(textEntry:GetValue()) ~= false) then
            frame:Remove()
        end
    end

    btnDeny = footer:Add('onyx.Button')
    btnDeny:SetText(cancelText or 'CANCEL')
    btnDeny:SetMasking(true)
    btnDeny:SetGradientColor(Color(255, 131, 131))
    btnDeny:SetColorIdle(Color(161, 59, 59))
    btnDeny:Font('Comfortaa Bold@16')
    btnDeny.DoClick = function(panel)
        frame:Remove()
        if (cancelCallback) then
            cancelCallback()
        end
    end

    return frame
end

function onyx.ChoosePlayer(title, desc, func, bIncludeClient, filter)
    local margin = onyx.ScaleTall(25)
    local space = onyx.ScaleTall(10)
    local client = LocalPlayer()
    local players = {}

    local colorTertiary = onyx:Config('colors.tertiary')

    local padding = onyx.ScaleTall(5)

    for _, ply in ipairs(player.GetAll()) do
        if (not bIncludeClient and ply == client) then continue end
        if (filter and not filter(ply)) then continue end

        table.insert(players, ply)
    end

    local frame = vgui.Create('onyx.Frame')
    frame:SetTitle(title)
    frame:SetSize(ScrW() * .25, ScrH() * .5)
    frame:Center()
    frame:MakePopup()
    frame:Focus(true)
    frame.buttons = {}

    local content = frame:Add('onyx.ScrollPanel')
    content:Dock(FILL)
    content:DockMargin(margin, margin, margin, margin)

    local lblDesc = content:Add('onyx.Label')
    lblDesc:SetContentAlignment(5)
    lblDesc:Dock(TOP)
    lblDesc:Font('Comfortaa@20')
    lblDesc:SetText(desc)
    lblDesc:SetAutoStretchVertical(true)
    lblDesc:DockMargin(0, 0, 0, space)
    frame.lblDesc = lblDesc

    for _, ply in ipairs(players) do
        local panel = content:Add('onyx.Button')
        panel:SetText('')
        panel:SetTall(onyx.ScaleTall(40))
        panel:SetColorIdle(onyx:Config('colors.primary'))
        panel:SetColorHover(onyx:Config('colors.secondary'))
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

        local avatar = panel:Add('onyx.RoundedAvatar')
        avatar:Dock(LEFT)
        avatar:SetWide(panel:GetTall() - padding * 2)
        avatar:SetPlayer(ply, 64)
        avatar:DockMargin(0, 0, onyx.ScaleTall(7.5), 0)

        local lblTitle = panel:Add('onyx.Label')
        lblTitle:SetText(ply:Name())
        lblTitle:Font('Comfortaa Bold@16')
        lblTitle:Dock(TOP)
        lblTitle:SetTall(avatar:GetWide() / 2)
        panel.lblTitle = lblTitle

        local plyTeam = ply:Team()
        local lblSubTitle = panel:Add('onyx.Label')
        lblSubTitle:SetText(team.GetName(plyTeam))
        lblSubTitle:SetTextColor(team.GetColor(plyTeam))
        lblSubTitle:Font('Comfortaa@16')
        lblSubTitle:Dock(TOP)
        panel.lblSubTitle = lblSubTitle
    end

    return frame
end