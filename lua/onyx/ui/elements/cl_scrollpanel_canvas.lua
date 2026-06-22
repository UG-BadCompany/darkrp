--[[

Author: tochonement
Email: tochonement@gmail.com

22.08.2021

--]]

local PANEL = {}

AccessorFunc(PANEL, 'm_iSpace', 'Space')

function PANEL:Init()
    self.container = self:Add('Panel')

    self:SetSpace(ScreenScale(2))
end

function PANEL:PerformLayout(w, h)
    self:UpdateSize()
end

function PANEL:GetPanels()
    return self.container:GetChildren()
end

function PANEL:CalculateTall()
    local panels = self:GetPanels()
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

function PANEL:UpdateSize()
    local w, h = self:GetWide(), self:CalculateTall()

    self.container:SetSize(w, h)

    self:Call('OnContainerTallUpdated', nil, self:GetTall(), h)
end

function PANEL:AddPanel(panel)
    panel:SetParent(self.container)
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, self:GetSpace())

    local class = panel.ClassName or 'Panel'
    if (not class:find('onyx')) then
        onyx.gui.Extend(panel)
    end

    panel:InjectEventHandler('PerformLayout')
    panel:On('PerformLayout', function()
        self:UpdateSize()
    end)

    panel:Call('OnPanelAdded', nil, panel)
end

function PANEL:OnPanelAdded()
end

onyx.gui.Register('onyx.ScrollPanel.Canvas', PANEL)

-- ANCHOR Test

-- onyx.gui.Test('onyx.Frame', .66, .66, function(self)
--     self:MakePopup()

--     local list = self:Add('onyx.ScrollPanel')
--     list:Dock(FILL)

--     for i = 1, 1024 do
--         local button = list:Add('onyx.Button')
--         button:SetText('Button #' .. i)
--         button:SetTall(32)
--     end
-- end)