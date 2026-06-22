util.AddNetworkString("DarkRPUI.Notify")
util.AddNetworkString("DarkRPUI.SettingsSync")
util.AddNetworkString("DarkRPUI.Admin.Action")
util.AddNetworkString("DarkRPUI.Admin.Notify")
util.AddNetworkString("DarkRPUI.Admin.RequestPlayerInfo")
util.AddNetworkString("DarkRPUI.Admin.PlayerInfo")
function DarkRPUI.Notify(ply, kind, title, msg)
    net.Start("DarkRPUI.Notify"); net.WriteString(kind or "info"); net.WriteString(title or "Notice"); net.WriteString(msg or "")
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

util.AddNetworkString("DarkRPUI.Admin.RequestLogs")
util.AddNetworkString("DarkRPUI.Admin.Logs")