B4DUI = B4DUI or {}; B4DUI.SafeArea=B4DUI.SafeArea or {left=24,top=24,right=24,bottom=24}
CreateClientConVar("b4d_ui_debug_safearea","0",true,false,"Draw B4D UI safe-area bounds")
function B4DUI.GetSafeArea() return B4DUI.SafeArea.left,B4DUI.SafeArea.top,ScrW()-B4DUI.SafeArea.right,ScrH()-B4DUI.SafeArea.bottom end
function B4DUI.ClampToSafeArea(x,y,w,h) local l,t,r,b=B4DUI.GetSafeArea(); return math.Clamp(x,l,r-w), math.Clamp(y,t,b-h) end
hook.Add("HUDPaint","B4DUI.SafeAreaDebug",function() if GetConVar("b4d_ui_debug_safearea"):GetBool() then local l,t,r,b=B4DUI.GetSafeArea(); surface.SetDrawColor(B4DUI.Color("accent")); surface.DrawOutlinedRect(l,t,r-l,b-t,2) end end)
