B4DUI.ServerSettings=B4DUI.ServerSettings or table.Copy(B4DUI.Config)
net.Receive("B4DUI.SettingsSync",function(_,ply) if not B4DUI.HasPermission(ply,"settings_admin") then return end; B4DUI.ServerSettings=net.ReadTable() or B4DUI.ServerSettings; B4DUI.Notify(nil,"B4D UI settings updated by "..ply:Nick(),"success") end)
