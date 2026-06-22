DarkRPUI = DarkRPUI or {}; DarkRPUI.Layout = DarkRPUI.Layout or {}; DarkRPUI.Util = DarkRPUI.Util or {}
DarkRPUI.Layout.SafePadding = DarkRPUI.Layout.SafePadding or { x = 24, y = 24 }
CreateClientConVar("darkrpui_debug_safearea", "0", true, false, "Draw DarkRP UI safe-area bounds.")
function DarkRPUI.Layout.GetSafeRect()
    local padX = DarkRPUI.Util.Scale(DarkRPUI.Layout.SafePadding.x)
    local padY = DarkRPUI.Util.Scale(DarkRPUI.Layout.SafePadding.y)
    return padX, padY, ScrW() - padX * 2, ScrH() - padY * 2
end
function DarkRPUI.Layout.ClampToScreen(x, y, w, h)
    local sx, sy, sw, sh = DarkRPUI.Layout.GetSafeRect()
    return math.Clamp(x or sx, sx, sx + sw - (w or 1)), math.Clamp(y or sy, sy, sy + sh - (h or 1))
end
function DarkRPUI.Layout.Place(anchor, w, h, ox, oy)
    local sx, sy, sw, sh = DarkRPUI.Layout.GetSafeRect(); ox, oy = DarkRPUI.Util.Scale(ox or 0), DarkRPUI.Util.Scale(oy or 0)
    local x = ({left=sx+ox, center=sx+sw/2-w/2, right=sx+sw-w-ox})[anchor.x or "left"] or sx
    local y = ({top=sy+oy, center=sy+sh/2-h/2, bottom=sy+sh-h-oy})[anchor.y or "top"] or sy
    return DarkRPUI.Layout.ClampToScreen(x,y,w,h)
end
hook.Add("HUDPaint", "DarkRPUI.DebugSafeArea", function()
    if GetConVar("darkrpui_debug_safearea"):GetBool() then local x,y,w,h=DarkRPUI.Layout.GetSafeRect(); surface.SetDrawColor(DarkRPUI.Color("accent",180)); surface.DrawOutlinedRect(x,y,w,h,2) end
end)
