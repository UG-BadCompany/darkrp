DarkRPUI = DarkRPUI or {}; DarkRPUI.Context = DarkRPUI.Context or {}
function DarkRPUI.Context.Open(items, x, y)
 if IsValid(DarkRPUI.Context.Menu) then DarkRPUI.Context.Menu:Remove() end
 local m=vgui.Create("DPanel"); DarkRPUI.Context.Menu=m; m:SetSize(DarkRPUI.Util.Scale(220),DarkRPUI.Util.Scale(10+#items*38)); x,y=DarkRPUI.Layout.ClampToScreen(x or gui.MouseX(), y or gui.MouseY(), m:GetWide(), m:GetTall()); m:SetPos(x,y); m:MakePopup(); m.Paint=function(_,w,h) DarkRPUI.UI.ShadowedBox(12,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border"),110) end
 for i,it in ipairs(items or {}) do local b=vgui.Create("DButton",m); b:SetText((it.icon and (it.icon.."  ") or "")..(it.label or "Action")); b:SetPos(6,5+(i-1)*38); b:SetSize(m:GetWide()-12,34); DarkRPUI.UI.StyleButton(b); b.DoClick=function() if it.callback then it.callback() end; m:Remove() end end
 return m
end
hook.Add("Think","DarkRPUI.ContextEscape",function() if IsValid(DarkRPUI.Context.Menu) and input.IsKeyDown(KEY_ESCAPE) then DarkRPUI.Context.Menu:Remove() end end)
