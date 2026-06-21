DarkRPUI = DarkRPUI or {}; DarkRPUI.F4 = DarkRPUI.F4 or {}
local function buyCommand(cmd) if cmd and cmd ~= "" then RunConsoleCommand("say", "/" .. cmd) end end
local sources = {
    jobs=function() return RPExtraTeams or {} end,
    entities=function() return DarkRPEntities or {} end,
    weapons=function() local out={} for _,v in ipairs(CustomShipments or {}) do if v.separate then out[#out+1]=v end end return out end,
    shipments=function() local out={} for _,v in ipairs(CustomShipments or {}) do if not v.noship then out[#out+1]=v end end return out end,
    vehicles=function() return CustomVehicles or {} end,
    ammo=function() return (GAMEMODE and GAMEMODE.AmmoTypes) or {} end,
    food=function() return FoodItems or {} end
}
local function itemName(it) return it.name or it.Name or it.label or it.ammoType or "Item" end
local function itemDesc(it) return it.description or it.desc or it.model or it.entity or it.command or it.cmd or "Available on this server" end
local function itemPrice(it) return it.price or it.Price or it.pricesep or it.pricewep end
local function createPlaceholder(parent, tab) local text=(DarkRPUI.Config.Placeholders and DarkRPUI.Config.Placeholders[tab]) or "This module is ready for server integration."; if hook.Run("DarkRPUI.Build"..tab:gsub("^%l", string.upper).."Panel", parent) then return end DarkRPUI.UI.EmptyState(parent, text, "Clean hook/config integration point — no broken dependencies.") end
local function addCards(scroll, items, click)
    local grid=vgui.Create("DIconLayout",scroll); grid:Dock(FILL); grid:SetSpaceX(12); grid:SetSpaceY(12)
    for _,it in ipairs(items or {}) do local price=itemPrice(it); local card=DarkRPUI.UI.MakeCard(grid,itemName(it),itemDesc(it),function() click(it) end,price and DarkRPUI.Util.FormatMoney(price) or nil); card:SetSize(DarkRPUI.Util.Scale(270),DarkRPUI.Util.Scale(116)) end
end
function DarkRPUI.F4.Close()
    local f = DarkRPUI.F4.Frame
    if not IsValid(f) then return end
    DarkRPUI.F4.Frame = nil
    gui.EnableScreenClicker(false)
    DarkRPUI.UI.AnimatePanelOut(f, function(p) if IsValid(p) then p:Remove() end end)
end
function DarkRPUI.F4.Open()
    if IsValid(DarkRPUI.F4.Frame) then DarkRPUI.F4.Close(); return end
    local f=vgui.Create("DFrame"); DarkRPUI.F4.Frame=f; f:SetSize(ScrW()*0.88,ScrH()*0.88); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:MakePopup(); DarkRPUI.UI.AnimatePanelIn(f); f.OnKeyCodePressed=function(_,key) if key==KEY_ESCAPE then DarkRPUI.F4.Close() end end; f.OnClose=function() DarkRPUI.F4.Close() end
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,6); DarkRPUI.UI.RoundedBox(18,0,0,w,h,DarkRPUI.Color("background")); DarkRPUI.UI.Text("DarkRP Command Center","DarkRPUI.Title",28,22); DarkRPUI.UI.Text(DarkRP and "Live DarkRP data" or "DarkRP not detected: preview/fallback mode", "DarkRPUI.Small",30,62,DarkRPUI.Color(DarkRP and "subtext" or "warning")) end
    local close=DarkRPUI.UI.CloseButton(f, DarkRPUI.F4.Close); close:SetPos(f:GetWide()-64,16)
    local nav=vgui.Create("DPanel",f); nav:SetPos(22,92); nav:SetSize(218,f:GetTall()-114); nav.Paint=function(_,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("panel")) end
    local body=vgui.Create("DPanel",f); body:SetPos(258,92); body:SetSize(f:GetWide()-280,f:GetTall()-114); body.Paint=function(_,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("panel")) end
    local current="dashboard"
    local function render(tab, name)
        current=tab; body:Clear(); local header=DarkRPUI.UI.MakeHeader(body,name or tab:upper(),"Search, filter, purchase, favorite, and integrate server systems."); header:Dock(TOP); header:DockMargin(20,18,20,8)
        if tab=="dashboard" then local p=vgui.Create("DPanel",body); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function(_,w,h) local ply=LocalPlayer(); DarkRPUI.UI.Text("Welcome, "..ply:Nick(),"DarkRPUI.Title",20,20); DarkRPUI.UI.Text("Money: "..DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"money",0)),"DarkRPUI.Subtitle",20,68,DarkRPUI.Color("success")); DarkRPUI.UI.Text("Job: "..(team.GetName(ply:Team()) or "Citizen"),"DarkRPUI.Body",20,104,team.GetColor(ply:Team())); DarkRPUI.UI.Text("Use the left navigation for jobs, shops, rules, settings, and staff tools.","DarkRPUI.Body",20,144,DarkRPUI.Color("subtext")) end return end
        if tab=="rules" then local p=vgui.Create("DLabel",body); p:Dock(FILL); p:DockMargin(24,0,24,24); p:SetWrap(true); p:SetFont("DarkRPUI.Body"); p:SetTextColor(DarkRPUI.Color("subtext")); p:SetText((DarkRPUI.Config and DarkRPUI.Config.RulesText) or "No rules configured."); return end
        if tab=="settings" then DarkRPUI.SettingsPanel(body); return end
        if tab=="admin" then DarkRPUI.Admin.OpenPanel(body); return end
        if DarkRPUI.Config.Placeholders and DarkRPUI.Config.Placeholders[tab] then createPlaceholder(body, tab); return end
        local search=vgui.Create("DTextEntry",body); search:Dock(TOP); search:DockMargin(20,0,20,10); search:SetTall(36); search:SetPlaceholderText("Search "..(name or tab).."..."); search:SetFont("DarkRPUI.Body")
        local scroll=vgui.Create("DScrollPanel",body); scroll:Dock(FILL); scroll:DockMargin(20,0,20,20)
        local function rebuild() scroll:Clear(); local q=string.lower(search:GetValue() or ""); local items=(sources[tab] and sources[tab]()) or {}; local filtered={} for _,it in ipairs(items) do local n=string.lower(itemName(it)); if q=="" or string.find(n,q,1,true) then filtered[#filtered+1]=it end end; if #filtered==0 then DarkRPUI.UI.EmptyState(scroll, "No results", "No server data matched this search."); return end; addCards(scroll, filtered, function(it) buyCommand(it.cmd or it.command) end) end
        search.OnChange=rebuild; rebuild()
    end
    for _,t in ipairs((DarkRPUI.Config and DarkRPUI.Config.F4Tabs) or {}) do if not t.staffOnly or DarkRPUI.Util.IsAdmin(LocalPlayer()) then local b=vgui.Create("DButton",nav); b:Dock(TOP); b:DockMargin(10,6,10,0); b:SetTall(42); b:SetText(t.icon.."  "..t.name); b:SetFont("DarkRPUI.Body"); b:SetTextColor(DarkRPUI.Color("text")); b.Hover=0; b.Active=0; b.Paint=function(s,w,h) s.Hover=DarkRPUI.UI.LerpValue(s.Hover,s:IsHovered() and 1 or 0,12); s.Active=DarkRPUI.UI.LerpValue(s.Active,current==t.id and 1 or 0,14); DarkRPUI.UI.RoundedBox(8,0,0,w,h,DarkRPUI.LerpColor(math.max(s.Hover,s.Active),Color(0,0,0,0),DarkRPUI.Color(current==t.id and "accent" or "card"))); surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("accent"),220*s.Active)); surface.DrawRect(0,8,3,h-16) end; b.DoClick=function() render(t.id,t.name) end end end
    render("dashboard","Dashboard")
end
hook.Add("ShowSpare2", "DarkRPUI.F4.Override", function() if not DarkRPUI.Config or DarkRPUI.Config.EnableF4Menu ~= false then DarkRPUI.F4.Open(); return false end end)
