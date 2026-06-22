DarkRPUI=DarkRPUI or {}; DarkRPUI.UI=DarkRPUI.UI or {}; local UI=DarkRPUI.UI
function UI.CreateSidebar(parent,width) local p=UI.Component("sidebar",parent); p:SetWide(width or 230); p:Dock(LEFT); p:DockMargin(18,72,12,18); p.Paint=function(_,w,h) UI.RoundedBox(18,0,0,w,h,DarkRPUI.Color("sidebarDark")) end; return p end
function UI.SidebarButton(parent,text,icon,active,click) local b=UI.MakeIconButton(parent,(icon or "•").."  "..text,click); b:Dock(TOP); b:DockMargin(10,8,10,0); b:SetTall(44); b.ActiveFunc=active; return b end
