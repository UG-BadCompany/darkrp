DarkRPUI = DarkRPUI or {}; DarkRPUI.Settings = DarkRPUI.Settings or {}; DarkRPUI.Config = DarkRPUI.Config or {}; DarkRPUI.UI = DarkRPUI.UI or {}

local UI = DarkRPUI.UI
local selectedCategory = "interface"
local categories = {
    {id="interface", icon="◈", name="Interface", desc="Menus, blur, motion"},
    {id="hud", icon="▣", name="HUD", desc="Scale, compact layout"},
    {id="theme", icon="◆", name="Theme", desc="Palette and accent"},
    {id="alerts", icon="◍", name="Alerts", desc="Sounds and toasts"}
}
local accents = { Color(79,140,255), Color(155,105,255), Color(60,210,130), Color(255,190,70), Color(255,80,96), Color(90,220,220) }

local function save(toast)
    if DarkRPUI.SaveSettings then DarkRPUI.SaveSettings() end
    if DarkRPUI.SyncSettings then DarkRPUI.SyncSettings() end
    if toast and DarkRPUI.Notify then DarkRPUI.Notify("success", "Settings saved", "Your premium UI preferences were updated.") end
end
local function card(parent, title, desc, h)
    local p=vgui.Create("DPanel",parent); p:Dock(TOP); p:DockMargin(0,0,0,14); p:SetTall(h or 82); p.Hover=0
    p.Paint=function(s,w,hh)
        s.Hover=UI.LerpValue(s.Hover,s:IsHovered() and 1 or 0,12)
        UI.ShadowedBox(16,0,0,w,hh,UI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),UI.LerpColor(s.Hover,DarkRPUI.Color("border"),DarkRPUI.Color("accent")),70+35*s.Hover)
        surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("accent"),205)); surface.DrawRect(0,12,4,hh-24)
        UI.Text(title,"DarkRPUI.Subtitle",18,14); UI.Text(desc or "","DarkRPUI.Small",18,43,DarkRPUI.Color("subtext"))
    end
    return p
end
local function toggle(parent, title, desc, key)
    local c=card(parent,title,desc,78); local t=vgui.Create("DButton",c); t:SetText(""); t:SetSize(74,34); t:SetPos(0,22); t.AlignRight=function() t:SetPos(c:GetWide()-94,22) end; c.PerformLayout=function() t:AlignRight() end; t.Anim=0
    t.Paint=function(s,w,h) s.Anim=UI.LerpValue(s.Anim,DarkRPUI.Settings[key] and 1 or 0,14); UI.RoundedBox(17,0,0,w,h,UI.LerpColor(s.Anim,DarkRPUI.Color("border"),DarkRPUI.Color("accent"))); UI.RoundedBox(14,4+36*s.Anim,4,26,26,DarkRPUI.Color("text")); surface.SetDrawColor(DarkRPUI.WithAlpha(color_white,35)); surface.DrawRect(8,5,w-16,2) end
    t.DoClick=function() UI.PlayClick(); DarkRPUI.Settings[key]=not DarkRPUI.Settings[key]; save(true) end
end
local function slider(parent, title, desc, key, min, max, dec)
    local c=card(parent,title,desc,98); local s=vgui.Create("DNumSlider",c); s:SetPos(18,58); s:SetSize(c:GetWide()-36,30); s:SetText(""); s:SetMin(min); s:SetMax(max); s:SetDecimals(dec or 2); s:SetValue(DarkRPUI.Settings[key] or 1); c.PerformLayout=function() s:SetWide(c:GetWide()-36) end
    s.Label:SetTextColor(DarkRPUI.Color("subtext")); s.TextArea:SetFont("DarkRPUI.Tiny"); UI.StyleTextEntry(s.TextArea)
    s.Slider.Paint=function(_,w,h) UI.RoundedBox(5,8,h/2-4,w-16,8,DarkRPUI.Color("border")); UI.RoundedBox(5,8,h/2-4,(w-16)*s.Slider:GetSlideX(),8,DarkRPUI.Color("accent")) end
    s.Slider.Knob.Paint=function(k,w,h) UI.ShadowedBox(10,0,0,w,h,DarkRPUI.Color("accent"),DarkRPUI.Color("text"),45) end
    s.OnValueChanged=function(_,v) DarkRPUI.Settings[key]=v; save(false) end
end
local function combo(parent, title, desc, key, values)
    local c=card(parent,title,desc,92); local b=vgui.Create("DComboBox",c); b:SetSize(230,40); b:SetPos(0,26); b:SetValue(DarkRPUI.Settings[key] or values[1]); c.PerformLayout=function() b:SetPos(c:GetWide()-250,26) end; for _,v in ipairs(values) do b:AddChoice(v,v) end; UI.StyleCombo(b); b.OnSelect=function(_,_,_,id) DarkRPUI.Settings[key]=id; save(true) end
