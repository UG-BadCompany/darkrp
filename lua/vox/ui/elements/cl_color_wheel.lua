--[[

Author: tochnonement
Email: tochnonement@gmail.com

13/06/2023

--]]
local MAT_CIRCLE = Material('vox_framework/color_wheel.png', 'smooth mips')

local PANEL = {}

AccessorFunc(PANEL, 'm_Saturation', 'Saturation', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_Hue', 'Hue', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_Value', 'Value', FORCE_NUMBER)

function PANEL:Init()
    self:SetSaturation(0)
    self:SetHue(0)
    self:SetValue(1)
    self.dragging = false
end

function PANEL:SetValue(value)
    self.m_Value = math.Clamp(value, 0, 1)

    local brightness = 255 * self.m_Value
    local crosshairBrightness = 255 - brightness

    self.wheelColor = Color(brightness, brightness, brightness)
    self.crosshairColor = Color(crosshairBrightness, crosshairBrightness, crosshairBrightness)
end

function PANEL:Paint(w, h)
    local saturation = self.m_Saturation
    local hue = self.m_Hue

    -- draw circle with smooth edges
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(MAT_CIRCLE)
        surface.DrawTexturedRect(0, 0, w, h)
    render.PopFilterMin()
    render.PopFilterMag()

    -- draw crosshair
    local x0, y0 = w * .5, h * .5
    local x, y = x0, y0

    local r = h * .5 * saturation
    local rad = math.rad((hue - 90) % 360)
    local sin, cos = math.sin(rad), math.cos(rad)

    x = x0 + r * cos
    y = y0 + r * sin

    surface.SetDrawColor(self.crosshairColor)
    surface.DrawRect(x - 4, y - 1, 8, 2)
    surface.DrawRect(x - 1, y - 4, 2, 8)
end

function PANEL:OnMousePressed()
    self.dragging = true
    self:MouseCapture(true)
end

function PANEL:OnMouseReleased()
    self.dragging = false
    self:MouseCapture(false)
end

function PANEL:Think()
    if (self.dragging) then
        local x, y = self:ScreenToLocal(input.GetCursorPos())
        local w, h = self:GetSize()
        local radius = w * .5

        x = math.Clamp(x, 0, w)
        y = math.Clamp(y, 0, h)

        local xRelative0, yRelative0 = x - radius, y - radius

        local rad = math.atan2(yRelative0, xRelative0)
        local length = math.sqrt( math.pow(xRelative0, 2) + math.pow(yRelative0, 2) )

        self.m_Hue = (math.deg(rad) + 90) % 360
        self.m_Saturation = math.min(1, length / radius)
    end
end

function PANEL:GetColor()
    -- https://github.com/facepunch/garrysmod-issues/issues/2407
    local colorTable = HSVToColor(self.m_Hue, self.m_Saturation, self.m_Value)
    local colorObject = Color(colorTable.r, colorTable.g, colorTable.b)
    return colorObject
end

function PANEL:SetColor(color)
    local h, s, v = ColorToHSV(color)

    self:SetHue(h)
    self:SetSaturation(s)
    self:SetValue(v)
end

vox.gui.Register('vox.ColorWheel', PANEL)

-- vox.gui.Test('DFrame', .5, .5, function(self)
--     self:MakePopup()

--     local mixer = self:Add('vox.ColorWheel')
--     mixer:SetSize(64, 64)
--     mixer:Center()
--     mixer:SetSaturation(.5)
--     mixer:SetValue(1)
--     mixer:SetColor(Color(255, 53, 53))

--     local panel = self:Add('Panel')
--     panel:SetSize(48, 48)
--     panel.Paint = function(p, w, h)
--         surface.SetDrawColor(mixer:GetColor())
--         surface.DrawRect(0, 0, w, h)
--     end
-- end)
