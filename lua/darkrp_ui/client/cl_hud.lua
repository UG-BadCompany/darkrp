DarkRPUI = DarkRPUI or {}
local hide = { CHudHealth=true, CHudBattery=true, CHudAmmo=true, CHudSecondaryAmmo=true, DarkRP_HUD=true, DarkRP_EntityDisplay=true, DarkRP_ZombieInfo=true, DarkRP_LocalPlayerHUD=true, DarkRP_Hungermod=true, DarkRP_ArrestedHUD=true }
hook.Add("HUDShouldDraw", "DarkRPUI.HideDefaultHUD", function(name) if DarkRPUI.Config.EnableHUD and hide[name] then return false end end)
local function stat(label, value, frac, col, x, y, w) DarkRPUI.UI.Text(label,"DarkRPUI.Tiny",x,y,DarkRPUI.Color("subtext")); DarkRPUI.UI.Text(value,"DarkRPUI.Body",x,y+14); DarkRPUI.UI.RoundedBox(4,x,y+40,w,5,DarkRPUI.Color("border")); DarkRPUI.UI.RoundedBox(4,x,y+40,w*DarkRPUI.Util.Clamp(frac,0,1),5,col) end
local function levelData(ply) if DarkRPUI.GetLevelData then return DarkRPUI.GetLevelData(ply) end return DarkRPUI.Util.DarkRPVar(ply,"level",1), DarkRPUI.Util.DarkRPVar(ply,"xp",0), DarkRPUI.Util.DarkRPVar(ply,"xpmax",100) end
hook.Add("HUDPaint", "DarkRPUI.HUD.Paint", function()
    if not DarkRPUI.Config.EnableHUD or (DarkRPUI.Settings and DarkRPUI.Settings.hud == false) then return end
    local ply=LocalPlayer(); if not IsValid(ply) then return end
    local s=(DarkRPUI.Settings and DarkRPUI.Settings.hud_scale or 1); local pad=DarkRPUI.Util.Scale(22*s); local w=DarkRPUI.Util.Scale(430*s); local h=DarkRPUI.Util.Scale(142*s); local y=ScrH()-h-pad
    DarkRPUI.UI.OutlinedBox(16,pad,y,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border")); DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Subtitle",pad+18,y+14); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Citizen","DarkRPUI.Small",pad+18,y+40,team.GetColor(ply:Team()))
    stat("HEALTH", math.max(ply:Health(),0).."%", ply:Health()/100, DarkRPUI.Color("success"), pad+18,y+66,DarkRPUI.Util.Scale(120*s)); stat("ARMOR", ply:Armor().."%", ply:Armor()/100, DarkRPUI.Color("accent"), pad+154,y+66,DarkRPUI.Util.Scale(120*s)); local hunger=DarkRPUI.Util.DarkRPVar(ply,"Energy",100); stat("HUNGER", hunger.."%", hunger/100, DarkRPUI.Color("warning"), pad+290,y+66,DarkRPUI.Util.Scale(120*s))
    local lvl,xp,xpmax=levelData(ply); DarkRPUI.UI.Text("LVL "..tostring(lvl).."  XP "..tostring(xp).."/"..tostring(xpmax),"DarkRPUI.Tiny",pad+18,y+120,DarkRPUI.Color("subtext"))
    DarkRPUI.UI.Text(DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"money",0)),"DarkRPUI.Number",pad+w+18,y+8,DarkRPUI.Color("success")); DarkRPUI.UI.Text("Salary "..DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"salary",0)),"DarkRPUI.Small",pad+w+20,y+38,DarkRPUI.Color("subtext"))
    if DarkRPUI.Util.DarkRPVar(ply,"wanted",false) then DarkRPUI.UI.Text("WANTED", "DarkRPUI.Subtitle", ScrW()/2, 28, DarkRPUI.Color("error"), TEXT_ALIGN_CENTER) end
    if GetGlobalBool("DarkRP_LockDown") then DarkRPUI.UI.Text("LOCKDOWN ACTIVE", "DarkRPUI.Subtitle", ScrW()/2, 56, DarkRPUI.Color("warning"), TEXT_ALIGN_CENTER) end
    if ply:IsSpeaking() then DarkRPUI.UI.Text("VOICE", "DarkRPUI.Subtitle", ScrW()/2, ScrH()-90, DarkRPUI.Color("accent"), TEXT_ALIGN_CENTER) end
    local wep=ply:GetActiveWeapon(); if DarkRPUI.Config.HUD.showAmmo and IsValid(wep) and wep:Clip1() >= 0 then DarkRPUI.UI.Text(wep:Clip1().." / "..ply:GetAmmoCount(wep:GetPrimaryAmmoType()),"DarkRPUI.Number",ScrW()-pad, ScrH()-pad-40, DarkRPUI.Color("text"), TEXT_ALIGN_RIGHT) end
    local agenda=DarkRPUI.Util.DarkRPVar(ply,"agenda",nil); if agenda then DarkRPUI.UI.Text("AGENDA: "..tostring(agenda),"DarkRPUI.Small",ScrW()-pad,92,DarkRPUI.Color("subtext"),TEXT_ALIGN_RIGHT) end
    if DarkRP and DarkRP.getLaws then local laws=DarkRP.getLaws() or {}; for i=1, math.min(#laws, DarkRPUI.Config.HUD.maxLaws or 6) do DarkRPUI.UI.Text(i..". "..laws[i],"DarkRPUI.Tiny",ScrW()-pad,112+i*16,DarkRPUI.Color("muted"),TEXT_ALIGN_RIGHT) end end
end)
