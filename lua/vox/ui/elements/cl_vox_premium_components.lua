-- Vox Premium Design System: reusable glass/dashboard controls for every module.
vox = vox or {}
vox.premium = vox.premium or {}

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

-- Final premium renderer overrides: every legacy Vox panel/card/row/badge now inherits the glass dashboard style.
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

-- 2026 VOX Command Center design-system layer.
vox.theme = vox.theme or {}
vox.theme.tokens = vox.theme.tokens or {
    bg = Color(4, 10, 20, 245), frame = Color(8, 18, 34, 245), panel = Color(10, 25, 46, 235), panelAlt = Color(13, 32, 58, 235),
    card = Color(12, 28, 52, 230), cardHover = Color(18, 42, 76, 240), cardSelected = Color(18, 55, 105, 245), border = Color(55, 115, 180, 90),
    borderStrong = Color(0, 174, 255, 180), accent = Color(0, 174, 255), accentSoft = Color(0, 174, 255, 45), secondaryAccent = Color(125, 75, 255),
    success = Color(42, 220, 120), money = Color(50, 230, 130), warning = Color(255, 190, 75), danger = Color(255, 70, 90),
    health = Color(255, 70, 90), armor = Color(70, 135, 255), hunger = Color(255, 190, 75), text = Color(245, 250, 255),
    textSoft = Color(185, 205, 230), muted = Color(115, 140, 170), disabled = Color(75, 85, 105), shadow = Color(0, 0, 0, 180), glass = Color(10, 22, 42, 215)
}

function vox.ThemeTokens()
    vox.theme = vox.theme or {}; vox.theme.tokens = vox.theme.tokens or {}
    return vox.theme.tokens
end

function vox.PremiumPalette()
    local t = vox.ThemeTokens()
    return { base=t.bg, glass=t.glass, panel=t.panel, raised=t.panelAlt, accent=t.accent, violet=t.secondaryAccent, text=t.text, muted=t.textSoft,
        money=t.money, danger=t.danger, armor=t.armor, amber=t.warning, success=t.success, border=t.border, borderStrong=t.borderStrong, card=t.card, cardHover=t.cardHover }
end

vox.ui = vox.ui or {}
local function tc(name, fallback) local t = vox.ThemeTokens(); return t[name] or fallback or color_white end
local function rr(r) return math.max(0, r or 18) end

function vox.ui.DrawSoftShadow(x,y,w,h,r,a)
    draw.RoundedBox(rr(r), x + 6, y + 8, w, h, ColorAlpha(tc('shadow'), a or 115))
    draw.RoundedBox(rr(r), x + 2, y + 3, w, h, Color(0, 0, 0, 45))
end
function vox.ui.DrawGlowBorder(x,y,w,h,accent,r,alpha)
    accent = accent or tc('accent')
    surface.SetDrawColor(ColorAlpha(accent, alpha or 150)); surface.DrawOutlinedRect(x, y, w, h, 1)
    surface.SetDrawColor(ColorAlpha(accent, 70)); surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)
end
function vox.ui.DrawGlassPanel(x,y,w,h,state)
    state = state or {}; local accent = state.accent or tc('accent'); local radius = rr(state.radius or 18)
    vox.ui.DrawSoftShadow(x,y,w,h,radius,state.shadowAlpha)
    draw.RoundedBox(radius, x, y, w, h, ColorAlpha(state.color or tc('glass'), state.alpha or 225))
    if vox.DrawMatGradient then
        vox.DrawMatGradient(x, y, w, h, RIGHT, ColorAlpha(accent, state.glow or 24))
        vox.DrawMatGradient(x, y, w, h, BOTTOM, ColorAlpha(tc('secondaryAccent'), 14))
    end
    surface.SetDrawColor(tc('border')); surface.DrawOutlinedRect(x, y, w, h, 1)
    surface.SetDrawColor(ColorAlpha(accent, 170)); surface.DrawLine(x + radius, y + 1, x + math.min(w - radius, w * .42), y + 1)
end
function vox.ui.DrawCard(x,y,w,h,state)
    state = state or {}; local accent = state.accent or tc('accent')
    vox.ui.DrawGlassPanel(x,y,w,h,{radius=state.radius or 14, accent=accent, color=state.selected and tc('cardSelected') or (state.hovered and tc('cardHover') or tc('card')), alpha=state.alpha or 230, glow=state.hovered and 42 or 18})
    draw.RoundedBox(3, x + 10, y + 10, 3, h - 20, ColorAlpha(accent, state.hovered and 235 or 185))
end
function vox.ui.DrawAccentLine(x,y,w,h,accent) draw.RoundedBox(h*.5, x,y,w,h, ColorAlpha(accent or tc('accent'), 230)) end
function vox.ui.DrawStatusDot(x,y,r,accent,pulse) draw.RoundedBox(r, x-r, y-r, r*2, r*2, ColorAlpha(accent or tc('success'), pulse and (150+math.sin(CurTime()*5)*70) or 230)) end
function vox.ui.DrawAvatarBadge(x,y,s,accent) draw.RoundedBox(s*.5,x,y,s,s,tc('panelAlt')); vox.DrawOutlinedCircle(x+s*.5,y+s*.5,s*.5-1,2,accent or tc('accent')); vox.ui.DrawStatusDot(x+s-8,y+s-8,4,tc('success'),true) end
function vox.ui.DrawProgressBar(x,y,w,h,f,accent,bg) draw.RoundedBox(h*.5,x,y,w,h,bg or ColorAlpha(tc('text'),20)); draw.RoundedBox(h*.5,x,y,math.Clamp(f or 0,0,1)*w,h,accent or tc('accent')) end
function vox.ui.DrawStatRing(x,y,r,f,accent) vox.DrawOutlinedCircle(x,y,r,3,ColorAlpha(tc('text'),24)); vox.DrawOutlinedCircle(x,y,r,3,ColorAlpha(accent or tc('accent'),120 + 100*math.Clamp(f or 1,0,1))) end
function vox.ui.DrawBlurOverlay(panel,amount) if vox.DrawBlurExpensive then vox.DrawBlurExpensive(panel, amount or 8) end end

