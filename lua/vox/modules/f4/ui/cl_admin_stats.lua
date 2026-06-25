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
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackAdminColors.primary, colors.secondary or fallbackAdminColors.secondary, colors.tertiary or fallbackAdminColors.tertiary, colors.accent or fallbackAdminColors.accent
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
            local primary, secondary, _, accent = getThemeColors()
            vox.DrawVoxPanel(0, 0, w, h, { primary = primary, secondary = secondary, accent = accent }, 10)
            draw.SimpleText('ADMIN PANEL', vox.Font('Comfortaa Bold@14'), vox.ScaleWide(14), vox.ScaleTall(16), fallbackAdminColors.text, 0, 0)
        end

        local navItems = {'Player Management', 'Player Actions', 'Player Info', 'Bans', 'Logs', 'Reports', 'Commands', 'Settings'}
        for index, label in ipairs(navItems) do
            local btn = self.nav:Add('DButton')
            btn:Dock(TOP)
            btn:DockMargin(vox.ScaleWide(10), index == 1 and vox.ScaleTall(48) or 0, vox.ScaleWide(10), vox.ScaleTall(6))
            btn:SetTall(vox.ScaleTall(30))
            btn:SetText('')
            btn.Paint = function(panel, w, h)
                local _, _, _, accent = getThemeColors()
                draw.RoundedBox(7, 0, 0, w, h, ColorAlpha(accent, panel:IsHovered() and 38 or (index == 1 and 30 or 12)))
                draw.SimpleText(label, vox.Font('Comfortaa Bold@11'), vox.ScaleWide(10), h * .5, fallbackAdminColors.text, 0, 1)
            end
        end

        self.content = self:Add('Panel')
        self.content:Dock(FILL)
        self:BuildPlayerManagement()
    end

    function PANEL:AddAdminBlock(parent, title)
        local block = parent:Add('Panel')
        block.Paint = function(_, w, h)
            local primary, secondary, _, accent = getThemeColors()
            vox.DrawVoxPanel(0, 0, w, h, { primary = primary, secondary = secondary, accent = accent }, 10)
            draw.SimpleText(title, vox.Font('Comfortaa Bold@15'), vox.ScaleWide(14), vox.ScaleTall(12), fallbackAdminColors.text, 0, 0)
            surface.SetDrawColor(ColorAlpha(accent, 80))
            surface.DrawRect(vox.ScaleWide(14), vox.ScaleTall(36), w - vox.ScaleWide(28), 1)
        end
        return block
    end

    function PANEL:BuildPlayerManagement()
        local content = self.content
        content:Clear()

        local header = self:AddAdminBlock(content, 'Player Management')
        header:Dock(TOP)
        header:SetTall(vox.ScaleTall(72))
        header:DockMargin(0, 0, 0, vox.ScaleTall(10))
        header.PaintOver = function(_, w, h)
            draw.SimpleText('Online staff tools, player status, and moderation shortcuts.', vox.Font('Comfortaa@13'), vox.ScaleWide(14), vox.ScaleTall(46), fallbackAdminColors.muted, 0, 0)
            draw.SimpleText(#player.GetAll() .. ' ONLINE', vox.Font('Comfortaa Bold@12'), w - vox.ScaleWide(16), vox.ScaleTall(22), fallbackAdminColors.accent, 2, 1)
        end

        local actions = self:AddAdminBlock(content, 'Player Actions')
        actions:Dock(RIGHT)
        actions:SetWide(vox.ScaleWide(230))
        actions:DockMargin(vox.ScaleWide(10), 0, 0, 0)
        local actionRows = {'Kick Player', 'Warn Player', 'Bring / Goto', 'Freeze Player', 'Open Reports'}
        for index, label in ipairs(actionRows) do
            local row = actions:Add('DButton')
            row:Dock(TOP)
            row:DockMargin(vox.ScaleWide(12), index == 1 and vox.ScaleTall(48) or 0, vox.ScaleWide(12), vox.ScaleTall(7))
            row:SetTall(vox.ScaleTall(34))
            row:SetText('')
            row.Paint = function(panel, w, h)
                local _, secondary, _, accent = getThemeColors()
                draw.RoundedBox(7, 0, 0, w, h, ColorAlpha(secondary, 230))
                draw.SimpleText(label, vox.Font('Comfortaa Bold@12'), vox.ScaleWide(12), h * .5, fallbackAdminColors.text, 0, 1)
                draw.SimpleText('›', vox.Font('Comfortaa Bold@18'), w - vox.ScaleWide(12), h * .5, accent, 2, 1)
            end
        end

        local list = self:AddAdminBlock(content, 'Players')
        list:Dock(FILL)
        local scroll = list:Add('vox.ScrollPanel')
        scroll:Dock(FILL)
        scroll:DockMargin(vox.ScaleWide(12), vox.ScaleTall(48), vox.ScaleWide(12), vox.ScaleTall(12))

        for _, ply in ipairs(player.GetAll()) do
            local row = scroll:Add('Panel')
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, vox.ScaleTall(7))
            row:SetTall(vox.ScaleTall(44))
            row.Paint = function(_, w, h)
                local _, secondary, _, accent = getThemeColors()
                draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(secondary, 235))
                draw.RoundedBox(6, vox.ScaleWide(10), vox.ScaleTall(9), vox.ScaleTall(26), vox.ScaleTall(26), ColorAlpha(accent, 35))
                draw.SimpleText(string.sub(ply:Nick() or '?', 1, 1), vox.Font('Comfortaa Bold@14'), vox.ScaleWide(23), h * .5, fallbackAdminColors.text, 1, 1)
                draw.SimpleText(ply:Nick(), vox.Font('Comfortaa Bold@13'), vox.ScaleWide(46), vox.ScaleTall(10), fallbackAdminColors.text, 0, 0)
                draw.SimpleText(team.GetName(ply:Team()) or 'Unknown', vox.Font('Comfortaa@11'), vox.ScaleWide(46), vox.ScaleTall(25), fallbackAdminColors.muted, 0, 0)
                draw.SimpleText(ply:IsAdmin() and 'STAFF' or 'PLAYER', vox.Font('Comfortaa Bold@10'), w - vox.ScaleWide(14), h * .5, ply:IsAdmin() and fallbackAdminColors.accent or fallbackAdminColors.muted, 2, 1)
            end
        end
    end

    vox.gui.Register('vox.f4.AdminStats', PANEL)
end
