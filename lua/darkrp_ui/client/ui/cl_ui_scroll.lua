DarkRPUI=DarkRPUI or {}; DarkRPUI.UI=DarkRPUI.UI or {}
-- Component module intentionally extends the shared DarkRPUI.UI library with named, reusable primitives.
function DarkRPUI.UI.CreateScroll(parent) local s=vgui.Create("DScrollPanel",parent); if DarkRPUI.UI.StyleScrollbar then DarkRPUI.UI.StyleScrollbar(s) end; return s end
