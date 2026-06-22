-- by p1ng :D

local COLOR_PRIMARY = onyx:Config('colors.primary')
local COLOR_SECONDARY = onyx:Config('colors.secondary')
local COLOR_TERTIARY = onyx:Config('colors.tertiary')
local COLOR_HOVERED = onyx.ColorBetween(COLOR_PRIMARY, COLOR_SECONDARY)

local COLOR_HIGH_PING = Color(196, 0, 0)
local COLOR_LOW_PING = Color(98, 255, 108)
local COLOR_PING_BG = onyx.OffsetColor(COLOR_PRIMARY, -10)

local COLOR_MUTED = Color(195, 147, 147)
local COLOR_SHADOW = Color(0, 0, 0, 100)

local WIMG_PING = onyx.wimg.Simple('https://i.imgur.com/z9OfU9m.png', 'smooth mips')
local WIMG_MIC_COMMON = onyx.wimg.Simple('https://i.imgur.com/WOBOLh8.png', 'smooth mips')
local WIMG_MIC_MUTE = onyx.wimg.Simple('https://i.imgur.com/eSYvIFa.png', 'smooth mips')

local SHADOW_DISTANCE = 2

local drawPlayerName do
    local fontCommon = onyx.Font('Comfortaa SemiBold@16') -- the size got dynamically changed
    local fontGlow = onyx.Font('Comfortaa SemiBold@16', 'blursize:2') -- the size got dynamically changed

    local draw_SimpleText = draw.SimpleText

    function drawPlayerName(text, x, y, rankData, ax, ay, realX, realY)
        local color = istable(rankData) and rankData.color or color_white
        local effectIndex = istable(rankData) and rankData.effect or 1
        local effectData = onyx.scoreboard.nameEffects[effectIndex] or onyx.scoreboard.nameEffects[1]
        local effectDrawFn = effectData.func

        -- common
        effectDrawFn(text, x, y, color, ax, ay, realX + x, realY + y)
    end
end

--[[------------------------------
PANEL
--------------------------------]]
local PANEL = {}

AccessorFunc(PANEL, 'm_ePlayer', 'Player')

function PANEL:Init()
    local font = onyx.Font('Comfortaa SemiBold@16')

    self.lineThickness = 1
    self.colorOutline = COLOR_TERTIARY
    self.blur = onyx.scoreboard.IsBlurActive()

    self.avatar = self:Add('onyx.RoundedAvatar')
    self.avatar:SetMouseInputEnabled(false)
    self.avatar.PaintOver = function(panel, w, h)
        onyx.DrawOutlinedCircle(w * .5, h * .5, math.Round(h * .5), 5, panel.color or color_white)
    end

    self.lblName = self:Add('Panel')
    self.lblName:SetMouseInputEnabled(false)
    AccessorFunc(self.lblName, 'Text', 'Text')
    self.lblName.Paint = function(panel, w, h)
        drawPlayerName(panel.Text, 0, h * .5, self.rankData, 0, 1, panel:LocalToScreen(0, 0))
    end

    self.buttonMute = self:AddMuteButton()

    self.pingIcon = self:Add('Panel')
    self.pingIcon:SetMouseInputEnabled(false)
    self.pingIcon.count = 4
    self.pingIcon.Paint = function(panel, w, h)
        local maxLines = 4
        local curLines = math.min(maxLines, panel.count)
        local fraction = (curLines / maxLines)
        local scissorWidth = w * fraction -- the image has perfect element distance
        local color = onyx.LerpColor(1 - fraction, COLOR_LOW_PING, COLOR_HIGH_PING)

        local x, y = panel:LocalToScreen(0, 0)

        WIMG_PING:Draw(0, 0, w, h, COLOR_PING_BG)

        render.SetScissorRect(x, y, x + scissorWidth, y + h, true)
            WIMG_PING:Draw(0, 0, w, h, color)
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    self.content = self:Add('onyx.Scoreboard.ColumnsRow')
    self.content:SetMouseInputEnabled(false)
    self.content:Dock(FILL)
    self.content:InitColumns()
end

function PANEL:GetPingLineCount(playerPing)
    -- calculations on how many lines

    local goodPing = 95
    local step = 50
    local maxLines = 4

    for index = 0, (maxLines - 1) do
        local lineCount = maxLines - index
        local iterPing = goodPing + (index * step)
        if (playerPing < iterPing) then
            return lineCount
        end
    end

    return 1
end

function PANEL:AddMuteButton(url)
    -- muted: https://i.imgur.com/eSYvIFa.png

    local button = self:Add('onyx.ImageButton')
    button.DoClick = function(panel)
        local ply = self:GetPlayer()
        if (IsValid(ply)) then
            ply:SetMuted(not ply:IsMuted())
            panel:Update()
        end
    end
    button.Update = function(panel)
        local ply = self:GetPlayer()
        if (IsValid(ply)) then
            local state = ply:IsMuted()
            panel:SetColor(state and COLOR_MUTED or color_white)
            panel.m_WebImage = (state and WIMG_MIC_MUTE or WIMG_MIC_COMMON)
        end
    end

    return button
