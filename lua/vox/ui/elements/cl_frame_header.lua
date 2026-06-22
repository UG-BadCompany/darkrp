--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

local PANEL = {}
local CLOSE_BUTTON = Material('vox_framework/close.png', 'smooth')

function PANEL:Init()
    self.colorBG = vox:Config('colors.secondary')

    self.lblText = self:Add('vox.Label')
    self.lblText:CenterText()

    self.btnClose = self:Add('vox.ImageButton')
    self.btnClose:SetMaterial(CLOSE_BUTTON)
    self.btnClose:InstallHoverAnim()
    self.btnClose:SetColorHover(Color(255, 87, 87))
    self.btnClose:SetColorPressed(Color(204, 38, 38))
    self.btnClose:SetImageScale(.6)
    self.btnClose.DoClick = function()
        self:GetParent():Close()
    end

    self:SetTitle('Title')
end

function PANEL:PerformLayout(w, h)
    self.lblText:SetSize(w, h)

    self.btnClose:Dock(RIGHT)
    self.btnClose:SetWide(h)
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(8, 0, 0, w, h, self.colorBG, true, true)
end

function PANEL:SetTitle(text)
    self.lblText:SetText(vox.utf8.upper(text))
end

vox.gui.Register('vox.Frame.Header', PANEL)
