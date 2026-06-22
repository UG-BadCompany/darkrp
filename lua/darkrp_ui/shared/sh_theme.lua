DarkRPUI = DarkRPUI or {}
DarkRPUI.Themes = DarkRPUI.Themes or {}

local function C(r,g,b,a) return Color(r,g,b,a or 255) end
local function theme(name, radius, colors)
    colors.frame = colors.frame or colors.panel
    colors.sidebar = colors.sidebar or colors.panel
    colors.panelDark = colors.panelDark or colors.background
    colors.panelAlt = colors.panelAlt or colors.panel
    colors.textSoft = colors.textSoft or colors.subtext or colors.muted
    colors.subtext = colors.subtext or colors.textSoft or colors.muted
    colors.accentSoft = colors.accentSoft or Color(colors.accent.r, colors.accent.g, colors.accent.b, 35)
    colors.borderSoft = colors.borderSoft or C(255,255,255,12)
    colors.purple = colors.purple or C(170,90,255)
    colors.info = colors.info or colors.accent
    colors.overlay = colors.overlay or colors.glass
    colors.disabled = colors.disabled or C(80,88,100,180)
    colors.locked = colors.locked or colors.error
    colors.highlight = colors.highlight or colors.accent
    return { name=name, radius=radius or 16, colors=colors }
end

function DarkRPUI.RegisterTheme(id, data)
    if not id or not istable(data) then return false end
    data.id = id
    DarkRPUI.Themes[id] = data
    return true
end

DarkRPUI.RegisterTheme("obsidian_blue", theme("Obsidian Blue", 18, {
    background=C(8,12,18), panel=C(14,20,30), card=C(20,29,42), cardHover=C(27,39,56), border=C(45,63,86),
    text=C(244,248,255), muted=C(142,157,178), accent=C(74,142,255), success=C(60,215,142), warning=C(255,190,76), error=C(255,82,105),
    shadow=C(0,0,0,190), glass=C(118,165,255,34)
}))
DarkRPUI.RegisterTheme("midnight_purple", theme("Midnight Purple", 18, {
    background=C(13,9,22), panel=C(22,15,36), card=C(31,22,49), cardHover=C(43,30,67), border=C(71,54,101),
    text=C(250,246,255), muted=C(171,153,196), accent=C(166,107,255), success=C(80,225,161), warning=C(255,196,86), error=C(255,89,133),
    shadow=C(0,0,0,195), glass=C(183,121,255,36)
}))
DarkRPUI.RegisterTheme("carbon_red", theme("Carbon Red", 16, {
    background=C(14,14,16), panel=C(22,22,25), card=C(31,31,35), cardHover=C(43,39,42), border=C(68,58,62),
    text=C(252,249,250), muted=C(166,158,162), accent=C(235,64,82), success=C(73,210,135), warning=C(255,176,61), error=C(255,70,82),
    shadow=C(0,0,0,205), glass=C(255,80,92,28)
}))
DarkRPUI.RegisterTheme("emerald_city", theme("Emerald City", 18, {
    background=C(6,18,16), panel=C(11,31,27), card=C(17,43,38), cardHover=C(23,59,51), border=C(44,91,78),
    text=C(240,255,250), muted=C(139,183,170), accent=C(48,220,151), success=C(74,235,154), warning=C(238,197,75), error=C(255,91,91),
    shadow=C(0,0,0,190), glass=C(67,255,181,30)
}))
DarkRPUI.RegisterTheme("gold_luxury", theme("Gold Luxury", 20, {
    background=C(18,14,8), panel=C(31,24,14), card=C(44,34,20), cardHover=C(62,47,26), border=C(99,77,43),
    text=C(255,250,235), muted=C(199,176,131), accent=C(245,190,80), success=C(82,215,142), warning=C(255,210,98), error=C(255,86,86),
    shadow=C(0,0,0,205), glass=C(255,205,99,30)
}))
DarkRPUI.RegisterTheme("clean_light", theme("Clean Light", 16, {
    background=C(235,239,247), panel=C(248,250,255), card=C(255,255,255), cardHover=C(240,246,255), border=C(202,213,229),
    text=C(24,32,44), muted=C(95,111,132), accent=C(55,118,245), success=C(36,175,105), warning=C(214,143,33), error=C(222,62,81),
    shadow=C(88,105,135,95), glass=C(255,255,255,145)
}))
DarkRPUI.RegisterTheme("custom_accent", theme("Custom Accent", 18, table.Copy(DarkRPUI.Themes.obsidian_blue.colors)))
DarkRPUI.Themes.dark_professional = DarkRPUI.Themes.obsidian_blue
if not istable(DarkRPUI.Theme) then DarkRPUI.Theme = {} end

