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
        accent = Color(70, 135, 255),
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

local function paintPremiumCard(panel, w, h, accent, title, desc, locked)
    local colors = getThemeColors()
    accent = colors.accent
    if vox.DrawVoxCard then
        vox.DrawVoxCard(0, 0, w, h, { primary = colors.primary, secondary = colors.secondary, accent = accent }, { hovered = panel:IsHovered(), accent = accent, radius = 10, bladeWidth = 4 })
    else
        draw.RoundedBox(10, 0, 0, w, h, colors.secondary)
    end
    vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(colors.accent, panel:IsHovered() and 16 or 6))
    surface.SetDrawColor(ColorAlpha(colors.accent, panel:IsHovered() and 130 or 55))
    surface.DrawLine(vox.ScaleWide(12), h - 2, w - vox.ScaleWide(14), h - 2)
    draw.SimpleText(title, vox.Font('Comfortaa Bold@18'), vox.ScaleWide(18), vox.ScaleTall(15), locked and colors.muted or colors.text, 0, 0)
    draw.SimpleText(desc, vox.Font('Comfortaa@13'), vox.ScaleWide(18), vox.ScaleTall(40), colors.muted, 0, 0)
    if locked then
        vox.DrawAngledRect(w - vox.ScaleWide(86), vox.ScaleTall(14), vox.ScaleWide(66), vox.ScaleTall(24), 7, ColorAlpha(colors.negative, 40))
        draw.SimpleText('LOCKED', vox.Font('Comfortaa Bold@11'), w - vox.ScaleWide(53), vox.ScaleTall(26), colors.negative, 1, 1)
    end
end

local function buildHeader(parent, title, subtitle)
    local header = parent:Add('Panel')
    header:Dock(TOP)
    header:SetTall(vox.ScaleTall(76))
    header:DockMargin(0, 0, 0, vox.ScaleTall(12))
    header.Paint = function(_, w, h)
        local colors = getThemeColors()
        vox.DrawVoxPanel(0, 0, w, h, { primary = ColorAlpha(colors.primary, 245), secondary = colors.secondary, accent = colors.accent }, 14)
        vox.DrawVoxBlade(vox.ScaleWide(16), vox.ScaleTall(14), vox.ScaleWide(6), h - vox.ScaleTall(28), colors.accent)
        draw.SimpleText(title, vox.Font('Comfortaa Bold@26'), vox.ScaleWide(34), vox.ScaleTall(18), colors.text, 0, 0)
        draw.SimpleText(subtitle, vox.Font('Comfortaa@14'), vox.ScaleWide(36), vox.ScaleTall(48), colors.muted, 0, 0)
    end
end

local function addGrid(parent)
    local scroll = parent:Add('vox.ScrollPanel')
    scroll:Dock(FILL)
    local grid = scroll:Add('vox.Grid')
    grid:Dock(TOP)
    grid:SetColumnCount(3)
    grid:SetSpace(vox.ScaleTall(10))
    return grid
end

local INV = {}
function INV:Init()
    local colors = getThemeColors()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Inventory', 'Command roleplay storage with clean item slots and restricted-state previews.')
    local grid = addGrid(self)
    local items = {
        {'Pocket Cash', money(LocalPlayer():getDarkRPVar('money') or 0), colors.accent},
        {'Weapon License', LocalPlayer():getDarkRPVar('HasGunlicense') and 'Active permit' or 'No permit', colors.accent},
        {'Identity Card', team.GetName(LocalPlayer():Team()), team.GetColor(LocalPlayer():Team())},
        {'Shipment Slot', 'Server inventory hook ready', colors.accent, true},
        {'Evidence Pouch', 'DarkRP pocket compatible', colors.warning},
        {'Quick Actions', 'Use dashboard actions for commands', colors.money}
    }
    for _, data in ipairs(items) do
        local card = grid:Add('DButton')
        card:SetText('')
        card:SetTall(vox.ScaleTall(108))
        card.Paint = function(panel, w, h) paintPremiumCard(panel, w, h, data[3], data[1], data[2], data[4]) end
    end
end
vox.gui.Register('vox.f4.Inventory', INV)

local UP = {}
function UP:Init()
    local colors = getThemeColors()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Player Upgrades', 'Readable progression cards for perks, VIP boosts, and server-specific upgrades.')
    local grid = addGrid(self)
    for _, data in ipairs({
        {'Salary Boost', '+10% payday preview', colors.accent},
        {'Pocket Capacity', 'Extra DarkRP storage slots', colors.accent, true},
        {'Crafting Speed', 'Faster roleplay interactions', colors.money},
        {'Reputation', 'Community standing module', colors.warning},
        {'VIP Queue', 'Donation integration ready', colors.warning, true},
        {'Cosmetic Badge', 'Scoreboard rank flair', colors.accent}
    }) do
        local card = grid:Add('DButton')
        card:SetText('')
        card:SetTall(vox.ScaleTall(108))
        card.Paint = function(panel, w, h) paintPremiumCard(panel, w, h, data[3], data[1], data[2], data[4]) end
    end
end
vox.gui.Register('vox.f4.Upgrades', UP)

local SET = {}
function SET:Init()
    local colors = getThemeColors()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Vox Settings', 'Live preview cards for HUD, F4, scoreboard rows, notifications, and accessibility.')
    local grid = addGrid(self)
    local rows = {
        {'HUD Style', 'Choose Tactical Card, Command Strip, Minimal Edge, or Roleplay Profile.', colors.accent},
        {'HUD / F4 / Scoreboard Scale', 'Adjust readable frame sizes without clipping.', colors.accent},
        {'Theme & Accent', 'Dark glass, blue-gray, electric blue, and active theme accents.', colors.accent},
        {'Blur & Animations', 'Toggle glass blur, transitions, and reduce motion.', colors.money},
        {'Compact Mode', 'Tighter cards for dense roleplay servers.', colors.warning},
        {'Live Previews', 'HUD card, F4 card, scoreboard row, and notification preview.', colors.warning}
    }
    for _, data in ipairs(rows) do
        local card = grid:Add('DButton')
        card:SetText('')
        card:SetTall(vox.ScaleTall(108))
        card.Paint = function(panel, w, h) paintPremiumCard(panel, w, h, data[3], data[1], data[2]) end
        card.DoClick = function()
            if vox.hud and vox.hud.OpenSettings then vox.hud.OpenSettings() end
        end
    end
end
vox.gui.Register('vox.f4.Settings', SET)
