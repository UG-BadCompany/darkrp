DarkRPUI = DarkRPUI or {}; DarkRPUI.Modals = DarkRPUI.Modals or {}
function DarkRPUI.Modals.Confirm(title, text, yes, no)
 local f=vgui.Create("DFrame"); f:SetTitle(""); f:ShowCloseButton(false); f:SetSize(DarkRPUI.Util.Scale(420),DarkRPUI.Util.Scale(210)); local x,y=DarkRPUI.Layout.Place({x="center",y="center"},f:GetWide(),f:GetTall()); f:SetPos(x,y); f:MakePopup(); f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,4); DarkRPUI.UI.ShadowedBox(18,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border"),140); DarkRPUI.UI.Text(title or "Confirm","DarkRPUI.Subtitle",24,22); draw.DrawText(text or "Are you sure?","DarkRPUI.Body",24,62,DarkRPUI.Color("subtext")) end
 local b1=vgui.Create("DButton",f); b1:SetText("Confirm"); b1:SetPos(220,154); b1:SetSize(90,34); DarkRPUI.UI.StyleButton(b1,DarkRPUI.Color("accent")); b1.DoClick=function() if yes then yes() end; f:Remove() end
 local b2=vgui.Create("DButton",f); b2:SetText("Cancel"); b2:SetPos(316,154); b2:SetSize(78,34); DarkRPUI.UI.StyleButton(b2); b2.DoClick=function() if no then no() end; f:Remove() end
 return f
end
