--[[

Author: tochnonement
Email: tochnonement@gmail.com

22/04/2023

--]]

local PANEL = {}

local colorPrimary = vox:Config('colors.primary')
local colorSecondary = vox:Config('colors.secondary')
local colorAccent = vox:Config('colors.accent')
local colorGray = Color(125, 125, 125)
local MAT_ARROW = Material('vox_framework/tick.png', 'smooth mips')

AccessorFunc(PANEL, 'm_CurrentOptionText', 'CurrentOptionText')
AccessorFunc(PANEL, 'm_Font', 'Font')
AccessorFunc(PANEL, 'm_colOutlineActiveColor', 'OutlineActiveColor')
AccessorFunc(PANEL, 'm_colOutlineIdleColor', 'OutlineIdleColor')
AccessorFunc(PANEL, 'm_bHideOptionIcon', 'HideOptionIcon')

function PANEL:Init()
    self:Import('click')
    self:Import('hovercolor')
    self:SetTall(vox.ScaleTall(30))

    self:SetColorKey('backgroundColor')
    self:SetColorIdle(colorPrimary)
    self:SetColorHover(vox.OffsetColor(self:GetColorIdle(), -5))

    self:SetFont(vox.Font('Comfortaa@16'))

    self:SetOutlineIdleColor(colorSecondary)
    self:SetOutlineActiveColor(colorAccent)
    self:Reset()

    self.options = {}
end

function PANEL:SetOutlineIdleColor(color)
    self.m_colOutlineIdleColor = color
    self.currentOutlineColor = vox.CopyColor(color)
end

function PANEL:Paint(w, h)
    local thickness = 1
    local currentOutlineColor = self.currentOutlineColor

    if (self.highlight) then
        currentOutlineColor = ColorAlpha(self.highlightColor, math.abs(math.sin(CurTime() * 6)) * 200 + 55)
        if (self.highlightEndTime and self.highlightEndTime <= CurTime()) then
            self:ResetHighlight()
        end
    end

    draw.RoundedBox(8, 0, 0, w, h, currentOutlineColor)
    draw.RoundedBox(8, thickness, thickness, w - thickness * 2, h - thickness * 2, self.backgroundColor)

    local x = vox.ScaleWide(10)
    local material = self.mat

    if (material and self.current > 0 and not self.m_bHideOptionIcon) then
        local size = vox.ScaleTall(12)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(material)
        surface.DrawTexturedRect(x, h * .5 - size * .5, size, size)

        x = x + size + vox.ScaleWide(5)
    end

    draw.SimpleText(self.m_CurrentOptionText, self.m_Font, x, h * .5, self.current > 0 and color_white or colorGray, 0, 1)

    local sz = math.floor(h * .33)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(MAT_ARROW)
    surface.DrawTexturedRectRotated(w - h * .5, h * .5, sz, sz, 0)
end

function PANEL:AddOption(text, data, bSelectedDefault, mat, url)
    return self:AddOptionAdvanced({
        text = text,
        data = data,
        bSelectedDefault = bSelectedDefault,
        mat = mat
    })
end

function PANEL:AddOptionAdvanced(tblOption)
    return table.insert(self.options, tblOption)
end

function PANEL:ChooseOptionID(index, bIgnoreProcessing)
    local option = self.options[index]
    assert(option, 'trying to set invalid option (index:' .. index .. ')')

    self:SetCurrentOptionText(option.text)
    self.current = index

    if (option.iconURL) then
        self.wimage = vox.wimg.Simple(option.iconURL, option.iconParams)
    else
        self.wimage = nil
    end

    if (not bIgnoreProcessing) then
        self:Call('OnSelect', nil, index, option.text, option.data)
    end
end

function PANEL:GetSelectedID()
    return self.current
end

function PANEL:GetOptionData(index)
    index = index or self.current

    local option = self.options[index]
    if (option) then
        return option.data
    end
end

function PANEL:GetOptionText(index)
    index = index or self.current

    local option = self.options[index]
    if (option) then
        return option.text
    end
end

function PANEL:Reset()
    self.current = -1
    self.wimage = nil
    if (vox.lang) then
        self:SetCurrentOptionText(vox.lang:Get('Select an option'))
    else
        self:SetCurrentOptionText('Select an option')
    end
    if (IsValid(self.dmenu)) then
        self.dmenu:Close()
    end
end

function PANEL:Clear()
    self.options = {}
    self:Reset()
end

function PANEL:GetOptions()
    return self.options
end

function PANEL:FindOptionByData(data)
    for index, option in ipairs(self.options) do
        if (option.data and option.data == data) then
            return option, index
        end
    end
end

function PANEL:DoClick()
    if (self.active) then
        return
    end

    self:ResetHighlight()

    local x, y = self:LocalToScreen(0, 0)

    local dmenu = vgui.Create('vox.Menu')
    dmenu:SetPos(x, y + self:GetTall())
    dmenu:SetMinimumWidth(self:GetWide())
    dmenu.parent = self
    dmenu.Think = function(panel)
        local parent = panel.parent
        if (IsValid(parent)) then
            local x, y = parent:LocalToScreen(0, 0)
            local targetY = y + parent:GetTall()
            if (dmenu:GetY() ~= targetY) then
                dmenu:Close()
            end
            -- dmenu:SetPos(x, targetY)
        end
    end

    for index, option in ipairs(self.options) do
        local opt = dmenu:AddOption(option.text, function()
            self:ChooseOptionID(index)
        end)

        if (option.iconURL) then
            opt:SetIconURL(option.iconURL, option.iconParams)
        end
    end

    dmenu:Open()

    self.dmenu = dmenu
end

function PANEL:SetActive(bBool)
    self.active = bBool
    vox.anim.Simple(self, .2, {
        currentOutlineColor = (bBool and self.m_colOutlineActiveColor or self.m_colOutlineIdleColor)
    }, 1)
end

function PANEL:Think()
    local bRealActive = IsValid(self.dmenu)
    if (bRealActive ~= self.active) then
        self:SetActive(bRealActive)
    end
end

function PANEL:OnRemove()
    if (IsValid(self.dmenu)) then
        self.dmenu:Remove()
    end
end

function PANEL:OnDisabled()
    local offset = -5
    self.voxAnims = nil
    self:SetColorIdle(vox.OffsetColor(colorPrimary, offset))
    self:SetColorHover(vox.OffsetColor(self:GetColorIdle(), -5 + offset))
end

function PANEL:OnEnabled()
    local offset = 0
    self.voxAnims = nil
    self:SetColorIdle(vox.OffsetColor(colorPrimary, offset))
    self:SetColorHover(vox.OffsetColor(self:GetColorIdle(), -5 + offset))
end

function PANEL:Highlight(color, time)
    self.highlightColor = color
    self.highlightStartTime = CurTime()
    if (time) then
        self.highlightEndTime = CurTime() + time
    end
    self.highlight = true
end

function PANEL:ResetHighlight()
    self.highlightColor = nil
    self.highlightStartTime = nil
    self.highlightEndTime = nil
    self.highlight = nil
end

vox.gui.Register('vox.ComboBox', PANEL)
