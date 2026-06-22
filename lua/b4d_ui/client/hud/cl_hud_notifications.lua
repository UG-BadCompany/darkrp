B4DUI = B4DUI or {}; B4DUI.HUD=B4DUI.HUD or {Elements={}}
B4DUI.Notifications=B4DUI.Notifications or {}; function B4DUI.PushNotification(msg,kind) table.insert(B4DUI.Notifications,1,{msg=msg,kind=kind or "info",life=CurTime()+5}) end
B4DUI.HUD.Register("Notifications",function() local x,y=ScrW()-340,80; for i,n in ipairs(B4DUI.Notifications) do if n.life<CurTime() then table.remove(B4DUI.Notifications,i) else draw.RoundedBox(10,x,y+(i-1)*54,310,44,B4DUI.Color("panel")); draw.SimpleText(n.msg,"B4D.Small",x+14,y+12+(i-1)*54,B4DUI.Color("text")) end end end)
