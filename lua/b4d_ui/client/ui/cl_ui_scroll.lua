B4DUI = B4DUI or {}; B4DUI.UI=B4DUI.UI or {}
function B4DUI.UI.SkinScroll(panel) local bar=panel:GetVBar(); bar:SetWide(5); bar.Paint=function() end; bar.btnGrip.Paint=function(_,w,h) draw.RoundedBox(3,0,0,w,h,B4DUI.Color("accent")) end; bar.btnUp.Paint=function() end; bar.btnDown.Paint=function() end end
