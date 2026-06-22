DarkRPUI = DarkRPUI or {}; DarkRPUI.WeaponSelector = DarkRPUI.WeaponSelector or { index=1, untilTime=0 }
local WS=DarkRPUI.WeaponSelector
local function weapons() local ply=LocalPlayer(); return IsValid(ply) and ply:GetWeapons() or {} end
function WS.Show(delta)
    local weps=weapons(); if #weps<1 then return true end
    WS.index=math.Clamp((WS.index or 1)+(delta or 0),1,#weps); WS.untilTime=CurTime()+2.2; surface.PlaySound("ui/buttonrollover.wav"); return true
end
hook.Add("PlayerBindPress","DarkRPUI.WeaponSelector",function(_,bind,pressed)
    if not pressed then return end; bind=string.lower(bind or "")
    if bind:find("invnext",1,true) then return WS.Show(1) end
    if bind:find("invprev",1,true) then return WS.Show(-1) end
    if bind:find("slot") then local n=tonumber(bind:match("slot(%d)")); if n then WS.index=n; WS.untilTime=CurTime()+2.2; return true end end
    if bind:find("+attack",1,true) and WS.untilTime>CurTime() then local w=weapons()[WS.index]; if IsValid(w) then RunConsoleCommand("use",w:GetClass()) end; WS.untilTime=0; return true end
end)
hook.Add("HUDPaint","DarkRPUI.DrawWeaponSelector",function()
    if (WS.untilTime or 0) <= CurTime() then return end
    local weps=weapons(); local count=math.min(#weps,6); if count<1 then return end
    local box=DarkRPUI.Util.Scale(118); local gap=DarkRPUI.Util.Scale(8); local w=count*box+(count-1)*gap; local h=DarkRPUI.Util.Scale(66); local x,y=DarkRPUI.Layout.Place({x="center",y="top"},w,h,0,18)
    for i=1,count do local wx=x+(i-1)*(box+gap); local active=i==WS.index; DarkRPUI.UI.ShadowedBox(12,wx,y,box,h,active and DarkRPUI.Color("accentSoft") or DarkRPUI.Color("card"),active and DarkRPUI.Color("accent") or DarkRPUI.Color("border"),90); DarkRPUI.UI.Text(tostring(i),"DarkRPUI.Tiny",wx+10,y+7,DarkRPUI.Color("muted")); DarkRPUI.UI.Text(IsValid(weps[i]) and (weps[i]:GetPrintName() or weps[i]:GetClass()) or "Empty","DarkRPUI.Small",wx+box/2,y+34,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
end)
