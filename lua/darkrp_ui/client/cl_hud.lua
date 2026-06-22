DarkRPUI = DarkRPUI or {}; DarkRPUI.HUD = DarkRPUI.HUD or {}
local hide = { CHudHealth=true, CHudBattery=true, CHudAmmo=true, CHudSecondaryAmmo=true, DarkRP_HUD=true, DarkRP_EntityDisplay=true, DarkRP_ZombieInfo=true, DarkRP_LocalPlayerHUD=true, DarkRP_Hungermod=true, DarkRP_ArrestedHUD=true }
hook.Add("HUDShouldDraw", "DarkRPUI.HideDefaultHUD", function(name) if DarkRPUI.Config.EnableHUD and hide[name] then return false end end)

local state={hp=100,ar=0,hunger=100,money=0,salary=0,wanted=0,lockdown=0,voice=0, moneyFlash=0, lastMoney=nil, ammo=0, reserve=0}
local function lerp(k,target,speed) state[k]=DarkRPUI.UI.LerpValue(state[k] or target,target,speed or 12); return state[k] end
local function levelData(ply) if DarkRPUI.GetLevelData then return DarkRPUI.GetLevelData(ply) end return DarkRPUI.Util.DarkRPVar(ply,"level",1), DarkRPUI.Util.DarkRPVar(ply,"xp",0), DarkRPUI.Util.DarkRPVar(ply,"xpmax",100) end
local function bar(icon,label,value,frac,col,x,y,w,compact)
    DarkRPUI.UI.Text(icon,"DarkRPUI.Small",x,y-2,col); if not compact then DarkRPUI.UI.Text(label,"DarkRPUI.Tiny",x+20,y,DarkRPUI.Color("subtext")) end
    DarkRPUI.UI.Text(value,"DarkRPUI.Body",x+w,y-2,DarkRPUI.Color("text"),TEXT_ALIGN_RIGHT)
    DarkRPUI.UI.RoundedBox(6,x,y+24,w,9,DarkRPUI.WithAlpha(DarkRPUI.Color("border"),190)); DarkRPUI.UI.RoundedBox(6,x,y+24,w*DarkRPUI.Util.Clamp(frac,0,1),9,col)
    surface.SetDrawColor(DarkRPUI.WithAlpha(color_white,24)); surface.DrawRect(x+2,y+26,math.max(0,w*DarkRPUI.Util.Clamp(frac,0,1)-4),2)
end
local function card(x,y,w,h,title,body,col,alpha,icon)
    if DarkRPUI.Layout then x,y,w,h = DarkRPUI.Layout.ClampRect(x,y,w,h,true) end
    alpha=alpha or 1; col=col or DarkRPUI.Color("accent")
    DarkRPUI.UI.ShadowedBox(18,x,y,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),238*alpha),DarkRPUI.WithAlpha(DarkRPUI.Color("border"),255*alpha),112*alpha)
    surface.SetDrawColor(col.r,col.g,col.b,215*alpha); surface.DrawRect(x,y+10,4,h-20)
    surface.SetDrawColor(DarkRPUI.WithAlpha(col,22*alpha)); surface.DrawRect(x+5,y+1,w-10,math.max(1,h-2))
    surface.SetDrawColor(DarkRPUI.WithAlpha(color_white,18*alpha)); surface.DrawRect(x+12,y+8,w-24,1)
    if icon then DarkRPUI.UI.Text(icon,"DarkRPUI.Body",x+14,y+10,col); DarkRPUI.UI.Text(title,"DarkRPUI.Small",x+40,y+11,col) else DarkRPUI.UI.Text(title,"DarkRPUI.Small",x+14,y+10,col) end
    draw.DrawText(body or "","DarkRPUI.Tiny",x+14,y+34,DarkRPUI.WithAlpha(DarkRPUI.Color("subtext"),255*alpha),TEXT_ALIGN_LEFT)
