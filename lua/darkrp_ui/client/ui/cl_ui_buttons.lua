DarkRPUI=DarkRPUI or {}; DarkRPUI.UI=DarkRPUI.UI or {}
-- Component module intentionally extends the shared DarkRPUI.UI library with named, reusable primitives.
function DarkRPUI.UI.PrimaryButton(parent,text,click) local b=vgui.Create("DButton",parent); b:SetText(text or "OK"); DarkRPUI.UI.StyleButton(b,DarkRPUI.Color("accent")); b.DoClick=click or function() end; return b end
