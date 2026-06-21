DarkRPUI = DarkRPUI or {}; DarkRPUI.F4 = DarkRPUI.F4 or {}

local fallbackModel = "models/player/kleiner.mdl"
local favorites = (DarkRPUI.Settings and DarkRPUI.Settings.favorites) or DarkRPUI.F4.Favorites or {}; DarkRPUI.F4.Favorites = favorites
local selectedItem
local currentTab = "dashboard"

local sources = {
    jobs=function() return RPExtraTeams or {} end,
    entities=function() return DarkRPEntities or {} end,
    weapons=function() local out={} for _,v in ipairs(CustomShipments or {}) do if v.separate then out[#out+1]=v end end return out end,
    shipments=function() local out={} for _,v in ipairs(CustomShipments or {}) do if not v.noship then out[#out+1]=v end end return out end,
    vehicles=function() return CustomVehicles or {} end,
    ammo=function() return (GAMEMODE and GAMEMODE.AmmoTypes) or {} end,
    food=function() return FoodItems or {} end
}

local function safeTeamColor(teamId, fallback) if teamId and team.GetColor then return team.GetColor(teamId) end return fallback or DarkRPUI.Color("accent") end
local function buyCommand(cmd) if cmd and cmd ~= "" then DarkRPUI.UI.PlayClick(); RunConsoleCommand("say", "/" .. cmd) end end
local function itemName(it) return it and (it.name or it.Name or it.label or it.ammoType or it.entity or "Item") or "Item" end
local function itemDesc(it) return it and (it.description or it.desc or it.Description or it.model or it.entity or it.command or it.cmd or "Available on this server") or "Available on this server" end
local function itemPrice(it) return it and (it.price or it.Price or it.pricesep or it.pricewep) end
local modelCache = {}
local function validModel(mdl) return isstring(mdl) and mdl ~= "" and (not util or not util.IsValidModel or util.IsValidModel(mdl)) end
local function modelList(it)
    local key = it and (it.command or it.cmd or it.name or it.Name or it)
    if key and modelCache[key] then return modelCache[key] end
    local m = it and (it.model or it.Model or it.models or it.Models or it.shipmodel)
    local out={}
    if istable(m) then for _,v in ipairs(m) do if validModel(v) then out[#out+1]=v end end
    elseif validModel(m) then out[1]=m end
    if #out == 0 then out[1]=fallbackModel end
    if key then modelCache[key]=out end
    return out
end
local function jobCommand(job) return job and (job.command or job.cmd) end
local function buyItem(it) if DarkRPUI.Config and DarkRPUI.Config.ConfirmPurchases then Derma_Query("Purchase "..itemName(it).."?", "Confirm purchase", "Buy", function() buyCommand(it.cmd or it.command) end, "Cancel") else buyCommand(it.cmd or it.command) end end
local function jobSalary(job) return job and (job.salary or job.Salary or 0) or 0 end
local function jobPlayers(teamId) local count=0 for _,p in ipairs(player.GetAll()) do if p:Team()==teamId then count=count+1 end end return count end
local function jobMax(job) return job and (job.max or job.Max or 0) or 0 end
local function weaponText(job) local weapons=job and (job.weapons or job.Weapons) or {}; if #weapons == 0 then return "Standard loadout" end return table.concat(weapons, ", ") end
local function isJobLocked(job) local grp=DarkRPUI.Util.PlayerGroup(LocalPlayer()); if job and job.customCheck and not job.customCheck(LocalPlayer()) then return true end; if job and job.allowed and not job.allowed[grp] then return true end; return false end
local function canShowJob(job) if not job then return false end if job.customCheck and job.CustomCheckFailMsg and not job.customCheck(LocalPlayer()) then return true end return true end
local function addAnim(panel, index) panel:SetAlpha(0); panel.DarkRPUIEntrance=0; timer.Simple((index or 1)*0.012, function() if IsValid(panel) then panel:AlphaTo(255, 0.18, 0); panel.DarkRPUIEntrance=1 end end) end

local function makeSearch(parent, placeholder, onChange)
    return DarkRPUI.UI.PremiumSearch(parent, placeholder, onChange)
end

local function buildInfoPanel(parent)
    local info=vgui.Create("DPanel",parent); info:SetWide(DarkRPUI.Util.Scale(310)); info.Paint=function(s,w,h)
        DarkRPUI.UI.OutlinedBox(18,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),235),DarkRPUI.Color("border"))
        if not selectedItem then DarkRPUI.UI.Text("Select an item","DarkRPUI.Subtitle",24,26); DarkRPUI.UI.Text("Details, requirements, preview, and actions appear here.","DarkRPUI.Small",24,58,DarkRPUI.Color("subtext")); return end
        DarkRPUI.UI.Text(itemName(selectedItem),"DarkRPUI.Subtitle",24,26)
        DarkRPUI.UI.Text(itemDesc(selectedItem),"DarkRPUI.Small",24,58,DarkRPUI.Color("subtext"))
    end
    info.Refresh=function()
        info:Clear(); if not selectedItem then return end
        local mdl=DarkRPUI.UI.MakeModelPreview(info, modelList(selectedItem), true); mdl:SetPos(24,108); mdl:SetSize(info:GetWide()-48,220)
        local y=344
        local price=itemPrice(selectedItem); local salary=selectedItem.salary
        local rows={{"Category", selectedItem.category or selectedItem.Category or "General"},{price and "Price" or "Salary", price and DarkRPUI.Util.FormatMoney(price) or DarkRPUI.Util.FormatMoney(salary or 0)},{"Population", selectedItem.team and (jobPlayers(selectedItem.team).." / "..(jobMax(selectedItem)==0 and "∞" or jobMax(selectedItem))) or "—"},{"Models", tostring(#modelList(selectedItem)).." available"},{"Requirements", isJobLocked(selectedItem) and "VIP / staff / custom check" or "Available"},{"Loadout", weaponText(selectedItem)}}
        for _,r in ipairs(rows) do local lab=vgui.Create("DLabel",info); lab:SetPos(24,y); lab:SetSize(info:GetWide()-48,22); lab:SetFont("DarkRPUI.Small"); lab:SetTextColor(DarkRPUI.Color("subtext")); lab:SetText(r[1]..": "..tostring(r[2])); y=y+26 end
        local act=vgui.Create("DButton",info); act:SetPos(24,info:GetTall()-70); act:SetSize(info:GetWide()-48,46); act:SetText(currentTab=="jobs" and (isJobLocked(selectedItem) and "Requirements Not Met" or "Become Job") or "Purchase"); DarkRPUI.UI.StyleButton(act, isJobLocked(selectedItem) and DarkRPUI.Color("error") or DarkRPUI.Color("accent")); act.DoClick=function() if isJobLocked(selectedItem) then DarkRPUI.Notify("warning","Job locked","You do not meet this job requirement."); return end; if currentTab=="jobs" then buyCommand(jobCommand(selectedItem)) else buyItem(selectedItem) end end
    end
    return info
end

local function buildDashboard(body)
    local grid=vgui.Create("DIconLayout",body); grid:Dock(FILL); grid:DockMargin(0,10,0,0); grid:SetSpaceX(16); grid:SetSpaceY(16)
    local hero=vgui.Create("DPanel",grid); hero:SetSize(536,138); hero.Pulse=0; hero.Paint=function(s,w,h) s.Pulse=DarkRPUI.UI.LerpValue(s.Pulse,1,2); DarkRPUI.UI.OutlinedBox(18,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),240),DarkRPUI.Color("accent")); surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("accent"),28)); surface.DrawRect(0,0,w,h); DarkRPUI.UI.Text("CITY COMMAND CENTER","DarkRPUI.Title",22,18); DarkRPUI.UI.Text("Live roleplay controls, economy, server modules, and player status in one polished interface.","DarkRPUI.Small",24,58,DarkRPUI.Color("subtext")); DarkRPUI.UI.Text(os.date("%H:%M").." UTC","DarkRPUI.Number",w-24,22,DarkRPUI.Color("accent"),TEXT_ALIGN_RIGHT) end; addAnim(hero,1)
    local ply=LocalPlayer(); local cards={{"Profile", ply:Nick(), "Current roleplay identity"},{"Current Job", team.GetName(ply:Team()) or "Citizen", "Salary "..DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"salary",0))},{"Wallet", DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"money",0)), "Cash on hand"},{"Vitals", "HP "..ply:Health().." / Armor "..ply:Armor(), "Animated HUD synced"},{"Level / XP", "Level placeholder", "Integrate via DarkRPUI.GetLevelData"},{"Staff Online", tostring(#team.GetPlayers(TEAM_ADMIN or -1)), "Staff presence"},{"Announcements", "Welcome to the city", "Configure server news"},{"Quick Actions", "Jobs • Rules • Store", "One click navigation"}}
    for i,c in ipairs(cards) do local card=DarkRPUI.UI.MakeAnimatedCard(grid,c[1],c[2].."\n"..c[3]); card:SetSize(260,138); addAnim(card,i+1) end
end

local function buildJobs(body, info)
    local top=vgui.Create("DPanel",body); top:Dock(TOP); top:SetTall(50); top.Paint=nil
    local searchHolder, search = makeSearch(top, "Search jobs by name, category, weapons...", nil); searchHolder:Dock(LEFT); searchHolder:SetWide(360)
    local category="All"; local sort="Name"
    local cats={All=true}; for _,j in ipairs(RPExtraTeams or {}) do cats[j.category or j.Category or "General"]=true end
    local combo=vgui.Create("DComboBox",top); combo:Dock(LEFT); combo:DockMargin(12,0,0,6); combo:SetWide(180); combo:SetValue("All categories"); for c in pairs(cats) do combo:AddChoice(c) end; DarkRPUI.UI.StyleCombo(combo)
    local sortBox=vgui.Create("DComboBox",top); sortBox:Dock(LEFT); sortBox:DockMargin(12,0,0,6); sortBox:SetWide(150); sortBox:SetValue("Sort: Name"); sortBox:AddChoice("Name"); sortBox:AddChoice("Salary"); sortBox:AddChoice("Players"); DarkRPUI.UI.StyleCombo(sortBox)
    local scroll=vgui.Create("DScrollPanel",body); scroll:Dock(FILL); scroll:DockMargin(0,8,0,0)
    local grid=vgui.Create("DIconLayout",scroll); grid:Dock(FILL); grid:SetSpaceX(14); grid:SetSpaceY(14)
    local function rebuild()
        grid:Clear(); local q=string.lower(search:GetValue() or ""); local jobs={}
        for id,j in ipairs(RPExtraTeams or {}) do if canShowJob(j) then local cat=j.category or j.Category or "General"; local hay=string.lower(table.concat({itemName(j),cat,itemDesc(j),weaponText(j)}," ")); if (category=="All" or cat==category) and (q=="" or string.find(hay,q,1,true)) then j.team=id; jobs[#jobs+1]=j end end end
        table.sort(jobs,function(a,b) if sort=="Salary" then return jobSalary(a)>jobSalary(b) elseif sort=="Players" then return jobPlayers(a.team)>jobPlayers(b.team) end return itemName(a)<itemName(b) end)
        if #jobs==0 then DarkRPUI.UI.EmptyState(grid,"No jobs found","Try another search or category filter."); return end
        for i,j in ipairs(jobs) do
            local col=safeTeamColor(j.team, DarkRPUI.Color("accent")); local card=DarkRPUI.UI.MakeAnimatedCard(grid,"",""); card:SetSize(300,246); card.Job=j; addAnim(card,i)
            local mdl=DarkRPUI.UI.MakeModelPreview(card, modelList(j), false); mdl:SetPos(14,14); mdl:SetSize(92,110)
            local favKey=jobCommand(j) or itemName(j); local fav=DarkRPUI.UI.MakeIconButton(card, favorites[favKey] and "★" or "☆", function(b) favorites[favKey] = not favorites[favKey] or nil; DarkRPUI.Settings = DarkRPUI.Settings or {}; DarkRPUI.Settings.favorites=favorites; if DarkRPUI.SaveSettings then DarkRPUI.SaveSettings() end; b:SetText(favorites[favKey] and "★" or "☆"); DarkRPUI.UI.PlayClick() end); fav:SetPos(252,14); fav:SetSize(34,34)
            local become=vgui.Create("DButton",card); become:SetText("Become Job"); become:SetPos(14,196); become:SetSize(272,36); DarkRPUI.UI.StyleButton(become,col); become.DoClick=function() if isJobLocked(j) then DarkRPUI.Notify("warning","Job locked","You do not meet this job requirement."); return end; buyCommand(jobCommand(j)) end
            card.PaintOver=function(s,w,h)
                surface.SetDrawColor(col.r,col.g,col.b,210); surface.DrawRect(0,0,4,h)
                DarkRPUI.UI.Text(itemName(j),"DarkRPUI.Subtitle",118,18)
                DarkRPUI.UI.Text(j.category or j.Category or "General","DarkRPUI.Tiny",118,46,DarkRPUI.Color("subtext"))
                DarkRPUI.UI.Badge(118,66,"$ "..DarkRPUI.Util.FormatMoney(jobSalary(j)),DarkRPUI.Color("success"))
                DarkRPUI.UI.Badge(118,90,jobPlayers(j.team).." / "..(jobMax(j)==0 and "∞" or jobMax(j)).." slots",DarkRPUI.Color("accent"))
                draw.DrawText(itemDesc(j),"DarkRPUI.Tiny",14,132,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT)
                DarkRPUI.UI.Text("Loadout: "..weaponText(j),"DarkRPUI.Tiny",14,172,DarkRPUI.Color("muted"))
                local bx=118; if favorites[jobCommand(j) or itemName(j)] then bx=bx+DarkRPUI.UI.Badge(bx,116,"FAV",DarkRPUI.Color("accent"))+6 end; if j.vote then bx=bx+DarkRPUI.UI.Badge(bx,116,"VOTE",DarkRPUI.Color("warning"))+6 end; if isJobLocked(j) then bx=bx+DarkRPUI.UI.Badge(bx,116,"LOCKED",DarkRPUI.Color("error"))+6 end; if j.admin or j.adminOnly then DarkRPUI.UI.Badge(bx,116,"STAFF",DarkRPUI.Color("warning")) elseif j.vip or j.vipOnly then DarkRPUI.UI.Badge(bx,116,"VIP",DarkRPUI.Color("accent")) end
            end
            card.DoClick=function() selectedItem=j; info.Refresh() end
        end
    end
    combo.OnSelect=function(_,_,v) category=v; rebuild() end; sortBox.OnSelect=function(_,_,v) sort=v; rebuild() end; search.OnChange=rebuild; rebuild()
end

local function buildShop(body, tab, info)
    local searchHolder, search = makeSearch(body, "Search "..tab.."...", nil); searchHolder:Dock(TOP); searchHolder:DockMargin(0,0,0,12)
    local scroll=vgui.Create("DScrollPanel",body); scroll:Dock(FILL)
    local grid=vgui.Create("DIconLayout",scroll); grid:Dock(FILL); grid:SetSpaceX(14); grid:SetSpaceY(14)
    local function rebuild()
        grid:Clear(); local q=string.lower(search:GetValue() or ""); local items=(sources[tab] and sources[tab]()) or {}; local n=0
        for _,it in ipairs(items) do local hay=string.lower(itemName(it).." "..itemDesc(it)); if q=="" or string.find(hay,q,1,true) then n=n+1; local price=itemPrice(it); local card=DarkRPUI.UI.MakeAnimatedCard(grid,itemName(it),itemDesc(it)); card:SetSize(260,150); addAnim(card,n); card.DoClick=function() selectedItem=it; info.Refresh() end; card.PaintOver=function(_,w,h) if price then DarkRPUI.UI.Text(DarkRPUI.Util.FormatMoney(price),"DarkRPUI.Subtitle",16,h-34,DarkRPUI.Color("success")) end end; local b=vgui.Create("DButton",card); b:SetText("Buy"); b:SetPos(170,104); b:SetSize(74,32); DarkRPUI.UI.StyleButton(b,DarkRPUI.Color("success")); b.DoClick=function() buyItem(it) end end end
        if n==0 then DarkRPUI.UI.EmptyState(grid,"Nothing available","No configured DarkRP data matched this filter.") end
    end
    search.OnChange=rebuild; rebuild()
end

function DarkRPUI.F4.Close()
    local f = DarkRPUI.F4.Frame; if not IsValid(f) then return end; DarkRPUI.F4.Frame=nil; gui.EnableScreenClicker(false); DarkRPUI.UI.AnimateOut(f,function(p) if IsValid(p) then p:Remove() end end)
end
function DarkRPUI.F4.Open()
    if IsValid(DarkRPUI.F4.Frame) then DarkRPUI.F4.Close(); return end
    selectedItem=nil; currentTab="dashboard"
    local f=vgui.Create("DFrame"); DarkRPUI.F4.Frame=f; f:SetSize(ScrW()*0.92,ScrH()*0.90); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:MakePopup(); f:SetKeyboardInputEnabled(true); DarkRPUI.UI.AnimateIn(f)
    f.OnKeyCodePressed=function(_,key) if key==KEY_ESCAPE then DarkRPUI.F4.Close() end end
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,8); DarkRPUI.UI.OutlinedBox(22,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),238),DarkRPUI.Color("border")); DarkRPUI.UI.Text(GetHostName() or "DarkRP Server","DarkRPUI.Title",30,22); local ply=LocalPlayer(); DarkRPUI.UI.Text(ply:Nick().."  •  "..DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"money",0)).."  •  "..(team.GetName(ply:Team()) or "Citizen"),"DarkRPUI.Small",32,62,DarkRPUI.Color("subtext")) end
    local close=DarkRPUI.UI.MakeCloseButton(f, DarkRPUI.F4.Close); close:SetPos(f:GetWide()-64,20)
    local nav=vgui.Create("DPanel",f); nav:SetPos(22,96); nav:SetSize(220,f:GetTall()-118); nav.Paint=function(_,w,h) DarkRPUI.UI.OutlinedBox(18,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border")) end
    local body=vgui.Create("DPanel",f); body:SetPos(264,96); body:SetSize(f:GetWide()-606,f:GetTall()-118); body.Paint=nil
    local info=buildInfoPanel(f); info:SetPos(f:GetWide()-322,96); info:SetTall(f:GetTall()-118)
    local function render(tab,name)
        currentTab=tab; selectedItem=nil; body:Clear(); body:SetAlpha(0); body:AlphaTo(255,0.14,0); info.Refresh(); DarkRPUI.UI.PlayClick(); local head=DarkRPUI.UI.MakeHeader(body,name,"Premium animated controls, filters, sorting, and server-safe data."); head:Dock(TOP); head:DockMargin(0,0,0,6)
        if tab=="dashboard" then buildDashboard(body) elseif tab=="jobs" then buildJobs(body,info) elseif tab=="rules" then local l=vgui.Create("DLabel",body); l:Dock(FILL); l:SetWrap(true); l:SetFont("DarkRPUI.Body"); l:SetTextColor(DarkRPUI.Color("subtext")); l:SetText((DarkRPUI.Config and DarkRPUI.Config.RulesText) or "No rules configured.") elseif tab=="settings" then DarkRPUI.SettingsPanel(body) elseif tab=="admin" then DarkRPUI.Admin.OpenPanel(body) elseif sources[tab] then buildShop(body,tab,info) else DarkRPUI.UI.EmptyState(body,"Coming soon",(DarkRPUI.Config.Placeholders and DarkRPUI.Config.Placeholders[tab]) or "This premium module is ready for integration.") end
    end
    for _,t in ipairs((DarkRPUI.Config and DarkRPUI.Config.F4Tabs) or {}) do if not t.staffOnly or DarkRPUI.Util.IsAdmin(LocalPlayer()) then local b=DarkRPUI.UI.MakeIconButton(nav,t.icon.."  "..t.name,function() render(t.id,t.name) end); b:Dock(TOP); b:DockMargin(12,8,12,0); b:SetTall(42); b.ActiveFunc=function() return currentTab==t.id end end end
    render("dashboard","Dashboard")
end
hook.Add("ShowSpare2", "DarkRPUI.F4.Override", function() if not DarkRPUI.Config or DarkRPUI.Config.EnableF4Menu ~= false then DarkRPUI.F4.Open(); return false end end)
