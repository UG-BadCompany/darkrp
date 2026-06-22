DarkRPUI=DarkRPUI or {}; DarkRPUI.UI=DarkRPUI.UI or {}; local UI=DarkRPUI.UI
function UI.CreateFrame(title,w,h)
 local f=vgui.Create("DFrame"); f:SetSize(w,h); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); UI.AnimatePanelIn(f)
 f.Paint=function(s,pw,ph) UI.DrawBlur(s,5); UI.ShadowedBox(22,0,0,pw,ph,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),242),DarkRPUI.Color("border"),130); UI.Text(title or "DarkRP UI","DarkRPUI.Title",24,18) end
 return f
end