end

function PANEL:Paint(w, h)
    local lineThickness = self.lineThickness
    local category = self.category
    local isExpanded = category:GetExpanded()
    local rounded = category.canvas:GetTall() < 1
    local isHovered = self:IsHovered()
    local color = isHovered and COLOR_HOVERED or COLOR_PRIMARY

    if (self.blur) then
        draw.RoundedBoxEx(8, 0, 0, w, h, ColorAlpha(color, 230), true, true, rounded, rounded)
    else
        draw.RoundedBoxEx(8, 0, 0, w, h, self.colorOutline, true, true, rounded, rounded)
        draw.RoundedBoxEx(8, lineThickness, lineThickness, w - lineThickness * 2, h - lineThickness * 2, color, true, true, rounded, rounded)
    end

    local mask = rounded and self.maskAllRounded or self.maskExpanded
    if (mask) then
        onyx.DrawWithPolyMask(mask, function()
            onyx.DrawMatGradient(0, 0, w, h, TOP, self.colorGradient)
        end)
    end
end

function PANEL:PerformLayout(w, h)
    local padding = self.padding
    local height = h - padding * 2
    local paddingX = self.paddingX + 1 -- this got set in cl_frame.lua
    local firstElementWidth = self.firstElementWidth
    local avatarMargin = onyx.ScaleTall(5)
    local lineThickness = self.lineThickness

    self:DockPadding(paddingX, padding, paddingX, padding)

    self.avatar:Dock(LEFT)
    self.avatar:SetWide(height)
    self.avatar:DockMargin(0, 0, avatarMargin, 0)

    self.lblName:Dock(LEFT)
    self.lblName:SetWide(firstElementWidth - height - avatarMargin)
    self.lblName:DockMargin(0, 0, self.paddingX, 0)

    self.buttonMute:SetWide(height)
    self.buttonMute:Dock(RIGHT)
    self.buttonMute:DockMargin(self.paddingX, 0, 0, 0)

    self.pingIcon:SetWide(height)
    self.pingIcon:Dock(RIGHT)
    self.pingIcon:DockMargin(self.paddingX, 0, 0, 0)

    if (onyx.scoreboard:GetOptionValue('colored_players') or onyx.scoreboard.IsTTT()) then
        self.maskAllRounded = onyx.CalculateRoundedBox(8, lineThickness, lineThickness, w - lineThickness * 2, h - lineThickness * 2)
        self.maskExpanded = onyx.CalculateRoundedBoxEx(8, lineThickness, lineThickness, w - lineThickness * 2, h - lineThickness * 2, true, false, false, true)
    end
end

function PANEL:SetupPlayer(ply)
    local teamIndex = ply:Team()
    local teamColor = team.GetColor(teamIndex)

    if (onyx.scoreboard.IsTTT()) then
        teamColor = onyx.scoreboard.GetRoleColorTTT(ply)
    end

    local convertedColor = onyx.scoreboard.ConvertTeamColor(teamColor)
    local usergroup = ply:GetUserGroup()

    self:SetPlayer(ply)

    self.colorGradient = ColorAlpha(onyx.LerpColor(.5, teamColor, color_black), 40) -- lerp makes gradients look better
    self.rankData = onyx.scoreboard:GetRankData(usergroup)

    self.avatar.color = convertedColor
    self.avatar:SetPlayer(ply, 64)

    self.lblName:SetText(ply:Name())

    self.buttonMute:Update()

    self:UpdateColumnValues(self.rankData)
end

function PANEL:UpdateColumnValues()
    local ply = self:GetPlayer()
    if (not IsValid(ply)) then return end

    for index, data in ipairs(onyx.scoreboard:GetActiveColumns()) do
        local value = data.getValue(ply)
        local formatted = data.formatValue and data.formatValue(value) or value

        self.content:SetValue(index, formatted, value)

        if (data.getColor) then
            self.content:SetColor(index, data.getColor(ply))
        end

        if (data.buildFunc) then
            data.buildFunc(self.content.columns[index], ply)
        end
    end
end

function PANEL:Think()
    local ply = self:GetPlayer()
    if (IsValid(ply)) then
        self.pingIcon.count = self:GetPingLineCount(ply:Ping())
    end
end

onyx.gui.Register('onyx.Scoreboard.PlayerLine', PANEL)

--[[------------------------------
// ANCHOR Debug
--------------------------------]]
-- onyx.gui.Test('onyx.Scoreboard.Frame', .66, .66, function(self)
--     self:Center()
--     self:MakePopup()
-- end)