-- 2026 design-token compatibility table requested by server owners.
DarkRPUI.Theme.ObsidianBlue = {
    background = C(15,17,23,245), frame = C(21,24,32,248), frameHeader = C(28,32,41,250), sidebar = C(32,37,46,250), sidebarDark = C(25,29,37,250),
    panel = C(31,35,44,245), panelDark = C(22,25,32,245), panelLight = C(39,44,54,245), card = C(36,41,51,245), cardDark = C(29,33,41,245), cardHover = C(46,53,64,250),
    row = C(30,34,42,230), rowHover = C(42,49,60,245), rowSelected = C(45,157,255,35), border = C(55,65,78,150), borderSoft = C(255,255,255,10),
    text = C(245,247,250), textSoft = C(190,198,210), muted = C(125,136,150), accent = C(45,157,255), accentHover = C(75,175,255), accentSoft = C(45,157,255,45),
    success = C(70,220,125), money = C(68,230,120), warning = C(255,195,70), error = C(245,80,90), armor = C(70,130,255), hunger = C(245,190,60), wanted = C(190,75,255),
    shadow = C(0,0,0,160), glass = C(15,17,23,210), disabled = C(80,85,95), locked = C(120,125,135)
}
DarkRPUI.RegisterTheme("cream_light", theme("Cream Light", 16, { background=C(246,241,230), panel=C(255,251,243), card=C(255,255,250), cardHover=C(248,239,222), border=C(214,196,164), text=C(35,31,26), muted=C(112,96,76), accent=C(64,128,245), success=C(38,170,100), warning=C(200,135,35), error=C(205,60,72), shadow=C(120,96,60,80), glass=C(255,248,235,170) }))
DarkRPUI.RegisterTheme("burgundy", theme("Burgundy", 18, { background=C(24,9,15), panel=C(39,15,25), card=C(54,22,35), cardHover=C(74,30,48), border=C(104,48,65), text=C(255,242,247), muted=C(196,144,160), accent=C(220,70,112), success=C(72,215,138), warning=C(255,190,70), error=C(255,80,95), shadow=C(0,0,0,205), glass=C(220,70,112,30) }))
DarkRPUI.Themes.clean_light.name = "Cream Light"

local function resolveTheme(id)
    local active = id or DarkRPUI.ActiveTheme or (DarkRPUI.Settings and DarkRPUI.Settings.theme) or DarkRPUI.Config.DefaultTheme
    local t = DarkRPUI.Themes[active] or DarkRPUI.Themes.obsidian_blue
    if active == "custom_accent" and DarkRPUI.Settings and istable(DarkRPUI.Settings.accent) then
        t.colors.accent = Color(DarkRPUI.Settings.accent[1] or 74, DarkRPUI.Settings.accent[2] or 142, DarkRPUI.Settings.accent[3] or 255)
        t.colors.accentSoft = Color(t.colors.accent.r, t.colors.accent.g, t.colors.accent.b, 35)
    end
    return t
end

DarkRPUI.Theme.Default = {
    name = "Obsidian Blue", background = C(18,20,27,245), frame = C(24,27,36,248), sidebar = C(30,35,43,248),
    panel = C(32,36,45,245), panelDark = C(20,22,29,245), card = C(37,42,51,245), cardHover = C(43,50,61,250),
    border = C(48,56,68,180), borderSoft = C(255,255,255,12), text = C(245,247,250), textSoft = C(195,203,215),
    muted = C(130,140,155), accent = C(45,157,255), accentSoft = C(45,157,255,35), success = C(68,220,120),
    warning = C(255,190,70), error = C(245,75,85), purple = C(170,90,255), shadow = C(0,0,0,150),
    glass = C(15,17,23,210), locked = C(130,130,145), disabled = C(70,75,85)
}
setmetatable(DarkRPUI.Theme, { __call = function(_, id) return resolveTheme(id) end })
function DarkRPUI.Color(name, alpha)
    local themeObj = DarkRPUI.Theme()
    local c = (themeObj.colors and themeObj.colors[name]) or DarkRPUI.Theme.ObsidianBlue[name] or DarkRPUI.Theme.Default[name] or color_white
    if alpha then return Color(c.r,c.g,c.b,alpha) end
    return c
end
function DarkRPUI.ThemeRadius(mult) return math.Round((DarkRPUI.Theme().radius or 16) * (mult or 1)) end
function DarkRPUI.WithAlpha(c, a) c = c or color_white return Color(c.r, c.g, c.b, a) end
function DarkRPUI.LerpColor(t, a, b) a=a or color_white; b=b or color_white; t=math.Clamp(t or 0,0,1); return Color(Lerp(t,a.r,b.r),Lerp(t,a.g,b.g),Lerp(t,a.b,b.b),Lerp(t,a.a or 255,b.a or 255)) end