end
local function themeCards(parent)
    local c=card(parent,"Theme previews","Choose the base dashboard look.",154); local x=18
    for id,t in pairs(DarkRPUI.Themes or {}) do local b=vgui.Create("DButton",c); b:SetText(""); b:SetPos(x,62); b:SetSize(168,72); b.Hover=0; b.Paint=function(s,w,h) s.Hover=UI.HoverLerp(s,12); local active=(DarkRPUI.Settings.theme or DarkRPUI.ActiveTheme)==id; UI.ShadowedBox(14,0,0,w,h,t.colors.panel,t.colors.accent,55+35*s.Hover); UI.RoundedBox(8,12,12,42,16,t.colors.accent); UI.RoundedBox(8,12,36,92,10,t.colors.card); UI.Text(t.name,"DarkRPUI.Tiny",12,54,t.colors.text); if active then UI.Badge(w-58,10,"LIVE",t.colors.success) end end; b.DoClick=function() DarkRPUI.Settings.theme=id; if DarkRPUI.SetTheme then DarkRPUI.SetTheme(id) end; save(true) end; x=x+184 end
end
local function accentCards(parent)
    local c=card(parent,"Accent color","Preview accent chips for a unified UI language.",122); for i,col in ipairs(accents) do local b=vgui.Create("DButton",c); b:SetText(""); b:SetPos(18+(i-1)*58,64); b:SetSize(44,38); b.Hover=0; b.Paint=function(s,w,h) s.Hover=UI.HoverLerp(s,12); UI.ShadowedBox(12,0,-2*s.Hover,w,h,col,DarkRPUI.Color("border"),55); surface.SetDrawColor(DarkRPUI.WithAlpha(color_white,45)); surface.DrawRect(8,7,w-16,3) end; b.DoClick=function() DarkRPUI.Settings.accent={col.r,col.g,col.b}; save(true) end end
end
function DarkRPUI.SettingsPanel(parent)
    local p=vgui.Create("DPanel",parent); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function() end
    local left=vgui.Create("DPanel",p); left:Dock(LEFT); left:SetWide(238); left:DockMargin(0,0,18,0); left.Paint=function(_,w,h) UI.ShadowedBox(18,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border"),105); UI.Text("Settings","DarkRPUI.Title",20,18); UI.Text("Premium control center","DarkRPUI.Small",22,54,DarkRPUI.Color("subtext")) end
    local right=vgui.Create("DScrollPanel",p); right:Dock(FILL); UI.StyleScrollbar(right)
    local function rebuild()
        right:Clear()
        if selectedCategory=="interface" then toggle(right,"Premium HUD","Enable the custom sleek DarkRP HUD.","hud"); toggle(right,"Background blur","Use layered menu blur and glass shadows.","blur"); combo(right,"Notification position","Where confirmation toasts appear.","notification_position",{"top-right","top-left","bottom-right","bottom-left"}) end
        if selectedCategory=="hud" then toggle(right,"Compact mode","Use tighter HUD cards for smaller screens.","compact"); slider(right,"HUD scale","Fine tune HUD card sizing.","hud_scale",0.75,1.35,2) end
        if selectedCategory=="theme" then themeCards(right); accentCards(right) end
        if selectedCategory=="alerts" then toggle(right,"Interface sounds","Play polished click and hover feedback.","sounds") end
        local reset=vgui.Create("DButton",right); reset:Dock(TOP); reset:DockMargin(0,4,0,0); reset:SetTall(46); reset:SetText("Reset settings"); UI.StyleButton(reset,DarkRPUI.Color("error")); reset.DoClick=function() UI.Confirm("Reset settings","Restore the premium UI defaults?","Reset","Cancel",function(ok) if ok then DarkRPUI.Settings.hud=true; DarkRPUI.Settings.blur=true; DarkRPUI.Settings.sounds=true; DarkRPUI.Settings.compact=false; DarkRPUI.Settings.hud_scale=1; save(true); rebuild() end end) end
    end
    local y=92; for _,cat in ipairs(categories) do local b=vgui.Create("DButton",left); b:SetText(""); b:SetPos(14,y); b:SetSize(210,60); b.Hover=0; b.Paint=function(s,w,h) s.Hover=UI.HoverLerp(s,12); local active=selectedCategory==cat.id; local f=active and 1 or s.Hover; UI.RoundedBox(14,0,0,w,h,UI.LerpColor(f,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover"))); if active then surface.SetDrawColor(DarkRPUI.Color("accent")); surface.DrawRect(0,10,4,h-20) end; UI.Text(cat.icon,"DarkRPUI.Body",16,18,active and DarkRPUI.Color("accent") or DarkRPUI.Color("muted")); UI.Text(cat.name,"DarkRPUI.Body",48,11); UI.Text(cat.desc,"DarkRPUI.Tiny",48,34,DarkRPUI.Color("subtext")) end; b.DoClick=function() UI.PlayClick(); selectedCategory=cat.id; rebuild() end; y=y+70 end
    rebuild()
end
concommand.Add("darkrpui_settings", function() if DarkRPUI.F4 and DarkRPUI.F4.Open then DarkRPUI.F4.Open() end end)
