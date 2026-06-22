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
    ammo=function() return (GAMEMODE and GAMEMODE.AmmoTypes) or {} end,
    food=function() return FoodItems or {} end
}

local function safeTeamColor(teamId, fallback) if teamId and team.GetColor then return team.GetColor(teamId) end return fallback or DarkRPUI.Color("accent") end
local function buyCommand(cmd) if cmd and cmd ~= "" then DarkRPUI.UI.PlayClick(); RunConsoleCommand("say", "/" .. cmd) end end
local function itemName(it) return it and (it.name or it.Name or it.label or it.ammoType or it.entity or "Item") or "Item" end
local function itemDesc(it) local d=it and (it.description or it.desc or it.Description or it.entity or it.command or it.cmd or "Available on this server") or "Available on this server"; return tostring(d) end
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
local function buyItem(it) if DarkRPUI.Config and DarkRPUI.Config.ConfirmPurchases then DarkRPUI.UI.Confirm("Confirm purchase", "Purchase "..itemName(it).."?", "Buy", "Cancel", function(ok) if ok then buyCommand(it.cmd or it.command) end end) else buyCommand(it.cmd or it.command) end end
local function jobSalary(job) return job and (job.salary or job.Salary or 0) or 0 end
local function jobPlayers(teamId) local count=0 for _,p in ipairs(player.GetAll()) do if p:Team()==teamId then count=count+1 end end return count end
local function jobMax(job) return job and (job.max or job.Max or 0) or 0 end
local function weaponText(job) local weapons=job and (job.weapons or job.Weapons) or {}; if #weapons == 0 then return "Standard loadout" end return table.concat(weapons, ", ") end

local function shipmentKeys(it) return { it and it.name, it and it.Name, it and it.entity, it and it.class, it and it.weaponClass } end
local function shipmentWhitelist(it)
    local cfg = (DarkRPUI.Config and DarkRPUI.Config.ShipmentJobWhitelist) or {}
    for _,k in ipairs(shipmentKeys(it)) do if k and cfg[k] ~= nil then return cfg[k] end end
end
local function shipmentAllowed(it)
    if currentTab ~= "shipments" then return true end
    local wl = shipmentWhitelist(it); local defaultAllow = DarkRPUI.Config.ShipmentWhitelistDefaultAllow == true
    if wl == nil then return defaultAllow end
    local teamId = LocalPlayer():Team()
    for key,allowed in pairs(wl) do
        local resolved = isnumber(key) and key or _G[tostring(key)]
        if allowed and resolved == teamId then return true end
        if allowed == false and resolved == teamId then return false end
    end
    return defaultAllow and true or false
end

local function isJobLocked(job) local grp=DarkRPUI.Util.PlayerGroup(LocalPlayer()); if job and job.customCheck and not job.customCheck(LocalPlayer()) then return true end; if job and job.allowed and not job.allowed[grp] then return true end; return false end
local function canShowJob(job) if not job then return false end if job.customCheck and job.CustomCheckFailMsg and not job.customCheck(LocalPlayer()) then return true end return true end
local function addAnim(panel, index) panel:SetAlpha(0); panel.DarkRPUIEntrance=0; timer.Simple((index or 1)*0.012, function() if IsValid(panel) then panel:AlphaTo(255, DarkRPUI.UI.AnimSpeed(1.15), 0); panel.DarkRPUIEntrance=1 end end) end

local function makeSearch(parent, placeholder, onChange)
    return DarkRPUI.UI.PremiumSearch(parent, placeholder, onChange)
end

local function statRow(parent, y, icon, label, value, col)
    local r=vgui.Create("DPanel",parent); r:SetPos(24,y); r:SetSize(parent:GetWide()-48,30)
    r.Paint=function(_,w,h)
        DarkRPUI.UI.RoundedBox(8,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("card"),170))
        DarkRPUI.UI.Text(icon or "•","DarkRPUI.Small",10,7,col or DarkRPUI.Color("accent"))
        DarkRPUI.UI.Text(label,"DarkRPUI.Tiny",34,8,DarkRPUI.Color("subtext"))
        DarkRPUI.UI.Text(tostring(value or "—"),"DarkRPUI.Tiny",w-10,8,DarkRPUI.Color("text"),TEXT_ALIGN_RIGHT)
    end
    return y+36
end

