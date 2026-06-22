B4DUI = B4DUI or {}; B4DUI.UI=B4DUI.UI or {}
function B4DUI.UI.PaintPanel(w,h,accent) draw.RoundedBox(14,0,0,w,h,B4DUI.Color("panel")); surface.SetDrawColor(B4DUI.Color("border")); surface.DrawOutlinedRect(0,0,w,h,1); draw.RoundedBox(14,0,0,3,h,accent or B4DUI.Color("accent")) end
function B4DUI.UI.Label(parent,text,font,color) local l=parent:Add("DLabel"); l:SetText(text or ""); l:SetFont(font or "B4D.Body"); l:SetTextColor(color or B4DUI.Color("text")); l:SizeToContents(); return l end
