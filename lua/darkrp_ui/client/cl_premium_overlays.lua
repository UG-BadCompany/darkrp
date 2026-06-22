DarkRPUI = DarkRPUI or {}
DarkRPUI.Radial = DarkRPUI.Radial or {}
DarkRPUI.WeaponSelector = DarkRPUI.WeaponSelector or { openUntil = 0, selectedSlot = 1 }

local function safeRect() return DarkRPUI.Layout.GetSafeRect() end
local function clamp(x,y,w,h) return DarkRPUI.Layout.ClampRect(x,y,w,h,true) end
local function tcol(name,a) return DarkRPUI.WithAlpha(DarkRPUI.Color(name), a or DarkRPUI.Color(name).a or 255) end

function DarkRPUI.Radial.Open(items, x, y, onChoose)
    local sx, sy, sw, sh = safeRect(); local size = DarkRPUI.Util.Scale(300)
    x, y = DarkRPUI.Layout.ClampToScreen((x or ScrW()/2) - size/2, (y or ScrH()/2) - size/2, size, size)
    DarkRPUI.Radial.Active = { items = items or {}, x = x, y = y, w = size, h = size, selected = 1, born = CurTime(), onChoose = onChoose }
    gui.EnableScreenClicker(true)
end
function DarkRPUI.Radial.Close(confirm)
    local r = DarkRPUI.Radial.Active; if not r then return end
    if confirm and r.onChoose and r.items[r.selected] then r.onChoose(r.items[r.selected], r.selected) end
    DarkRPUI.Radial.Active = nil; gui.EnableScreenClicker(false)
