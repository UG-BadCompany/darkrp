net.Receive("DarkRPUI.Notify", function() DarkRPUI.Notify(net.ReadString(), net.ReadString(), net.ReadString()) end)
function DarkRPUI.SyncSettings() net.Start("DarkRPUI.SettingsSync"); net.WriteTable(DarkRPUI.Settings or {}); net.SendToServer() end
