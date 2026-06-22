B4DUI = B4DUI or {}; B4DUI.AdminUI=B4DUI.AdminUI or {}; concommand.Add("b4d_admin",function() if B4DUI.HasPermission(LocalPlayer(),"admin_menu") then B4DUI.AdminUI.Open() end end)
