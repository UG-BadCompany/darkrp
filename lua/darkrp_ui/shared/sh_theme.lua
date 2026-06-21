DarkRPUI = DarkRPUI or {}
DarkRPUI.Themes = DarkRPUI.Themes or {}

local function copyColor(c) return Color(c.r, c.g, c.b, c.a or 255) end
function DarkRPUI.RegisterTheme(id, data)
    if not id or not istable(data) then return false end
    data.id = id
    DarkRPUI.Themes[id] = data
    return true
end

DarkRPUI.RegisterTheme("dark_professional", {
    name = "Dark Professional",
    radius = 14,
    colors = {
        background=Color(17,19,21), panel=Color(24,27,31), panelAlt=Color(20,23,27), card=Color(32,37,43),
        cardHover=Color(39,45,52), border=Color(42,49,58), text=Color(255,255,255), subtext=Color(168,176,186),
        muted=Color(105,113,124), accent=Color(79,140,255), success=Color(60,210,130), error=Color(255,80,96),
        warning=Color(255,190,70), info=Color(90,170,255), shadow=Color(0,0,0,180), overlay=Color(8,10,12,230)
    }
})
DarkRPUI.RegisterTheme("midnight_purple", { name="Midnight Purple", radius=16, colors=table.Copy(DarkRPUI.Themes.dark_professional.colors) })
DarkRPUI.Themes.midnight_purple.colors.accent = Color(155,105,255)

function DarkRPUI.Theme(id) return DarkRPUI.Themes[id or DarkRPUI.ActiveTheme or DarkRPUI.Config.DefaultTheme] or DarkRPUI.Themes.dark_professional end
function DarkRPUI.Color(name, alpha)
    local t = DarkRPUI.Theme()
    local c = (t.colors and t.colors[name]) or color_white
    if alpha then c = Color(c.r, c.g, c.b, alpha) end
    return c
end
function DarkRPUI.ThemeRadius(mult) return math.Round((DarkRPUI.Theme().radius or 12) * (mult or 1)) end
function DarkRPUI.WithAlpha(c, a) c = c or color_white return Color(c.r, c.g, c.b, a) end
function DarkRPUI.LerpColor(t, a, b) a = a or color_white; b = b or color_white; t = math.Clamp(t or 0, 0, 1); return Color(Lerp(t, a.r, b.r), Lerp(t, a.g, b.g), Lerp(t, a.b, b.b), Lerp(t, a.a or 255, b.a or 255)) end
