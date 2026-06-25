local fallbackF4ItemColors = {
    primary = Color(8, 19, 38),
    secondary = Color(12, 32, 62),
    tertiary = Color(16, 42, 78),
    accent = Color(70, 135, 255)
}
local colorOutline = Color(255, 255, 255, 5)
local colorGray = Color(159, 159, 159)
local fontDesc = vox.Font('Comfortaa@16')
local colorFavoriteIconIdle = Color(235, 235, 235)
local colorFavoriteIconActive = Color(255, 241, 93)

local function getThemeColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackF4ItemColors.primary, colors.secondary or fallbackF4ItemColors.secondary, colors.tertiary or fallbackF4ItemColors.tertiary, colors.accent or fallbackF4ItemColors.accent
end

local PANEL = {}

function PANEL:Init()
    self.padding = vox.ScaleTall(7.5)
    local themePrimary, themeSecondary, _, themeAccent = getThemeColors()
    self.itemColor = themeAccent
    self.itemColorBG = themePrimary
    self.colorBG = themeSecondary
    self.colorBGGradient = ColorAlpha(themeAccent, 25)
    self.gradientEnabled = vox.f4:GetOptionValue('colored_items')

    self.iconContainer = self:Add('Panel')
    self.iconContainer:SetMouseInputEnabled(false)
    self.iconContainer.PerformLayout = function(panel, w, h)
        panel.mask = vox.CalculateCircle(w * .5, h * .5, h * .5 - 2, 24)
    end
    self.iconContainer.Paint = function(panel, w, h)
        local child = panel:GetChild(0)
        if (IsValid(child)) then
            vox.DrawCircle(w * .5, h * .5, h * .5, self.itemColorBG)

            vox.DrawWithPolyMask(panel.mask, function()
                child:PaintManual()
            end)

            vox.DrawOutlinedCircle(w * .5, h * .5, h * .5, 3, self.itemColor)
        end
    end

    if (vox.f4:GetOptionValue('model_3d')) then
        self.iconModel = self.iconContainer:Add('DModelPanel')
        self.iconModel.LayoutEntity = function() end
        self.iconModel.PreDrawModel = function(panel)
            if (surface.GetAlphaMultiplier() < .5) then
                return false
            end
        end
    else
        self.iconModel = self.iconContainer:Add('SpawnIcon')
    end
    self.iconModel:Dock(FILL)
    self.iconModel:SetPaintedManually(true)
    self.iconModel:DockMargin(2, 2, 2, 2)

    self.lblName = self:Add('vox.Label')
    self.lblName:SetText('Name')
    self.lblName:Font('Comfortaa Bold@18')
    self.lblName:SetContentAlignment(1)

    self.pnlDesc = self:Add('Panel')
    self.pnlDesc:SetMouseInputEnabled(false)
    self.pnlDesc.label = ''
    self.pnlDesc.text = ''
    self.pnlDesc.color = ''
    self.pnlDesc.Paint = function(panel, w, h)
        local label = panel.label:Trim()
        if (label ~= '') then
            local textW = draw.SimpleText(label .. ': ', fontDesc, 0, 0, colorGray, 0, 0)
            draw.SimpleText(panel.text, fontDesc, textW, 0, panel.color, 0, 0)
        else
            draw.SimpleText(panel.text, fontDesc, 0, 0, panel.color, 0, 0)
        end
    end
end

function PANEL:GetName()
    return self.lblName:GetText()
end

function PANEL:SetDescLabel(label)
    self.pnlDesc.label = label
end

function PANEL:SetDesc(desc)
    self.pnlDesc.text = desc
end

function PANEL:SetDescColor(label)
    self.pnlDesc.color = label
end

function PANEL:SetColor(color, bgFraction)
    self.itemColor = color
    if (bgFraction) then
        local _, themeSecondary = getThemeColors()
        self.colorBGGradient = ColorAlpha(self.itemColor, 14)
        self.itemColorBG = vox.LerpColor(math.min(bgFraction or .08, .1), themeSecondary, vox.CopyColor(self.itemColor))
    end
end

