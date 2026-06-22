-- by p1ng :D

local COLOR_PRIMARY = onyx:Config('colors.primary')
local COLOR_SECONDARY = onyx:Config('colors.secondary')
local COLOR_TERTIARY = onyx:Config('colors.tertiary')
local COLOR_ACCENT = onyx:Config('colors.accent')
local COLOR_GRAY = Color(149, 149, 149)

--[[------------------------------
// ANCHOR Frame
--------------------------------]]
local PANEL = {}

function PANEL:Init()
    self:SetTitle(onyx.utf8.upper(onyx.scoreboard:GetOptionValue('title')))

    self.blur = onyx.scoreboard.IsBlurActive()

    self.container = self:Add('onyx.Panel')

    self.sidebar = self:Add('onyx.MiniSidebar')
    self.sidebar:SetContainer(self.container)
    self.sidebar:SetWide(onyx.ScaleTall(45)) -- it's important to set width at this point

    self.sidebar:AddTab({
        name = '<PLAYERS>',
        desc = '',
        icon = 'https://i.imgur.com/1dE2q2H.png',
        class = 'onyx.Scoreboard.PlayerList'
    })

    CAMI.PlayerHasAccess(LocalPlayer(), 'onyx_scoreboard_edit', function(bAllowed)
        if (bAllowed) then
            self.sidebar:AddTab({
                name = '<ADMIN>',
                desc = '',
                icon = 'https://i.imgur.com/l4M12dO.png',
                onClick = function()
                    onyx.scoreboard.OpenAdminSettings()
                    self:Remove()
                    return false
                end
            })
        end
    end)

    self.sidebar:ChooseTab(1)
end

function PANEL:PerformLayout(w, h)
    local margin = onyx.ScaleTall(10)

    self.BaseClass.PerformLayout(self, w, h)

    self.container:Dock(FILL)
    self.container:DockMargin(margin, margin, margin, margin)

    self.sidebar:Dock(LEFT)
end

function PANEL:Paint(w, h)
    if (self.blur) then
        onyx.DrawBlurExpensive(self, 9)
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(onyx.ColorBetween(COLOR_PRIMARY, color_black), 230))
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

onyx.gui.Register('onyx.Scoreboard.Frame', PANEL, 'onyx.Frame')

--[[------------------------------
// ANCHOR Debug
--------------------------------]]
-- onyx.gui.Test('onyx.Scoreboard.Frame', .6, .6, function(self)
--     onyx.scoreboard.Frame = self
--     self:Center()
--     self:MakePopup()
-- end)