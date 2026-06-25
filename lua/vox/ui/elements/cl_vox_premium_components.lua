-- Vox dashboard glass design system: reusable command-center controls for every module.
vox = vox or {}
vox.premium = vox.premium or {} -- Backwards-compatible storage for existing renderer callers.

local function safeColor(c, fallback)
    if (istable and istable(c) and c.r and c.g and c.b) then return c end
    return fallback or Color(255,255,255)
end

vox.premium.colors = vox.premium.colors or {
    base = Color(5, 8, 16), glass = Color(10, 16, 29), panel = Color(14, 23, 39), raised = Color(21, 33, 54),
    accent = Color(0, 188, 255), violet = Color(139, 92, 246), text = Color(242, 247, 255), muted = Color(139, 154, 176),
    money = Color(72, 221, 142), danger = Color(255, 78, 104), armor = Color(88, 166, 255), amber = Color(255, 190, 88)
}

function vox.PremiumPalette()
    local p = table.Copy(vox.premium.colors)
    local theme = (vox.GetThemeColors and vox.GetThemeColors()) or {}
    p.accent = safeColor(theme.accent, p.accent); p.violet = safeColor(theme.secondaryAccent, p.violet)
    p.text = safeColor(theme.textPrimary, p.text); p.muted = safeColor(theme.textSecondary, p.muted)
    p.glass = safeColor(theme.primary, p.glass); p.panel = safeColor(theme.secondary, p.panel); p.raised = safeColor(theme.tertiary, p.raised)
    return p
end

local function font(name, fallback)
    return (vox.Font and vox.Font(name)) or fallback or 'DermaDefault'
end

function vox.DrawVoxGlass(x, y, w, h, state)
    state = state or {}; local p = vox.PremiumPalette(); local a = safeColor(state.accent, p.accent); local r = state.radius or 18
    draw.RoundedBox(r, x + 6, y + 8, w, h, Color(0, 0, 0, state.shadow or 72))
    draw.RoundedBox(r, x, y, w, h, ColorAlpha(safeColor(state.base, p.glass), state.alpha or 232))
    if vox.DrawMatGradient then
        vox.DrawMatGradient(x, y, w, h, RIGHT, ColorAlpha(a, state.glow or 26))
        vox.DrawMatGradient(x, y, w, h, BOTTOM, ColorAlpha(p.violet, 15))
    end
    surface.SetDrawColor(ColorAlpha(p.raised, 230)); surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)
    surface.SetDrawColor(ColorAlpha(a, 145)); surface.DrawLine(x + r, y + 1, x + math.min(w - r, 180), y + 1)
    surface.SetDrawColor(ColorAlpha(color_white, 12)); surface.DrawLine(x + r, y + 2, x + w - r, y + 2)
end

function vox.DrawVoxPremiumCard(x, y, w, h, state)
    state = state or {}; local p = vox.PremiumPalette(); local a = safeColor(state.accent, p.accent); local lift = state.hovered and 3 or 0
    vox.DrawVoxGlass(x, y - lift, w, h, state)
    draw.RoundedBox(math.min(state.radius or 18, 8), x + 9, y + 10 - lift, 3, h - 20, ColorAlpha(a, 230))
    if state.hovered then surface.SetDrawColor(ColorAlpha(a, 170)); surface.DrawOutlinedRect(x, y - lift, w, h, 1) end
end

local function register(class, base, methods)
    local PANEL = methods or {}; vox.gui.Register(class, PANEL, base or 'Panel')
end

local Root = {}
function Root:Init() self:SetAlpha(0); self:AlphaTo(255,.18,0); self.accent = vox.PremiumPalette().accent end
function Root:Paint(w,h) if vox.DrawBlurExpensive then vox.DrawBlurExpensive(self, 8) end; vox.DrawVoxGlass(0,0,w,h,{radius=24,alpha=244,accent=self.accent,shadow=100}); draw.SimpleText('VOX', font('Comfortaa Bold@22'), 28, 24, vox.PremiumPalette().text) end
register('VoxRootFrame','vox.Frame',Root)

local Glass = {}; function Glass:Init() self.accent = vox.PremiumPalette().accent end; function Glass:Paint(w,h) vox.DrawVoxGlass(0,0,w,h,{radius=self.radius or 18,accent=self.accent}) end; register('VoxGlassFrame','Panel',Glass); register('VoxTopBar','VoxGlassFrame',{}); register('VoxInfoCard','VoxGlassFrame',{})
local Card = {}; function Card:Init() self.hover=0; self.accent=vox.PremiumPalette().accent end; function Card:Think() self.hover=Lerp(FrameTime()*12,self.hover,self:IsHovered() and 1 or 0) end; function Card:Paint(w,h) vox.DrawVoxPremiumCard(0,0,w,h,{accent=self.accent,hovered=self.hover>.1,radius=16}) end
for _, n in ipairs({'VoxDashboardCard','VoxStatTile','VoxPlayerCard','VoxJobCard','VoxShopCard','VoxNotificationCard','VoxProfileCard','VoxPlayerRow'}) do register(n,'Panel',Card) end

