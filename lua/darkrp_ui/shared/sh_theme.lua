DarkRPUI = DarkRPUI or {}
DarkRPUI.Themes = DarkRPUI.Themes or {}
function DarkRPUI.RegisterTheme(id, data) data.id = id DarkRPUI.Themes[id] = data end
DarkRPUI.RegisterTheme("dark_professional", { name = "Dark Professional", colors = { background=Color(17,19,21), panel=Color(24,27,31), card=Color(32,37,43), border=Color(42,49,58), text=Color(255,255,255), subtext=Color(168,176,186), accent=Color(79,140,255), success=Color(60,210,130), error=Color(255,80,96), warning=Color(255,190,70), info=Color(90,170,255), shadow=Color(0,0,0,180) } })
function DarkRPUI.Theme(id) return DarkRPUI.Themes[id or DarkRPUI.Config.DefaultTheme] or DarkRPUI.Themes.dark_professional end
function DarkRPUI.Color(name) local t = DarkRPUI.Theme(DarkRPUI.ActiveTheme) return (t.colors and t.colors[name]) or color_white end
