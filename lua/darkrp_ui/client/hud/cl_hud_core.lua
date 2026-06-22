DarkRPUI=DarkRPUI or {}; DarkRPUI.HUD=DarkRPUI.HUD or {}; DarkRPUI.HUD.Elements=DarkRPUI.HUD.Elements or {}
local hide={CHudHealth=true,CHudBattery=true,CHudAmmo=true,CHudSecondaryAmmo=true,DarkRP_HUD=true,DarkRP_EntityDisplay=true,DarkRP_LocalPlayerHUD=true,DarkRP_Hungermod=true}
function DarkRPUI.HUD.RegisterElement(id,data) data.id=id; DarkRPUI.HUD.Elements[id]=data end
function DarkRPUI.HUD.Enabled(id) local s=DarkRPUI.Settings or {}; if s.hud==false then return false end; if s["hud_"..id]==false then return false end; return DarkRPUI.Config.EnableHUD~=false end
hook.Add("HUDShouldDraw","DarkRPUI.HideDefaultHUD",function(n) if DarkRPUI.Config.EnableHUD and hide[n] then return false end end)
hook.Add("HUDPaint","DarkRPUI.HUD.PaintElements",function() for id,el in pairs(DarkRPUI.HUD.Elements) do if DarkRPUI.HUD.Enabled(id) and el.paint then el.paint(LocalPlayer()) end end end)
