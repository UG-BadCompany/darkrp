DarkRPUI = DarkRPUI or {}; DarkRPUI.FontCache = DarkRPUI.FontCache or {}
function DarkRPUI.CreateFonts() for name, def in pairs(DarkRPUI.Fonts or {}) do local size = math.max(10, DarkRPUI.Util.Scale(def.size)) surface.CreateFont("DarkRPUI."..name, { font=def.font, size=size, weight=def.weight, extended=true, antialias=true }) end end
hook.Add("OnScreenSizeChanged", "DarkRPUI.Fonts.Rescale", DarkRPUI.CreateFonts)
hook.Add("Initialize", "DarkRPUI.Fonts.Init", DarkRPUI.CreateFonts)
DarkRPUI.CreateFonts()
