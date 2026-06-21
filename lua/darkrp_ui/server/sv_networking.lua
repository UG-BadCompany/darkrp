util.AddNetworkString("DarkRPUI.Notify"); util.AddNetworkString("DarkRPUI.AdminAction"); util.AddNetworkString("DarkRPUI.SettingsSync")
function DarkRPUI.Notify(ply, kind, title, msg) net.Start("DarkRPUI.Notify"); net.WriteString(kind or "info"); net.WriteString(title or "Notice"); net.WriteString(msg or ""); if IsValid(ply) then net.Send(ply) else net.Broadcast() end end
