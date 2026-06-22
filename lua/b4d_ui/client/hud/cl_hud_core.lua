B4DUI = B4DUI or {}; B4DUI.HUD=B4DUI.HUD or {Elements={}}
function B4DUI.HUD.Register(id,paint) B4DUI.HUD.Elements[id]=paint end
hook.Add("HUDShouldDraw","B4DUI.HideDefault",function(n) if {CHudHealth=true,CHudBattery=true,CHudAmmo=true,CHudSecondaryAmmo=true,DarkRP_HUD=true,DarkRP_EntityDisplay=true,DarkRP_LocalPlayerHUD=true,DarkRP_Hungermod=true}[n] then return false end end)
hook.Add("HUDPaint","B4DUI.PaintHUD",function() for id,fn in pairs(B4DUI.HUD.Elements) do if B4DUI.Config.HUD[id]~=false then fn() end end end)
