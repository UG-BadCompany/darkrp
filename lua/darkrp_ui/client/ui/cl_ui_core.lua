DarkRPUI = DarkRPUI or {}; DarkRPUI.UI = DarkRPUI.UI or {}
local UI=DarkRPUI.UI
function UI.Component(name, parent, class) local p=vgui.Create(class or "DPanel", parent); p.DarkRPUIComponent=name; return p end
function UI.PaintPanel(w,h,accent) UI.ShadowedBox(16,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),238),accent or DarkRPUI.Color("border"),105) end
function UI.SectionTitle(parent,title,sub) local h=UI.MakeHeader(parent,title,sub or ""); h:Dock(TOP); return h end
