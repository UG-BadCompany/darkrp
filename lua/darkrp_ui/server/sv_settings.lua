net.Receive("DarkRPUI.SettingsSync", function(_, ply) ply.DarkRPUISettings = net.ReadTable() or {} end)
