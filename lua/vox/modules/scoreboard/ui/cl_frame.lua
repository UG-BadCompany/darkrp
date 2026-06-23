local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_TERTIARY = vox:Config('colors.tertiary')
local COLOR_ACCENT = vox:Config('colors.accent')
local COLOR_GRAY = Color(149, 149, 149)

local PANEL = {}

function PANEL:Init()
    self:SetTitle('VOX SCOREBOARD')

    self.blur = vox.scoreboard.IsBlurActive()

    self:SetAlpha(0)
    self:AlphaTo(255, .16, 0)
    self:SetSize(ScrW() * .86, ScrH() * .82)
    self:Center()

    self.container = self:Add('vox.Panel')

    self.sidebar = self:Add('vox.MiniSidebar')
    self.sidebar:SetContainer(self.container)
    self.sidebar:SetWide(vox.ScaleTall(64)) -- it's important to set width at this point

    self.sidebar:AddTab({
        name = '<PLAYERS>',
        desc = '',
        icon = 'https://i.imgur.com/1dE2q2H.png',
        class = 'vox.Scoreboard.PlayerList'
    })

    CAMI.PlayerHasAccess(LocalPlayer(), 'vox_scoreboard_edit', function(bAllowed)
        if (bAllowed) then
            self.sidebar:AddTab({
                name = '<ADMIN>',
                desc = '',
                icon = 'https://i.imgur.com/l4M12dO.png',
                onClick = function()
                    vox.scoreboard.OpenAdminSettings()
                    self:Remove()
                    return false
                end
            })
        end
    end)

    self.sidebar:ChooseTab(1)
end

function PANEL:PerformLayout(w, h)
    local margin = vox.ScaleTall(10)

    self.BaseClass.PerformLayout(self, w, h)

    self.container:Dock(FILL)
    self.container:DockMargin(margin, vox.ScaleTall(76), margin, margin)
    self.container.Paint = function(_, cw, ch)
        vox.DrawVoxGlass(0, 0, cw, ch, { radius = 22, alpha = 238, accent = COLOR_ACCENT })
        vox.DrawVoxCornerTicks(vox.ScaleWide(16), vox.ScaleTall(16), cw - vox.ScaleWide(32), ch - vox.ScaleTall(32), ColorAlpha(COLOR_ACCENT, 70), vox.ScaleWide(30))
    end

    self.sidebar:Dock(LEFT)
end

function PANEL:Paint(w, h)
    if (self.blur) then
        vox.DrawBlurExpensive(self, 9)
    end

    local t = vox.ThemeTokens and vox.ThemeTokens() or {}
    local accent = t.accent or COLOR_ACCENT
    vox.ui.DrawGlassPanel(0, 0, w, h, { radius = 24, alpha = 244, accent = accent, glow = 34 })
    vox.DrawVoxCornerTicks(vox.ScaleWide(18), vox.ScaleTall(18), w - vox.ScaleWide(36), h - vox.ScaleTall(36), ColorAlpha(accent, 85), vox.ScaleWide(32))
    draw.SimpleText('VOX SCOREBOARD', vox.Font('Comfortaa Bold@20'), vox.ScaleWide(32), vox.ScaleTall(28), t.text or color_white, 0, 1)
    draw.SimpleText('Search, sort, inspect and manage every player online', vox.Font('Comfortaa@13'), vox.ScaleWide(32), vox.ScaleTall(52), t.textSoft or COLOR_GRAY, 0, 1)
end

function PANEL:Think()
    if (self.closeDisabled) then
        local bindButtonName = input.LookupBinding('+showscores', true)
        local bindButtonInt = bindButtonName and input.GetKeyCode(bindButtonName)
        if (not bindButtonInt) then return end

        local newState = input.IsKeyDown(bindButtonInt)
        if (self.oldState == nil) then
            self.oldState = newState
        elseif (self.oldState ~= newState) then
            if (newState) then
                self:Remove()
            end
            self.oldState = newState
        end
    end
end

vox.gui.Register('vox.Scoreboard.Frame', PANEL, 'VoxRootFrame')

-- Vox local preview helper
-- vox.gui.Test('vox.Scoreboard.Frame', .6, .6, function(self)
--     vox.scoreboard.Frame = self
--     self:Center()
--     self:MakePopup()
-- end)