-- Legacy renderer aliases forced through the shared theme.
function vox.DrawVoxGlass(x,y,w,h,state) return vox.ui.DrawGlassPanel(x,y,w,h,state) end
function vox.DrawVoxPremiumCard(x,y,w,h,state) return vox.ui.DrawCard(x,y,w,h,state) end
function vox.DrawVoxPanel(x,y,w,h,colors,radius) return vox.ui.DrawGlassPanel(x,y,w,h,{radius=radius or 18, accent=(colors and colors.accent) or tc('accent')}) end
function vox.DrawVoxCard(x,y,w,h,colors,state) state=state or {}; state.accent=state.accent or (colors and colors.accent) or tc('accent'); return vox.ui.DrawCard(x,y,w,h,state) end
function vox.DrawVoxRow(x,y,w,h,colors,state) state=state or {}; state.radius=state.radius or 12; state.accent=state.accent or (colors and colors.accent) or tc('accent'); return vox.ui.DrawCard(x,y,w,h,state) end
function vox.DrawVoxBadge(x,y,w,h,label,colors,state) state=state or {}; local a=state.accent or (colors and colors.accent) or tc('accent'); draw.RoundedBox(h*.5,x,y,w,h,ColorAlpha(a,45)); surface.SetDrawColor(ColorAlpha(a,150)); surface.DrawOutlinedRect(x,y,w,h,1); draw.SimpleText(string.upper(tostring(label or '')), state.font or 'DermaDefaultBold', x+w*.5,y+h*.5,state.textColor or tc('text'),1,1) end

local function ensureComponent(name, base, methods)
    local PANEL = methods or {}; vox.gui.Register(name, PANEL, base or 'Panel')
end
local HoverCard = {}
function HoverCard:Init() self.voxHover = 0; self.accent = self.accent or tc('accent') end
function HoverCard:Think() self.voxHover = Lerp(FrameTime()*12, self.voxHover or 0, self:IsHovered() and 1 or 0) end
function HoverCard:Paint(w,h) vox.ui.DrawCard(0,0,w,h,{accent=self.accent, hovered=(self.voxHover or 0)>.08, selected=self.Selected}) end
local Button2 = {}
function Button2:Init() self.voxHover=0; self:SetTextColor(tc('text')); self:SetFont((vox.Font and vox.Font('Comfortaa Bold@15')) or 'DermaDefaultBold') end
function Button2:Think() self.voxHover=Lerp(FrameTime()*14,self.voxHover or 0,self:IsHovered() and 1 or 0) end
function Button2:Paint(w,h) vox.ui.DrawCard(0,0,w,h,{radius=12, accent=self.accent or tc('accent'), hovered=(self.voxHover or 0)>.08, alpha=218+25*(self.voxHover or 0)}); return false end
local Danger = table.Copy(Button2); function Danger:Init() Button2.Init(self); self.accent = tc('danger') end
local Entry2 = {}
function Entry2:Init() self:SetTall(42); self:SetFont((vox.Font and vox.Font('Comfortaa@15')) or 'DermaDefault'); self:SetTextColor(tc('text')); self:SetPlaceholderColor(tc('muted')) end
function Entry2:Paint(w,h) vox.ui.DrawGlassPanel(0,0,w,h,{radius=12, alpha=214}); self:DrawTextEntryText(tc('text'),tc('accent'),tc('text')) end
for _,n in ipairs({'VoxGlassPanel','VoxCard','VoxStatCard','VoxActionCard','VoxPlayerCard','VoxPlayerRow','VoxJobCard','VoxShopCard','VoxSettingsRow','VoxNotificationCard','VoxDoorCard','VoxWeaponSlot'}) do ensureComponent(n,'Panel',HoverCard) end
for _,n in ipairs({'VoxButton','VoxActionButton','VoxIconButton','VoxSidebarButton','VoxSidebarItem','VoxColumnHeader'}) do ensureComponent(n,'DButton',Button2) end
ensureComponent('VoxDangerButton','DButton',Danger)
for _,n in ipairs({'VoxSearchBox','VoxTextInput','VoxInput'}) do ensureComponent(n,'DTextEntry',Entry2) end
ensureComponent('VoxFrame','VoxRootFrame',{}); ensureComponent('VoxTopBar','VoxGlassPanel',{}); ensureComponent('VoxSidebar','vox.Sidebar',{}); ensureComponent('VoxTabBar','Panel',HoverCard); ensureComponent('VoxBadge','Panel',HoverCard)
ensureComponent('VoxToggle','vox.Toggler',{}); ensureComponent('VoxSlider','DNumSlider',{}); ensureComponent('VoxDropdown','vox.Combo',{}); ensureComponent('VoxScrollPanel','vox.ScrollPanel',{}); ensureComponent('VoxModal','VoxRootFrame',{}); ensureComponent('VoxContextMenu','vox.Menu',{}); ensureComponent('VoxRadialMenu','Panel',HoverCard); ensureComponent('VoxProgressBar','Panel',HoverCard); ensureComponent('VoxAvatarBadge','vox.RoundedAvatar',{}); ensureComponent('VoxModelStage','DModelPanel',{})
