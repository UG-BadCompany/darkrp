--[[

Author: tochnonement
Email: tochnonement@gmail.com

18/04/2022

--]]

local TRAIT = {}

AccessorFunc(TRAIT, 'm_colIdle', 'ColorIdle')
AccessorFunc(TRAIT, 'm_colHover', 'ColorHover')
AccessorFunc(TRAIT, 'm_colPressed', 'ColorPressed')
AccessorFunc(TRAIT, 'm_bHoverBlocked', 'HoverBlocked')

local ANIM_DURATION = .2

local function isDisabled(panel)
    if panel.GetDisabled then
        return panel:GetDisabled()
    end
end

local function animColor(panel, targetkey, duration)
    local key = panel.m_ColorKey

    onyx.anim.Create(panel, duration or ANIM_DURATION, {
        index = onyx.anim.ANIM_HOVER,
        target = {
            [key] = panel[targetkey]
        }
    })
end

function TRAIT:SetColorKey(colorKey)
    self.m_ColorKey = colorKey
end

function TRAIT:SetColorIdle(color, offset)
    self.m_colIdle = color
    self[self.m_ColorKey] = onyx.CopyColor(color)

    if (offset) then
        self:SetColorHover(onyx.OffsetColor(color, offset))
    end
end

function TRAIT:OnPress()
    if isDisabled(self) then return end
    if self:GetHoverBlocked() then return end

    animColor(self, 'm_colPressed')
end

function TRAIT:OnRelease()
    if isDisabled(self) then return end
    if self:GetHoverBlocked() then return end
    if self:IsHovered() then
        animColor(self, 'm_colHover')
    end
end

function TRAIT:OnCursorEntered()
    if isDisabled(self) then return end
    if self:GetHoverBlocked() then return end

    animColor(self, 'm_colHover')
end

function TRAIT:OnCursorExited()
    if isDisabled(self) then return end
    if self:GetHoverBlocked() then return end

    animColor(self, 'm_colIdle')
end

onyx.trait.Register('hovercolor', TRAIT)