local Button = {}; function Button:Init() self:SetTextColor(vox.PremiumPalette().text); self:SetFont(font('Comfortaa Bold@16')); self.hover=0 end; function Button:Think() self.hover=Lerp(FrameTime()*14,self.hover,self:IsHovered() and 1 or 0) end; function Button:Paint(w,h) local p=vox.PremiumPalette(); vox.DrawVoxGlass(0,0,w,h,{radius=12,accent=p.accent,alpha=205+35*self.hover,glow=20+35*self.hover}); return false end
register('VoxActionButton','DButton',Button); register('VoxIconButton','DButton',Button); register('VoxSidebarItem','DButton',Button)

local Entry = {}; function Entry:Init() self:SetTall(42); self:SetFont(font('Comfortaa@15')); self:SetTextColor(vox.PremiumPalette().text); self:SetPlaceholderColor(vox.PremiumPalette().muted) end; function Entry:Paint(w,h) vox.DrawVoxGlass(0,0,w,h,{radius=13,alpha=218}); self:DrawTextEntryText(vox.PremiumPalette().text,vox.PremiumPalette().accent,vox.PremiumPalette().text) end
register('VoxInput','DTextEntry',Entry); register('VoxSearchBox','DTextEntry',Entry)

register('VoxSidebar','vox.Sidebar',{}); register('VoxDropdown','vox.Combo',{}); register('VoxToggle','vox.Toggler',{}); register('VoxSlider','DNumSlider',{}); register('VoxColorPicker','DColorMixer',{}); register('VoxScrollPanel','vox.ScrollPanel',{}); register('VoxScrollbar','DVScrollBar',{}); register('VoxModal','VoxRootFrame',{}); register('VoxConfirmModal','VoxRootFrame',{}); register('VoxTooltip','Panel',{}); register('VoxContextMenu','vox.Menu',{}); register('VoxProgressBar','Panel',{}); register('VoxCircularMeter','Panel',{}); register('VoxAvatarBadge','vox.RoundedAvatar',{}); register('VoxModelStage','DModelPanel',{}); register('VoxRankBadge','Panel',{}); register('VoxColumnHeader','DButton',Button)

-- Backwards-compatible aliases used by older module code.
register('VoxGlassPanel','VoxGlassFrame',{}); register('VoxCard','VoxDashboardCard',{}); register('VoxButton','VoxActionButton',{}); register('VoxFrame','VoxRootFrame',{})

-- Final dashboard renderer overrides: older Vox panel/card/row/badge calls inherit the command-center glass style.
function vox.DrawVoxPanel( x, y, w, h, colors, radius )
    colors = colors or {}
    vox.DrawVoxGlass( x, y, w, h, { radius = radius or 18, accent = colors.accent, base = colors.primary, alpha = 236 } )
end

function vox.DrawVoxCard( x, y, w, h, colors, state )
    colors = colors or {}; state = state or {}
    vox.DrawVoxPremiumCard( x, y, w, h, { radius = state.radius or 16, accent = state.accent or colors.accent, base = colors.primary, hovered = state.hovered } )
end

function vox.DrawVoxRow( x, y, w, h, colors, state )
    colors = colors or {}; state = state or {}
    draw.RoundedBox( state.radius or 12, x, y, w, h, ColorAlpha( colors.secondary or vox.PremiumPalette().panel, state.alpha or 218 ) )
    if state.hovered or state.selected then
        local accent = state.accent or colors.accent or vox.PremiumPalette().accent
        if vox.DrawMatGradient then vox.DrawMatGradient( x, y, w, h, RIGHT, ColorAlpha( accent, 34 ) ) end
        surface.SetDrawColor( ColorAlpha( accent, 150 ) ); surface.DrawOutlinedRect( x, y, w, h, 1 )
    end
end

function vox.DrawVoxBadge( x, y, w, h, label, colors, state )
    colors = colors or {}; state = state or {}
    local accent = state.accent or colors.accent or vox.PremiumPalette().accent
    draw.RoundedBox( h * .5, x, y, w, h, ColorAlpha( accent, state.alpha or 45 ) )
    surface.SetDrawColor( ColorAlpha( accent, 145 ) ); surface.DrawOutlinedRect( x, y, w, h, 1 )
    draw.SimpleText( string.upper( tostring( label or '' ) ), state.font or 'DermaDefaultBold', x + w * .5, y + h * .5, state.textColor or colors.textPrimary or color_white, 1, 1 )
end
