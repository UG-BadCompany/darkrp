local MAT_ARROW = Material('vox_framework/wing.png', 'smooth mips')
local colorPrimary = vox:Config('colors.primary')
local colorSecondary = vox:Config('colors.secondary')
local colorAccent = vox:Config('colors.accent')
local colorTertiary = vox:Config('colors.tertiary')

local font0 = vox.Font('Comfortaa Bold@16')

local PANEL = {}

AccessorFunc(PANEL, 'm_Title', 'Title')
AccessorFunc(PANEL, 'm_iCategoryHeight', 'CategoryHeight')
AccessorFunc(PANEL, 'm_iSpace', 'Space')
AccessorFunc(PANEL, 'm_iInset', 'Inset')
AccessorFunc(PANEL, 'm_bExpanded', 'Expanded')
AccessorFunc(PANEL, 'm_iTextMargin', 'TextMargin')
AccessorFunc(PANEL, 'm_bSquareCorners', 'SquareCorners')

function PANEL:Init()
    local padding = vox.ScaleTall(5)

    self.m_iArrowAngle = 90

    self.button = vgui.Create('Panel', self)
    vox.gui.Extend(self.button)
    self.button:Import('click')
    self.button:Import('hovercolor')
    self.button:SetColorKey('backgroundColor')
    self.button:SetColorIdle(vox.ColorBetween(colorSecondary, colorPrimary))
    self.button:SetColorHover(colorTertiary)
    self.button.textColor = color_white
    self.button.Paint = function(p, w, h)
        if (self.m_bSquareCorners and self.canvas:GetTall() > 0) then
            draw.RoundedBoxEx(8, 0, 0, w, h, p.backgroundColor, true, true)
        else
            draw.RoundedBox(8, 0, 0, w, h, p.backgroundColor)
        end

        local x = self.m_iTextMargin or padding
        local sz = math.floor(h * .5)

        if (self.wimage) then
            self.wimage:Draw(h * .5 - sz * .5, h * .5 - sz * .5, sz, sz, colorAccent)

            x = h
        end

        draw.SimpleText(self:GetTitle(), font0, x, h * .5, p.textColor, 0, 1)

        local sz = math.floor(h * .33)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(MAT_ARROW)
        surface.DrawTexturedRectRotated(w - h * .5, h * .5, sz, sz, self.m_iArrowAngle)
    end

    self.button.DoClick = function()
        if self:GetExpanded() then
            self:Close()
        else
            self:Open()
        end
    end

    self.canvas = vgui.Create('Panel', self)

    self:SetTitle('CATEGORY')
    self:SetInset(0)
    self:SetCategoryHeight(vox.ScaleTall(30))
    self:SetSpace(vox.ScaleTall(5))
    self:SetTall(self:GetCategoryHeight())
end

function PANEL:GetItems()
    return self.canvas:GetChildren()
end

function PANEL:SetExpanded(bBool)
    if (bBool) then
        self.button:SetColorIdle(colorSecondary)
    else
        self.button:SetColorIdle(vox.ColorBetween(colorSecondary, colorPrimary))
    end

    self.m_bExpanded = bBool

    self:Call('OnStateChanged', nil, bBool)
end

function PANEL:Animate(height, arrowAngle)
    self.ah = self:GetTall()

    vox.anim.Create(self, 0.3, {
        index = 1,
        target = {ah = height, m_iArrowAngle = arrowAngle},
        think = function(anim, panel)
            panel:SetTall(panel.ah)
            panel.canvas:SetTall(panel.ah - panel:GetSpace() - panel:GetCategoryHeight())
        end
    })
end

function PANEL:Think()
    self.canvas:SetVisible(self.canvas:GetTall() > 0) -- optimization
end

function PANEL:Open()
    local height = self:GetTotalHeight()

    self:SetExpanded(true)

    self:Animate(height, 0)
end

function PANEL:Close()
    self:SetExpanded(false)

    self:Animate(self:GetCategoryHeight(), 90)
end

function PANEL:Update()
    if (self:GetExpanded()) then
        local categoryHeight = self:GetCategoryHeight()
        local space = self:GetSpace()
        local height = self:GetTotalHeight()

        self.m_iArrowAngle = 0

        self:SetTall(height)
        self.canvas:SetTall(height - space - categoryHeight)
    end
end

function PANEL:UpdateInTick(ticks)
    ticks = ticks or 2
    timer.Simple(engine.TickInterval() * ticks, function()
        if (IsValid(self)) then
            self:Update()
        end
    end)
end

function PANEL:SetIcon(url, params)
    self.wimage = vox.wimg.Simple(url, params)
end

function PANEL:PerformLayout(w, h)
    self.button:SetSize(w, self:GetCategoryHeight())
    self.canvas:SetWide(w)
    self.canvas:SetPos(0, self.button:GetTall() + self:GetSpace())
end

function PANEL:GetContentHeight()
    local panels = self.canvas:GetChildren()
    local count = #panels
    local size = 0

    for index, child in ipairs(panels) do
        if child:IsVisible() then
            local _, top, _, bottom = child:GetDockMargin()

            size = size + child:GetTall()
            size = size + top
            size = size + (index ~= count and bottom or 0)
        end
    end

    return size
end

function PANEL:GetTotalHeight()
    local h = self:GetCategoryHeight() + self:GetContentHeight() + self:GetSpace()

    h = h + self:GetInset() * 2

    return h
end

function PANEL:SetInset(amt)
    self.m_iInset = amt
    if (IsValid(self.canvas)) then
        self.canvas:DockPadding(amt, amt, amt, 0)
    end
end

function PANEL:Add(class)
    local panel = self.canvas:Add(class)

    -- self:AddPanel(panel)

    return panel
end

function PANEL:AddPanel(panel)
    return self.canvas:Add(panel)
end

function PANEL:GetItems()
    return self.canvas:GetChildren()
end

vox.gui.Register('vox.Category', PANEL)
