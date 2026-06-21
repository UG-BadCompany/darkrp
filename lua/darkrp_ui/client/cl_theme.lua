DarkRPUI = DarkRPUI or {}; DarkRPUI.ActiveTheme = DarkRPUI.ActiveTheme or DarkRPUI.Config.DefaultTheme
function DarkRPUI.SetTheme(id) if not DarkRPUI.Themes[id] then return false end DarkRPUI.ActiveTheme = id hook.Run("DarkRPUI.ThemeChanged", id) return true end