end
hook.Add("HUDPaint", "DarkRPUI.HUD.Paint", function()
    if not DarkRPUI.Config.EnableHUD or (DarkRPUI.Settings and DarkRPUI.Settings.hud == false) then return end
    local ply=LocalPlayer(); if not IsValid(ply) then return end
    local compact=DarkRPUI.Settings and DarkRPUI.Settings.compact; local show=DarkRPUI.Settings or {}; local style=show.hud_style or (compact and "Compact Corner" or "Modern Bar"); compact = compact or style == "Compact Corner"; local resScale=(DarkRPUI.Config.LowResolutionScale ~= false) and math.Clamp(ScrW()/1280, .78, 1) or 1; local s=(DarkRPUI.Settings and DarkRPUI.Settings.hud_scale or 1) * (compact and .86 or 1) * resScale; local sx,sy,sw,sh = DarkRPUI.Layout.GetSafeRect(); local pad=DarkRPUI.Util.Scale(0); local w=DarkRPUI.Util.Scale((style == "Center Minimal" and 360 or (compact and 314 or 430))*s); local h=DarkRPUI.Util.Scale((style == "Modern Bar" and 124 or (compact and 96 or 144))*s); local pos=show.hud_position or "bottom-left"; local x=(style == "Center Minimal" and (sx+sw/2-w/2) or (string.find(pos,"right",1,true) and (sx+sw-w-pad) or sx+pad)); local y=(style == "Center Minimal" and (sy+sh-h-DarkRPUI.Util.Scale(12)) or (string.find(pos,"top",1,true) and sy+pad or (sy+sh-h-pad))); x,y,w,h = DarkRPUI.Layout.ClampRect(x,y,w,h,true)
    local hp=lerp("hp",math.Clamp(ply:Health(),0,100),10); local ar=lerp("ar",math.Clamp(ply:Armor(),0,100),10); local hunger=lerp("hunger",DarkRPUI.Util.DarkRPVar(ply,"Energy",100),10)
    local money=DarkRPUI.Util.DarkRPVar(ply,"money",0); if state.lastMoney and money ~= state.lastMoney then state.moneyFlash=1 end; state.lastMoney=money; state.moneyFlash=DarkRPUI.UI.LerpValue(state.moneyFlash,0,6); state.money=DarkRPUI.UI.LerpValue(state.money or money,money,7); state.salary=DarkRPUI.UI.LerpValue(state.salary or 0,DarkRPUI.Util.DarkRPVar(ply,"salary",0),7)
    DarkRPUI.UI.ShadowedBox(20,x,y,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),240),DarkRPUI.Color("border"),125); surface.SetDrawColor(team.GetColor(ply:Team())); surface.DrawRect(x,y+12,5,h-24); surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("glass"),70)); surface.DrawRect(x+6,y+1,w-12,h-2); surface.SetDrawColor(DarkRPUI.WithAlpha(color_white,16)); surface.DrawRect(x+16,y+8,w-32,1)
    DarkRPUI.UI.Text(compact and "◈" or ply:Nick(),"DarkRPUI.Subtitle",x+18,y+12); DarkRPUI.UI.Text((compact and ply:Nick().." • " or "")..(team.GetName(ply:Team()) or "Citizen"),"DarkRPUI.Small",x+18,y+38,team.GetColor(ply:Team()))
    local bw=(w-(compact and 48 or 54))/(compact and 2 or 3); bar("♥","HEALTH",math.Round(hp).."%",hp/100,DarkRPUI.Color("success"),x+18,y+64,bw,compact); bar("◆","ARMOR",math.Round(ar).."%",ar/100,DarkRPUI.Color("accent"),x+30+bw,y+64,bw,compact); if not compact and show.show_hunger ~= false then bar("●","HUNGER",math.Round(hunger).."%",hunger/100,DarkRPUI.Color("warning"),x+42+bw*2,y+64,bw,false) end
    local lvl,xp,xpmax=levelData(ply); if not compact and show.show_level ~= false then DarkRPUI.UI.Text("LVL "..tostring(lvl).."   XP "..tostring(xp).."/"..tostring(xpmax),"DarkRPUI.Tiny",x+18,y+h-24,DarkRPUI.Color("subtext")) end
    if show.show_money ~= false then
        local moneyCol=DarkRPUI.LerpColor(state.moneyFlash,DarkRPUI.Color("success"),DarkRPUI.Color("text"))
        DarkRPUI.UI.Text(DarkRPUI.Util.FormatMoney(math.Round(state.money)),"DarkRPUI.Number",x+w-18,y+12,moneyCol,TEXT_ALIGN_RIGHT)
        if not compact and show.show_salary ~= false then DarkRPUI.UI.Text("Salary "..DarkRPUI.Util.FormatMoney(math.Round(state.salary)),"DarkRPUI.Tiny",x+w-18,y+42,DarkRPUI.Color("subtext"),TEXT_ALIGN_RIGHT) end
    end
    local wep=ply:GetActiveWeapon(); if show.show_ammo ~= false and DarkRPUI.Config.HUD.showAmmo and IsValid(wep) and wep:Clip1() >= 0 then local clip=lerp("ammo",wep:Clip1(),12); local reserve=lerp("reserve",ply:GetAmmoCount(wep:GetPrimaryAmmoType()),12); local aw=compact and 150 or 205; local ah=compact and 58 or 76; local ax,ay=DarkRPUI.Layout.ClampRect(sx+sw-aw, sy+sh-ah, aw, ah, true); DarkRPUI.UI.ShadowedBox(18,ax,ay,aw,ah,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),235),DarkRPUI.Color("border"),105); surface.SetDrawColor(DarkRPUI.Color("warning")); surface.DrawRect(ax,ay+10,4,ah-20); DarkRPUI.UI.Text("⌁","DarkRPUI.Body",ax+14,ay+12,DarkRPUI.Color("warning")); DarkRPUI.UI.Text(math.Round(clip).." / "..math.Round(reserve),"DarkRPUI.Number",ax+aw-14,ay+10,DarkRPUI.Color("text"),TEXT_ALIGN_RIGHT); if not compact then DarkRPUI.UI.Text(string.upper(wep:GetPrintName() or "AMMO"),"DarkRPUI.Tiny",ax+16,ay+50,DarkRPUI.Color("subtext")) end end
    state.voice=lerp("voice",ply:IsSpeaking() and 1 or 0,12); if state.voice>.02 then local pulse=(math.sin(CurTime()*9)*.5+.5)*state.voice; card(sx+sw/2-92,sy+sh-94-10*pulse,184,50,"VOICE","Transmitting microphone",DarkRPUI.Color("accent"),state.voice,"◍") end
    state.wanted=lerp("wanted",DarkRPUI.Util.DarkRPVar(ply,"wanted",false) and 1 or 0,9); if state.wanted>.02 then card(sx+sw/2-190,sy-34*(1-state.wanted),380,60,"WANTED","Police are actively searching for you",DarkRPUI.Color("error"),state.wanted,"!") end
    state.lockdown=lerp("lockdown",GetGlobalBool("DarkRP_LockDown") and 1 or 0,9); if state.lockdown>.02 then card(sx+sw/2-200,sy+66-34*(1-state.lockdown),400,60,"LOCKDOWN ACTIVE","Return indoors and await further instructions",DarkRPUI.Color("warning"),state.lockdown,"⚑") end
    if not compact and show.show_agenda ~= false and DarkRPUI.Config.HUD.showAgenda then local agenda=DarkRPUI.Util.DarkRPVar(ply,"agenda",nil); if agenda then card(sx+sw-330,sy+68,330,96,"AGENDA",tostring(agenda),DarkRPUI.Color("accent"),1,"▣") end end
    if not compact and show.show_laws ~= false and DarkRPUI.Config.HUD.showLaws and DarkRP and DarkRP.getLaws then local laws=DarkRP.getLaws() or {}; if #laws>0 then local text=""; for i=1, math.min(#laws, DarkRPUI.Config.HUD.maxLaws or 6) do text=text.."• "..laws[i].."\n" end; card(sx+sw-330,sy+178,330,138,"CITY LAWS",text,DarkRPUI.Color("info"),1,"§") end end
end)
