--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

local PANEL = {}

local fontCommon = vox.Font('Comfortaa@16')
local colorCommon = Color(235, 235, 235)

function PANEL:Init()
    self:SetTextColor(colorCommon)
    self:SetFont(fontCommon)
end

function PANEL:CenterText()
    self:SetContentAlignment(5)
end

-- Trying to save my time....

function PANEL:Font(...)
    self:SetFont(vox.Font(...))
end

function PANEL:Color(r, g, b, a)
    if isnumber(r) then
        self:SetTextColor(Color(r, g, b, a))
    else
        self:SetTextColor(r)
    end
end

function PANEL:Shadow(distance, color)
    distance = distance or 1
    color = color and (isnumber(color) and Color(0, 0, 0, color) or color) or Color(0, 0, 0, 100)

    self:SetExpensiveShadow(distance, color)
end

function PANEL:AlignText(a)
    self:SetContentAlignment(a)
end

function PANEL:GetContentWidth()
    surface.SetFont(self:GetFont())
    return select(1, surface.GetTextSize(self:GetText()))
end

vox.gui.Register('vox.Label', PANEL, 'DLabel')
