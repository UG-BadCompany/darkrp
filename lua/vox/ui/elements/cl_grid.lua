--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/03/2023

--]]

local PANEL = {}

AccessorFunc(PANEL, 'm_iColumnCount', 'ColumnCount')
AccessorFunc(PANEL, 'm_iSpaceX', 'SpaceX')
AccessorFunc(PANEL, 'm_iSpaceY', 'SpaceY')
AccessorFunc(PANEL, 'm_fSizeRatio', 'SizeRatio')

function PANEL:Init()
    self:SetSpaceX(0)
    self:SetSpaceY(0)
    self:SetColumnCount(4)
end

function PANEL:PerformLayout(w, h)
    self:Layout(w, h)

    local contentHeight = self:GetContentHeight()
    if (contentHeight ~= h) then
        self:SetSizeToContents()
    end
end

function PANEL:SetSpace(space)
    self:SetSpaceX(space)
    self:SetSpaceY(space)
end

function PANEL:Layout(w, h)
    local children = self:GetVisibleChildren()

    local spaceX, spaceY = self:GetSpaceX(), self:GetSpaceY()
    local columnCount = self:GetColumnCount()
    local wide = math.floor((w - spaceX * (columnCount - 1)) / columnCount)

    local x, y = 0, 0
    local ratio = self:GetSizeRatio()

    for i, child in ipairs(children) do
        child:SetWide(wide)
        child:SetPos(x, y)

        if (ratio) then
            child:SetTall(math.Round(wide * ratio))
        end

        x = x + wide + spaceX

        if (i % columnCount == 0) then
            y = y + child:GetTall() + spaceY
            x = 0
        end
    end
end

function PANEL:GetVisibleChildren()
    local result, count = {}, 0
    for _, ch in ipairs(self:GetChildren()) do
        if (ch:IsVisible()) then
            count = count + 1
            result[count] = ch
        end
    end
    return result
end

function PANEL:GetContentHeight()
    local height = 0
    local children = self:GetChildren()
    local visible = 0

    for _, child in ipairs(children) do
        if (child:IsVisible()) then
            visible = visible + 1
        end
    end

    local rows = math.ceil(visible / self:GetColumnCount())
    local height = rows * self:GetRowHeight() + (rows - 1) * self:GetSpaceY()

    return height
end

function PANEL:GetRowHeight()
    local rowHeight = 0
    for _, ch in ipairs(self:GetVisibleChildren()) do
        rowHeight = math.max(rowHeight, ch:GetTall())
    end
    return rowHeight
end

function PANEL:SetSizeToContents()
    local contentHeight = self:GetContentHeight()
    self:SetTall(contentHeight)
end

function PANEL:AddItem(panel)
end

function PANEL:GetItems()
    return self:GetChildren()
end

vox.gui.Register('vox.Grid', PANEL)

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .66, .66, function(self)
--     self:MakePopup()

--     local list = self:Add('vox.ScrollPanel')
--     list:Dock(FILL)

--     local grid = list:Add('vox.Grid')
--     grid:Dock(TOP)
--     grid:SetSizeRatio(1.25)

--     for i = 1, 32 do
--         local button = grid:Add('vox.Button')
--         button:SetText('Button #' .. i)
--         -- button:SetTall(100)
--         button:SetTextColor(color_black)
--         button.Paint = function(p, w, h)
--             surface.SetDrawColor(color_white)
--             surface.DrawRect(0, 0, w, h)

--             surface.SetDrawColor(0, 0, 255)
--             surface.DrawOutlinedRect(0, 0, w, h, 4)
--         end

--         grid:AddItem(button)
--     end

--     for var = 1, 32 do
--         if (var > 16) then
--             grid:GetChild(var - 1):SetVisible(false)
--         end
--     end

--     -- grid:InvalidateLayout(true)
--     -- grid:SetSizeToContents()
-- end)
