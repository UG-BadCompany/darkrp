DarkRPUI = DarkRPUI or {}
local hide = { CHudHealth=true, CHudBattery=true, CHudAmmo=true, CHudSecondaryAmmo=true, DarkRP_HUD=true, DarkRP_EntityDisplay=true, DarkRP_ZombieInfo=true, DarkRP_LocalPlayerHUD=true, DarkRP_Hungermod=true, DarkRP_Agenda=true, DarkRP_LockdownHUD=true, DarkRP_ArrestedHUD=true }
hook.Add("HUDShouldDraw", "DarkRPUI.HideDefaultHUD", function(name) if DarkRPUI.Config.EnableHUD and hide[name] then return false end end)
local function stat(label, value, frac, col, x, y, w)
    DarkRPUI.UI.Text(label,"DarkRPUI.Tiny",x,y,DarkRPUI.Color("subtext")); DarkRPUI.UI.Text(value,"DarkRPUI.Body",x,y+14,DarkRPUI.Color("text"));
    DarkRPUI.UI.RoundedBox(4,x,y+40,w,5,DarkRPUI.Color("border")); DarkRPUI.UI.RoundedBox(4,x,y+40,w*DarkRPUI.Util.Clamp(frac,0,1),5,col)
end
hook.Add("HUDPaint", "DarkRPUI.HUD.Paint", function()
    if not DarkRPUI.Config.EnableHUD or (DarkRPUI.Settings and DarkRPUI.Settings.hud == false) then return end
    local ply=LocalPlayer(); if not IsValid(ply) then return end
    local s=(DarkRPUI.Settings and DarkRPUI.Settings.hud_scale or 1); local pad=DarkRPUI.Util.Scale(22*s); local w=DarkRPUI.Util.Scale(420*s); local h=DarkRPUI.Util.Scale(126*s); local y=ScrH()-h-pad
    DarkRPUI.UI.RoundedBox(16,pad,y,w,h,DarkRPUI.Color("panel")); surface.SetDrawColor(DarkRPUI.Color("border")); surface.DrawOutlinedRect(pad,y,w,h,1)
    DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Subtitle",pad+18,y+14); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Citizen","DarkRPUI.Small",pad+18,y+40,team.GetColor(ply:Team()))
    stat("HEALTH", math.max(ply:Health(),0).."%", ply:Health()/100, DarkRPUI.Color("success"), pad+18,y+66,DarkRPUI.Util.Scale(115*s))
    stat("ARMOR", ply:Armor().."%", ply:Armor()/100, DarkRPUI.Color("accent"), pad+148,y+66,DarkRPUI.Util.Scale(115*s))
    local hunger = ply.getDarkRPVar and ply:getDarkRPVar("Energy") or 100; stat("HUNGER", tostring(hunger).."%", hunger/100, DarkRPUI.Color("warning"), pad+278,y+66,DarkRPUI.Util.Scale(115*s))
    local money = ply.getDarkRPVar and ply:getDarkRPVar("money") or 0; DarkRPUI.UI.Text(DarkRPUI.Util.FormatMoney(money),"DarkRPUI.Number",pad+w+18,y+8,DarkRPUI.Color("success"))
    local sal = ply.getDarkRPVar and ply:getDarkRPVar("salary") or 0; DarkRPUI.UI.Text("Salary "..DarkRPUI.Util.FormatMoney(sal),"DarkRPUI.Small",pad+w+20,y+38,DarkRPUI.Color("subtext"))
    if ply.getDarkRPVar and ply:getDarkRPVar("wanted") then DarkRPUI.UI.Text("WANTED", "DarkRPUI.Subtitle", ScrW()/2, 28, DarkRPUI.Color("error"), TEXT_ALIGN_CENTER) end
    if GetGlobalBool("DarkRP_LockDown") then DarkRPUI.UI.Text("LOCKDOWN ACTIVE", "DarkRPUI.Subtitle", ScrW()/2, 56, DarkRPUI.Color("warning"), TEXT_ALIGN_CENTER) end
    local wep=ply:GetActiveWeapon(); if IsValid(wep) and wep:Clip1() >= 0 then DarkRPUI.UI.Text(wep:Clip1().." / "..ply:GetAmmoCount(wep:GetPrimaryAmmoType()),"DarkRPUI.Number",ScrW()-pad, ScrH()-pad-40, DarkRPUI.Color("text"), TEXT_ALIGN_RIGHT) end
end)
