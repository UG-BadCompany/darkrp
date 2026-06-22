local colorPrimary = vox:Config('colors.primary')
local colorSecondary = vox:Config('colors.secondary')
local colorAccent = vox:Config('colors.accent')
local colorGradient = vox.OffsetColor(colorAccent, -50)
local colorTertiary = vox:Config('colors.tertiary')
local colorCircleGray = Color(69, 69, 69)
local colorLabel = color_white
local fontTitle = vox.Font('Comfortaa Bold@16')

local L = function(...) return vox.lang:Get(...) end

local PANEL = {}

local formatMoney do
    local format = {
        {'t', 10 ^ 12, 2},
        {'b', 10 ^ 9, 2},
        {'m', 10 ^ 6, 2},
        {'k', 10 ^ 3}
    }
    local amount = #format

    function formatMoney(money)
        for index = 1, amount do
            local data = format[index]
            local name = data[1]
            local value = data[2]
            local decimals = data[3] or 1
            if (money > value) then
                return DarkRP.formatMoney( math.Round(money / value, decimals) ) .. name
            end
        end

        return DarkRP.formatMoney(money)
    end
end

local function drawShadowBG(panel, w, h, color)
    vox.DrawVoxPanel(0, 0, w, h, { primary = color, secondary = colorSecondary, accent = colorAccent }, 8)
    vox.DrawVoxBlade(0, vox.ScaleTall(10), vox.ScaleWide(7), h - vox.ScaleTall(20), colorAccent)
end

function PANEL:Init()
    self.space = vox.ScaleTall(10)
    self.padding = vox.ScaleTall(10)
    self.smallHeaderHeight = vox.ScaleTall(25)

    self.divStats = self:Add('Panel')
    self.divStats.PerformLayout = function(panel, w, h)
        local children = panel:GetChildren()
        local amount = #children
        local space = self.space
        local wide = (w - (space * (amount - 1))) / amount

        for index, child in ipairs(children) do
            child:SetWide(wide)
            child:Dock(LEFT)
            child:DockMargin(0, 0, space, 0)
        end
    end

    self.divBody = self:Add('Panel')

    self.divActions = self.divBody:Add('Panel')
    self.divActions.Paint = function(panel, w, h)
        drawShadowBG(panel, w, h, colorPrimary)
    end

    self.lblActions = self.divActions:Add('vox.Label')
    self.lblActions:SetText(L('f4_actions_u'))
    self.lblActions:SetFont(fontTitle)
    self.lblActions:SetTextColor(colorLabel)
    self.lblActions:Dock(TOP)
    self.lblActions:DockMargin(0, 0, 0, vox.ScaleTall(10))
    self.lblActions:CenterText()
    self.lblActions:SetTall(self.smallHeaderHeight)
    self.lblActions.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, ColorAlpha(colorSecondary, 220), true, true)
        vox.DrawAngledRect(w - vox.ScaleWide(48), 0, vox.ScaleWide(48), h, vox.ScaleWide(10), ColorAlpha(colorAccent, 45))
    end

    self.listActions = self.divActions:Add('vox.ScrollPanel')
    self.listActions:DockMargin(self.padding, 0, self.padding, self.padding)
    self.listActions:Dock(FILL)

    self.divAdmins = self.divBody:Add('Panel')
    self.divAdmins:SetVisible(not vox.f4:GetOptionValue('hide_admins'))
    self.divAdmins.Paint = function(panel, w, h)
        drawShadowBG(panel, w, h, colorPrimary)
    end

    self.lblAdmins = self.divAdmins:Add('vox.Label')
    self.lblAdmins:SetText(L('f4_staffonline_u'))
    self.lblAdmins:SetFont(fontTitle)
    self.lblAdmins:SetTextColor(colorLabel)
    self.lblAdmins:Dock(TOP)
    self.lblAdmins:DockMargin(0, 0, 0, vox.ScaleTall(10))
    self.lblAdmins:CenterText()
    self.lblAdmins:SetTall(self.smallHeaderHeight)
    self.lblAdmins.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, ColorAlpha(colorSecondary, 220), true, true)
        vox.DrawAngledRect(w - vox.ScaleWide(48), 0, vox.ScaleWide(48), h, vox.ScaleWide(10), ColorAlpha(colorAccent, 45))
    end

    self.listAdmins = self.divAdmins:Add('vox.ScrollPanel')
    self.listAdmins:DockMargin(self.padding, 0, self.padding, self.padding)
    self.listAdmins:Dock(FILL)

    self:InitActions()
    self:InitStats()
    self:InitAdmins()
