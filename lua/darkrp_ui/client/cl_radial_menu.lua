DarkRPUI = DarkRPUI or {}; DarkRPUI.Radial = DarkRPUI.Radial or { open=false, items={} }
local R=DarkRPUI.Radial
function DarkRPUI.OpenRadial(items, opts) R.items=items or {}; R.opts=opts or {}; R.open=true; R.started=CurTime(); gui.EnableScreenClicker(true) end
DarkRPUI.Radial.Open = DarkRPUI.OpenRadial
function DarkRPUI.CloseRadial(run) if run and R.selected and R.items[R.selected] and isfunction(R.items[R.selected].callback) then R.items[R.selected].callback() end; R.open=false; gui.EnableScreenClicker(false) end
DarkRPUI.Radial.Close = DarkRPUI.CloseRadial
hook.Add("Think","DarkRPUI.RadialThink",function() if R.open and input.IsKeyDown(KEY_ESCAPE) then DarkRPUI.CloseRadial(false) end end)
hook.Add("HUDPaint","DarkRPUI.RadialPaint",function()
 if not R.open then return end; local cx,cy=ScrW()/2,ScrH()/2; local radius=DarkRPUI.Util.Scale(150); local inner=DarkRPUI.Util.Scale(58); local n=math.max(#R.items,1); local mx,my=gui.MousePos(); local ang=math.deg(math.atan2(my-cy,mx-cx)); if ang<0 then ang=ang+360 end; R.selected=math.floor((ang+90/ n)/(360/n))%n+1; surface.SetDrawColor(0,0,0,115); surface.DrawRect(0,0,ScrW(),ScrH())
 for i,it in ipairs(R.items) do local a=(i-1)/n*math.pi*2-math.pi/2; local px=cx+math.cos(a)*radius*.62; local py=cy+math.sin(a)*radius*.62; local sel=i==R.selected; draw.NoTexture(); DarkRPUI.UI.RoundedBox(18,px-52,py-26,104,52,sel and DarkRPUI.Color("accent") or DarkRPUI.Color("glass")); DarkRPUI.UI.Text(it.icon or it.label or "•","DarkRPUI.Subtitle",px,py-8,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER); if it.label then DarkRPUI.UI.Text(it.label,"DarkRPUI.Tiny",px,py+12,DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end end
 DarkRPUI.UI.RoundedBox(inner,cx-inner,cy-inner,inner*2,inner*2,DarkRPUI.Color("panel")); local label=(R.items[R.selected] and R.items[R.selected].label) or (R.opts.title or "Select"); DarkRPUI.UI.Text(label,"DarkRPUI.Body",cx,cy,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end)
hook.Add("GUIMousePressed","DarkRPUI.RadialClick",function(code) if R.open and code==MOUSE_LEFT then DarkRPUI.CloseRadial(true); return true elseif R.open and code==MOUSE_RIGHT then DarkRPUI.CloseRadial(false); return true end end)