function PANEL:PerformLayout(w, h)
    local padding = self.padding
    local height = h - padding * 2
    local btnFavorite = self.btnFavorite

    self:DockPadding(padding, padding, padding, padding)
    self.mask = vox.CalculateRoundedBox(8, 1, 1, w - 2, h - 2)

    self.iconContainer:Dock(LEFT)
    self.iconContainer:SetWide(height)
    self.iconContainer:DockMargin(0, 0, vox.ScaleWide(10), 0)

    self.lblName:Dock(TOP)
    self.lblName:SetTall(height * .5)

    self.pnlDesc:Dock(FILL)

    if (IsValid(btnFavorite) and btnFavorite:IsVisible()) then
        btnFavorite:Dock(RIGHT)
        btnFavorite:SetZPos(-1)
        btnFavorite:SetWide(height)
    end
end

function PANEL:Paint(w, h)
    local themePrimary, themeSecondary, themeTertiary, themeAccent = getThemeColors()
    local accent = self.itemColor or themeAccent
    local bg = self.colorBG or themeSecondary

    if vox.DrawVoxPanel then
        vox.DrawVoxPanel(0, 0, w, h, { primary = bg, secondary = themePrimary, accent = themeAccent }, 8)
        if (self:IsHovered()) then
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, ColorAlpha(themeAccent, 18))
            surface.SetDrawColor(ColorAlpha(themeAccent, 105))
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
        end
    else
        draw.RoundedBox(8, 0, 0, w, h, colorOutline)
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, bg)
    end

    if (self.gradientEnabled) then
        vox.DrawWithPolyMask(self.mask, function()
            vox.DrawMatGradient(0, 0, w, h, TOP, self.colorBGGradient)
        end)
    end
end

function PANEL:SetModel(modelPath)
    self.iconModel:SetModel(modelPath)
end

function PANEL:SetName(name)
    self.lblName:SetText(name)
end

local AXIS = {'x', 'y', 'z'}
function PANEL:PositionCamera(pos)
    local iconModel = self.iconModel

    if (not IsValid(iconModel)) then return end
    if (iconModel.ClassName ~= 'DModelPanel') then return end

    local ent = iconModel.Entity
    if (not IsValid(ent)) then return end

    if (pos == 'face') then
        local bone = ent:LookupBone('ValveBiped.Bip01_Head1')
        if (not bone) then return end

        local eyepos = ent:GetBonePosition(bone)
        eyepos:Add(Vector(0, 0, 2))

        iconModel:SetLookAt(eyepos)
        iconModel:SetCamPos(eyepos - Vector(-20, 0, 0))
        iconModel:SetFOV(45)

        ent:SetEyeTarget(eyepos - Vector(-20, 0, 0))
    elseif (pos == 'center') then
        local min, max = ent:GetRenderBounds()
        local center = (min + max) / 2
        local distance = 0

        for _, key in ipairs(AXIS) do
            distance = math.max(distance, max[key])
        end

        iconModel:SetLookAt(center)
        iconModel:SetFOV(distance + 10)
    end
end

function PANEL:AddFavoriteButton()
    self.btnFavorite = self:Add('vox.ImageButton')
    self.btnFavorite.SetState = function(panel, state, ignore)
        panel.bState = state

        if (not ignore and self.objectIdentifier) then
            vox.f4:SetFavorite(self.objectIdentifier, state)
        end

        local targetColor = state and colorFavoriteIconActive or colorFavoriteIconIdle

        if (state) then
            panel:SetImage('vox_f4menu/favorite_fill.png', 'smooth mips')
        else
            panel:SetImage('vox_f4menu/favorite_outline.png', 'smooth mips')
        end

        vox.anim.Create(panel, .33, {
            index = vox.anim.ANIM_HOVER,
            target = {
                m_colColor = targetColor
            }
        })

        self:Call('OnFavoriteStateSwitched', nil, state)
    end

    self.btnFavorite.m_Angle = 0
    self.btnFavorite.voxEvents['OnCursorEntered'] = nil
    self.btnFavorite.voxEvents['OnCursorExited'] = nil
    self.btnFavorite.voxEvents['OnRelease'] = nil
    self.btnFavorite.voxEvents['OnPress'] = nil
    self.btnFavorite:InstallRotationAnim()
    self.btnFavorite.m_iImageScale = .5
    self.btnFavorite.m_iImageScaleInitial = .5

    self.btnFavorite.DoClick = function(panel)
        panel:SetState(not panel.bState)
    end

    self.btnFavorite:SetState(vox.f4:IsFavorite(self.objectIdentifier), true)
end

vox.gui.Register('vox.f4.Item', PANEL)