end
hook.Add("Think", "DarkRPUI.Radial.SafeClose", function() if DarkRPUI.Radial.Active and input.IsKeyDown(KEY_ESCAPE) then DarkRPUI.Radial.Close(false) end end)
hook.Add("HUDPaint", "DarkRPUI.Radial.Paint", function()
    local r = DarkRPUI.Radial.Active; if not r then return end
    local mx,my = gui.MousePos(); if mx <= 0 and my <= 0 then mx,my = ScrW()/2,ScrH()/2 end
    local cx,cy = r.x+r.w/2,r.y+r.h/2; local count=math.max(#r.items,1); local ang=math.deg(math.atan2(my-cy,mx-cx)); if ang<0 then ang=ang+360 end
    r.selected = math.Clamp(math.floor((ang/360)*count)+1,1,count)
    DarkRPUI.UI.ShadowedBox(r.w/2,r.x,r.y,r.w,r.h,tcol("glass",220),DarkRPUI.Color("border"),120)
    surface.SetDrawColor(tcol("accent",28)); surface.DrawOutlinedRect(cx-r.w*.42, cy-r.h*.42, r.w*.84, r.h*.84, 1)
    for i,it in ipairs(r.items) do local a=(i-0.5)/count*math.pi*2; local ix=cx+math.cos(a)*r.w*.31; local iy=cy+math.sin(a)*r.h*.31; local sel=i==r.selected
        DarkRPUI.UI.RoundedBox(14,ix-44,iy-24,88,48,sel and tcol("accent",210) or tcol("card",235)); DarkRPUI.UI.Text((it.icon or "•").." "..(it.label or it.name or "Action"),"DarkRPUI.Tiny",ix,iy-6,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER)
    end
    local it=r.items[r.selected] or {}; DarkRPUI.UI.Text(it.label or it.name or "Select","DarkRPUI.Subtitle",cx,cy-10,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER)
end)

hook.Add("PlayerBindPress", "DarkRPUI.WeaponSelector.Bind", function(ply, bind, pressed)
    if not pressed or not DarkRPUI.Settings or DarkRPUI.Settings.weapon_selector == false then return end
    local n = string.match(bind or "", "slot(%d)"); if not n then return end
    DarkRPUI.WeaponSelector.selectedSlot = tonumber(n) or 1; DarkRPUI.WeaponSelector.openUntil = CurTime()+1.8
end)
hook.Add("HUDPaint", "DarkRPUI.WeaponSelector.Paint", function()
    local ws = DarkRPUI.WeaponSelector; if (ws.openUntil or 0) < CurTime() then return end
    local ply=LocalPlayer(); if not IsValid(ply) then return end
    local sx,sy,sw = safeRect(); local w,h=DarkRPUI.Util.Scale(760),DarkRPUI.Util.Scale(108); local x,y=clamp(sx+sw/2-w/2,sy,w,h)
    DarkRPUI.UI.ShadowedBox(18,x,y,w,h,tcol("panel",238),DarkRPUI.Color("border"),110)
    for slot=1,6 do local bx=x+14+(slot-1)*((w-28)/6); local bw=(w-42)/6; local sel=slot==ws.selectedSlot; DarkRPUI.UI.RoundedBox(12,bx,y+14,bw,h-28,sel and tcol("accent",150) or DarkRPUI.Color("card")); DarkRPUI.UI.Text(tostring(slot),"DarkRPUI.Tiny",bx+10,y+22,DarkRPUI.Color("muted")); local name="Empty"; for _,wep in ipairs(ply:GetWeapons()) do if IsValid(wep) and (wep.Slot or 0)+1==slot then name=wep:GetPrintName() or wep:GetClass(); break end end; DarkRPUI.UI.Text(name,"DarkRPUI.Small",bx+bw/2,y+54,sel and DarkRPUI.Color("text") or DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER) end
end)

hook.Add("HUDPaint", "DarkRPUI.DoorProperty.Paint", function()
    if DarkRPUI.Settings and DarkRPUI.Settings.door_ui == false then return end
    local ply=LocalPlayer(); if not IsValid(ply) then return end
    local tr=ply:GetEyeTrace(); local ent=tr.Entity; if not IsValid(ent) or tr.HitPos:DistToSqr(ply:EyePos()) > 16000 then return end
    local isDoor = ent.isDoor and ent:isDoor() or string.find(string.lower(ent:GetClass() or ""), "door", 1, true)
    if not isDoor then return end
    local title = ent.getKeysTitle and ent:getKeysTitle() or "Property"
    local owner = ent.getDoorOwner and ent:getDoorOwner(); local owned = IsValid(owner)
    local body = owned and ("Owned by "..owner:Nick()) or ("For Sale" .. ((GAMEMODE and GAMEMODE.Config and GAMEMODE.Config.doorcost) and (" • Press F2 to buy for "..DarkRPUI.Util.FormatMoney(GAMEMODE.Config.doorcost)) or " • Press F2 to buy"))
    local w,h=DarkRPUI.Util.Scale(360),DarkRPUI.Util.Scale(72); local x,y=clamp(ScrW()/2-w/2,ScrH()/2+DarkRPUI.Util.Scale(120),w,h)
    DarkRPUI.UI.ShadowedBox(16,x,y,w,h,tcol("panel",235),DarkRPUI.Color("border"),95); DarkRPUI.UI.Text(title,"DarkRPUI.Subtitle",x+w/2,y+14,owned and DarkRPUI.Color("accent") or DarkRPUI.Color("success"),TEXT_ALIGN_CENTER); DarkRPUI.UI.Text(body,"DarkRPUI.Small",x+w/2,y+42,DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER)
end)

hook.Add("ShutDown", "DarkRPUI.ConnectionLost.Mark", function() DarkRPUI.ConnectionLost = true end)

-- Premium overhead identity cards: minimal, distance-faded name/job/wanted display.
hook.Add("PostPlayerDraw", "DarkRPUI.OverheadIdentity.Paint", function(ply)
    if ply == LocalPlayer() or not IsValid(ply) or not ply:Alive() then return end
    if DarkRPUI.Settings and DarkRPUI.Settings.overhead_ui == false then return end
    local lp=LocalPlayer(); if not IsValid(lp) then return end
    local dist=lp:GetPos():DistToSqr(ply:GetPos()); local max=DarkRPUI.Util.Scale(520)^2; if dist > max then return end
    local a=math.Clamp(255-(dist/max)*255,0,255); local pos=ply:EyePos()+Vector(0,0,12); local ang=EyeAngles(); ang:RotateAroundAxis(ang:Right(),90); ang:RotateAroundAxis(ang:Up(),-90)
    cam.Start3D2D(pos, Angle(0,ang.y,90), 0.065)
        local name=ply:Nick(); local job=team.GetName(ply:Team()) or "Citizen"; local col=team.GetColor(ply:Team()) or DarkRPUI.Color("accent")
        surface.SetFont("DarkRPUI.Body"); local nw=surface.GetTextSize(name); surface.SetFont("DarkRPUI.Small"); local jw=surface.GetTextSize(job); local w=math.max(nw,jw)+42; local h=54
        DarkRPUI.UI.ShadowedBox(12,-w/2,-h,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),math.min(a,220)),DarkRPUI.WithAlpha(DarkRPUI.Color("border"),a),70*a/255)
        DarkRPUI.UI.Text(name,"DarkRPUI.Body",0,-48,DarkRPUI.WithAlpha(DarkRPUI.Color("text"),a),TEXT_ALIGN_CENTER)
        DarkRPUI.UI.Text(job,"DarkRPUI.Small",0,-25,Color(col.r,col.g,col.b,a),TEXT_ALIGN_CENTER)
        if DarkRPUI.Util.DarkRPVar(ply,"wanted",false) then DarkRPUI.UI.Text("★ WANTED","DarkRPUI.Tiny",0,-8,DarkRPUI.WithAlpha(DarkRPUI.Color("error"),a),TEXT_ALIGN_CENTER) end
    cam.End3D2D()
end)

-- Theme-aware connection lost overlay for timeout/reconnect screens.
hook.Add("HUDPaint", "DarkRPUI.ConnectionLostOverlay.Paint", function()
    if not DarkRPUI.ConnectionLost then return end
    local w,h=ScrW(),ScrH(); surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("background"),235)); surface.DrawRect(0,0,w,h)
    local bw,bh=420,220; local x,y=w/2-bw/2,h/2-bh/2
    DarkRPUI.UI.ShadowedBox(22,x,y,bw,bh,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),245),DarkRPUI.Color("border"),150)
    DarkRPUI.UI.Text("⌁","DarkRPUI.Title",w/2,y+34,DarkRPUI.Color("error"),TEXT_ALIGN_CENTER)
    DarkRPUI.UI.Text("CONNECTION LOST","DarkRPUI.Title",w/2,y+82,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER)
    DarkRPUI.UI.Text("Attempting to reconnect. You can retry or disconnect.","DarkRPUI.Small",w/2,y+122,DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER)
    DarkRPUI.UI.RoundedBox(12,x+52,y+160,146,40,DarkRPUI.Color("accent")); DarkRPUI.UI.Text("Reconnect","DarkRPUI.Body",x+125,y+170,color_white,TEXT_ALIGN_CENTER)
    DarkRPUI.UI.RoundedBox(12,x+222,y+160,146,40,DarkRPUI.Color("card")); DarkRPUI.UI.Text("Disconnect","DarkRPUI.Body",x+295,y+170,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER)
end)
