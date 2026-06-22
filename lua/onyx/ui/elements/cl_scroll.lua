--[[

Author: tochonement
Email: tochonement@gmail.com

22.08.2021

--]]

local PANEL = {}

function PANEL:Init()
    onyx.gui.Extend(self.btnGrip)

    self:Import('smoothscroll')
    self:SetHideButtons(true)

    self.bgColor = ColorAlpha(onyx.cfg.colors.accent, 40)

    self.btnGrip.color = Color(0, 0, 0)
    self.btnGrip:Import('hovercolor')
    self.btnGrip:SetColorKey('color')
    self.btnGrip:SetColorIdle(onyx.cfg.colors.accent)
    self.btnGrip:SetColorHover(onyx.OffsetColor(onyx.cfg.colors.accent, -30))
    self.btnGrip.Paint = function(panel, w, h)
        draw.RoundedBox(4, 0, 0, w, h, panel.color)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.bgColor)
end

function PANEL:OnMouseWheeled(delta)
    local hovered = vgui.GetHoveredPanel()

    if IsValid(hovered) and hovered ~= self and hovered.OnMouseWheeled then
        return
    end

    self.BaseClass.OnMouseWheeled(self, delta)
end

onyx.gui.Register('onyx.Scroll', PANEL, 'DVScrollBar')