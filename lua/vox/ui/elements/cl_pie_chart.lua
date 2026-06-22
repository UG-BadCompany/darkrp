--[[

Author: tochnonement
Email: tochnonement@gmail.com

04/01/2024

--]]

local CIRCLE_FULL_ANGLE = 360

local PANEL = {}

AccessorFunc(PANEL, 'm_Data', 'Data')
AccessorFunc(PANEL, 'm_LegendFont', 'LegendFont')
AccessorFunc(PANEL, 'm_iSum', 'Sum')
AccessorFunc(PANEL, 'm_bDonut', 'Donut')
AccessorFunc(PANEL, 'm_flRadius', 'Radius')
AccessorFunc(PANEL, 'm_colCircleBackgroundColor', 'CircleBackgroundColor')

function PANEL:Init()
    self:SetData({})
    self:SetCircleBackgroundColor(Color(100, 100, 100))
    self:SetDonut(false)
    self:SetRadius(.33)
    self:SetLegendFont(vox.Font('Comfortaa@16'))

    self.divBody = self:Add('Panel')
    self.divBody.Paint = function(panel, w, h)
        self:DrawChart(w, h)
    end
    self.divBody.PerformLayout = function(panel, w, h)
        self:PerformChart(w, h)
    end

    self.divLegend = self:Add('Panel')
    self.divLegend.Paint = function(panel, w, h)
        self:DrawLegend(w, h)
    end
end

function PANEL:PerformLayout(w, h)
    self.divBody:Dock(FILL)

    self.divLegend:Dock(RIGHT)
    self.divLegend:SetWide(w * .5)
end

function PANEL:SetLegendVisible(bVisible)
    self.divLegend:SetVisible(bVisible)
end

function PANEL:AddRecord(text, amount, color)
    vox.AssertType(text, 'string', 'AddRecord', 1)
    vox.AssertType(amount, 'number', 'AddRecord', 2)

    local color = color or vox.ColorEditHSV(color_white, math.random(360), .8, .8)

    local data = self:GetData()
    table.insert(data, {
        text = text,
        amount = amount,
        color = color
    })

    table.sort(data, function(a, b)
        return a.amount > b.amount
    end)

    self:UpdateSum()
end

function PANEL:UpdateSum()
    local data = self:GetData()
    local sum = 0

    for _, record in ipairs(data) do
        sum = sum + record.amount
    end

    for _, record in ipairs(data) do
        record.fraction = (record.amount / sum)
    end

    self:SetSum(sum)
    self.divBody:InvalidateLayout(true)

    return sum
end

function PANEL:DrawLegend(w, h)
    local data = self:GetData()
    local amount = #data
    local font = self:GetLegendFont()
    local y = 0

    surface.SetFont(font)
    local _, textH = surface.GetTextSize('A')
    local space = vox.ScaleTall(5)
    local iconMargin = vox.ScaleWide(5)

    for index = 1, amount do
        local record = data[index]

        vox.DrawCircle(textH * .5, y + textH * .5, textH * .5, record.color)

        draw.SimpleText(record.text, font, textH + iconMargin, y, color_white, 0, 0)
        draw.SimpleText(math.Round(record.fraction * 100, 1) .. '%', font, w, y, color_white, 2, 0)

        y = y + textH + space
    end
end

function PANEL:DrawChart(w, h)
    local data = self:GetData()
    local radius = math.min(w, h) * self:GetRadius()
    local isDonut = self:GetDonut()
    local outlineThickness = 4

    if (isDonut) then
        vox.DrawOutlinedCircle(w * .5, h * .5, radius, outlineThickness, self.m_colCircleBackgroundColor)
    else
        vox.DrawCircle(w * .5, h * .5, radius, self.m_colCircleBackgroundColor)
    end

    for _, record in ipairs(data) do
        vox.DrawWithPolyMask(record.poly, function()
            if (isDonut) then
                vox.DrawOutlinedCircle(w * .5, h * .5, radius, outlineThickness, record.color)
            else
                vox.DrawCircle(w * .5, h * .5, radius, record.color)
            end
        end)
    end

    self:PostDrawChart(w, h)
end

function PANEL:PostDrawChart(w, h)

end

function PANEL:PerformChart(w, h)
    local data = self:GetData()
    local startAngle = 0
    local radius = math.min(w, h) * self:GetRadius()

    for _, record in ipairs(data) do
        if (not record.fraction) then break end

        local segmentAngle = math.Round(record.fraction * CIRCLE_FULL_ANGLE)

        record.poly = vox.CalculateArc(w * .5, h * .5, startAngle, segmentAngle, radius + 2, 24, true)

        startAngle = startAngle + segmentAngle
    end
end

vox.gui.Register('vox.PieChart', PANEL)

--[[------------------------------
DEBUG
--------------------------------]]
-- vox.gui.Test('vox.Frame', .65, .65, function(self, w, h)
--     self:MakePopup()
--     local content = self:Add('vox.PieChart')
--     content:DockPadding(10, 10, 10, 10)
--     content:Dock(FILL)
--     -- content:SetLegendVisible(false)
--     content:AddRecord('Apple', 10, Color(220, 31, 31))
--     content:AddRecord('Pear', 10, Color(113, 193, 78))
--     content:AddRecord('Banana', 5, Color(255, 224, 48))
--     content:AddRecord('Orange', 2, Color(255, 143, 15))
--     content:SetDonut(true)
-- end)
