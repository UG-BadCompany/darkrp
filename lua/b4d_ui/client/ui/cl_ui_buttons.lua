B4DUI = B4DUI or {}; B4DUI.UI=B4DUI.UI or {}
function B4DUI.UI.Button(parent,text,fn) local b=parent:Add("DButton"); b:SetText(text or "Button"); b:SetFont("B4D.Body"); b:SetTextColor(B4DUI.Color("text")); b.Paint=function(self,w,h) draw.RoundedBox(9,0,0,w,h,self:IsHovered() and B4DUI.Color("accent") or B4DUI.Color("panel2")) end; b.DoClick=fn or function() end; return b end
