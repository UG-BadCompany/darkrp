-- Vox Premium Design System: reusable glass/dashboard controls for every module.
local function C(name, fallback)
    return (vox.GetThemeColors and vox.GetThemeColors()[name]) or fallback
end

vox.premium = vox.premium or {}
vox.premium.colors = {
    base = Color(7, 10, 18), glass = Color(13, 19, 32), panel = Color(18, 26, 43),
    raised = Color(24, 35, 56), accent = Color(0, 188, 255), violet = Color(139, 92, 246),
    text = Color(242, 247, 255), muted = Color(139, 154, 176), money = Color(72, 221, 142),
    danger = Color(255, 78, 104), armor = Color(88, 166, 255), amber = Color(255, 190, 88)
}

function vox.PremiumPalette()
    local p = table.Copy(vox.premium.colors)
    local theme = vox.GetThemeColors and vox.GetThemeColors() or {}
    p.accent = theme.accent or p.accent; p.text = theme.textPrimary or p.text; p.muted = theme.textSecondary or p.muted
    return p
end

function vox.DrawVoxGlass(x, y, w, h, state)
    state = state or {}; local p = vox.PremiumPalette(); local a = state.accent or p.accent; local r = state.radius or 18
    draw.RoundedBox(r, x, y, w, h, ColorAlpha(state.base or p.glass, state.alpha or 232))
    vox.DrawMatGradient(x, y, w, h, RIGHT, ColorAlpha(a, state.glow or 22))
    vox.DrawMatGradient(x, y, w, h, BOTTOM, ColorAlpha(p.violet, 14))
    surface.SetDrawColor(ColorAlpha(p.raised, 220)); surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)
    surface.SetDrawColor(ColorAlpha(a, 120)); surface.DrawLine(x + r, y + 1, x + math.min(w - r, 140), y + 1)
    surface.SetDrawColor(ColorAlpha(color_white, 10)); surface.DrawLine(x + r, y + 2, x + w - r, y + 2)
end

function vox.DrawVoxPremiumCard(x, y, w, h, state)
    state = state or {}; local p = vox.PremiumPalette(); local hover = state.hovered and 1 or 0; local lift = hover * 3
    vox.DrawVoxGlass(x, y - lift, w, h, state)
    local a = state.accent or p.accent
    draw.RoundedBox(state.radius or 18, x + 8, y + 8 - lift, 3, h - 16, ColorAlpha(a, 220))
    if hover > 0 then
        vox.DrawMatGradient(x, y - lift, w, h, RIGHT, ColorAlpha(a, 34)); surface.SetDrawColor(ColorAlpha(a, 155)); surface.DrawOutlinedRect(x, y - lift, w, h, 1)
    end
end

local function registerPanel(class, base, init)
    local PANEL = {}; PANEL.Init = init or function() end; vox.gui.Register(class, PANEL, base or 'Panel')
end

local GP = {}
function GP:Init() self.accent = vox.PremiumPalette().accent end
function GP:Paint(w,h) vox.DrawVoxGlass(0,0,w,h,{accent=self.accent,radius=18}) end
vox.gui.Register('VoxGlassPanel', GP, 'Panel')

local PANEL = {}
function PANEL:Init() self.hover = 0; self.accent = vox.PremiumPalette().accent end
function PANEL:Think() self.hover = Lerp(FrameTime()*12, self.hover, self:IsHovered() and 1 or 0) end
function PANEL:Paint(w,h) vox.DrawVoxPremiumCard(0,0,w,h,{accent=self.accent, hovered=self.hover>.08, radius=18}) end
vox.gui.Register('VoxCard', PANEL, 'Panel')

local BP = {}
function BP:Init() self:SetTextColor(vox.PremiumPalette().text); self:SetFont(vox.Font('Comfortaa Bold@16')); self.hover=0 end
function BP:Think() self.hover=Lerp(FrameTime()*14,self.hover,self:IsHovered() and 1 or 0) end
function BP:Paint(w,h) local p=vox.PremiumPalette(); vox.DrawVoxGlass(0,0,w,h,{accent=p.accent, alpha=205+30*self.hover, radius=12, glow=18+30*self.hover}); return false end
vox.gui.Register('VoxButton', BP, 'DButton')

local TP = {}
function TP:Init() self:SetTall(vox.ScaleTall(42)); self:SetPlaceholderText('Search Vox...') end
function TP:Paint(w,h) vox.DrawVoxGlass(0,0,w,h,{radius=14, alpha=218}); self:DrawTextEntryText(vox.PremiumPalette().text, vox.PremiumPalette().accent, vox.PremiumPalette().text) end
vox.gui.Register('VoxSearchBox', TP, 'DTextEntry')

-- Public component aliases requested by the product spec; modules can opt in incrementally.
local aliases = {
    VoxFrame='vox.Frame', VoxPanel='VoxGlassPanel', VoxStatCard='VoxCard', VoxSidebar='vox.Sidebar',
    VoxSidebarButton='VoxButton', VoxTopBar='VoxGlassPanel', VoxTabBar='VoxGlassPanel', VoxIconButton='VoxButton',
    VoxToggle='vox.Toggler', VoxSlider='DNumSlider', VoxDropdown='vox.Combo', VoxInput='vox.TextEntry',
    VoxScrollPanel='vox.ScrollPanel', VoxTooltip='Panel', VoxModal='vox.Frame', VoxContextMenu='vox.Menu',
    VoxBadge='VoxGlassPanel', VoxPlayerRow='VoxCard', VoxJobCard='VoxCard', VoxShopCard='VoxCard',
    VoxNotification='VoxCard', VoxProgressBar='Panel', VoxAvatarBadge='vox.RoundedAvatar', VoxModelStage='DModelPanel'
}
for name, base in pairs(aliases) do
    local A = {}; vox.gui.Register(name, A, base)
end
