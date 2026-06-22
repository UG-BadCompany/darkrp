B4DUI = B4DUI or {}; B4DUI.ClientSettings=B4DUI.ClientSettings or {}
function B4DUI.SaveClientSettings() file.CreateDir("b4d_ui"); file.Write("b4d_ui/settings.json",util.TableToJSON(B4DUI.ClientSettings,true)) end
function B4DUI.LoadClientSettings() if file.Exists("b4d_ui/settings.json","DATA") then B4DUI.ClientSettings=util.JSONToTable(file.Read("b4d_ui/settings.json","DATA") or "{}") or {} end end
B4DUI.LoadClientSettings()
