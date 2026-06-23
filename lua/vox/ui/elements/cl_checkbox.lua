local PANEL = {}

local colorPrimary = vox:Config('colors.primary')
local colorSecondary = vox:Config('colors.secondary')
local colorAccent = vox:Config('colors.accent')
local MAT_TICK = Material('vox_framework/tick.png', 'smooth mips')

AccessorFunc(PANEL, 'm_bChecked', 'Checked', FORCE_BOOL)

function PANEL:Init()
    local size = vox.ScaleTall(18)
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    local primary = colors.primary or colorPrimary
    local secondary = colors.secondary or colorSecondary
    local accent = colors.accent or colorAccent

    self.m_bChecked = false

    self:Import('click')
    self:SetSize(size, size)

    self:Import('hovercolor')
    self:SetColorKey('outlineColor')
    self:SetColorIdle(secondary)
    self:SetColorHover(accent)

    self.backgroundColor = vox.CopyColor(primary)
    self.backgroundIdleColor = primary
    self.backgroundActiveColor = accent
end

function PANEL:Paint(w, h)
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    self.backgroundIdleColor = colors.primary or self.backgroundIdleColor
    self.backgroundActiveColor = colors.accent or self.backgroundActiveColor
    self:SetColorIdle(colors.secondary or self:GetColorIdle())
    self:SetColorHover(colors.accent or self:GetColorHover())

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
        vox.anim.Create(self, .33, {
            index = 40,
            target = {
                backgroundColor = self.backgroundActiveColor
            }
        })
    else
        vox.anim.Create(self, .33, {
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

vox.gui.Register('vox.CheckBox', PANEL)

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .4, .65, function(self)
--     self:MakePopup()

--     for i = 1, 10 do
--         local panel = self:Add('Panel')
--         panel:Dock(TOP)
--         panel:SetTall(ScreenScale(24))

--         local btn = panel:Add('vox.CheckBox')
--         -- btn:Dock(LEFT)
--         btn:AlignRight(0)
--         btn:CenterVertical()
--     end
-- end)
