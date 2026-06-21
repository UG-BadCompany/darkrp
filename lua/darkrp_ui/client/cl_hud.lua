DarkRPUI = DarkRPUI or {}; DarkRPUI.HUD = DarkRPUI.HUD or {}
local hide = { CHudHealth=true, CHudBattery=true, CHudAmmo=true, CHudSecondaryAmmo=true, DarkRP_HUD=true, DarkRP_EntityDisplay=true, DarkRP_ZombieInfo=true, DarkRP_LocalPlayerHUD=true, DarkRP_Hungermod=true, DarkRP_ArrestedHUD=true }
hook.Add("HUDShouldDraw", "DarkRPUI.HideDefaultHUD", function(name) if DarkRPUI.Config.EnableHUD and hide[name] then return false end end)

local state={hp=100,ar=0,hunger=100,money=0,salary=0,wanted=0,lockdown=0,voice=0, moneyFlash=0, lastMoney=nil}
local function lerp(k,target,speed) state[k]=DarkRPUI.UI.LerpValue(state[k] or target,target,speed or 9); return state[k] end
local function levelData(ply) if DarkRPUI.GetLevelData then return DarkRPUI.GetLevelData(ply) end return DarkRPUI.Util.DarkRPVar(ply,"level",1), DarkRPUI.Util.DarkRPVar(ply,"xp",0), DarkRPUI.Util.DarkRPVar(ply,"xpmax",100) end
local function bar(label,value,frac,col,x,y,w)
    DarkRPUI.UI.Text(label,"DarkRPUI.Tiny",x,y,DarkRPUI.Color("subtext")); DarkRPUI.UI.Text(value,"DarkRPUI.Body",x+w,y-2,DarkRPUI.Color("text"),TEXT_ALIGN_RIGHT)
    DarkRPUI.UI.RoundedBox(6,x,y+24,w,9,DarkRPUI.Color("border")); DarkRPUI.UI.RoundedBox(6,x,y+24,w*DarkRPUI.Util.Clamp(frac,0,1),9,col)
    surface.SetDrawColor(DarkRPUI.WithAlpha(color_white,22)); surface.DrawRect(x+2,y+26,math.max(0,w*DarkRPUI.Util.Clamp(frac,0,1)-4),2)
end
local function card(x,y,w,h,title,body,col)
    DarkRPUI.UI.OutlinedBox(15,x,y,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),235),DarkRPUI.Color("border")); surface.SetDrawColor((col or DarkRPUI.Color("accent")).r,(col or DarkRPUI.Color("accent")).g,(col or DarkRPUI.Color("accent")).b,210); surface.DrawRect(x,y,4,h)
    DarkRPUI.UI.Text(title,"DarkRPUI.Small",x+14,y+10,col or DarkRPUI.Color("accent")); draw.DrawText(body or "","DarkRPUI.Tiny",x+14,y+32,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT)
