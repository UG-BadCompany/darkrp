--[[

Author: tochnonement
Email: tochnonement@gmail.com

07/05/2023

--]]

local PANEL = {}

local colorPrimary = onyx:Config('colors.primary')
local colorSecondary = onyx:Config('colors.secondary')
local colorAccent = onyx:Config('colors.accent')
local MAT_TICK = Material('onyx_framework/tick.png', 'smooth mips')

AccessorFunc(PANEL, 'm_bChecked', 'Checked', FORCE_BOOL)

function PANEL:Init()
    local size = onyx.ScaleTall(18)

    self.m_bChecked = false

    self:Import('click')
    self:SetSize(size, size)

    self:Import('hovercolor')
    self:SetColorKey('outlineColor')
    self:SetColorIdle(colorSecondary)
    self:SetColorHover(colorAccent)

    self.backgroundColor = onyx.CopyColor(colorPrimary)
    self.backgroundIdleColor = colorPrimary
    self.backgroundActiveColor = colorAccent
end

function PANEL:Paint(w, h)
    local backgroundColor = self.backgroundColor
    local outlineColor = self.outlineColor
    local size = math.ceil(h * .66)

    draw.RoundedBox(8, 0, 0, w, h, outlineColor)
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, backgroundColor)

    if (self.m_bChecked) then
        surface.SetDrawColor(color_white)
        surface.SetMaterial(MAT_TICK)
        surface.DrawTexturedRect(w * .5 - size * .5, h * .5 - size * .5, size, size)
    end
end

function PANEL:DoClick()
    self:SetValue(not self.m_bChecked)
end

function PANEL:SetChecked(bBool)
    assert(isbool(bBool), string.format('bad argument #1 to `SetChecked` (expected bool, got %s)', type(bBool)))
    self.m_bChecked = bBool

    if (bBool) then
        onyx.anim.Create(self, .33, {
            index = 40,
            target = {
                backgroundColor = self.backgroundActiveColor
            }
        })
    else
        onyx.anim.Create(self, .33, {
            index = 40,
            target = {
                backgroundColor = self.backgroundIdleColor
            }
        })
    end
end

function PANEL:SetValue(bBool)
    self:SetChecked(bBool)
    self:Call('OnChange', nil, bBool)
end

function PANEL:GetValue()
    return self.m_bChecked
end

onyx.gui.Register('onyx.CheckBox', PANEL)

-- ANCHOR Test

-- onyx.gui.Test('onyx.Frame', .4, .65, function(self)
--     self:MakePopup()

--     for i = 1, 10 do
--         local panel = self:Add('Panel')
--         panel:Dock(TOP)
--         panel:SetTall(ScreenScale(24))

--         local btn = panel:Add('onyx.CheckBox')
--         -- btn:Dock(LEFT)
--         btn:AlignRight(0)
--         btn:CenterVertical()
--     end
-- end)