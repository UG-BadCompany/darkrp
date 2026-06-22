--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/04/2023

--]]

local PANEL = {}

function PANEL:Init()
    self.avatar = self:Add('AvatarImage')
    self.avatar:Dock(FILL)
    self.avatar:SetPaintedManually(true)

    self:Combine(self.avatar, 'SetPlayer')
    self:Combine(self.avatar, 'SetSteamID')
end

function PANEL:PerformLayout(w, h)
    self.mask = onyx.CalculateCircle(w * .5, h * .5, math.Round(h * .5) - 1, 24)
end

function PANEL:Paint(w, h)
    local mask = self.mask
    if (mask) then
        onyx.MaskFn(function()
            onyx.DrawPoly(mask)
        end, function()
            self.avatar:PaintManual()
        end)
    end
end

onyx.gui.Register('onyx.RoundedAvatar', PANEL)