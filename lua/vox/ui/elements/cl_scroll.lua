local PANEL = {}

local fallbackScrollColors = {
    primary = Color(8, 19, 38),
    secondary = Color(12, 32, 62),
    accent = Color(70, 135, 255)
}

local function getScrollColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackScrollColors.primary, colors.secondary or fallbackScrollColors.secondary, colors.accent or fallbackScrollColors.accent
end

function PANEL:Init()
    vox.gui.Extend(self.btnGrip)

    self:Import('smoothscroll')
    self:SetHideButtons(true)

    local _, _, accent = getScrollColors()
    self.bgColor = ColorAlpha(accent, 40)

    self.btnGrip.color = Color(0, 0, 0)
    self.btnGrip:Import('hovercolor')
    self.btnGrip:SetColorKey('color')
    self.btnGrip:SetColorIdle(accent)
    self.btnGrip:SetColorHover(vox.OffsetColor(accent, -30))
    self.btnGrip.Paint = function(panel, w, h)
        draw.RoundedBox(4, 0, 0, w, h, panel.color)
    end
end

function PANEL:Paint(w, h)
    local primary, secondary, accent = getScrollColors()
    self.btnGrip:SetColorIdle(accent)
    self.btnGrip:SetColorHover(vox.OffsetColor(accent, -30))
    draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(secondary or primary, 105))
    surface.SetDrawColor(ColorAlpha(accent, 45))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function PANEL:OnMouseWheeled(delta)
    local hovered = vgui.GetHoveredPanel()

    if IsValid(hovered) and hovered ~= self and hovered.OnMouseWheeled then
        return
    end

    self.BaseClass.OnMouseWheeled(self, delta)
end

vox.gui.Register('vox.Scroll', PANEL, 'DVScrollBar')
