--[[

Author: tochnonement
Email: tochnonement@gmail.com

02/03/2024

--]]

local COLOR_PRIMARY = onyx:Config('colors.primary')
local COLOR_SECONDARY = onyx:Config('colors.secondary')
local COLOR_TERTIARY = onyx:Config('colors.tertiary')
local COLOR_ACCENT = onyx:Config('colors.accent')
local SHADOW_ALPHA = 200
local COLOR_SHADOW = Color(0, 0, 0, 100)
local COLOR_GRAY = Color(149, 149, 149)
local COLOR_GRAY_LIGHT = Color(198, 198, 198)
local SHADOW_DISTANCE = 2

--[[------------------------------
PANEL
--------------------------------]]
local PANEL = {}

AccessorFunc(PANEL, 'm_Font', 'Font')
AccessorFunc(PANEL, 'm_bHeader', 'Header')

function PANEL:Init()
    self.m_Font = onyx.Font('Comfortaa@16')
    self.columns = {}
end

function PANEL:InitColumns()
    local activeColumns = onyx.scoreboard:GetActiveColumns()

    self.columnsAmount = #activeColumns
    self.realColumnsAmount = self.columnsAmount - 2

    for index, column in ipairs(activeColumns) do
        self.columns[index] = self:CreateColumn(column, index)
    end
end

function PANEL:CreateColumn(data, index)
    local column = self:Add('onyx.Label')
    if (data.id == 'team' and DarkRP) then
        column:SetText(onyx.lang:Get('scoreboard_col_job'))
    else
        column:SetText(onyx.lang:Get(data.name))
    end

    column:SetFont(self.m_Font)
    column:CenterText()
    column:SetExpensiveShadow(SHADOW_DISTANCE, COLOR_SHADOW)
    column.data = data

    if (not data.small and self.realColumnsAmount == 1) then
        column:SetContentAlignment(4)
        column.TextLeft = true
    end

    if (self:GetHeader()) then
        column:SetTextColor(COLOR_GRAY)

        if (data.icon) then
            local wimgIcon = onyx.wimg.Simple(data.icon, 'smooth mips')
            column:SetText('')
            column.Paint = function(panel, w, h)
                local size = math.min(h, onyx.ScaleTall(16))
                local space = onyx.ScaleTall(5)
                local font = panel:GetFont()
                local textColor = panel:GetTextColor()
                local text = data.small and '' or data.name
                local textNotEmpty = text ~= ''
                local y0 = h * .5
                local x0 = w * .5
                local textW, textH

                if (textNotEmpty) then
                    surface.SetFont(font)
                    textW, textH = surface.GetTextSize(text)

                    local totalW = textW + size + space
                    local x = x0 - totalW * .5

                    wimgIcon:Draw(x + SHADOW_DISTANCE, y0 - size * .5 + SHADOW_DISTANCE, size, size, COLOR_SHADOW)
                    wimgIcon:Draw(x, y0 - size * .5, size, size, textColor)
                    draw.SimpleText(text, font, x + size + space, y0, textColor, 0, 1)
                else
                    wimgIcon:Draw(x0 - size * .5 + SHADOW_DISTANCE, y0 - size * .5 + SHADOW_DISTANCE, size, size, COLOR_SHADOW)
                    wimgIcon:Draw(x0 - size * .5, y0 - size * .5, size, size, textColor)
                end
            end
        end
    else
        if (data.buildFunc) then
            column:SetText('')
            column.NoText = true
            column.Paint = nil
        end
    end

    return column
end

function PANEL:SetValue(index, formattedValue, rawValue)
    local column = self:GetColumn(index)
    if (not column.NoText) then
        column:SetText(formattedValue)
    end
    column.TextValue = formattedValue -- if GetText got overrided
    column.Value = rawValue or formattedValue
end

function PANEL:SetColor(index, value)
    self:GetColumn(index):SetTextColor(value)
end

function PANEL:SetClickFunc(index, func)
    local column = self:GetColumn(index)
    column:Import('click')
    column.DoClick = func
    column.Think = function(panel)
        if (not panel.hoverBlocked) then
            panel:SetTextColor(panel:IsHovered() and color_white or COLOR_GRAY)
        end
    end
end

function PANEL:GetColumn(index)
    local column = self.columns[index]
    assert(column, 'Invalid column')
    return column
end

function PANEL:PerformLayout(w, h)
    local bEqual = false
    local widthLeft = 1
    local columnsAmount = #self.columns

    local smallWidth = w * .066
    local smallAmount = 0

    local bigAmount = 0
    local bigAreaWidth = w

    -- calculate sizes
    if (not bEqual) then
        for index = columnsAmount, 1, -1 do
            local column = self.columns[index]
            local data = column.data
            if (data.small) then
                smallAmount = smallAmount + 1
                bigAreaWidth = bigAreaWidth - smallWidth
            else
                bigAmount = bigAmount + 1
            end
        end
    end

    -- set sizes
    for index, column in ipairs(self.columns) do
        local width = not bEqual and math.Round(column.data.small and smallWidth or bigAreaWidth / bigAmount) or math.Round(w / columnsAmount)
        local side = bigAmount == 0 and RIGHT or LEFT
        local zpos = bigAmount == 0 and (columnsAmount - index) or index

        column:SetWide(width)
        column:SetZPos(zpos)
        column:Dock(side)
    end
end

onyx.gui.Register('onyx.Scoreboard.ColumnsRow', PANEL)