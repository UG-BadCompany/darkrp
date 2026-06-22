--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

local PANEL = {}

AccessorFunc(PANEL, 'm_Material', 'Material')
AccessorFunc(PANEL, 'm_colColor', 'Color')
AccessorFunc(PANEL, 'm_iImageAngle', 'ImageAngle')
AccessorFunc(PANEL, 'm_iImageScale', 'ImageScale')
AccessorFunc(PANEL, 'm_iImageWide', 'ImageWide')
AccessorFunc(PANEL, 'm_iImageTall', 'ImageTall')

function PANEL:Init()
    self:SetImageScale(1)
    self:SetImageAngle(0)
    self:SetColor(color_white)
end

function PANEL:SetImageSize(w, h)
    h = h or w -- square

    self:SetImageWide(w)
    self:SetImageTall(h)
end

function PANEL:SetURL(url, parameters)
    self.m_WebImage = vox.wimg.Simple(url, parameters)
end

function PANEL:SetWebImage(id, parameters)
    self.m_WebImage = vox.wimg.Create(id, parameters)
end

function PANEL:SetSVG(id, w, h, colorable)
    self.m_SVG = vox.svg.Create(id, w, (h or w), colorable)
end

function PANEL:SetImage(path, params)
    self:SetMaterial(Material(path, params))
end

function PANEL:GetWebImage()
    return self.m_WebImage
end

function PANEL:GetSVG()
    return self.m_SVG
end

function PANEL:Paint(w, h)
    self:Call('PaintBackground', nil, w, h)

    local webImage = self:GetWebImage()
    local material = self:GetMaterial()
    local svg = self:GetSVG()
    local color = self:GetColor()
    local scale = self:GetImageScale()
    local angle = self:GetImageAngle()
    local iw, ih = self:GetImageWide() or w, self:GetImageTall() or h
    local ix, iy = w * .5, h * .5

    iw = iw * scale
    ih = ih * scale

    if svg then
        svg:Draw(w * .5 - svg:GetWide() * .5, h * .5 - svg:GetTall() * .5, nil, nil, color)
    elseif webImage then
        webImage:DrawRotated(ix, iy, iw, ih, angle, color)
    elseif material && angle != 0 then
        vox.DrawMaterialRotated(material, 0, 0, iw, ih, angle, color)
    elseif material then
        surface.SetDrawColor(color)
        surface.SetMaterial(material)
        surface.DrawTexturedRect(w * .5 - iw * .5, h * .5 - ih * .5, iw, ih)
    end
end

vox.gui.Register('vox.Image', PANEL)
