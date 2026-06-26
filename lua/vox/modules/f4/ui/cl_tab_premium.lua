local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_TERTIARY = vox:Config('colors.tertiary')
local COLOR_ACCENT = vox:Config('colors.accent')
local COLOR_TEXT = Color(238, 244, 255)
local COLOR_MUTED = Color(145, 160, 178)

local function getThemeColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return {
        primary = colors.primary or COLOR_PRIMARY,
        secondary = colors.secondary or COLOR_SECONDARY,
        tertiary = colors.tertiary or COLOR_TERTIARY,
        accent = colors.accent or Color(70, 135, 255),
        money = colors.money or Color(35, 225, 120),
        negative = colors.negative or Color(255, 75, 95),
        warning = Color(88, 166, 255),
        text = colors.textPrimary or COLOR_TEXT,
        muted = colors.textSecondary or COLOR_MUTED
    }
end

local function money(v)
    return DarkRP and DarkRP.formatMoney and DarkRP.formatMoney(v or 0) or tostring(v or 0)
end

local function paintCommandRow(panel, w, h, title, desc, state, action)
    local colors = getThemeColors()
    local hovered = panel:IsHovered()
    vox.DrawVoxPanel(0, 0, w, h, { primary = colors.secondary, secondary = colors.tertiary, accent = colors.accent }, 9)
    draw.RoundedBox(9, 1, 1, w - 2, h - 2, ColorAlpha(colors.primary, 82))
    vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(colors.accent, hovered and 18 or 7))
    draw.RoundedBox(2, vox.ScaleWide(12), vox.ScaleTall(13), vox.ScaleWide(4), h - vox.ScaleTall(26), colors.accent)

    draw.SimpleText(title, vox.Font('Comfortaa Bold@17'), vox.ScaleWide(28), vox.ScaleTall(14), colors.text, 0, 0)
    draw.SimpleText(desc, vox.Font('Comfortaa@13'), vox.ScaleWide(28), vox.ScaleTall(38), colors.muted, 0, 0)

    if state then
        local pillW = vox.ScaleWide(92)
        draw.RoundedBox(7, w - pillW - vox.ScaleWide(16), vox.ScaleTall(15), pillW, vox.ScaleTall(24), ColorAlpha(colors.accent, hovered and 42 or 26))
        draw.SimpleText(state, vox.Font('Comfortaa Bold@11'), w - pillW * .5 - vox.ScaleWide(16), vox.ScaleTall(27), colors.text, 1, 1)
    end

    if action then
        draw.SimpleText(action, vox.Font('Comfortaa Bold@11'), w - vox.ScaleWide(18), h - vox.ScaleTall(18), colors.accent, 2, 1)
    end
end

local function buildHeader(parent, title, subtitle)
    local header = parent:Add('Panel')
    header:Dock(TOP)
    header:SetTall(vox.ScaleTall(70))
    header:DockMargin(0, 0, 0, vox.ScaleTall(10))
    header.Paint = function(_, w, h)
        local colors = getThemeColors()
        vox.DrawVoxPanel(0, 0, w, h, { primary = ColorAlpha(colors.primary, 245), secondary = colors.secondary, accent = colors.accent }, 12)
        draw.RoundedBox(3, vox.ScaleWide(14), vox.ScaleTall(13), vox.ScaleWide(5), h - vox.ScaleTall(26), colors.accent)
        draw.SimpleText(title, vox.Font('Comfortaa Bold@24'), vox.ScaleWide(32), vox.ScaleTall(15), colors.text, 0, 0)
        draw.SimpleText(subtitle, vox.Font('Comfortaa@14'), vox.ScaleWide(34), vox.ScaleTall(43), colors.muted, 0, 0)
    end
end

local function addRowList(parent)
    local scroll = parent:Add('vox.ScrollPanel')
    scroll:Dock(FILL)
    local list = scroll:Add('DIconLayout')
    list:Dock(TOP)
    list:SetSpaceY(vox.ScaleTall(8))
    list:SetSpaceX(0)
    list.PerformLayout = function(panel, w)
        local y = 0
        for _, child in ipairs(panel:GetChildren()) do
            child:SetPos(0, y)
            child:SetWide(w)
            y = y + child:GetTall() + panel:GetSpaceY()
        end
        panel:SetTall(y)
    end
    return list
end

local function addRows(parent, rows, onClick)
    local list = addRowList(parent)
    for _, data in ipairs(rows) do
        local row = list:Add('DButton')
        row:SetText('')
        row:SetTall(vox.ScaleTall(72))
        row.Paint = function(panel, w, h) paintCommandRow(panel, w, h, data[1], data[2], data[3], data[4]) end
        row.DoClick = onClick or function() end
    end
end

local INV = {}
function INV:Init()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Inventory', 'Compact command inventory with readable status rows and quick actions.')
    addRows(self, {
        {'Pocket Cash', money(LocalPlayer():getDarkRPVar('money') or 0), 'WALLET', 'DARKRP'},
        {'Weapon License', LocalPlayer():getDarkRPVar('HasGunlicense') and 'Active permit' or 'No permit', 'PERMIT', 'DETAILS'},
        {'Identity Card', team.GetName(LocalPlayer():Team()), 'ROLE', 'VIEW'},
        {'Shipment Slot', 'Server inventory hook ready', 'LOCKED', 'COMING SOON'},
        {'Evidence Pouch', 'DarkRP pocket compatible', 'READY', 'OPEN'},
        {'Quick Actions', 'Use dashboard actions for commands', 'TOOLS', 'RUN'}
    })
end
vox.gui.Register('vox.f4.Inventory', INV)

local UP = {}
function UP:Init()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Player Upgrades', 'Compact progression rows for perks, boosts, and server-specific unlocks.')
    addRows(self, {
        {'Salary Boost', '+10% payday preview', 'ACTIVE', 'CONFIGURE'},
        {'Pocket Capacity', 'Extra DarkRP storage slots', 'LOCKED', 'UPGRADE'},
        {'Crafting Speed', 'Faster roleplay interactions', 'READY', 'VIEW'},
        {'Reputation', 'Community standing module', 'TRACKED', 'OPEN'},
        {'VIP Queue', 'Donation integration ready', 'LOCKED', 'LEARN'},
        {'Cosmetic Badge', 'Scoreboard rank flair', 'EQUIPPED', 'CHANGE'}
    })
end
vox.gui.Register('vox.f4.Upgrades', UP)

local SET = {}
function SET:Init()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Vox Settings', 'Live F4 configuration using the same settings controls as the admin menu.')

    local config = self:Add('vox.Configuration')
    config:Dock(FILL)
    config:LoadAddonSettings('f4')
    config:OpenCategories()

    local hudButton = self:Add('DButton')
    hudButton:Dock(BOTTOM)
    hudButton:DockMargin(0, vox.ScaleTall(10), 0, 0)
    hudButton:SetTall(vox.ScaleTall(34))
    hudButton:SetText('')
    hudButton.Paint = function(panel, w, h)
        local colors = getThemeColors()
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(colors.accent, panel:IsHovered() and 58 or 34))
        surface.SetDrawColor(ColorAlpha(colors.accent, 130))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText('OPEN FULL HUD SETTINGS', vox.Font('Comfortaa Bold@12'), w * .5, h * .5, colors.text, 1, 1)
    end
    hudButton.DoClick = function()
        if vox.hud and vox.hud.OpenSettings then
            vox.hud.OpenSettings()
        end
    end
end
vox.gui.Register('vox.f4.Settings', SET)
