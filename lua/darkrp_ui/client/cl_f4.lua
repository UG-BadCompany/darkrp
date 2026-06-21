DarkRPUI = DarkRPUI or {}; DarkRPUI.F4 = DarkRPUI.F4 or {}
local function makeScroll(parent) local s=vgui.Create("DScrollPanel",parent); s:Dock(FILL); return s end
local function addCards(scroll, items, click)
    local grid=vgui.Create("DIconLayout",scroll); grid:Dock(FILL); grid:SetSpaceX(12); grid:SetSpaceY(12)
    for _,it in ipairs(items or {}) do local card=DarkRPUI.UI.MakeCard(grid, it.name or it.Name or "Item", it.description or it.model or it.cmd or "Available", function() click(it) end); card:SetSize(DarkRPUI.Util.Scale(260),DarkRPUI.Util.Scale(104)) end
end
local sources={ jobs=function() return RPExtraTeams or {} end, entities=function() return DarkRPEntities or {} end, weapons=function() return CustomShipments or {} end, shipments=function() return CustomShipments or {} end, vehicles=function() return CustomVehicles or {} end, ammo=function() return GAMEMODE and GAMEMODE.AmmoTypes or {} end, food=function() return FoodItems or {} end }
function DarkRPUI.F4.Open()
    if IsValid(DarkRPUI.F4.Frame) then DarkRPUI.F4.Frame:Remove() end
    local f=vgui.Create("DFrame"); DarkRPUI.F4.Frame=f; f:SetSize(ScrW()*0.86,ScrH()*0.86); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:MakePopup(); f:SetAlpha(0); f:AlphaTo(255,DarkRPUI.Config.AnimationSpeed,0)
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,6); DarkRPUI.UI.RoundedBox(18,0,0,w,h,DarkRPUI.Color("background")); DarkRPUI.UI.Text("DarkRP Command Center","DarkRPUI.Title",28,22); DarkRPUI.UI.Text("Premium roleplay dashboard", "DarkRPUI.Small",30,62,DarkRPUI.Color("subtext")) end
    local close=vgui.Create("DButton",f); close:SetText("×"); close:SetFont("DarkRPUI.Title"); close:SetTextColor(DarkRPUI.Color("text")); close:SetSize(48,48); close:SetPos(f:GetWide()-64,16); close.Paint=function() end; close.DoClick=function() f:Close() end
    local nav=vgui.Create("DPanel",f); nav:SetPos(22,92); nav:SetSize(210,f:GetTall()-114); nav.Paint=function(s,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("panel")) end
    local body=vgui.Create("DPanel",f); body:SetPos(250,92); body:SetSize(f:GetWide()-272,f:GetTall()-114); body.Paint=function(s,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("panel")) end
    local current="dashboard"; local function render(tab)
        current=tab; body:Clear(); local header=DarkRPUI.UI.MakeHeader(body, tab:upper(), "Search, filter, favorite, and purchase from a responsive card layout."); header:Dock(TOP); header:DockMargin(20,18,20,8)
        if tab=="dashboard" then local p=vgui.Create("DPanel",body); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function(s,w,h) DarkRPUI.UI.Text("Welcome, "..LocalPlayer():Nick(),"DarkRPUI.Title",20,20); DarkRPUI.UI.Text("Money: "..DarkRPUI.Util.FormatMoney(LocalPlayer().getDarkRPVar and LocalPlayer():getDarkRPVar("money") or 0),"DarkRPUI.Subtitle",20,68,DarkRPUI.Color("success")); DarkRPUI.UI.Text("Future widgets: server events, quests, recent reports, marketplace highlights.","DarkRPUI.Body",20,110,DarkRPUI.Color("subtext")) end; return end
        if tab=="rules" then local p=vgui.Create("DLabel",body); p:Dock(FILL); p:DockMargin(24,0,24,24); p:SetWrap(true); p:SetFont("DarkRPUI.Body"); p:SetTextColor(DarkRPUI.Color("subtext")); p:SetText(DarkRPUI.Config.RulesText); return end
        if tab=="settings" then DarkRPUI.SettingsPanel(body); return end
        local scroll=makeScroll(body); scroll:DockMargin(20,0,20,20); local items=(sources[tab] and sources[tab]()) or {{name=tab:gsub("^%l",string.upper), description=DarkRPUI.Config.Placeholders[tab] or "Connect server data/config for this module."}}; addCards(scroll, items, function(it) if it.cmd and RunConsoleCommand then RunConsoleCommand("say", "/"..it.cmd) end end)
    end
    for _,t in ipairs(DarkRPUI.Config.F4Tabs) do local b=vgui.Create("DButton",nav); b:Dock(TOP); b:DockMargin(10,6,10,0); b:SetTall(42); b:SetText(t.icon.."  "..t.name); b:SetFont("DarkRPUI.Body"); b:SetTextColor(DarkRPUI.Color("text")); b.Paint=function(s,w,h) DarkRPUI.UI.RoundedBox(8,0,0,w,h,current==t.id and DarkRPUI.Color("accent") or (s:IsHovered() and DarkRPUI.Color("card") or Color(0,0,0,0))) end; b.DoClick=function() render(t.id) end end
    render("dashboard")
end
hook.Add("ShowSpare2", "DarkRPUI.F4.Override", function() if DarkRPUI.Config.EnableF4Menu then DarkRPUI.F4.Open(); return false end end)
