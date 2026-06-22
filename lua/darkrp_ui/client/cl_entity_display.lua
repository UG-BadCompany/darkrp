DarkRPUI = DarkRPUI or {}
hook.Add("HUDPaint","DarkRPUI.PlayerOverhead",function()
 local lp=LocalPlayer(); if not IsValid(lp) then return end
 for _,p in ipairs(player.GetAll()) do if p~=lp and p:Alive() then local pos=p:EyePos()+Vector(0,0,12); local sp=pos:ToScreen(); if sp.visible then local d=lp:GetPos():Distance(p:GetPos()); if d<900 then local a=math.Clamp(255-(d-250)*.35,0,255); local job=team.GetName(p:Team()) or "Citizen"; local col=team.GetColor(p:Team()) or DarkRPUI.Color("accent"); DarkRPUI.UI.Text(p:Nick(),"DarkRPUI.Body",sp.x,sp.y,DarkRPUI.WithAlpha(DarkRPUI.Color("text"),a),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER); DarkRPUI.UI.Text((DarkRPUI.Util.DarkRPVar(p,"wanted",false) and "★ " or "")..job,"DarkRPUI.Small",sp.x,sp.y+17,Color(col.r,col.g,col.b,a),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end end end end
end)
