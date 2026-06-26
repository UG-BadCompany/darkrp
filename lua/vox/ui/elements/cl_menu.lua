local PANEL = {}

AccessorFunc(PANEL, 'm_bDeleteSelf', 'DeleteSelf')
AccessorFunc(PANEL, 'm_iMinimumWidth', 'MinimumWidth')

local MAT_WING = Material('vox_framework/wing.png', 'smooth mips')
local fallbackMenuColors = {
    primary = Color(3, 11, 24),
    secondary = Color(8, 27, 52),
    accent = Color(0, 174, 255),
    text = Color(238, 246, 255),
    muted = Color(145, 172, 200),
    negative = Color(255, 75, 95)
}

function PANEL:Init()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    self.backgroundColor = colors.primary or fallbackMenuColors.primary
    self.outlineColor = colors.accent or fallbackMenuColors.accent
    self.textColor = colors.textPrimary or fallbackMenuColors.text
    self.mutedColor = colors.textSecondary or fallbackMenuColors.muted
    self.negativeColor = colors.negative or fallbackMenuColors.negative
    self.options = {}
    self.submenus = {}

    self:SetDrawOnTop(true)
    self:SetDeleteSelf(true)
    self:SetVisible(false)
    self:SetMinimumWidth(vox.ScaleWide(120))

    local padding = vox.ScaleTall(2)

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

        width = math.max(width, child:GetContentWidth() + vox.ScaleTall(10))
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

    vox.bshadows.BeginShadow()
        draw.RoundedBox(8, x, y, w, h, ColorAlpha(self.outlineColor, 110))
        draw.RoundedBox(8, x + thickness, y + thickness, w - thickness * 2, h - thickness * 2, ColorAlpha(self.backgroundColor, 245))
    vox.bshadows.EndShadow(1, 3, 3)
end

function PANEL:ToCursor()
    self:SetPos(input.GetCursorPos())
end

function PANEL:AddOption(text, callback)
    local button = self:Add('vox.Button')
    button:SetText(text)

    button.OnMousePressed = function(panel)
        vox.menuButtonPressTime = CurTime()

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
    button:SetColorHover(vox.OffsetColor(button:GetColorIdle(), 10))
    button:SetTextColor((text:find('Report') or text:find('Kick')) and self.negativeColor or self.textColor)
    button:SetContentAlignment(4)
    button:SetText('')
    button:InjectEventHandler('Paint')
    button:On('Paint', function(panel, w, h)
        local material = panel.wimage and panel.wimage:GetMaterial() or panel.material
        local x = vox.ScaleWide(10)

        if (material) then
            local size = vox.ScaleTall(12)

            surface.SetDrawColor(panel:GetTextColor())
            surface.SetMaterial(material)
            surface.DrawTexturedRect(x, h * .5 - size * .5, size, size)

            x = x + size + vox.ScaleWide(5)
        end

        if (text:find('Report') or text:find('Kick')) then panel:SetTextColor(self.negativeColor) end
        draw.SimpleText(text, panel:GetFont(), x, h * .5, panel:GetTextColor(), 0, 1)
    end)

    button.GetContentWidth = function(panel)
        surface.SetFont(panel:GetFont())
        local w = surface.GetTextSize(text)
        local material = panel.wimage and panel.wimage:GetMaterial() or panel.material

        w = w + vox.ScaleWide(10)

        if (material) then
            w = w + vox.ScaleTall(12) + vox.ScaleWide(5)
        end

        if (panel.submenu) then
            w = w + vox.ScaleTall(12) + vox.ScaleWide(5)
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
        panel.wimage = vox.wimg.Simple(url, params)
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
    local submenu = vgui.Create('vox.Menu')
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
        vox.gui.InjectEventHandler(parent, 'OnRemove')
        vox.gui.AddEvent(parent, 'OnRemove', function()
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

vox.gui.Register('vox.Menu', PANEL, 'vox.ScrollPanel')
