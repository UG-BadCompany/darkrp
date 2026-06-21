DarkRPUI = DarkRPUI or {}; DarkRPUI.Notifications = DarkRPUI.Notifications or {}
local queue, active = {}, {}
local meta = { success="success", error="error", warning="warning", info="info", event="accent", generic="info" }
local function shouldSound() return (DarkRPUI.Settings and DarkRPUI.Settings.sounds ~= false) and DarkRPUI.Config.SoundEnabled end
function DarkRPUI.Notify(kind, title, msg, duration)
    if not DarkRPUI.Config.EnableNotifications or (DarkRPUI.Settings and DarkRPUI.Settings.notifications == false) then return end
    table.insert(queue, { kind=kind or "info", title=title or "Notice", msg=msg or "", duration=duration or 5, born=CurTime(), x=ScrW()+440, alpha=0 })
    if shouldSound() then surface.PlaySound(DarkRPUI.Config.NotificationSound) end
end
function notification.AddLegacy(text, typ, len) local map={[0]="info",[1]="warning",[2]="error",[3]="success"}; DarkRPUI.Notify(map[typ] or "info", "Notification", text, len or 5) end
function GAMEMODE:AddNotify(text, typ, len) DarkRPUI.Notify(({[0]="info",[1]="warning",[2]="error",[3]="success"})[typ] or "info", "DarkRP", text, len or 5) end
hook.Add("Think", "DarkRPUI.Notifications.Queue", function() while #active < 5 and #queue > 0 do local n=table.remove(queue,1); n.born=CurTime(); table.insert(active,n) end end)
hook.Add("HUDPaint", "DarkRPUI.Notifications.Paint", function()
    local sw, sh = ScrW(), ScrH(); local pad = DarkRPUI.Util.Scale(18); local w = DarkRPUI.Util.Scale((DarkRPUI.Settings and DarkRPUI.Settings.compact) and 310 or 380); local h = DarkRPUI.Util.Scale(82)
    local pos = DarkRPUI.Settings and DarkRPUI.Settings.notification_position or DarkRPUI.Config.NotificationPosition
    for i=#active,1,-1 do local n=active[i]; local life=CurTime()-n.born; if life > n.duration then table.remove(active,i) else
        local right = not string.find(pos or "top-right", "left", 1, true); local bottom = string.find(pos or "top-right", "bottom", 1, true)
        local targetX = right and (sw-w-pad) or pad; n.x=Lerp(FrameTime()*12,n.x,targetX); n.alpha=math.min(255,n.alpha+FrameTime()*900)
        local y = bottom and (sh-pad-i*(h+pad)) or (pad+(i-1)*(h+pad)); local color=DarkRPUI.Color(meta[n.kind] or "info")
        DarkRPUI.UI.OutlinedBox(12,n.x,y,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),n.alpha),DarkRPUI.Color("border")); surface.SetDrawColor(color); surface.DrawRect(n.x,y,4,h)
        DarkRPUI.UI.Text(n.title,"DarkRPUI.Subtitle",n.x+18,y+12); DarkRPUI.UI.Text(n.msg,"DarkRPUI.Small",n.x+18,y+40,DarkRPUI.Color("subtext")); surface.SetDrawColor(color); surface.DrawRect(n.x+18,y+h-8,(w-36)*math.max(0,1-life/n.duration),3)
    end end
end)
