local PANEL = {}

function PANEL:Init()
    self.canvas = vgui.Create('vox.ScrollPanel.Canvas', self)

    self.scroll = vgui.Create('vox.Scroll', self)

    self.canvas:On('OnContainerTallUpdated', function(panel, canvasTall, containerTall)
        self.scroll:SetUp(canvasTall, containerTall)
    end)

    self:Combine(self.canvas, 'AddPanel')
    self:Combine(self.canvas, 'OnPanelAdded')
    self:Combine(self.scroll, 'OnMouseWheeled')
    self:CombineMutator(self.canvas, 'Space')
end

function PANEL:PerformLayout(w, h)
    self.canvas:Dock(FILL)

    self.scroll:Dock(RIGHT)
    self.scroll:SetWide(vox.ScaleWide(6))
    self.scroll:DockMargin(ScreenScale(2), 0, 0, 0)
end

function PANEL:OnVScroll(offset)
    self:GetContainer():SetY(offset)
end

function PANEL:GetContainer()
    return self.canvas.container
end

function PANEL:GetItems()
    return self:GetContainer():GetChildren()
end

function PANEL:Add(class)
    local panel = vgui.Create(class)

    assert(panel, 'Panel class \"' .. class .. '\" doesn\'t exist')

    self:AddPanel(panel)

    return panel
end

-- hack
function PANEL:Think()
    local scroll = self.scroll:GetScroll()
    local canvasSize = self.scroll.CanvasSize
    if (scroll ~= canvasSize) then
        local target = math.min(scroll, canvasSize)
        self.scroll:SetScroll(target)
        if (canvasSize <= 1) then
            self.canvas.container:SetPos(0, -scroll)
            self.scroll.Current = 0
            self.scroll.Scroll = 0
        end
    end
end

vox.gui.Register('vox.ScrollPanel', PANEL)

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .66, .66, function(self)
--     self:MakePopup()

--     local list = self:Add('vox.ScrollPanel')
--     list:Dock(FILL)

--     for i = 1, 32 do
--         local button = list:Add('vox.Button')
--         button:SetText('Button #' .. i)
--     end
-- end)
