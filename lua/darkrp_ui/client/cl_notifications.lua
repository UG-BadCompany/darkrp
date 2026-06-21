DarkRPUI = DarkRPUI or {}; DarkRPUI.Notifications = DarkRPUI.Notifications or {}
DarkRPUI.Config = DarkRPUI.Config or {}; DarkRPUI.Settings = DarkRPUI.Settings or {}; DarkRPUI.Util = DarkRPUI.Util or {}
local queue, active = {}, {}
local meta = { success="success", error="error", warning="warning", info="info", event="accent", generic="info" }
local icons = { success="✓", error="!", warning="⚠", info="i", event="★", generic="•" }
local legacyInstalled, gmInstalled = false, false
local function enabled() return not DarkRPUI.Config or DarkRPUI.Config.EnableNotifications ~= false end
local function scale(v) return (DarkRPUI.Util and DarkRPUI.Util.Scale and DarkRPUI.Util.Scale(v)) or v end
local function shouldSound() return (not DarkRPUI.Settings or DarkRPUI.Settings.sounds ~= false) and (not DarkRPUI.Config or DarkRPUI.Config.SoundEnabled ~= false) end
local function C(name) return (DarkRPUI.Color and DarkRPUI.Color(name)) or color_white end
function DarkRPUI.Notify(kind, title, msg, duration)
    if not enabled() or (DarkRPUI.Settings and DarkRPUI.Settings.notifications == false) then return end
    table.insert(queue, { kind=kind or "info", title=title or "Notice", msg=tostring(msg or ""), duration=duration or 5, born=CurTime(), x=ScrW()+440, alpha=0, leaving=false })
    if shouldSound() and DarkRPUI.Config and DarkRPUI.Config.NotificationSound then surface.PlaySound(DarkRPUI.Config.NotificationSound) end
end
local function installNotificationLegacy()
    if legacyInstalled or not notification then return end
    legacyInstalled = true
    local map={[0]="info",[1]="warning",[2]="error",[3]="success"}
    notification.AddLegacy = function(text, typ, len) DarkRPUI.Notify(map[typ] or "info", "Notification", text, len or 5) end
end
local function installDarkRPNotify()
    if gmInstalled or not GAMEMODE then return false end
    gmInstalled = true
    GAMEMODE.AddNotify = function(_, text, typ, len) DarkRPUI.Notify(({[0]="info",[1]="warning",[2]="error",[3]="success"})[typ] or "info", "DarkRP", text, len or 5) end
    return true
end
local function installNotifyOverrides()
    installNotificationLegacy()
    if installDarkRPNotify() then timer.Remove("DarkRPUI.Notifications.Retry") return end
    timer.Create("DarkRPUI.Notifications.Retry", 0.5, 20, function() if installDarkRPNotify() then timer.Remove("DarkRPUI.Notifications.Retry") end end)
end
hook.Add("Initialize", "DarkRPUI.Notifications.SafeOverrides", installNotifyOverrides)
hook.Add("InitPostEntity", "DarkRPUI.Notifications.SafeOverridesPost", installNotifyOverrides)
timer.Simple(0, installNotifyOverrides)
hook.Add("Think", "DarkRPUI.Notifications.Queue", function() while #active < 5 and #queue > 0 do local n=table.remove(queue,1); n.born=CurTime(); table.insert(active,n) end end)
hook.Add("HUDPaint", "DarkRPUI.Notifications.Paint", function()
    if not DarkRPUI.UI or not DarkRPUI.UI.OutlinedBox then return end
    local sw, sh = ScrW(), ScrH(); local pad = scale(18); local w = scale((DarkRPUI.Settings and DarkRPUI.Settings.compact) and 310 or 380); local h = scale(82)
    local pos = (DarkRPUI.Settings and DarkRPUI.Settings.notification_position) or (DarkRPUI.Config and DarkRPUI.Config.NotificationPosition) or "top-right"
    for i=#active,1,-1 do local n=active[i]; local life=CurTime()-n.born; if life > n.duration then n.leaving=true end
        local right = not string.find(pos, "left", 1, true); local bottom = string.find(pos, "bottom", 1, true)
        local targetX = n.leaving and (right and sw+20 or -w-20) or (right and (sw-w-pad) or pad); n.x=Lerp(FrameTime()*12,n.x,targetX); n.alpha=Lerp(FrameTime()*10,n.alpha,n.leaving and 0 or 255)
        if n.leaving and n.alpha < 5 then table.remove(active,i) else local y = bottom and (sh-pad-i*(h+pad)) or (pad+(i-1)*(h+pad)); local color=C(meta[n.kind] or "info")
            DarkRPUI.UI.OutlinedBox(14,n.x,y,w,h,DarkRPUI.WithAlpha(C("panel"),n.alpha),DarkRPUI.WithAlpha(C("border"),n.alpha)); surface.SetDrawColor(color.r,color.g,color.b,n.alpha); surface.DrawRect(n.x,y,5,h)
            DarkRPUI.UI.RoundedBox(12,n.x+16,y+16,34,34,DarkRPUI.WithAlpha(color,42*n.alpha/255)); DarkRPUI.UI.Text(icons[n.kind] or icons.generic,"DarkRPUI.Body",n.x+33,y+23,DarkRPUI.WithAlpha(color,n.alpha),TEXT_ALIGN_CENTER)
            DarkRPUI.UI.Text(n.title,"DarkRPUI.Subtitle",n.x+62,y+12,DarkRPUI.WithAlpha(C("text"),n.alpha)); DarkRPUI.UI.Text(n.msg,"DarkRPUI.Small",n.x+62,y+40,DarkRPUI.WithAlpha(C("subtext"),n.alpha)); surface.SetDrawColor(color.r,color.g,color.b,n.alpha); DarkRPUI.UI.RoundedBox(4,n.x+62,y+h-9,(w-78)*math.max(0,1-life/n.duration),4,DarkRPUI.WithAlpha(color,n.alpha))
        end
    end
end)
