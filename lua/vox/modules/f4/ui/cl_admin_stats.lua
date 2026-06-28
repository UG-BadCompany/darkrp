local fallbackAdminColors = {
    primary = Color(8, 19, 38),
    secondary = Color(12, 32, 62),
    tertiary = Color(16, 42, 78),
    accent = Color(70, 135, 255),
    money = Color(35, 225, 120),
    negative = Color(255, 75, 95),
    text = Color(238, 244, 255),
    muted = Color(145, 160, 178)
}

local L = function(...) return vox.lang:Get(...) end
local function getThemeColors()
    if vox.f4 and vox.f4.GetReferenceColors then
        local colors = vox.f4.GetReferenceColors()
        return colors.bg, colors.card, colors.card2, colors.accent, colors.text, colors.muted
    end

    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackAdminColors.primary, colors.secondary or fallbackAdminColors.secondary, colors.secondary or fallbackAdminColors.secondary, colors.accent or fallbackAdminColors.accent, colors.textPrimary or fallbackAdminColors.text, colors.textSecondary or fallbackAdminColors.muted
end

local ADMIN_ACTIONS = {
    { label = 'Bring', id = 'bring' },
    { label = 'Goto', id = 'goto' },
    { label = 'Return', id = 'returnply' },
    { label = 'Freeze', id = 'freeze' },
    { label = 'Warn', id = 'warn', prompt = true, desc = 'Enter a warning reason.' },
    { label = 'Kick', id = 'kick', prompt = true, desc = 'Enter a kick reason.' },
    {
        label = 'DRC Compliance (Jail)',
        id = 'drc_compliance',
        prompt = true,
        desc = 'Enter DRC jail reason and optional seconds. Example: failrp 180',
        fallbackReason = 'general',
        fallbackDuration = 180
    },
    { label = 'Slay', id = 'slay' }
}

local function notifyActionError(text)
    if notification and notification.AddLegacy then
        notification.AddLegacy(text, NOTIFY_ERROR, 4)
    end
end

local function runAdminAction(panel, action)
    local ply = panel.selectedPlayer
    if not IsValid(ply) then
        notifyActionError('Select a player first.')
        return
    end

    if vox.admin and vox.admin.OpenPlayerAction then
        vox.admin.OpenPlayerAction(ply, action.id, {
            prompt = action.prompt,
            title = action.label,
            desc = action.desc and (action.desc .. ' Target: ' .. ply:Nick()) or ('Run ' .. action.label .. ' on ' .. ply:Nick() .. '?'),
            fallbackReason = action.fallbackReason,
            fallbackDuration = action.fallbackDuration,
            acceptText = action.label
        })
        return
    end

    RunConsoleCommand('vox_admin_action', action.id, ply:SteamID(), '', '0')
end