end

function PANEL:PerformLayout(w, h)
    local space = self.space

    self.divStats:SetTall(h * .25)
    self.divStats:Dock(TOP)
    self.divStats:DockMargin(0, 0, 0, space)

    self.divBody:Dock(FILL)

    self.divActions:Dock(FILL)

    self.divAdmins:Dock(RIGHT)
    self.divAdmins:SetWide((w - space * 1) * .33)
    self.divAdmins:DockMargin(space, 0, 0, 0)
end

function PANEL:InitActions()
    local client = LocalPlayer()
    local listActions = self.listActions
    local categories = {}

    for _, action in ipairs(vox.f4.actions) do
        local category = action.category
        local canSee = action.canSee

        if (canSee and not canSee(client)) then
            continue
        end

        if (not categories[category]) then
            local lblTitle = listActions:Add('vox.Label')
            lblTitle:SetText(vox.lang:Get(category))
            lblTitle:SetTextColor(color_white)
            lblTitle:Font('Montserrat@16')
            lblTitle:Dock(TOP)
            lblTitle:DockMargin(0, 0, 0, vox.ScaleTall(10))

            local gridPanel = listActions:Add('vox.Grid')
            gridPanel:Dock(TOP)
            gridPanel:SetColumnCount(3)
            gridPanel:SetSpaceX(vox.ScaleTall(5))
            gridPanel:SetSpaceY(gridPanel:GetSpaceX())
            gridPanel:DockMargin(0, 0, 0, vox.ScaleTall(10))

            categories[category] = gridPanel
        end

        self:AddAction(categories[category], action.name, action.func)
    end
end

function PANEL:AddAction(grid, name, func)
    local client = LocalPlayer()
    local button = grid:Add('vox.Button')
    button:SetText(vox.lang:Get(name))
    button:SetGradientColor(colorGradient)
    button:SetMasking(true)
    button:Font('Comfortaa Bold@16')
    button:SetTall(vox.ScaleTall(25))
    button.DoClick = function()
        if (func) then
            func(client)
        end
    end
end

function PANEL:InitAdmins()
    local padding = vox.ScaleTall(5)
    local client = LocalPlayer()
    for _, ply in ipairs(player.GetAll()) do
        if (vox.f4.IsAdmin(ply)) then
            local panel = self.listAdmins:Add('Panel')
            panel:Dock(TOP)
            panel:SetTall(vox.ScaleTall(45))
            panel:DockPadding(padding, padding, padding, padding)
            panel.Paint = function(panel, w, h)
                draw.RoundedBox(8, 0, 0, w, h, colorTertiary)
            end

            local height = panel:GetTall() - padding * 2

            local avatar = panel:Add('vox.RoundedAvatar')
            avatar:SetPlayer(ply, 64)
            avatar:SetWide(height)
            avatar:Dock(LEFT)
            avatar:DockMargin(0, 0, vox.ScaleWide(10), 0)
            avatar.PaintOver = function(panel, w, h)
                vox.DrawOutlinedCircle(w * .5, h * .5, h * .5, 3, color_white)
            end

            local lblName = panel:Add('vox.Label')
            lblName:Font('Comfortaa Bold@16')
            lblName:Dock(TOP)
            lblName:SetTall(height * .5)
            lblName:SetContentAlignment(1)
            lblName:SetText(ply:Name())

            if (client == ply) then
                lblName:SetTextColor(colorAccent)
            end

            local lblRank = panel:Add('vox.Label')
            lblRank:SetText(ply:GetUserGroup())
            lblRank:Font('Comfortaa@14')
            lblRank:Dock(TOP)
            lblRank:SetTall(height * .5)
            lblRank:SetTextColor(Color(200, 200, 200))
            lblRank:SetContentAlignment(7)
        end
    end
