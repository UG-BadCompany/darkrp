DarkRPUI = DarkRPUI or {}
function DarkRPUI.SettingsPanel(parent)
    local p=vgui.Create("DPanel",parent); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function() end
    local y=10
    local function toggle(label, key)
        local b=vgui.Create("DButton",p); b:SetPos(0,y); b:SetSize(280,42); b:SetText(""); b.Paint=function(s,w,h) DarkRPUI.UI.RoundedBox(10,0,0,w,h,DarkRPUI.Color("card")); DarkRPUI.UI.Text(label,"DarkRPUI.Body",14,11); DarkRPUI.UI.Text(DarkRPUI.Settings[key] and "ON" or "OFF","DarkRPUI.Body",w-18,11,DarkRPUI.Settings[key] and DarkRPUI.Color("success") or DarkRPUI.Color("error"),TEXT_ALIGN_RIGHT) end; b.DoClick=function() DarkRPUI.Settings[key]=not DarkRPUI.Settings[key]; DarkRPUI.SaveSettings(); DarkRPUI.SyncSettings() end; y=y+52
    end
    toggle("Premium HUD", "hud"); toggle("Notifications", "notifications")
    local theme=vgui.Create("DComboBox",p); theme:SetPos(0,y); theme:SetSize(280,42); theme:SetValue(DarkRPUI.Theme(DarkRPUI.ActiveTheme).name); for id,t in pairs(DarkRPUI.Themes) do theme:AddChoice(t.name,id) end; theme.OnSelect=function(_,_,_,id) DarkRPUI.Settings.theme=id; DarkRPUI.SetTheme(id); DarkRPUI.SaveSettings(); DarkRPUI.SyncSettings() end
end
concommand.Add("darkrpui_settings", function() DarkRPUI.F4.Open() timer.Simple(0, function() end) end)