do
    local PANEL = {}

    function PANEL:Init()
        self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))

        self.nav = self:Add('Panel')
        self.nav:Dock(LEFT)
        self.nav:SetWide(vox.ScaleWide(172))
        self.nav:DockMargin(0, 0, vox.ScaleWide(12), 0)
        self.nav.Paint = function(_, w, h)
            local primary, secondary, _, accent, text = getThemeColors()
            if vox.f4 and vox.f4.DrawReferencePanel then
                vox.f4.DrawReferencePanel(0, 0, w, h, { color = secondary, accent = accent, radius = 8 })
            else
                draw.RoundedBox(8, 0, 0, w, h, primary)
                surface.SetDrawColor(ColorAlpha(accent, 58))
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            draw.SimpleText('ADMIN PANEL', vox.Font('Comfortaa Bold@14'), vox.ScaleWide(14), vox.ScaleTall(16), text, 0, 0)
        end

        self.activeSection = 'Player Management'
        local navItems = {'Player Management', 'Player Actions', 'Player Info', 'Bans', 'Logs', 'Reports', 'Commands', 'Settings'}
        for index, label in ipairs(navItems) do
            local btn = self.nav:Add('DButton')
            btn:Dock(TOP)
            btn:DockMargin(vox.ScaleWide(10), index == 1 and vox.ScaleTall(48) or 0, vox.ScaleWide(10), vox.ScaleTall(6))
            btn:SetTall(vox.ScaleTall(30))
            btn:SetText('')
            btn.Paint = function(panel, w, h)
                local _, _, _, accent, text = getThemeColors()
                local active = self.activeSection == label
                draw.RoundedBox(7, 0, 0, w, h, ColorAlpha(accent, panel:IsHovered() and 38 or (active and 30 or 12)))
                draw.SimpleText(label, vox.Font('Comfortaa Bold@11'), vox.ScaleWide(10), h * .5, text, 0, 1)
            end
            btn.DoClick = function()
                self.activeSection = label
                if label == 'Player Management' or label == 'Player Actions' then
                    self:BuildPlayerManagement()
                elseif label == 'Settings' then
                    self:BuildSettings()
                else
                    self:BuildPlaceholder(label)
                end
            end
        end

        self.content = self:Add('Panel')
        self.content:Dock(FILL)
        self:BuildPlayerManagement()
    end

    function PANEL:AddAdminBlock(parent, title)
        local block = parent:Add('Panel')
        block.Paint = function(_, w, h)
            local primary, secondary, _, accent, text = getThemeColors()
            if vox.f4 and vox.f4.DrawReferencePanel then
                vox.f4.DrawReferencePanel(0, 0, w, h, { color = secondary, accent = accent, radius = 8 })
            else
                draw.RoundedBox(8, 0, 0, w, h, primary)
                surface.SetDrawColor(ColorAlpha(accent, 58))
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            draw.SimpleText(title, vox.Font('Comfortaa Bold@15'), vox.ScaleWide(14), vox.ScaleTall(12), text, 0, 0)
            surface.SetDrawColor(ColorAlpha(accent, 80))
            surface.DrawRect(vox.ScaleWide(14), vox.ScaleTall(36), w - vox.ScaleWide(28), 1)
        end
        return block
    end

    function PANEL:BuildPlayerManagement()
        local content = self.content
        content:Clear()
        self.selectedPlayer = IsValid(self.selectedPlayer) and self.selectedPlayer or player.GetAll()[1]

        local header = self:AddAdminBlock(content, 'Player Management')
        header:Dock(TOP)
        header:SetTall(vox.ScaleTall(72))
        header:DockMargin(0, 0, 0, vox.ScaleTall(10))
        header.PaintOver = function(_, w, h)
            local _, _, _, accent, _, muted = getThemeColors()
            draw.SimpleText('Online staff tools, player status, and moderation shortcuts.', vox.Font('Comfortaa@13'), vox.ScaleWide(14), vox.ScaleTall(46), muted, 0, 0)
            draw.SimpleText(#player.GetAll() .. ' ONLINE', vox.Font('Comfortaa Bold@12'), w - vox.ScaleWide(16), vox.ScaleTall(22), accent, 2, 1)
            draw.SimpleText(IsValid(self.selectedPlayer) and ('TARGET: ' .. self.selectedPlayer:Nick()) or 'NO TARGET SELECTED', vox.Font('Comfortaa Bold@11'), w - vox.ScaleWide(16), vox.ScaleTall(48), muted, 2, 1)
        end

        local actions = self:AddAdminBlock(content, 'Player Actions')
        actions:Dock(RIGHT)
        actions:SetWide(vox.ScaleWide(230))
        actions:DockMargin(vox.ScaleWide(10), 0, 0, 0)
        for index, action in ipairs(ADMIN_ACTIONS) do
            local row = actions:Add('DButton')
            row:Dock(TOP)
            row:DockMargin(vox.ScaleWide(12), index == 1 and vox.ScaleTall(48) or 0, vox.ScaleWide(12), vox.ScaleTall(7))
            row:SetTall(vox.ScaleTall(34))
            row:SetText('')
            row.Paint = function(panel, w, h)
                local _, secondary, _, accent = getThemeColors()
                draw.RoundedBox(7, 0, 0, w, h, ColorAlpha(secondary, panel:IsHovered() and 240 or 210))
                surface.SetDrawColor(ColorAlpha(accent, panel:IsHovered() and 88 or 35))
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                local _, _, _, _, text = getThemeColors()
                draw.SimpleText(action.label, vox.Font('Comfortaa Bold@12'), vox.ScaleWide(12), h * .5, text, 0, 1)
                draw.SimpleText('›', vox.Font('Comfortaa Bold@18'), w - vox.ScaleWide(12), h * .5, accent, 2, 1)
            end
            row.DoClick = function() runAdminAction(self, action) end
        end

        local list = self:AddAdminBlock(content, 'Players')
        list:Dock(FILL)
        local scroll = list:Add('vox.ScrollPanel')
        scroll:Dock(FILL)
        scroll:DockMargin(vox.ScaleWide(12), vox.ScaleTall(48), vox.ScaleWide(12), vox.ScaleTall(12))

        for _, ply in ipairs(player.GetAll()) do
            local row = scroll:Add('DButton')
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, vox.ScaleTall(7))
            row:SetTall(vox.ScaleTall(44))
            row:SetText('')
            row.DoClick = function()
                self.selectedPlayer = ply
            end
            row.Paint = function(panel, w, h)
                local _, secondary, _, accent = getThemeColors()
                local selected = self.selectedPlayer == ply
                draw.RoundedBox(8, 0, 0, w, h, selected and ColorAlpha(accent, 42) or ColorAlpha(secondary, panel:IsHovered() and 245 or 235))
                if selected or panel:IsHovered() then
                    surface.SetDrawColor(ColorAlpha(accent, selected and 140 or 80))
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end
                draw.RoundedBox(6, vox.ScaleWide(10), vox.ScaleTall(9), vox.ScaleTall(26), vox.ScaleTall(26), ColorAlpha(accent, 35))
                draw.SimpleText(string.sub(ply:Nick() or '?', 1, 1), vox.Font('Comfortaa Bold@14'), vox.ScaleWide(23), h * .5, fallbackAdminColors.text, 1, 1)
                draw.SimpleText(ply:Nick(), vox.Font('Comfortaa Bold@13'), vox.ScaleWide(46), vox.ScaleTall(10), fallbackAdminColors.text, 0, 0)
                draw.SimpleText(team.GetName(ply:Team()) or 'Unknown', vox.Font('Comfortaa@11'), vox.ScaleWide(46), vox.ScaleTall(25), fallbackAdminColors.muted, 0, 0)
                draw.SimpleText(ply:IsAdmin() and 'STAFF' or 'PLAYER', vox.Font('Comfortaa Bold@10'), w - vox.ScaleWide(14), h * .5, ply:IsAdmin() and fallbackAdminColors.accent or fallbackAdminColors.muted, 2, 1)
            end
        end
    end


    function PANEL:BuildPlaceholder(title)
        local content = self.content
        content:Clear()
        local block = self:AddAdminBlock(content, title)
        block:Dock(FILL)
        block.PaintOver = function(_, w, h)
            local _, _, _, accent, text, muted = getThemeColors()
            draw.SimpleText(title, vox.Font('Comfortaa Bold@22'), vox.ScaleWide(18), vox.ScaleTall(58), text, 0, 0)
            draw.SimpleText('This admin section is wired into the F4 tab and ready for server-specific command hooks.', vox.Font('Comfortaa@14'), vox.ScaleWide(18), vox.ScaleTall(88), muted, 0, 0)
            draw.SimpleText('Use Player Management for live player tools or Settings for real F4 configuration.', vox.Font('Comfortaa@13'), vox.ScaleWide(18), vox.ScaleTall(112), accent, 0, 0)
        end
    end

    function PANEL:BuildSettings()
        local content = self.content
        content:Clear()
        local block = self:AddAdminBlock(content, 'F4 Settings')
        block:Dock(FILL)
        local config = block:Add('vox.Configuration')
        config:Dock(FILL)
        config:DockMargin(vox.ScaleWide(12), vox.ScaleTall(48), vox.ScaleWide(12), vox.ScaleTall(12))
        config:LoadAddonSettings('f4')
        config:OpenCategories()
    end

    vox.gui.Register('vox.f4.AdminStats', PANEL)
end
