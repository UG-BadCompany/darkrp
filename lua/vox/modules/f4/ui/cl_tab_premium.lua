local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_TERTIARY = vox:Config('colors.tertiary')
local COLOR_ACCENT = vox:Config('colors.accent')
local COLOR_PURPLE = Color(142, 84, 255)
local COLOR_TEXT = Color(238, 244, 255)
local COLOR_MUTED = Color(145, 160, 178)

local function money(v)
    return DarkRP and DarkRP.formatMoney and DarkRP.formatMoney(v or 0) or tostring(v or 0)
end

local function paintPremiumCard(panel, w, h, accent, title, desc, locked)
    accent = accent or COLOR_ACCENT
    if vox.DrawVoxCard then
        vox.DrawVoxCard(0, 0, w, h, { primary = COLOR_PRIMARY, secondary = COLOR_SECONDARY, accent = accent }, { hovered = panel:IsHovered(), accent = accent, radius = 12, bladeWidth = 6 })
    else
        draw.RoundedBox(12, 0, 0, w, h, COLOR_SECONDARY)
    end
    vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(COLOR_PURPLE, panel:IsHovered() and 28 or 14))
    surface.SetDrawColor(ColorAlpha(accent, panel:IsHovered() and 150 or 70))
    surface.DrawLine(vox.ScaleWide(12), h - 2, w - vox.ScaleWide(14), h - 2)
    draw.SimpleText(title, vox.Font('Comfortaa Bold@18'), vox.ScaleWide(18), vox.ScaleTall(15), locked and COLOR_MUTED or COLOR_TEXT, 0, 0)
    draw.SimpleText(desc, vox.Font('Comfortaa@13'), vox.ScaleWide(18), vox.ScaleTall(40), COLOR_MUTED, 0, 0)
    if locked then
        vox.DrawAngledRect(w - vox.ScaleWide(86), vox.ScaleTall(14), vox.ScaleWide(66), vox.ScaleTall(24), 7, ColorAlpha(Color(255, 88, 88), 40))
        draw.SimpleText('LOCKED', vox.Font('Comfortaa Bold@11'), w - vox.ScaleWide(53), vox.ScaleTall(26), Color(255, 130, 130), 1, 1)
    end
end

local function buildHeader(parent, title, subtitle)
    local header = parent:Add('Panel')
    header:Dock(TOP)
    header:SetTall(vox.ScaleTall(76))
    header:DockMargin(0, 0, 0, vox.ScaleTall(12))
    header.Paint = function(_, w, h)
        vox.DrawVoxPanel(0, 0, w, h, { primary = ColorAlpha(COLOR_PRIMARY, 245), secondary = COLOR_SECONDARY, accent = COLOR_ACCENT }, 14)
        vox.DrawVoxBlade(vox.ScaleWide(16), vox.ScaleTall(14), vox.ScaleWide(7), h - vox.ScaleTall(28), COLOR_ACCENT)
        draw.SimpleText(title, vox.Font('Comfortaa Bold@26'), vox.ScaleWide(34), vox.ScaleTall(18), COLOR_TEXT, 0, 0)
        draw.SimpleText(subtitle, vox.Font('Comfortaa@14'), vox.ScaleWide(36), vox.ScaleTall(48), COLOR_MUTED, 0, 0)
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
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Inventory', 'Premium roleplay storage with clean item slots and restricted-state previews.')
    local grid = addGrid(self)
    local items = {
        {'Pocket Cash', money(LocalPlayer():getDarkRPVar('money') or 0), COLOR_ACCENT},
        {'Weapon License', LocalPlayer():getDarkRPVar('HasGunlicense') and 'Active permit' or 'No permit', Color(92, 205, 255)},
        {'Identity Card', team.GetName(LocalPlayer():Team()), team.GetColor(LocalPlayer():Team())},
        {'Shipment Slot', 'Server inventory hook ready', COLOR_PURPLE, true},
        {'Evidence Pouch', 'DarkRP pocket compatible', Color(255, 196, 82)},
        {'Quick Actions', 'Use dashboard actions for commands', Color(95, 255, 174)}
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
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Player Upgrades', 'Readable progression cards for perks, VIP boosts, and server-specific upgrades.')
    local grid = addGrid(self)
    for _, data in ipairs({
        {'Salary Boost', '+10% payday preview', COLOR_ACCENT},
        {'Pocket Capacity', 'Extra DarkRP storage slots', COLOR_PURPLE, true},
        {'Crafting Speed', 'Faster roleplay interactions', Color(95, 255, 174)},
        {'Reputation', 'Community standing module', Color(255, 196, 82)},
        {'VIP Queue', 'Donation integration ready', Color(255, 225, 106), true},
        {'Cosmetic Badge', 'Scoreboard rank flair', Color(92, 205, 255)}
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
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Vox Settings', 'Live preview cards for HUD, F4, scoreboard rows, notifications, and accessibility.')
    local grid = addGrid(self)
    local rows = {
        {'HUD Style', 'Choose Tactical Card, Command Strip, Minimal Edge, or Roleplay Profile.', COLOR_ACCENT},
        {'HUD / F4 / Scoreboard Scale', 'Adjust readable frame sizes without clipping.', Color(92, 205, 255)},
        {'Theme & Accent', 'Dark glass, blue-gray, electric blue, and purple accents.', COLOR_PURPLE},
        {'Blur & Animations', 'Toggle glass blur, transitions, and reduce motion.', Color(95, 255, 174)},
        {'Compact Mode', 'Tighter cards for dense roleplay servers.', Color(255, 196, 82)},
        {'Live Previews', 'HUD card, F4 card, scoreboard row, and notification preview.', Color(255, 225, 106)}
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