end
hook.Add("HUDPaint", "DarkRPUI.HUD.Paint", function()
    if not DarkRPUI.Config.EnableHUD or (DarkRPUI.Settings and DarkRPUI.Settings.hud == false) then return end
    local ply=LocalPlayer(); if not IsValid(ply) then return end
    local compact=DarkRPUI.Settings and DarkRPUI.Settings.compact; local s=(DarkRPUI.Settings and DarkRPUI.Settings.hud_scale or 1) * (compact and .86 or 1); local pad=DarkRPUI.Util.Scale(22*s); local w=DarkRPUI.Util.Scale((compact and 360 or 450)*s); local h=DarkRPUI.Util.Scale((compact and 116 or 154)*s); local y=ScrH()-h-pad
    local hp=lerp("hp",math.Clamp(ply:Health(),0,100),8); local ar=lerp("ar",math.Clamp(ply:Armor(),0,100),8); local hunger=lerp("hunger",DarkRPUI.Util.DarkRPVar(ply,"Energy",100),8)
    local money=DarkRPUI.Util.DarkRPVar(ply,"money",0); if state.lastMoney and money ~= state.lastMoney then state.moneyFlash=1 end; state.lastMoney=money; state.moneyFlash=DarkRPUI.UI.LerpValue(state.moneyFlash,0,4); state.money=DarkRPUI.UI.LerpValue(state.money or money,money,6); state.salary=DarkRPUI.UI.LerpValue(state.salary or 0,DarkRPUI.Util.DarkRPVar(ply,"salary",0),6)
    DarkRPUI.UI.OutlinedBox(18,pad,y,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),238),DarkRPUI.Color("border")); surface.SetDrawColor(team.GetColor(ply:Team())); surface.DrawRect(pad,y,5,h)
    DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Subtitle",pad+18,y+12); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Citizen","DarkRPUI.Small",pad+18,y+38,team.GetColor(ply:Team()))
    local bw=(w-54)/3; bar("HEALTH",math.Round(hp).."%",hp/100,DarkRPUI.Color("success"),pad+18,y+64,bw); bar("ARMOR",math.Round(ar).."%",ar/100,DarkRPUI.Color("accent"),pad+30+bw,y+64,bw); if not compact then bar("HUNGER",math.Round(hunger).."%",hunger/100,DarkRPUI.Color("warning"),pad+42+bw*2,y+64,bw) end
    local lvl,xp,xpmax=levelData(ply); DarkRPUI.UI.Text("LVL "..tostring(lvl).."   XP "..tostring(xp).."/"..tostring(xpmax),"DarkRPUI.Tiny",pad+18,y+h-24,DarkRPUI.Color("subtext"))
    local mw=DarkRPUI.Util.Scale(245*s); DarkRPUI.UI.OutlinedBox(16,pad+w+14,y,mw,76,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),230),DarkRPUI.LerpColor(state.moneyFlash,DarkRPUI.Color("border"),DarkRPUI.Color("success"))); DarkRPUI.UI.Text(DarkRPUI.Util.FormatMoney(math.Round(state.money)),"DarkRPUI.Number",pad+w+30,y+12,DarkRPUI.Color("success")); DarkRPUI.UI.Text("Salary "..DarkRPUI.Util.FormatMoney(math.Round(state.salary)),"DarkRPUI.Small",pad+w+32,y+48,DarkRPUI.Color("subtext"))
    local wep=ply:GetActiveWeapon(); if DarkRPUI.Config.HUD.showAmmo and IsValid(wep) and wep:Clip1() >= 0 then DarkRPUI.UI.OutlinedBox(16,ScrW()-pad-180,ScrH()-pad-74,180,62,DarkRPUI.Color("panel"),DarkRPUI.Color("border")); DarkRPUI.UI.Text(wep:Clip1().." / "..ply:GetAmmoCount(wep:GetPrimaryAmmoType()),"DarkRPUI.Number",ScrW()-pad-16,ScrH()-pad-62,DarkRPUI.Color("text"),TEXT_ALIGN_RIGHT); DarkRPUI.UI.Text("AMMO","DarkRPUI.Tiny",ScrW()-pad-164,ScrH()-pad-25,DarkRPUI.Color("subtext")) end
    state.voice=lerp("voice",ply:IsSpeaking() and 1 or 0,10); if state.voice>.02 then card(ScrW()/2-82,ScrH()-118,164,48,"VOICE","Transmitting microphone",DarkRPUI.Color("accent")) end
    state.wanted=lerp("wanted",DarkRPUI.Util.DarkRPVar(ply,"wanted",false) and 1 or 0,7); if state.wanted>.02 then card(ScrW()/2-180,24-30*(1-state.wanted),360,58,"WANTED","Police are actively searching for you",DarkRPUI.Color("error")) end
    state.lockdown=lerp("lockdown",GetGlobalBool("DarkRP_LockDown") and 1 or 0,7); if state.lockdown>.02 then card(ScrW()/2-190,88-30*(1-state.lockdown),380,58,"LOCKDOWN ACTIVE","Return indoors and await further instructions",DarkRPUI.Color("warning")) end
    if DarkRPUI.Config.HUD.showAgenda then local agenda=DarkRPUI.Util.DarkRPVar(ply,"agenda",nil); if agenda then card(ScrW()-pad-330,92,330,92,"AGENDA",tostring(agenda),DarkRPUI.Color("accent")) end end
    if DarkRPUI.Config.HUD.showLaws and DarkRP and DarkRP.getLaws then local laws=DarkRP.getLaws() or {}; if #laws>0 then local text=""; for i=1, math.min(#laws, DarkRPUI.Config.HUD.maxLaws or 6) do text=text..i..". "..laws[i].."\n" end; card(ScrW()-pad-330,196,330,132,"LAWS",text,DarkRPUI.Color("info")) end end
end)
