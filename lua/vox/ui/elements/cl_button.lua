local PANEL = {}

AccessorFunc(PANEL, 'm_colIdle', 'ColorIdle')
AccessorFunc(PANEL, 'm_colHover', 'ColorHover')
AccessorFunc(PANEL, 'm_colPressed', 'ColorPressed')
AccessorFunc(PANEL, 'm_colGradient', 'GradientColor')
AccessorFunc(PANEL, 'm_iGradientDirection', 'GradientDirection')
AccessorFunc(PANEL, 'm_bMasking', 'Masking')

local fallbackButtonColors = { accent = Color(70, 135, 255) }

local function getButtonAccent()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.accent or fallbackButtonColors.accent
end

function PANEL:Init()
    self:Import('click')
    self:Import('hovercolor')
    self:SetTall(ScreenScale(10))
    self:CenterText()

    local _SetColorIdle = self.SetColorIdle
    self.SetColorIdle = function(panel, color)
        _SetColorIdle(panel, color)

        local h, s, v = ColorToHSV(color)
        if (v > .5) then
            panel:SetTextColor(color_black)
        else
            panel:SetTextColor(color_white)
        end
    end

    self:SetColorKey('backgroundColor')
    self:SetColorIdle(getButtonAccent())
    -- self:SetColorHover(vox.OffsetColor(self:GetColorIdle(), -80))
    self:SetColorHover(vox.ColorEditHSV(self:GetColorIdle(), nil, nil, .66))
    self:SetGradientDirection(RIGHT)
end

function PANEL:Paint(w, h)
    local isMaskingEnabled = self.m_bMasking
    local colorGradient = self.m_colGradient

    draw.RoundedBox(8, 0, 0, w, h, self.backgroundColor)

    if (isMaskingEnabled and colorGradient) then
        vox.DrawWithPolyMask(self.mask, function()
            vox.DrawMatGradient(0, 0, w, h, self.m_iGradientDirection, colorGradient)
        end)
    end
end

function PANEL:PerformLayout(w, h)
    if (self.m_bMasking) then
        self.mask = vox.CalculateRoundedBox(8, 0, 0, w, h)
    end
end

vox.gui.Register('vox.Button', PANEL, 'vox.Label')

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .4, .65, function(self)
--     self:MakePopup()

--     for i = 1, 10 do
--         local btn = self:Add('vox.Button')
--         btn:Dock(TOP)
--         btn:SetText('Button #' .. i)
--         btn.DoClickInternal = function()

--         end
--         btn.DoClick = function()
--             print('test')
--         end

--         if i % 2 == 0 then
--             btn:SetDisabled(true)
--         end
--     end
-- end)
