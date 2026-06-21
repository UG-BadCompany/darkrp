DarkRPUI = DarkRPUI or {}; DarkRPUI.Notifications = DarkRPUI.Notifications or {}
local queue, active = {}, {}
local meta = { success="success", error="error", warning="warning", info="info", event="accent" }
function DarkRPUI.Notify(kind, title, msg, duration)
    if DarkRPUI.Settings and DarkRPUI.Settings.notifications == false then return end
    table.insert(queue, { kind=kind or "info", title=title or "Notice", msg=msg or "", duration=duration or 5, born=CurTime(), x=ScrW()+420 })
    if DarkRPUI.Config.SoundEnabled then surface.PlaySound(DarkRPUI.Config.NotificationSound) end
end
hook.Add("Think", "DarkRPUI.Notifications.Queue", function() while #active < 5 and #queue > 0 do table.insert(active, table.remove(queue,1)) end end)
hook.Add("HUDPaint", "DarkRPUI.Notifications.Paint", function()
    if not DarkRPUI.Config.EnableNotifications then return end
    local sw = ScrW(); local pad = DarkRPUI.Util.Scale(18); local w = DarkRPUI.Util.Scale(360); local h = DarkRPUI.Util.Scale(82)
    for i=#active,1,-1 do
        local n=active[i]; local life=CurTime()-n.born; if life > n.duration then table.remove(active,i) else
            local target=sw-w-pad; n.x=Lerp(FrameTime()*12,n.x,target); local y=pad+(i-1)*(h+pad)
            DarkRPUI.UI.RoundedBox(12,n.x,y,w,h,DarkRPUI.Color("panel")); surface.SetDrawColor(DarkRPUI.Color(meta[n.kind] or "info")); surface.DrawRect(n.x,y,4,h)
            DarkRPUI.UI.Text(n.title,"DarkRPUI.Subtitle",n.x+18,y+12); DarkRPUI.UI.Text(n.msg,"DarkRPUI.Small",n.x+18,y+40,DarkRPUI.Color("subtext"))
            surface.SetDrawColor(DarkRPUI.Color(meta[n.kind] or "info")); surface.DrawRect(n.x+18,y+h-8,(w-36)*(1-life/n.duration),3)
        end end
end)
