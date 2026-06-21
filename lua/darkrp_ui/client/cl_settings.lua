DarkRPUI = DarkRPUI or {}
function DarkRPUI.SettingsPanel(parent)
    local p=vgui.Create("DPanel",parent); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function() end
    local y=10
    local function save() DarkRPUI.SaveSettings(); DarkRPUI.SyncSettings() end
    local function toggle(label,key) local b=vgui.Create("DButton",p); b:SetPos(0,y); b:SetSize(320,42); b:SetText(""); b.Paint=function(_,w,h) DarkRPUI.UI.RoundedBox(10,0,0,w,h,DarkRPUI.Color("card")); DarkRPUI.UI.Text(label,"DarkRPUI.Body",14,11); DarkRPUI.UI.Text(DarkRPUI.Settings[key] and "ON" or "OFF","DarkRPUI.Body",w-18,11,DarkRPUI.Settings[key] and DarkRPUI.Color("success") or DarkRPUI.Color("error"),TEXT_ALIGN_RIGHT) end; b.DoClick=function() DarkRPUI.Settings[key]=not DarkRPUI.Settings[key]; save() end; y=y+52 end
    toggle("Premium HUD", "hud"); toggle("Blur", "blur"); toggle("Notification sounds", "sounds"); toggle("Compact mode", "compact")
    local scale=vgui.Create("DNumSlider",p); scale:SetPos(0,y); scale:SetSize(420,44); scale:SetText("HUD scale"); scale:SetMin(0.75); scale:SetMax(1.35); scale:SetDecimals(2); scale:SetValue(DarkRPUI.Settings.hud_scale or 1); scale.OnValueChanged=function(_,v) DarkRPUI.Settings.hud_scale=v; save() end; y=y+58
    local pos=vgui.Create("DComboBox",p); pos:SetPos(0,y); pos:SetSize(320,42); pos:SetValue(DarkRPUI.Settings.notification_position or "top-right"); for _,v in ipairs({"top-right","top-left","bottom-right","bottom-left"}) do pos:AddChoice(v,v) end; pos.OnSelect=function(_,_,_,id) DarkRPUI.Settings.notification_position=id; save() end; y=y+54
    local theme=vgui.Create("DComboBox",p); theme:SetPos(0,y); theme:SetSize(320,42); theme:SetValue(DarkRPUI.Theme(DarkRPUI.ActiveTheme).name); for id,t in pairs(DarkRPUI.Themes) do theme:AddChoice(t.name,id) end; theme.OnSelect=function(_,_,_,id) DarkRPUI.Settings.theme=id; DarkRPUI.SetTheme(id); save() end
end
concommand.Add("darkrpui_settings", function() DarkRPUI.F4.Open() end)