end

function PANEL:InitStats()
    local client = LocalPlayer()
    local players = player.GetAll()
    local playerOnline = #players
    local playerMax = game.MaxPlayers()
    local clientMoney = client:getDarkRPVar('money') or 0
    local totalMoney = 0
    local staffOnline = 0

    for _, ply in ipairs(players) do
        local money = ply:getDarkRPVar('money') or 0
        totalMoney = totalMoney + money

        if (vox.f4.IsAdmin(ply)) then
            staffOnline = staffOnline + 1
        end
    end

    self:AddStat(L('f4_playersonline_u'), playerOnline .. ' / ' .. playerMax, (playerOnline / playerMax), Color(255, 238, 108))
    self:AddStat(L('f4_totalmoney_u'), formatMoney(totalMoney), (clientMoney / totalMoney), Color(36, 129, 50), Color(179, 255, 170))
    self:AddStat(L('f4_staffonline_u'), staffOnline, (staffOnline > 0 and 1 or 0), Color(160, 61, 231))
end

function PANEL:AddStat(name, info, fraction, color, color2)
    local padding = vox.ScaleTall(10)
    local angle = math.Round(fraction * 360, 0, 360)
    local font0 = vox.Font('Comfortaa@18')

    local panel = self.divStats:Add('Panel')
    panel.Paint = function(this, w, h)
        drawShadowBG(this, w, h, colorPrimary)
        draw.SimpleText('VOX', vox.Font('Comfortaa Bold@14'), vox.ScaleWide(16), h - vox.ScaleTall(16), ColorAlpha(colorAccent, 105), 0, 1)
    end

    local lblTitle = panel:Add('vox.Label')
    lblTitle:SetText(name)
    lblTitle:SetFont(fontTitle)
    lblTitle:CenterText()
    lblTitle:SetTextColor(colorLabel)
    lblTitle:Dock(TOP)
    lblTitle:DockMargin(0, 0, 0, padding)
    lblTitle:SizeToContentsY(10)
    lblTitle.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, ColorAlpha(colorSecondary, 225), true, true)
        vox.DrawAngledRect(w - vox.ScaleWide(54), 0, vox.ScaleWide(54), h, vox.ScaleWide(12), ColorAlpha(color, 55))
    end

    local content = panel:Add('Panel')
    content:Dock(FILL)
    content:DockMargin(padding, 0, padding, padding)
    content.Paint = function(panel, w, h)
        local size = math.min(w, h)
        local radius = math.floor(size * .5)
        local x0 = w * .5
        local y0 = h * .5
        local outlineWidth   = 5

        DisableClipping(true)
            vox.DrawOutlinedCircle(x0 + 1, y0 + 1, radius, outlineWidth, Color(0, 0, 0, 100))
        DisableClipping(false)

        vox.DrawOutlinedCircle(x0, y0, radius, outlineWidth, color2 or colorCircleGray)
        vox.DrawWithPolyMask(panel.mask, function()
            vox.DrawOutlinedCircle(x0, y0, radius, outlineWidth, color)
        end)

        draw.SimpleText(info, font0, w * .5, h * .5, color_white, 1, 1)
    end
    content.PerformLayout = function(panel, w, h)
        panel.mask = vox.CalculateArc(w * .5, h * .5, 0, angle, h * .5 + 2, 24, true)
    end
end

vox.gui.Register('vox.f4.Dashboard', PANEL)

-- Vox local preview helper
-- vox.gui.Test('vox.f4.Frame', .6, .65, function(panel)
--     panel:MakePopup()
--     panel:ChooseTab(1)
-- end)
