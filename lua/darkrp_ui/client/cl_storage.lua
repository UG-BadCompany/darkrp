DarkRPUI = DarkRPUI or {}; DarkRPUI.Settings = DarkRPUI.Settings or {}
local path="darkrp_ui/settings.txt"
local defaults={ theme="obsidian_blue", accent={74,142,255}, hud=true, hud_scale=1, hud_style="Dashboard", hud_position="bottom-left", blur=true, blur_strength=8, notifications=true, notification_position="top-right", sounds=true, compact=false, show_money=true, show_salary=true, show_hunger=true, show_level=true, show_ammo=true, show_laws=true, show_agenda=true, animation_speed=1, reduce_motion=false, font_scale=1, favorites={} }
function DarkRPUI.LoadSettings()
    file.CreateDir("darkrp_ui")
    local data = file.Exists(path,"DATA") and util.JSONToTable(file.Read(path,"DATA") or "") or {}
    DarkRPUI.Settings = table.Merge(table.Copy(defaults), istable(data) and data or {})
    DarkRPUI.SetTheme(DarkRPUI.Settings.theme or defaults.theme)
end
function DarkRPUI.SaveSettings() file.CreateDir("darkrp_ui"); file.Write(path, util.TableToJSON(DarkRPUI.Settings or defaults, true)) end
hook.Add("Initialize","DarkRPUI.Settings.Load",DarkRPUI.LoadSettings)
timer.Simple(0, function() if not DarkRPUI.Settings.theme then DarkRPUI.LoadSettings() end end)
