-- by p1ng :D

local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_TERTIARY = vox:Config('colors.tertiary')
local COLOR_ACCENT = vox:Config('colors.accent')
local COLOR_GRAY = Color(149, 149, 149)

--[[------------------------------
// ANCHOR Frame
--------------------------------]]
local PANEL = {}

function PANEL:Init()
    self:SetTitle(vox.utf8.upper(vox.scoreboard:GetOptionValue('title')))

    self.blur = vox.scoreboard.IsBlurActive()

    self.container = self:Add('vox.Panel')

    self.sidebar = self:Add('vox.MiniSidebar')
    self.sidebar:SetContainer(self.container)
    self.sidebar:SetWide(vox.ScaleTall(45)) -- it's important to set width at this point

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
    self.container:DockMargin(margin, margin, margin, margin)

    self.sidebar:Dock(LEFT)
end

function PANEL:Paint(w, h)
    if (self.blur) then
        vox.DrawBlurExpensive(self, 9)
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(vox.ColorBetween(COLOR_PRIMARY, color_black), 230))
    else
        self.BaseClass.Paint(self, w, h)
    end
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

vox.gui.Register('vox.Scoreboard.Frame', PANEL, 'vox.Frame')

--[[------------------------------
// ANCHOR Debug
--------------------------------]]
-- vox.gui.Test('vox.Scoreboard.Frame', .6, .6, function(self)
--     vox.scoreboard.Frame = self
--     self:Center()
--     self:MakePopup()
-- end)
