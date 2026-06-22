--[[

Author: tochnonement
Email: tochnonement@gmail.com

02/03/2023

--]]

local PANEL = {}

AccessorFunc(PANEL, 'm_bDeleteSelf', 'DeleteSelf')
AccessorFunc(PANEL, 'm_iMinimumWidth', 'MinimumWidth')

local MAT_WING = Material('onyx_framework/wing.png', 'smooth mips')
local colorPrimary = onyx:Config('colors.primary')
local colorSecondary = onyx:Config('colors.secondary')

function PANEL:Init()
    self.backgroundColor = colorPrimary
    self.outlineColor = colorSecondary
    self.options = {}
    self.submenus = {}

    self:SetDrawOnTop(true)
    self:SetDeleteSelf(true)
    self:SetVisible(false)
    self:SetMinimumWidth(onyx.ScaleWide(120))

    local padding = onyx.ScaleTall(2)

    self:DockPadding(padding, padding, padding, padding)

    self.canvas:SetSpace(0)

    RegisterDermaMenuForClose(self)
end

function PANEL:PerformLayout(_, h)
    local _, padding1, _, padding2 = self:GetDockPadding()
    local _, localY = self:LocalToScreen(0, 0)
    local width = self:GetMinimumWidth()
    local height = padding1 + padding2
    local children = self.canvas:GetPanels()
    local childrenCount = #children

    for index, child in ipairs(self.canvas:GetPanels()) do
        height = height + child:GetTall()

        if (index < childrenCount) then
            height = height + select(4, child:GetDockMargin())
        end

        width = math.max(width, child:GetContentWidth() + onyx.ScaleTall(10))
    end

    if (localY + height) > ScrH() then
        height = ScrH() - localY
    end

    self:SetWide(width)
    self:SetTall(height)

    self.BaseClass.PerformLayout(self, width, height)

    self.scroll:DockMargin(0, 0, 0, 0)
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen()
    local thickness = 1

    onyx.bshadows.BeginShadow()
        draw.RoundedBox(8, x, y, w, h, self.outlineColor)
        draw.RoundedBox(8, x + thickness, y + thickness, w - thickness * 2, h - thickness * 2, self.backgroundColor)
    onyx.bshadows.EndShadow(1, 3, 3)
end

function PANEL:ToCursor()
    self:SetPos(input.GetCursorPos())
end

function PANEL:AddOption(text, callback)
    local button = self:Add('onyx.Button')
    button:SetText(text)

    button.OnMousePressed = function(panel)
        onyx.menuButtonPressTime = CurTime()

        panel:Call('DoClick')

        self:Remove()
    end

    button:On('OnCursorEntered', function(panel)
        self:CloseSubMenu()
    end)

    if callback then
        button.DoClick = callback
    end

    table.insert(self.options, button)
    local color = self.backgroundColor

    button:SetColorIdle(color)
    button:SetColorHover(onyx.OffsetColor(button:GetColorIdle(), 10))
    button:SetContentAlignment(4)
    button:SetText('')
    button:InjectEventHandler('Paint')
    button:On('Paint', function(panel, w, h)
        local material = panel.wimage and panel.wimage:GetMaterial() or panel.material
        local x = onyx.ScaleWide(10)

        if (material) then
            local size = onyx.ScaleTall(12)

            surface.SetDrawColor(panel:GetTextColor())
            surface.SetMaterial(material)
            surface.DrawTexturedRect(x, h * .5 - size * .5, size, size)

            x = x + size + onyx.ScaleWide(5)
        end

        draw.SimpleText(text, panel:GetFont(), x, h * .5, panel:GetTextColor(), 0, 1)
    end)

    button.GetContentWidth = function(panel)
        surface.SetFont(panel:GetFont())
        local w = surface.GetTextSize(text)
        local material = panel.wimage and panel.wimage:GetMaterial() or panel.material

        w = w + onyx.ScaleWide(10)

        if (material) then
            w = w + onyx.ScaleTall(12) + onyx.ScaleWide(5)
        end

        if (panel.submenu) then
            w = w + onyx.ScaleTall(12) + onyx.ScaleWide(5)
        end

        return w
    end

    button.SetIcon = function(panel, path, params)
        assert(path, 'no path provided')
        assert(isstring(path), 'path should be a string! alternative method: `SetMaterial`')
        panel.material = Material(path, params)
    end

    button.SetMaterial = function(panel, material)
        assert(material, 'no material provided')
        assert(type(material) == 'IMaterial', 'provided argument should be a IMaterial!')
        panel.material = material
    end

    button.SetIconURL = function(panel, url, params)
        assert(url, 'no url provided')
        panel.wimage = onyx.wimg.Simple(url, params)
    end

    return button
end

function PANEL:CloseSubMenu()
    if IsValid(self.activeSubmenu) then
        self.activeSubmenu:Close()
        self.activeSubmenu:CloseSubMenu()
    end
end

function PANEL:AddSubMenu(text)
    local submenu = vgui.Create('onyx.Menu')
    submenu:SetDeleteSelf(false)
    submenu.backgroundColor = self.backgroundColor
    submenu.outlineColor = self.outlineColor

    local button = self:AddOption(text)
    button:On('OnCursorEntered', function(panel)
        submenu:SetPos(self:GetX() + self:GetWide(), self:GetY() + panel:GetY())
        submenu:Open()
        submenu.parent = panel

        self.activeSubmenu = submenu
    end)
    button:On('Paint', function(panel, w, h)
        local sz = math.floor(h * .33)
        
        surface.SetDrawColor(panel:GetTextColor())
        surface.SetMaterial(MAT_WING)
        surface.DrawTexturedRectRotated(w - h * .5, h * .5, sz, sz, 90)
    end)
    button.submenu = true

    table.insert(self.submenus, submenu)

    return submenu, button
end

function PANEL:Open(parent)
    self:SetVisible(true)
    self:MakePopup()
    self:SetKeyBoardInputEnabled(false)
    self:InvalidateLayout(true)

    if (IsValid(parent)) then
        onyx.gui.InjectEventHandler(parent, 'OnRemove')
        onyx.gui.AddEvent(parent, 'OnRemove', function()
            if (IsValid(self)) then
                self:Remove()
            end
        end)
    end
end

function PANEL:Close()
    if (self.m_bDeleteSelf) then
        self:Remove()
    else
        self:SetVisible(false)
    end
end

function PANEL:OnRemove()
    for _, submenu in ipairs(self.submenus) do
        if (IsValid(submenu)) then
            submenu:Remove()
        end
    end
end

onyx.gui.Register('onyx.Menu', PANEL, 'onyx.ScrollPanel')
