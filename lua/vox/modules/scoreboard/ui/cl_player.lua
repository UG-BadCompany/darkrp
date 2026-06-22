local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_TERTIARY = vox:Config('colors.tertiary')
local COLOR_HOVERED = vox.ColorBetween(COLOR_PRIMARY, COLOR_SECONDARY)

local COLOR_HIGH_PING = Color(196, 0, 0)
local COLOR_LOW_PING = Color(98, 255, 108)
local COLOR_PING_BG = vox.OffsetColor(COLOR_PRIMARY, -10)

local COLOR_MUTED = Color(195, 147, 147)
local COLOR_SHADOW = Color(0, 0, 0, 100)

local WIMG_PING = vox.wimg.Simple('https://i.imgur.com/z9OfU9m.png', 'smooth mips')
local WIMG_MIC_COMMON = vox.wimg.Simple('https://i.imgur.com/WOBOLh8.png', 'smooth mips')
local WIMG_MIC_MUTE = vox.wimg.Simple('https://i.imgur.com/eSYvIFa.png', 'smooth mips')

local SHADOW_DISTANCE = 2

local drawPlayerName do
    local fontCommon = vox.Font('Comfortaa SemiBold@16') -- the size got dynamically changed
    local fontGlow = vox.Font('Comfortaa SemiBold@16', 'blursize:2') -- the size got dynamically changed

    local draw_SimpleText = draw.SimpleText

    function drawPlayerName(text, x, y, rankData, ax, ay, realX, realY)
        local color = istable(rankData) and rankData.color or color_white
        local effectIndex = istable(rankData) and rankData.effect or 1
        local effectData = vox.scoreboard.nameEffects[effectIndex] or vox.scoreboard.nameEffects[1]
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
    local font = vox.Font('Comfortaa SemiBold@16')

    self.lineThickness = 1
    self.colorOutline = COLOR_TERTIARY
    self.blur = vox.scoreboard.IsBlurActive()

    self.avatar = self:Add('vox.RoundedAvatar')
    self.avatar:SetMouseInputEnabled(false)
    self.avatar.PaintOver = function(panel, w, h)
        vox.DrawOutlinedCircle(w * .5, h * .5, math.Round(h * .5), 5, panel.color or color_white)
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
        local color = vox.LerpColor(1 - fraction, COLOR_LOW_PING, COLOR_HIGH_PING)

        local x, y = panel:LocalToScreen(0, 0)

        WIMG_PING:Draw(0, 0, w, h, COLOR_PING_BG)

        render.SetScissorRect(x, y, x + scissorWidth, y + h, true)
            WIMG_PING:Draw(0, 0, w, h, color)
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    self.content = self:Add('vox.Scoreboard.ColumnsRow')
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

    local button = self:Add('vox.ImageButton')
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
    local ply = self:GetPlayer()
    local teamColor = IsValid( ply ) and team.GetColor( ply:Team() ) or ( vox.hud and vox.hud:GetColor( 'accent' ) ) or color_white

    if vox.DrawVoxPanel then
        vox.DrawVoxPanel( 0, 0, w, h, { primary = color, secondary = COLOR_SECONDARY, accent = teamColor }, 8 )
    elseif (self.blur) then
        draw.RoundedBoxEx(8, 0, 0, w, h, ColorAlpha(color, 230), true, true, rounded, rounded)
    else
        draw.RoundedBoxEx(8, 0, 0, w, h, self.colorOutline, true, true, rounded, rounded)
        draw.RoundedBoxEx(8, lineThickness, lineThickness, w - lineThickness * 2, h - lineThickness * 2, color, true, true, rounded, rounded)
    end

    if vox.DrawVoxBlade then vox.DrawVoxBlade( 0, 6, 6, h - 12, teamColor ) end
    if isHovered then
        surface.SetDrawColor( ColorAlpha( teamColor, 38 ) )
        surface.DrawRect( 8, 1, w - 16, h - 2 )
    end

    local mask = rounded and self.maskAllRounded or self.maskExpanded
    if (mask) then
        vox.DrawWithPolyMask(mask, function()
            vox.DrawMatGradient(0, 0, w, h, TOP, self.colorGradient)
        end)
    end
end

function PANEL:PerformLayout(w, h)
    local padding = self.padding
    local height = h - padding * 2
    local paddingX = self.paddingX + 1 -- this got set in cl_frame.lua
    local firstElementWidth = self.firstElementWidth
    local avatarMargin = vox.ScaleTall(5)
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

    if (vox.scoreboard:GetOptionValue('colored_players') or vox.scoreboard.IsTTT()) then
        self.maskAllRounded = vox.CalculateRoundedBox(8, lineThickness, lineThickness, w - lineThickness * 2, h - lineThickness * 2)
        self.maskExpanded = vox.CalculateRoundedBoxEx(8, lineThickness, lineThickness, w - lineThickness * 2, h - lineThickness * 2, true, false, false, true)
    end
end

function PANEL:SetupPlayer(ply)
    local teamIndex = ply:Team()
    local teamColor = team.GetColor(teamIndex)

    if (vox.scoreboard.IsTTT()) then
        teamColor = vox.scoreboard.GetRoleColorTTT(ply)
    end

    local convertedColor = vox.scoreboard.ConvertTeamColor(teamColor)
    local usergroup = ply:GetUserGroup()

    self:SetPlayer(ply)

    self.colorGradient = ColorAlpha(vox.LerpColor(.5, teamColor, color_black), 40) -- lerp makes gradients look better
    self.rankData = vox.scoreboard:GetRankData(usergroup)

    self.avatar.color = convertedColor
    self.avatar:SetPlayer(ply, 64)

    self.lblName:SetText(ply:Name())

    self.buttonMute:Update()

    self:UpdateColumnValues(self.rankData)
end

function PANEL:UpdateColumnValues()
    local ply = self:GetPlayer()
    if (not IsValid(ply)) then return end

    for index, data in ipairs(vox.scoreboard:GetActiveColumns()) do
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

vox.gui.Register('vox.Scoreboard.PlayerLine', PANEL)

--[[------------------------------
// ANCHOR Debug
--------------------------------]]
-- vox.gui.Test('vox.Scoreboard.Frame', .66, .66, function(self)
--     self:Center()
--     self:MakePopup()
-- end)
