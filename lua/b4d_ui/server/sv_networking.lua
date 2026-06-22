util.AddNetworkString("B4DUI.AdminAction"); util.AddNetworkString("B4DUI.AdminLogs"); util.AddNetworkString("B4DUI.SettingsSync"); util.AddNetworkString("B4DUI.Notify")
function B4DUI.Notify(ply,msg,kind) net.Start("B4DUI.Notify"); net.WriteString(tostring(msg or "")); net.WriteString(tostring(kind or "info")); if IsValid(ply) then net.Send(ply) else net.Broadcast() end end
