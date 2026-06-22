DarkRPUI = DarkRPUI or {}
DarkRPUI.Themes = DarkRPUI.Themes or {}

local function C(r,g,b,a) return Color(r,g,b,a or 255) end
local function theme(name, radius, colors)
    colors.panelAlt = colors.panelAlt or colors.panel
    colors.subtext = colors.subtext or colors.muted
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

function DarkRPUI.Theme(id)
    local active = id or DarkRPUI.ActiveTheme or (DarkRPUI.Settings and DarkRPUI.Settings.theme) or DarkRPUI.Config.DefaultTheme
    local t = DarkRPUI.Themes[active] or DarkRPUI.Themes.obsidian_blue
    if active == "custom_accent" and DarkRPUI.Settings and istable(DarkRPUI.Settings.accent) then
        t.colors.accent = Color(DarkRPUI.Settings.accent[1] or 74, DarkRPUI.Settings.accent[2] or 142, DarkRPUI.Settings.accent[3] or 255)
    end
    return t
end
function DarkRPUI.Color(name, alpha)
    local c = (DarkRPUI.Theme().colors and DarkRPUI.Theme().colors[name]) or color_white
    if alpha then return Color(c.r,c.g,c.b,alpha) end
    return c
end
function DarkRPUI.ThemeRadius(mult) return math.Round((DarkRPUI.Theme().radius or 16) * (mult or 1)) end
function DarkRPUI.WithAlpha(c, a) c = c or color_white return Color(c.r, c.g, c.b, a) end
function DarkRPUI.LerpColor(t, a, b) a=a or color_white; b=b or color_white; t=math.Clamp(t or 0,0,1); return Color(Lerp(t,a.r,b.r),Lerp(t,a.g,b.g),Lerp(t,a.b,b.b),Lerp(t,a.a or 255,b.a or 255)) end