local function buildInfoPanel(parent)
    local info=vgui.Create("DPanel",parent); info:SetWide(DarkRPUI.Util.Scale(340)); info.RefreshPulse=0; info.Paint=function(s,w,h)
        DarkRPUI.UI.ShadowedBox(18,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),235),DarkRPUI.Color("border"),120)
        if not selectedItem then DarkRPUI.UI.Text("Select an item","DarkRPUI.Subtitle",24,26); DarkRPUI.UI.Text("Details, requirements, preview, and actions appear here.","DarkRPUI.Small",24,58,DarkRPUI.Color("subtext")); return end
        DarkRPUI.UI.Text(itemName(selectedItem),"DarkRPUI.Subtitle",24,24)
        if currentTab=="shipments" and not shipmentAllowed(selectedItem) then DarkRPUI.UI.Text("Restricted to specific jobs.","DarkRPUI.Small",24,82,DarkRPUI.Color("locked")) end
        draw.DrawText(itemDesc(selectedItem),"DarkRPUI.Tiny",24,54,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT)
    end
    info.Refresh=function()
        info:Clear(); if not selectedItem then return end
        info.RefreshPulse=1; info:AlphaTo(235,0,0); info:AlphaTo(255,DarkRPUI.UI.AnimSpeed(1.1),0)
        local mdl=DarkRPUI.UI.MakeModelPreview(info, modelList(selectedItem), true); mdl:SetPos(20,104); mdl:SetSize(info:GetWide()-40,250); mdl:SetAlpha(0); mdl:AlphaTo(255,DarkRPUI.UI.AnimSpeed(1.2),0)
        local y=366; local price=itemPrice(selectedItem); local salary=selectedItem.salary or selectedItem.Salary
        local bx=24
        if price then bx=bx+DarkRPUI.UI.Badge(bx,y,DarkRPUI.Util.FormatMoney(price),DarkRPUI.Color("success"))+6 end
        if salary then bx=bx+DarkRPUI.UI.Badge(bx,y,"Salary "..DarkRPUI.Util.FormatMoney(salary),DarkRPUI.Color("success"))+6 end
        if selectedItem.team then bx=bx+DarkRPUI.UI.Badge(bx,y,jobPlayers(selectedItem.team).."/"..(jobMax(selectedItem)==0 and "∞" or jobMax(selectedItem)).." slots",DarkRPUI.Color("accent"))+6 end
        if isJobLocked(selectedItem) then bx=bx+DarkRPUI.UI.Badge(bx,y,"LOCKED",DarkRPUI.Color("error"))+6 end
        if selectedItem.vip or selectedItem.vipOnly then bx=bx+DarkRPUI.UI.Badge(bx,y,"VIP",DarkRPUI.Color("accent"))+6 end
        if selectedItem.vote then bx=bx+DarkRPUI.UI.Badge(bx,y,"VOTE",DarkRPUI.Color("warning"))+6 end
        y=y+34
        y=statRow(info,y,"▣","Category",selectedItem.category or selectedItem.Category or "General",DarkRPUI.Color("accent"))
        y=statRow(info,y,"◈",price and "Price" or "Salary",price and DarkRPUI.Util.FormatMoney(price) or DarkRPUI.Util.FormatMoney(salary or 0),DarkRPUI.Color("success"))
        y=statRow(info,y,"●","Population",selectedItem.team and (jobPlayers(selectedItem.team).." / "..(jobMax(selectedItem)==0 and "∞" or jobMax(selectedItem))) or "—",DarkRPUI.Color("info"))
        y=statRow(info,y,"◆","Models",tostring(#modelList(selectedItem)).." available",DarkRPUI.Color("accent"))
        y=statRow(info,y,"!","Requirements",isJobLocked(selectedItem) and "VIP / staff / custom check" or "Available",isJobLocked(selectedItem) and DarkRPUI.Color("error") or DarkRPUI.Color("success"))
        if currentTab=="jobs" then y=statRow(info,y,"⌁","Loadout",weaponText(selectedItem),DarkRPUI.Color("warning")) end
        if currentTab=="jobs" then local favKey=jobCommand(selectedItem) or itemName(selectedItem); local fav=DarkRPUI.UI.MakeIconButton(info,favorites[favKey] and "★ Favorite" or "☆ Favorite",function(b) favorites[favKey]=not favorites[favKey] or nil; DarkRPUI.Settings=DarkRPUI.Settings or {}; DarkRPUI.Settings.favorites=favorites; if DarkRPUI.SaveSettings then DarkRPUI.SaveSettings() end; b:SetText(favorites[favKey] and "★ Favorite" or "☆ Favorite") end); fav:SetPos(24,info:GetTall()-124); fav:SetSize(info:GetWide()-48,40) end
        local lockedShipment = currentTab=="shipments" and not shipmentAllowed(selectedItem)
        local act=vgui.Create("DButton",info); act:SetPos(24,info:GetTall()-70); act:SetSize(info:GetWide()-48,48); act:SetText(lockedShipment and "Restricted" or (currentTab=="jobs" and (isJobLocked(selectedItem) and "Requirements Not Met" or "Become Job") or "Purchase")); DarkRPUI.UI.StyleButton(act, (lockedShipment or isJobLocked(selectedItem)) and DarkRPUI.Color("error") or DarkRPUI.Color("accent")); act.DoClick=function() DarkRPUI.UI.PlayClick(); if lockedShipment then DarkRPUI.Notify("warning","Shipment locked","Restricted to specific jobs."); return end; if isJobLocked(selectedItem) then DarkRPUI.Notify("warning","Job locked","You do not meet this job requirement."); return end; if currentTab=="jobs" then buyCommand(jobCommand(selectedItem)) else buyItem(selectedItem) end end
    end
    return info
end

local function buildDashboard(body)
    local grid=vgui.Create("DIconLayout",body); grid:Dock(FILL); grid:DockMargin(0,10,0,0); grid:SetSpaceX(16); grid:SetSpaceY(16)
    local hero=vgui.Create("DPanel",grid); hero:SetSize(536,138); hero.Pulse=0; hero.Paint=function(s,w,h) s.Pulse=DarkRPUI.UI.LerpValue(s.Pulse,1,2); DarkRPUI.UI.OutlinedBox(18,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),240),DarkRPUI.Color("accent")); surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("accent"),28)); surface.DrawRect(0,0,w,h); DarkRPUI.UI.Text("CITY COMMAND CENTER","DarkRPUI.Title",22,18); DarkRPUI.UI.Text("Live roleplay controls, economy, server modules, and player status in one polished interface.","DarkRPUI.Small",24,58,DarkRPUI.Color("subtext")); DarkRPUI.UI.Text(os.date("%H:%M").." UTC","DarkRPUI.Number",w-24,22,DarkRPUI.Color("accent"),TEXT_ALIGN_RIGHT) end; addAnim(hero,1)
    local ply=LocalPlayer(); local cards={{"Profile", ply:Nick(), "Current roleplay identity"},{"Current Job", team.GetName(ply:Team()) or "Citizen", "Salary "..DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"salary",0))},{"Wallet", DarkRPUI.Util.FormatMoney(DarkRPUI.Util.DarkRPVar(ply,"money",0)), "Cash on hand"},{"Vitals", "HP "..ply:Health().." / Armor "..ply:Armor(), "Animated HUD synced"},{"Level / XP", "Level placeholder", "Integrate via DarkRPUI.GetLevelData"},{"Staff Online", tostring(#team.GetPlayers(TEAM_ADMIN or -1)), "Staff presence"},{"Announcements", "Welcome to the city", "Configure server news"},{"Quick Actions", "Jobs • Rules • Store", "One click navigation"}}
    for i,c in ipairs(cards) do local card=DarkRPUI.UI.MakeAnimatedCard(grid,c[1],c[2].."\n"..c[3]); card:SetSize(260,138); addAnim(card,i+1) end
end

local function openJobDetail(job, parent, refresh)
    if not IsValid(parent) or not job then return end
    if IsValid(DarkRPUI.F4.JobDetail) then DarkRPUI.F4.JobDetail:Remove() end
    local overlay=vgui.Create("DPanel", parent); DarkRPUI.F4.JobDetail=overlay; overlay:Dock(FILL); overlay:SetAlpha(0); overlay:AlphaTo(255, DarkRPUI.UI.AnimSpeed(1), 0)
    overlay.Paint=function(_,w,h) DarkRPUI.UI.DrawBlur(parent,5); surface.SetDrawColor(0,0,0,165); surface.DrawRect(0,0,w,h) end
    local panel=vgui.Create("DPanel", overlay); panel:SetSize(math.min(parent:GetWide()-40,760), parent:GetTall()-42); panel:SetPos(parent:GetWide()-panel:GetWide()-20,21)
    local col=safeTeamColor(job.team, DarkRPUI.Color("accent")); local tab="description"
    panel.Paint=function(_,w,h)
        DarkRPUI.UI.ShadowedBox(22,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),248),DarkRPUI.Color("border"),140)
        surface.SetDrawColor(col.r,col.g,col.b,220); surface.DrawRect(0,0,6,h)
        surface.SetDrawColor(col.r,col.g,col.b,34); surface.DrawRect(6,0,w-6,96)
        DarkRPUI.UI.Text(itemName(job),"DarkRPUI.Title",28,22,DarkRPUI.Color("text"))
        DarkRPUI.UI.Text((job.category or job.Category or "General").." • Salary "..DarkRPUI.Util.FormatMoney(jobSalary(job)),"DarkRPUI.Small",30,56,col)
        local bx=30; if isJobLocked(job) then bx=bx+DarkRPUI.UI.Badge(bx,78,"LOCKED",DarkRPUI.Color("error"))+6 end; if job.vote then bx=bx+DarkRPUI.UI.Badge(bx,78,"VOTE",DarkRPUI.Color("warning"))+6 end; if job.vip or job.vipOnly then DarkRPUI.UI.Badge(bx,78,"VIP",DarkRPUI.Color("accent")) end
        DarkRPUI.UI.Text(tab=="weapons" and "Loadout" or tab=="rules" and "Rules & requirements" or "Description","DarkRPUI.Subtitle",30,128,col)
        local text = tab=="weapons" and weaponText(job) or tab=="rules" and "Follow staff direction, value roleplay, and respect job-specific limits.\n\nRequirements: "..(isJobLocked(job) and "Custom check / rank restriction" or "Available now") or itemDesc(job)
        draw.DrawText(text,"DarkRPUI.Small",30,162,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT)
        DarkRPUI.UI.Badge(30,h-118,jobPlayers(job.team).." / "..(jobMax(job)==0 and "∞" or jobMax(job)).." slots",DarkRPUI.Color("accent"))
    end
    local close=DarkRPUI.UI.MakeCloseButton(panel,function() if IsValid(overlay) then overlay:Remove() end end); close:SetPos(panel:GetWide()-58,16)
    local tabs={{"description","Description"},{"weapons","Weapons"},{"rules","Rules"}}
    for i,t in ipairs(tabs) do local b=vgui.Create("DButton",panel); b:SetText(t[2]); b:SetFont("DarkRPUI.Small"); b:SetTextColor(DarkRPUI.Color("text")); b:SetPos(30+(i-1)*112,102); b:SetSize(104,30); b.Paint=function(_,w,h) if tab==t[1] then surface.SetDrawColor(col); surface.DrawRect(10,h-3,w-20,3) end end; b.DoClick=function() tab=t[1] end end
    local mdl=DarkRPUI.UI.MakeModelPreview(panel, modelList(job), true); mdl:SetPos(panel:GetWide()-300,108); mdl:SetSize(270,panel:GetTall()-210)
    local favKey=jobCommand(job) or itemName(job); local fav=DarkRPUI.UI.MakeIconButton(panel, favorites[favKey] and "★ Favorite" or "☆ Favorite", function(b) favorites[favKey]=not favorites[favKey] or nil; DarkRPUI.Settings=DarkRPUI.Settings or {}; DarkRPUI.Settings.favorites=favorites; if DarkRPUI.SaveSettings then DarkRPUI.SaveSettings() end; b:SetText(favorites[favKey] and "★ Favorite" or "☆ Favorite"); if refresh then refresh() end end); fav:SetPos(30,panel:GetTall()-66); fav:SetSize(170,42)
    local become=vgui.Create("DButton",panel); become:SetText(isJobLocked(job) and "Requirements Not Met" or "Become"); become:SetPos(214,panel:GetTall()-66); become:SetSize(220,42); DarkRPUI.UI.StyleButton(become,isJobLocked(job) and DarkRPUI.Color("error") or col); become.DoClick=function() if isJobLocked(job) then DarkRPUI.Notify("warning","Job locked","You do not meet this job requirement."); return end; buyCommand(jobCommand(job)) end
