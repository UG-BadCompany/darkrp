local fallbackTogglerColors = {
    primary = Color(8, 19, 38),
    secondary = Color(12, 32, 62),
    tertiary = Color(16, 42, 78),
    accent = Color(70, 135, 255)
}

local function getTogglerColors()
    if vox.f4 and IsValid(vox.f4.frame) and vox.f4.GetReferenceColors then
        local ref = vox.f4.GetReferenceColors()
        return ref.bg, ref.card, ref.card2, ref.accent
    end

    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackTogglerColors.primary, colors.secondary or fallbackTogglerColors.secondary, colors.tertiary or fallbackTogglerColors.tertiary, colors.accent or fallbackTogglerColors.accent
end

do
    local PANEL = {}

    AccessorFunc(PANEL, 'm_bChecked', 'Checked', FORCE_BOOL)

    function PANEL:Init()
        local size = vox.ScaleTall(18)

        self.m_bChecked = false

        self:Import('click')
        self:SetSize(size * 2, size)

        self.perfectWidth = size * 2
        self.perfectHeight = size

        self.stateFraction = 0

        local _, secondary = getTogglerColors()
        self:SetBackgroundColor(secondary)
    end

    function PANEL:Paint(w, h)
        local radius = h * .5
        local height = h * .66
        local circleX = radius + (w - radius * 2) * self.stateFraction
        local realX, realY = self:LocalToScreen(0, 0)

        draw.RoundedBox(16, 0, h * .5 - height * .5, w, height, self.backgroundColorCurrent)

        render.SetScissorRect(realX, realY, realX + circleX, realY + h, true)
            surface.SetAlphaMultiplier(self.stateFraction)
                draw.RoundedBox(16, 0, h * .5 - height * .5, w, height, self.backgroundColorActive)
            surface.SetAlphaMultiplier(1)
        render.SetScissorRect(0, 0, 0, 0, false)

        vox.DrawCircle(circleX, h * .5, radius, self.gripColorCurrent)
    end

    function PANEL:DoClick()
        self:SetValue(not self.m_bChecked)
    end

    function PANEL:AnimState(bBool, ignoreAnimation)
        local time = .15
        if (bBool) then
            vox.anim.Create(self, time, {
                index = 40,
                skipAnimation = ignoreAnimation,
                target = {
                    stateFraction = 1,
                    gripColorCurrent = self.gripColorActive
                }
            })
        else
            vox.anim.Create(self, time, {
                index = 40,
                skipAnimation = ignoreAnimation,
                target = {
                    stateFraction = 0,
                    gripColorCurrent = self.gripColorIdle
                }
            })
        end
    end

    function PANEL:SetChecked(bBool, ignoreAnimation)
        assert(isbool(bBool), string.format('bad argument #1 to `SetChecked` (expected bool, got %s)', type(bBool)))
        self.m_bChecked = bBool
        self:AnimState(bBool, ignoreAnimation)
    end

    function PANEL:SetValue(bBool)
        self:SetChecked(bBool)
        self:Call('OnChange', nil, bBool)
    end

    function PANEL:GetValue()
        return self.m_bChecked
    end

    function PANEL:SetBackgroundColor(color)
        local f4Colors = vox.f4 and IsValid(vox.f4.frame) and vox.f4.GetReferenceColors and vox.f4.GetReferenceColors()
        local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
        local accent = (f4Colors and f4Colors.accent) or colors.accent or fallbackTogglerColors.accent
        self.backgroundColorCurrent = color
        self.backgroundColorActive = vox.LerpColor(.66, accent, self.backgroundColorCurrent)

        self.gripColorIdle = vox.OffsetColor(self.backgroundColorCurrent, 10)
        self.gripColorActive = accent
        self.gripColorCurrent = vox.CopyColor(self.gripColorIdle)
    end

    vox.gui.Register('vox.Toggler', PANEL)
end

do
    local PANEL = {}

    AccessorFunc(PANEL, 'm_iCheckContainerWidth', 'CheckContainerWidth')
    AccessorFunc(PANEL, 'm_bUnlockedTogglerSize', 'UnlockedTogglerSize')
    AccessorFunc(PANEL, 'm_iTextMargin', 'TextMargin')

    function PANEL:Init()
        self.lblText = self:Add('vox.Label')
        self.lblText:SetText('Example Label')

        self.togglerContainer = self:Add('Panel')

        self.toggler = self.togglerContainer:Add('vox.Toggler')

        self:SetTextMargin(vox.ScaleTall(5))
        self:CombineMutator(self.toggler, 'Checked')
        self:CombineMutator(self.toggler, 'Value')
        self:CombineMutator(self.lblText, 'Text')
        self:CombineMutator(self.lblText, 'Font')
        self:Combine(self.lblText, 'Font')
        self:Combine(self.toggler, 'SetBackgroundColor')
        self:MakeDispatchFn(self.toggler, 'OnChange')
    end

    function PANEL:PerformLayout(w, h)
        local togglerContainerWidth = self.m_iCheckContainerWidth or h
        local margin = self.m_iTextMargin

        self.togglerContainer:SetWide(togglerContainerWidth)
        self.togglerContainer:Dock(LEFT)
        self.togglerContainer:DockMargin(0, 0, margin, 0)

        self.lblText:Dock(FILL)

        if (self.UnlockedTogglerSize) then
            self.toggler:SetWide(togglerContainerWidth)
        else
            self.toggler:SetWide(math.min(self.toggler:GetWide(), togglerContainerWidth))
        end

        self.toggler:SetTall(self.toggler:GetWide() * .5)
        self.toggler:Center()
    end

    function PANEL:GetContentWide()
        local togglerContainerWidth = self.m_iCheckContainerWidth or self:GetTall()
        local lblText = self.lblText
        local margin = self.m_iTextMargin
        local wide = togglerContainerWidth + lblText:GetContentWidth() + margin
        return wide
    end
    PANEL.GetContentWidth = PANEL.GetContentWide

    vox.gui.Register('vox.TogglerLabel', PANEL)
end

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .4, .65, function(self)
--     self:MakePopup()

--     local iconlayout = self:Add('DIconLayout')
--     iconlayout:Dock(FILL)

--     for i = 1, 10 do
--         local panel = iconlayout:Add('vox.TogglerLabel')
--         -- panel:Dock(TOP)
--         panel:SetChecked(true, true)
--         panel:SetText('Hello there')
--         panel:Font('Comfortaa@16')
--         panel:SetTall(ScreenScale(14))
--         panel:SetWide(panel:GetContentWide())
--     end
-- end)
