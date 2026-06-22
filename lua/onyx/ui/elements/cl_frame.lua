--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

local PANEL = {}

function PANEL:Init()
    self.divHeader = self:Add('onyx.Frame.Header')
    self.colorBG = onyx.OffsetColor(onyx:Config('colors.primary'), -5)

    self:Combine(self.divHeader, 'SetTitle')
    self:SetTitle('Frame')

    self.disabledPanels = {}
    self.focusMultiplier = 0

    self._Remove = self.Remove
    self.Remove = function(panel)
        panel:Close()
    end
end

function PANEL:ShowCloseButton(bVis)
    self.divHeader.btnClose:SetVisible(bVis)
end

function PANEL:PerformLayout(w, h)
    self.divHeader:Dock(TOP)
    self.divHeader:SetTall(ScreenScale(12))
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen(0, 0)

    if (self.focused and self.focusMultiplier > 0) then
        DisableClipping(true)
            onyx.DrawBlurExpensive(self, self.focusMultiplier)
        DisableClipping(false)
    end

    assert( self.colorBG )
    onyx.bshadows.BeginShadow()
        draw.RoundedBox(8, x, y, w, h, self.colorBG)
    onyx.bshadows.EndShadow(1, 5, 5)
end

function PANEL:Focus()
    local panels = vgui.GetWorldPanel():GetChildren()
    for _, child in ipairs(panels) do
        if child:IsVisible() and child ~= self and child:IsMouseInputEnabled() then
            child:SetMouseInputEnabled(false)
            table.insert(self.disabledPanels, child)
        end
    end

    self.focused = true

    onyx.anim.Simple(self, .33, {
        focusMultiplier = 5
    }, 1)
end

function PANEL:UnFocus()
    for _, child in ipairs(self.disabledPanels) do
        if IsValid(child) then
            child:SetMouseInputEnabled(true)
        end
    end

    self.disabledPanels = {}
    self.focused = false
end

function PANEL:OnRemove()
    self:UnFocus()
end

function PANEL:Close()
    self:AlphaTo(0, .2, 0, function(_, panel)
        if (IsValid(panel)) then
            panel:_Remove()
        end
    end)
end

onyx.gui.Register('onyx.Frame', PANEL, 'EditablePanel')

-- ANCHOR Test

-- onyx.gui.Test('onyx.Frame', .65, .65, function(self)
--     self:Focus()
-- end)