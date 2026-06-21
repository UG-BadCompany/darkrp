DarkRPUI = DarkRPUI or {}; DarkRPUI.Settings = DarkRPUI.Settings or {}
local path="darkrp_ui/settings.txt"
local defaults={ theme="dark_professional", hud=true, hud_scale=1, notifications=true, favorites={} }
function DarkRPUI.LoadSettings() file.CreateDir("darkrp_ui"); local data=file.Exists(path,"DATA") and util.JSONToTable(file.Read(path,"DATA") or "") or {}; DarkRPUI.Settings=table.Merge(table.Copy(defaults), data or {}); DarkRPUI.SetTheme(DarkRPUI.Settings.theme or defaults.theme) end
function DarkRPUI.SaveSettings() file.Write(path, util.TableToJSON(DarkRPUI.Settings or defaults, true)) end
hook.Add("Initialize","DarkRPUI.Settings.Load",DarkRPUI.LoadSettings)