end

local function sectionHeader(parent, title)
    local h=vgui.Create("DPanel",parent); h:Dock(TOP); h:DockMargin(0,8,0,6); h:SetTall(32)
    h.Paint=function(_,w,hh) DarkRPUI.UI.RoundedBox(9,0,0,w,hh,DarkRPUI.Color("panelDark")); DarkRPUI.UI.Text(title,"DarkRPUI.Small",12,8,DarkRPUI.Color("text")); DarkRPUI.UI.Text("⌄","DarkRPUI.Small",w-22,8,DarkRPUI.Color("accent"),TEXT_ALIGN_CENTER) end
    return h
end

local function buildJobs(body, info)
    local top=vgui.Create("DPanel",body); top:Dock(TOP); top:SetTall(50); top.Paint=nil
    local searchHolder, search = makeSearch(top, "Search jobs…", nil); searchHolder:Dock(LEFT); searchHolder:SetWide(360)
    local favOnly=false; local favBtn=DarkRPUI.UI.MakeIconButton(top,"☆ Show Favorites",function(b) favOnly=not favOnly; b:SetText(favOnly and "★ Favorites" or "☆ Show Favorites"); if b.Rebuild then b.Rebuild() end end); favBtn:Dock(RIGHT); favBtn:SetWide(160)
    local scroll=vgui.Create("DScrollPanel",body); scroll:Dock(FILL); scroll:DockMargin(0,8,0,0); DarkRPUI.UI.StyleScrollbar(scroll)
    local function rebuild()
        scroll:Clear(); local q=string.lower(search:GetValue() or ""); local grouped={}; local order={}
        for id,j in ipairs(RPExtraTeams or {}) do if canShowJob(j) then j.team=id; local fav=favorites[jobCommand(j) or itemName(j)]; local hay=string.lower(table.concat({itemName(j),j.category or j.Category or "General",itemDesc(j),weaponText(j)}," ")); if (not favOnly or fav) and (q=="" or string.find(hay,q,1,true)) then local cat=fav and "Favorite" or (j.category or j.Category or "General"); if not grouped[cat] then grouped[cat]={}; order[#order+1]=cat end; grouped[cat][#grouped[cat]+1]=j end end end
        table.sort(order,function(a,b) if a=="Favorite" then return true elseif b=="Favorite" then return false end return a<b end)
        if #order==0 then DarkRPUI.UI.EmptyState(scroll,"No jobs found","Try another search or disable favorites."); return end
        for _,cat in ipairs(order) do sectionHeader(scroll,cat); for _,j in ipairs(grouped[cat]) do local col=safeTeamColor(j.team,DarkRPUI.Color("accent")); local row=vgui.Create("DButton",scroll); row:Dock(TOP); row:DockMargin(0,0,0,7); row:SetTall(66); row:SetText(""); row.Paint=function(s,w,h) s.Hover=DarkRPUI.UI.HoverLerp(s,12); DarkRPUI.UI.ShadowedBox(14,0,-math.floor(2*s.Hover),w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"),col),60); surface.SetDrawColor(col.r,col.g,col.b,210); surface.DrawRect(0,10,4,h-20); DarkRPUI.UI.Text(itemName(j),"DarkRPUI.Body",72,12); DarkRPUI.UI.Text("Salary "..DarkRPUI.Util.FormatMoney(jobSalary(j)),"DarkRPUI.Small",72,36,DarkRPUI.Color("success")); DarkRPUI.UI.Text(jobPlayers(j.team).."/"..(jobMax(j)==0 and "∞" or jobMax(j)),"DarkRPUI.Subtitle",w-54,21,col,TEXT_ALIGN_CENTER); if isJobLocked(j) then DarkRPUI.UI.Badge(w-150,23,"LOCKED",DarkRPUI.Color("error")) end end; local av=DarkRPUI.UI.MakeModelPreview(row, modelList(j), false); av:SetPos(12,7); av:SetSize(46,52); row.DoClick=function() selectedItem=j; if IsValid(info) then info.Refresh() end; openJobDetail(j, body, rebuild) end end end
    end
    favBtn.Rebuild=rebuild; search.OnChange=rebuild; rebuild()
end

local function buildPlayerUpgrades(body)
    local scroll=DarkRPUI.UI.ScrollPanel(body); scroll:Dock(FILL); scroll:DockMargin(0,8,0,0)
    local grid=vgui.Create("DIconLayout",scroll); grid:Dock(FILL); grid:SetSpaceX(14); grid:SetSpaceY(14)
    if hook.Run("DarkRPUI.BuildPlayerUpgrades", body) == true then return end
    local upgrades={{"Stamina","Run longer and recover faster","◆"},{"Strength","Improve carrying power and melee presence","✦"},{"Business","Better shop margins and commerce tools","$"},{"Crafting","Blueprint and production bonuses","▣"},{"Driving","Vehicle handling and delivery perks","⌁"},{"Security","Lock, alarm, and defense integrations","◈"},{"Intelligence","XP, research, and scanner bonuses","●"},{"Luck","Improve rare outcomes and discovery chances","★"},{"Endurance","Survive longer under pressure","♥"},{"Charisma","Improve roleplay social and trading perks","☻"}}
    for i,u in ipairs(upgrades) do
        local c=DarkRPUI.UI.MakeAnimatedCard(grid,"",""); c:SetSize(260,164); addAnim(c,i)
        c.PaintOver=function(_,w,h)
            DarkRPUI.UI.Text(u[3],"DarkRPUI.Title",18,16,DarkRPUI.Color("accent")); DarkRPUI.UI.Text(u[1],"DarkRPUI.Subtitle",62,20);
            draw.DrawText(u[2],"DarkRPUI.Small",18,58,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT)
            DarkRPUI.UI.RoundedBox(5,18,112,w-36,8,DarkRPUI.Color("border")); DarkRPUI.UI.RoundedBox(5,18,112,(w-36)*(0.12+(i%4)*0.18),8,DarkRPUI.Color("accent"))
            DarkRPUI.UI.Badge(18,132,"INTEGRATION READY",DarkRPUI.Color("info"))
        end
    end
end

local function buildShop(body, tab, info)
    local top=vgui.Create("DPanel",body); top:Dock(TOP); top:SetTall(50); top.Paint=nil
    local searchHolder, search = makeSearch(top, "Search "..tab.."…", nil); searchHolder:Dock(LEFT); searchHolder:SetWide(360)
    local favOnly=false; local favBtn=DarkRPUI.UI.MakeIconButton(top,"☆ Show Favorites",function(b) favOnly=not favOnly; b:SetText(favOnly and "★ Favorites" or "☆ Show Favorites"); if b.Rebuild then b.Rebuild() end end); favBtn:Dock(RIGHT); favBtn:SetWide(160)
    local scroll=vgui.Create("DScrollPanel",body); scroll:Dock(FILL); scroll:DockMargin(0,8,0,0); DarkRPUI.UI.StyleScrollbar(scroll)
    local function favoriteKey(it) return tab..":"..(itemName(it) or tostring(it)) end
    local function rebuild()
        scroll:Clear(); local q=string.lower(search:GetValue() or ""); local items=(sources[tab] and sources[tab]()) or {}; local grouped={}; local order={}
        for _,it in ipairs(items) do
            local allowed=shipmentAllowed(it); local locked=tab=="shipments" and not allowed
            if tab ~= "shipments" or allowed or DarkRPUI.Config.ShowLockedShipments ~= false then
                local fav=favorites[favoriteKey(it)]; local hay=string.lower(itemName(it).." "..itemDesc(it).." "..(it.category or it.Category or "General"))
                if (not favOnly or fav) and (q=="" or string.find(hay,q,1,true)) then
                    local cat=fav and "Favorite" or (it.category or it.Category or (tab=="shipments" and "Shipments" or tab=="weapons" and "Weapons" or "General"))
                    if not grouped[cat] then grouped[cat]={}; order[#order+1]=cat end
                    grouped[cat][#grouped[cat]+1]={data=it, locked=locked}
                end
            end
        end
        table.sort(order,function(a,b) if a=="Favorite" then return true elseif b=="Favorite" then return false end return a<b end)
        if #order==0 then DarkRPUI.UI.EmptyState(scroll,"Nothing available","No configured DarkRP data matched this filter."); return end
        for _,cat in ipairs(order) do sectionHeader(scroll,cat); for _,wrap in ipairs(grouped[cat]) do local it,locked=wrap.data,wrap.locked; local price=itemPrice(it); local row=vgui.Create("DButton",scroll); row:Dock(TOP); row:DockMargin(0,0,0,7); row:SetTall(64); row:SetText(""); row.Paint=function(s,w,h) s.Hover=DarkRPUI.UI.HoverLerp(s,12); DarkRPUI.UI.ShadowedBox(14,0,-math.floor(2*s.Hover),w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"), locked and DarkRPUI.Color("error") or DarkRPUI.Color("accent")),60); DarkRPUI.UI.Text(itemName(it),"DarkRPUI.Body",74,11); DarkRPUI.UI.Text(locked and "Restricted to specific jobs" or itemDesc(it),"DarkRPUI.Tiny",74,36,locked and DarkRPUI.Color("locked") or DarkRPUI.Color("subtext")); if price then DarkRPUI.UI.Text(DarkRPUI.Util.FormatMoney(price),"DarkRPUI.Body",w-88,21,DarkRPUI.Color("success"),TEXT_ALIGN_RIGHT) end; if locked then DarkRPUI.UI.Badge(w-184,22,"LOCKED",DarkRPUI.Color("error")) end end
            local mdl=DarkRPUI.UI.MakeModelPreview(row, modelList(it), false); mdl:SetPos(12,7); mdl:SetSize(46,50)
            local fav=DarkRPUI.UI.MakeIconButton(row, favorites[favoriteKey(it)] and "★" or "☆", function(b) favorites[favoriteKey(it)]=not favorites[favoriteKey(it)] or nil; DarkRPUI.Settings=DarkRPUI.Settings or {}; DarkRPUI.Settings.favorites=favorites; if DarkRPUI.SaveSettings then DarkRPUI.SaveSettings() end; b:SetText(favorites[favoriteKey(it)] and "★" or "☆"); rebuild() end); fav:SetPos(row:GetWide()-42,12); fav:SetSize(32,32); row.PerformLayout=function(_,w) fav:SetPos(w-42,16) end
            row.DoClick=function() selectedItem=it; if IsValid(info) then info.Refresh() end end
            row.DoRightClick=function() if locked then DarkRPUI.Notify("warning","Shipment locked","Restricted to whitelisted jobs.") else buyItem(it) end end
        end end
    end
    favBtn.Rebuild=rebuild; search.OnChange=rebuild; rebuild()
end


local function buildShopHub(body, info)
    local active = "entities"
    local tabs = {
        {id="entities", name="Entities", icon="▣"}, {id="weapons", name="Weapons", icon="⌁"},
        {id="shipments", name="Shipments", icon="▤"}, {id="ammo", name="Ammo", icon="▪"}, {id="food", name="Food", icon="◍"}
    }
    local tabbar=vgui.Create("DPanel",body); tabbar:Dock(TOP); tabbar:SetTall(50); tabbar.Paint=function(_,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("panelDark")); surface.SetDrawColor(DarkRPUI.Color("border")); surface.DrawRect(0,h-1,w,1) end
    local content=vgui.Create("DPanel",body); content:Dock(FILL); content:DockMargin(0,12,0,0)
    local buttons={}
    local function selectTab(id)
        active=id; currentTab=id; selectedItem=nil; content:Clear(); if IsValid(info) then info.Refresh() end
        buildShop(content,id,info)
    end
    for _,t in ipairs(tabs) do
        local b=vgui.Create("DButton",tabbar); b:Dock(LEFT); b:SetWide(142); b:SetText(t.icon.."  "..t.name); b:SetFont("DarkRPUI.Body"); b:SetTextColor(DarkRPUI.Color("muted")); b.Hover=0; buttons[#buttons+1]=b
        b.Paint=function(btn,w,h) btn.Hover=DarkRPUI.UI.HoverLerp(btn,14); local on=active==t.id; btn:SetTextColor(on and DarkRPUI.Color("accent") or DarkRPUI.LerpColor(btn.Hover,DarkRPUI.Color("muted"),DarkRPUI.Color("text"))); if on then surface.SetDrawColor(DarkRPUI.Color("accent")); surface.DrawRect(16,h-3,w-32,3) end end
        b.DoClick=function() selectTab(t.id) end
    end
    selectTab(active)
end

function DarkRPUI.F4.Close()
    local f = DarkRPUI.F4.Frame; if not IsValid(f) then return end; DarkRPUI.F4.Frame=nil; gui.EnableScreenClicker(false); DarkRPUI.UI.AnimateOut(f,function(p) if IsValid(p) then p:Remove() end end)
end
function DarkRPUI.F4.Open()
    if IsValid(DarkRPUI.F4.Frame) then DarkRPUI.F4.Close(); return end
    selectedItem=nil; currentTab="dashboard"
    local f=vgui.Create("DFrame"); DarkRPUI.F4.Frame=f; local fw,fh=DarkRPUI.Layout.SizeForScreen(math.max(820,ScrW()*0.70),math.max(560,ScrH()*0.76)); f:SetSize(fw,fh); f:Center(); DarkRPUI.Layout.ClampPanel(f,true); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:MakePopup(); f:SetKeyboardInputEnabled(true); DarkRPUI.UI.AnimateIn(f)
    f.OnKeyCodePressed=function(_,key) if key==KEY_ESCAPE then DarkRPUI.F4.Close() end end
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,8); DarkRPUI.UI.ShadowedBox(22,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),238),DarkRPUI.Color("border")); DarkRPUI.UI.Text(string.upper(GetHostName() or "DarkRP Server"),"DarkRPUI.Title",w/2,18,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER); local ply=LocalPlayer(); DarkRPUI.UI.Text("PREMIUM ROLEPLAY DASHBOARD","DarkRPUI.Tiny",w/2,44,DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER) end
    local close=DarkRPUI.UI.MakeCloseButton(f, DarkRPUI.F4.Close); close:SetPos(f:GetWide()-64,20)
    local navWrap=vgui.Create("DPanel",f); navWrap:SetPos(22,84); navWrap:SetSize(224,f:GetTall()-106); navWrap.Paint=function(_,w,h) DarkRPUI.UI.ShadowedBox(16,0,0,w,h,DarkRPUI.Color("sidebar"),DarkRPUI.Color("border")) end; local profile=vgui.Create("DPanel",navWrap); profile:Dock(TOP); profile:DockMargin(10,10,10,6); profile:SetTall(70); profile.Paint=function(_,w,h) local ply=LocalPlayer(); DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("cardDark")); surface.SetDrawColor(team.GetColor(ply:Team())); surface.DrawOutlinedRect(10,10,50,50,2); DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Body",70,15,DarkRPUI.Color("text")); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Citizen","DarkRPUI.Small",70,38,team.GetColor(ply:Team())) end; local av=vgui.Create("AvatarImage",profile); av:SetSize(42,42); av:SetPos(14,14); av:SetPlayer(LocalPlayer(),42); local nav=vgui.Create("DScrollPanel",navWrap); nav:Dock(FILL); nav:DockMargin(6,0,6,10); DarkRPUI.UI.StyleScrollbar(nav)
    local body=vgui.Create("DPanel",f); body:SetPos(266,84); body:SetSize(math.max(280,f:GetWide()-616),f:GetTall()-106); body.Paint=nil
    local info=buildInfoPanel(f); info:SetWide(math.min(DarkRPUI.Util.Scale(320), math.max(260, f:GetWide()*0.28))); info:SetPos(f:GetWide()-info:GetWide()-22,84); info:SetTall(f:GetTall()-106); body:SetWide(math.max(280, info:GetX()-body:GetX()-18))
    local function render(tab,name)
        currentTab=tab; selectedItem=nil; body:Clear(); body:SetAlpha(0); body:AlphaTo(255,DarkRPUI.UI.AnimSpeed(1),0); info.Refresh(); DarkRPUI.UI.PlayClick(); local head=DarkRPUI.UI.MakeHeader(body,name,"Premium animated controls, filters, sorting, and server-safe data."); head:Dock(TOP); head:DockMargin(0,0,0,6)
        if tab=="dashboard" then buildDashboard(body) elseif tab=="jobs" then buildJobs(body,info) elseif tab=="rules" then local card=DarkRPUI.UI.MakeAnimatedCard(body,"Server Rules",""); card:Dock(FILL); card.PaintOver=function(_,w,h) draw.DrawText((DarkRPUI.Config and DarkRPUI.Config.RulesText) or "No rules configured.","DarkRPUI.Body",22,58,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT) end elseif tab=="settings" then DarkRPUI.SettingsPanel(body) elseif tab=="player_upgrades" then buildPlayerUpgrades(body) elseif tab=="admin" then DarkRPUI.Admin.OpenPanel(body) elseif tab=="shop" then buildShopHub(body,info) elseif tab=="discord" then DarkRPUI.Util.OpenURL((DarkRPUI.Config.ServerLinks[1] or {}).url); DarkRPUI.UI.EmptyState(body,"Discord","Opening community link...") elseif tab=="donate" then DarkRPUI.Util.OpenURL("https://example.com/store"); DarkRPUI.UI.EmptyState(body,"Donate","Opening support store...") elseif tab=="forum" then DarkRPUI.Util.OpenURL("https://example.com/forums"); DarkRPUI.UI.EmptyState(body,"Forum","Opening forum link...") elseif sources[tab] then buildShop(body,tab,info) else DarkRPUI.UI.EmptyState(body,"Coming soon",(DarkRPUI.Config.Placeholders and DarkRPUI.Config.Placeholders[tab]) or "This premium module is ready for integration.") end
    end
    for _,t in ipairs((DarkRPUI.Config and DarkRPUI.Config.F4Tabs) or {}) do if not t.staffOnly or DarkRPUI.Util.IsAdmin(LocalPlayer()) then local b=DarkRPUI.UI.MakeIconButton(nav,t.icon.."  "..t.name,function() render(t.id,t.name) end); b:Dock(TOP); b:DockMargin(8,5,8,0); b:SetTall(54); b.PaintOver=function(_,w,h) DarkRPUI.UI.Text(t.subtitle or "","DarkRPUI.Tiny",38,31,DarkRPUI.Color("muted")) end; b.ActiveFunc=function() return currentTab==t.id or (t.id=="shop" and sources[currentTab]) end end end
    render("dashboard","Dashboard")
end
hook.Add("ShowSpare2", "DarkRPUI.F4.Override", function() if not DarkRPUI.Config or DarkRPUI.Config.EnableF4Menu ~= false then DarkRPUI.F4.Open(); return false end end)
