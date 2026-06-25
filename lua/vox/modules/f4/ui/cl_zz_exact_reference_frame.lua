-- Vox UI exact reference F4 remake
surface.CreateFont('VoxRef.Title', {font='Comfortaa', size=18, weight=800, extended=true})
surface.CreateFont('VoxRef.Text', {font='Comfortaa', size=14, weight=500, extended=true})
surface.CreateFont('VoxRef.Small', {font='Comfortaa', size=12, weight=700, extended=true})
surface.CreateFont('VoxRef.Tiny', {font='Comfortaa', size=10, weight=600, extended=true})
surface.CreateFont('VoxRef.CardTitle', {font='Comfortaa', size=20, weight=900, extended=true})

local FALLBACK={bg=Color(5,13,30,246),panel=Color(8,21,44,238),card=Color(12,28,58,232),card2=Color(15,36,70,232),border=Color(54,91,145,110),accent=Color(70,135,255),green=Color(35,225,120),red=Color(255,75,95),amber=Color(255,190,65),text=Color(240,248,255),soft=Color(145,172,200)}
local C=FALLBACK
local function palette()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    C = {
        bg = colors.primary or FALLBACK.bg,
        panel = colors.secondary or FALLBACK.panel,
        card = colors.secondary or FALLBACK.card,
        card2 = colors.tertiary or FALLBACK.card2,
        border = ColorAlpha(colors.accent or FALLBACK.accent, 110),
        accent = colors.accent or FALLBACK.accent,
        green = colors.money or colors.positive or FALLBACK.green,
        red = colors.negative or FALLBACK.red,
        amber = colors.warning or FALLBACK.amber,
        text = colors.textPrimary or colors.text or FALLBACK.text,
        soft = colors.textSecondary or colors.muted or FALLBACK.soft
    }
    return C
end

local CV_DISCORD_SERVER = CreateClientConVar('cl_vox_f4_announcement_discord_server_id', '', true, false, 'Discord server ID used by the F4 announcements feed.')
local CV_DISCORD_CHANNEL = CreateClientConVar('cl_vox_f4_announcement_discord_channel_id', '', true, false, 'Discord channel ID used by the F4 announcements feed.')
local ICON = {
    dashboard = Material('vox_f4menu/dashboard.png', 'smooth mips'),
    jobs = Material('vox_f4menu/jobs.png', 'smooth mips'),
    shop = Material('vox_f4menu/shop.png', 'smooth mips'),
    inventory = Material('vox_f4menu/entities.png', 'smooth mips'),
    upgrades = Material('vox_f4menu/stats.png', 'smooth mips'),
    settings = Material('vox_f4menu/settings.png', 'smooth mips'),
    admin = Material('vox_framework/settings.png', 'smooth mips'),
    wallet = Material('vox_f4menu/donate.png', 'smooth mips'),
    players = Material('vox_framework/user.png', 'smooth mips'),
    search = Material('vox_f4menu/search.png', 'smooth mips'),
    action = Material('vox_f4menu/rules.png', 'smooth mips'),
    wanted = Material('vox_hud/wanted.png', 'smooth mips'),
    time = Material('vox_hud/lockdown.png', 'smooth mips'),
    alert = Material('vox_hud/notify_hint.png', 'smooth mips')
}
local function rr(x,y,w,h,r,col) draw.RoundedBox(r or 8,x,y,w,h,col) end
local function outline(x,y,w,h,r,col) surface.SetDrawColor(col or C.border); surface.DrawOutlinedRect(x,y,w,h,1) end
local function glass(x,y,w,h,r,accent) palette(); if vox.DrawVoxPanel then vox.DrawVoxPanel(x,y,w,h,{primary=C.bg,secondary=C.panel,tertiary=C.card2,accent=accent or C.accent},r or 10) else rr(x,y,w,h,r or 10,C.bg); rr(x+1,y+1,w-2,h-2,r or 10,C.panel); outline(x,y,w,h,r,accent or C.border) end end
local function softCard(x,y,w,h,r,col) palette(); if vox.DrawVoxPanel then vox.DrawVoxPanel(x,y,w,h,{primary=col or C.card,secondary=C.panel,tertiary=C.card2,accent=C.accent},r or 8) else rr(x,y,w,h,r or 8,col or C.card); outline(x,y,w,h,r,ColorAlpha(C.border,70)) end end
local function matIcon(txt,x,y,col) draw.SimpleText(txt,'VoxRef.Title',x,y,col or C.text,1,1) end
local function money(v) if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(v or 0) end return '$'..string.Comma(v or 0) end
local function drawIcon(icon,x,y,w,h,col)
    if not icon then return end
    surface.SetDrawColor(col or C.text)
    surface.SetMaterial(icon)
    surface.DrawTexturedRect(x,y,w,h)
end
local function iconBubble(icon,x,y,size,col)
    rr(x,y,size,size,size*.5,ColorAlpha(col or C.accent,36))
    drawIcon(icon,x+size*.24,y+size*.24,size*.52,size*.52,col or C.accent)
end

local PANEL={}
function PANEL:Init()
    vox.f4.frame=self
    self:SetSize(math.min(ScrW()*0.78,1040), math.min(ScrH()*0.72,560)); self:Center(); self:SetTitle('')
    if self.ShowCloseButton then self:ShowCloseButton(false) end
    if IsValid(self.divHeader) then self.divHeader:SetVisible(false) end
    self:SetAlpha(0); self:AlphaTo(255,.15,0); self:MakePopup()
    self.active='dashboard'
    self.sidebar=self:Add('Panel'); self.content=self:Add('Panel')
    -- Compatibility for legacy F4 tab panels/previews that expect the old frame.container API.
    self.container = self.content
    self.containerPadding = 18
    self.closeButton=self:Add('DButton'); self.closeButton:SetText(''); self.closeButton.DoClick=function() self:Remove() end
    self.closeButton.Paint=function(p,w,h) draw.SimpleText('×','VoxRef.Title',w*.5,h*.5,p:IsHovered() and C.red or C.text,1,1) end
    self.tabs={
        {id='dashboard',name='Dashboard',desc='Overview & statistics',icon=ICON.dashboard},
        {id='jobs',name='Jobs',desc='Choose your path',icon=ICON.jobs,class='vox.f4.Jobs'},
        {id='shop',name='Shop',desc='Purchase items',icon=ICON.shop,class='vox.f4.Shop'},
        {id='inventory',name='Inventory',desc='Your items & equipment',icon=ICON.inventory,class='vox.f4.Inventory'},
        {id='upgrades',name='Upgrades',desc='Enhance your abilities',icon=ICON.upgrades,class='vox.f4.Upgrades'},
        {id='settings',name='Settings',desc='Personalize your experience',icon=ICON.settings,class='vox.f4.Settings'},
        {id='admin',name='Admin Panel',desc='Staff management',icon=ICON.admin,class='vox.f4.AdminStats',admin=true}
    }
    self:BuildSidebar(); self:BuildContent()
end
function PANEL:PerformLayout(w,h)
    local pad=12
    self.sidebar:SetPos(pad,32); self.sidebar:SetSize(220,h-44)
    self.content:SetPos(244,32); self.content:SetSize(w-256,h-44)
    self.closeButton:SetPos(w-34,4); self.closeButton:SetSize(28,24)
end
function PANEL:Paint(w,h)
    palette()
    glass(0,0,w,h,14,ColorAlpha(C.accent,135))
    vox.DrawVoxScanlines(14,32,w-28,h-44,ColorAlpha(C.accent,8),8)
    vox.DrawVoxCornerTicks(8,8,w-16,h-16,ColorAlpha(C.accent,115),18)
    draw.SimpleText('F4 MENU','VoxRef.Title',14,15,C.text,0,1)
    draw.SimpleText('(COMMAND CENTER)','VoxRef.Tiny',92,15,C.soft,0,1)
end
function PANEL:BuildSidebar()
    local s=self.sidebar
    s.Paint=function(_,w,h) palette(); softCard(0,0,w,h,12,ColorAlpha(C.bg,225)); vox.DrawVoxScanlines(12,12,w-24,h-24,ColorAlpha(C.accent,7),8) end
    local profile=s:Add('Panel'); profile:SetPos(10,12); profile:SetSize(200,64)
    profile.Paint=function(_,w,h)
        vox.DrawVoxPanel(0,0,w,h,{primary=ColorAlpha(C.panel,210),secondary=C.card2,accent=C.accent},10)
        local lp=LocalPlayer()
        draw.SimpleText(IsValid(lp) and lp:Name() or 'Player','VoxRef.Small',64,14,C.text,0,0)
        draw.SimpleText(IsValid(lp) and (lp:getDarkRPVar('job') or team.GetName(lp:Team())) or 'Citizen','VoxRef.Tiny',64,34,C.green,0,0)
    end
    local avatar=profile:Add('vox.RoundedAvatar'); avatar:SetPos(8,8); avatar:SetSize(48,48); avatar:SetPlayer(LocalPlayer(),64)
    avatar.PaintOver=function(_,w,h) vox.DrawOutlinedCircle(w*.5,h*.5,w*.5-1,2,C.accent) end
    local y=88
    for _,t in ipairs(self.tabs) do
        local b=s:Add('DButton'); b:SetText(''); b:SetPos(12,y); b:SetSize(196,42); y=y+48
        b.Paint=function(p,w,h)
            local active=self.active==t.id
            rr(0,0,w,h,7, active and ColorAlpha(C.card2,225) or ColorAlpha(C.panel,175))
            if active then draw.RoundedBox(3,0,6,4,h-12,C.accent) end
            if p:IsHovered() or active then outline(0,0,w,h,7,ColorAlpha(C.accent,80)) end
            drawIcon(t.icon,18,15,12,12,active and C.text or C.soft)
            draw.SimpleText(t.name,'VoxRef.Small',48,8,C.text,0,0)
            draw.SimpleText(t.desc,'VoxRef.Tiny',48,24,C.soft,0,0)
        end
        b.DoClick=function()
            self.active=t.id; self.activeTab=t; self:BuildContent()
        end
    end
    s.PaintOver=function(_,w,h)
        draw.SimpleText('Online Players','VoxRef.Tiny',18,h-48,C.soft,0,0); draw.SimpleText(#player.GetAll()..' / 64','VoxRef.Tiny',w-18,h-48,C.text,2,0)
        draw.SimpleText('Server Uptime','VoxRef.Tiny',18,h-30,C.soft,0,0); draw.SimpleText('2h 45m','VoxRef.Tiny',w-18,h-30,C.text,2,0)
    end
end
local function addCard(parent,x,y,w,h,title,value,sub,col,icon)
    local p=parent:Add('Panel'); p:SetPos(x,y); p:SetSize(w,h); p.Paint=function(_,cw,ch)
        softCard(0,0,cw,ch,8,ColorAlpha(C.card,224))
        if icon then iconBubble(icon,10,9,18,col or C.accent) end
        draw.SimpleText(string.upper(title),'VoxRef.Tiny',icon and 34 or 14,10,C.soft,0,0)
        draw.SimpleText(value,'VoxRef.CardTitle',14,31,C.text,0,0)
        draw.SimpleText(sub or '', 'VoxRef.Tiny',14,58,col or C.green,0,0)
    end; return p
end
function PANEL:BuildContent()
    self.content:Clear()
    local c=self.content
    c.Paint=function(_,w,h) palette(); softCard(0,0,w,h,12,ColorAlpha(C.bg,225)); vox.DrawVoxCornerTicks(8,8,w-16,h-16,ColorAlpha(C.accent,80),16) end
    local search=c:Add('DTextEntry'); self.search=search; search:SetPos(18,14); search:SetSize(math.max(c:GetWide()-36,220),30); search:SetText(''); search:SetPlaceholderText('Search the menu...'); if search.SetTextInset then search:SetTextInset(28,0) end
    search.Paint=function(p,w,h) palette(); rr(0,0,w,h,7,ColorAlpha(C.panel,230)); outline(0,0,w,h,7,ColorAlpha(C.accent,p:IsHovered() and 110 or 65)); drawIcon(ICON.search,10,h*.5-6,12,12,C.soft); p:DrawTextEntryText(C.text,C.accent,C.text) end
    c.PerformLayout=function(_,w,h)
        if IsValid(search) then search:SetPos(18,14); search:SetSize(w-36,30) end
        if IsValid(self.dashboardContent) then self.dashboardContent:SetPos(18,56); self.dashboardContent:SetSize(w-36,h-74) end
        if IsValid(self.nativeContent) then self.nativeContent:SetPos(18,56); self.nativeContent:SetSize(w-36,h-74) end
    end
    local activeTab=self.activeTab
    if self.active=='dashboard' then self:BuildDashboard(c) elseif activeTab and activeTab.class then self:BuildNativeTab(c, activeTab.class) else self:BuildPlaceholder(c,string.upper(self.active)) end
end
function PANEL:BuildNativeTab(c,class)
    local panel=c:Add(class)
    self.nativeContent=panel
    panel:SetPos(18,56); panel:SetSize(math.max(c:GetWide()-36,260),math.max(c:GetTall()-74,260))
end
local function getJobName(ply)
    if not IsValid(ply) then return 'Citizen' end
    return ply:getDarkRPVar('job') or team.GetName(ply:Team()) or 'Citizen'
end

function PANEL:GetDashboardAnnouncements()
    local serverID = (vox.f4.GetOptionValue and vox.f4:GetOptionValue('announcement_discord_server_id')) or CV_DISCORD_SERVER:GetString()
    local channelID = (vox.f4.GetOptionValue and vox.f4:GetOptionValue('announcement_discord_channel_id')) or CV_DISCORD_CHANNEL:GetString()
    serverID = tostring(serverID or '')
    channelID = tostring(channelID or '')

    if serverID ~= '' and channelID ~= '' then
        return {{
            title = 'Discord feed configured',
            desc = 'Server ' .. serverID .. ' / Channel ' .. channelID,
            meta = 'READY',
            icon = ICON.alert,
            color = C.green
        }}
    end

    return {{
        title = 'Discord announcements not configured',
        desc = 'Set server and channel IDs in client convars.',
        meta = 'SETUP',
        icon = ICON.alert,
        color = C.amber
    }, {
        title = 'Server ID',
        desc = 'cl_vox_f4_announcement_discord_server_id',
        meta = serverID ~= '' and 'SET' or 'EMPTY',
        icon = ICON.players,
        color = serverID ~= '' and C.green or C.soft
    }, {
        title = 'Channel ID',
        desc = 'cl_vox_f4_announcement_discord_channel_id',
        meta = channelID ~= '' and 'SET' or 'EMPTY',
        icon = ICON.action,
        color = channelID ~= '' and C.green or C.soft
    }}
end

function PANEL:GetPopularJobs(limit)
    local jobs = {}
    for _, job in pairs(RPExtraTeams or {}) do
        local teamID = job.team
        local count = teamID and team.NumPlayers(teamID) or 0
        if count > 0 or #jobs < (limit or 3) then
            table.insert(jobs, { job = job, count = count })
        end
    end

    table.sort(jobs, function(a, b)
        if a.count == b.count then return tostring(a.job.name) < tostring(b.job.name) end
        return a.count > b.count
    end)

    local rows = {}
    for index = 1, math.min(limit or 3, #jobs) do
        local data = jobs[index]
        local job = data.job
        local max = job.max == 0 and '∞' or tostring(job.max or 0)
        rows[#rows + 1] = {
            title = job.name or 'Unknown Job',
            desc = money(job.salary or 0) .. ' / min',
            meta = data.count .. ' / ' .. max,
            icon = ICON.jobs,
            color = C.accent,
            click = function()
                self.active = 'jobs'
                self.activeTab = self.tabs[2]
                self:BuildContent()
            end
        }
    end

    if #rows == 0 then
        rows[1] = { title = 'No jobs available', desc = 'DarkRP jobs have not loaded yet', meta = 'WAIT', icon = ICON.jobs, color = C.soft }
    end

    return rows
end

function PANEL:GetStaffRows()
    local rows = {}
    for _, ply in ipairs(player.GetAll()) do
        if vox.f4.IsAdmin and vox.f4.IsAdmin(ply) then
            rows[#rows + 1] = {
                title = ply:Nick(),
                desc = ply:GetUserGroup() or 'staff',
                meta = '●',
                icon = ICON.players,
                color = C.green
            }
        end
    end

    if #rows == 0 then
        rows[1] = { title = 'No staff online', desc = 'Staff list updates automatically', meta = '', icon = ICON.players, color = C.soft }
    end

    return rows
end

function PANEL:GetWantedRows()
    local rows = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:getDarkRPVar('wanted') then
            rows[#rows + 1] = {
                title = ply:Nick(),
                desc = ply:getDarkRPVar('wantedReason') or 'Wanted by Civil Protection',
                meta = 'WANTED',
                icon = ICON.wanted,
                color = C.red
            }
        end
    end

    if #rows == 0 then
        rows[1] = { title = 'No wanted players', desc = 'Everyone is clear right now', meta = 'CLEAR', icon = ICON.wanted, color = C.green }
    end

    return rows
end

function PANEL:GetQuickActions()
    return {{
        title = 'Laws of the Land',
        desc = 'Open DarkRP laws',
        icon = ICON.action,
        color = C.accent,
        click = function() RunConsoleCommand('say', '/laws') end
    }, {
        title = 'Wanted Players',
        desc = 'Jump to wanted list',
        icon = ICON.wanted,
        color = C.red,
        click = function() if IsValid(self.wantedPanel) then self.wantedPanel:RequestFocus() end end
    }, {
        title = 'Report Player',
        desc = 'Open staff chat prompt',
        icon = ICON.alert,
        color = C.amber,
        click = function() RunConsoleCommand('say', '@ ') end
    }, {
        title = 'Open Inventory',
        desc = 'View roleplay items',
        icon = ICON.inventory,
        color = C.accent,
        click = function()
            self.active = 'inventory'
            self.activeTab = self.tabs[4]
            self:BuildContent()
        end
    }}
end

function PANEL:BuildDashboard(c)
    self.dashboardContent = c:Add('Panel')
    self.dashboardContent:SetPos(18,56)
    self.dashboardContent:SetSize(math.max(c:GetWide()-36,260), math.max(c:GetTall()-74,260))
    self.dashboardContent.PerformLayout = function(panel, w, h)
        if panel._lastW == w and panel._lastH == h then return end
        panel._lastW = w
        panel._lastH = h
        self:RebuildDashboard(panel, w, h)
    end
end

function PANEL:RebuildDashboard(parent, w, h)
    parent:Clear()
    palette()

    local lp = LocalPlayer()
    local moneyVal = IsValid(lp) and (lp:getDarkRPVar('money') or 0) or 0
    local job = getJobName(lp)
    local players = player.GetAll()
    local maxPlayers = game.MaxPlayers and game.MaxPlayers() or 64
    local gap = 12
    local topH = 66
    local cardW = math.floor((w - gap * 3) / 4)
    local bodyY = topH + gap + 4
    local bodyH = h - bodyY
    local colW = math.floor((w - gap * 2) / 3)
    local bottomY = bodyY + math.floor(bodyH * .52) + gap
    local bottomH = math.max(96, h - bottomY)

    local jobCard = addCard(parent, cardW + gap, 0, cardW, topH, 'Current Job', job, 'View Jobs →', C.accent, ICON.jobs)
    jobCard:SetMouseInputEnabled(true)
    jobCard.OnMouseReleased = function()
        self.active = 'jobs'
        self.activeTab = self.tabs[2]
        self:BuildContent()
    end

    addCard(parent, 0, 0, cardW, topH, 'Wallet', money(moneyVal), 'Bank Balance', C.green, ICON.wallet)
    addCard(parent, (cardW + gap) * 2, 0, cardW, topH, 'Players Online', #players .. ' / ' .. maxPlayers, 'Join the community', C.accent, ICON.players)
    addCard(parent, (cardW + gap) * 3, 0, cardW, topH, 'Server Time', os.date('%H:%M'), os.date('%A'), C.accent, ICON.time)

    local announcementH = math.floor(bodyH * .52)
    self:ListPanel(parent, 0, bodyY, colW, announcementH, 'ANNOUNCEMENTS', self:GetDashboardAnnouncements(), {
        text = 'CONFIGURE DISCORD IDS',
        click = function()
            self.active = 'settings'
            self.activeTab = self.tabs[6]
            self:BuildContent()
        end
    })
    self:ListPanel(parent, colW + gap, bodyY, colW, announcementH, 'POPULAR JOBS', self:GetPopularJobs(4), {
        text = 'VIEW ALL JOBS',
        click = function()
            self.active = 'jobs'
            self.activeTab = self.tabs[2]
            self:BuildContent()
        end
    })
    self:ListPanel(parent, (colW + gap) * 2, bodyY, w - (colW + gap) * 2, announcementH, 'QUICK ACTIONS', self:GetQuickActions())
    self:ListPanel(parent, 0, bottomY, colW, bottomH, 'STAFF ONLINE', self:GetStaffRows())
    self.wantedPanel = self:ListPanel(parent, colW + gap, bottomY, w - colW - gap, bottomH, 'WANTED PLAYERS', self:GetWantedRows())
end

function PANEL:ListPanel(parent,x,y,w,h,title,rows,footer)
    local p=parent:Add('Panel'); p:SetPos(x,y); p:SetSize(w,h); p.Paint=function(_,cw,ch) softCard(0,0,cw,ch,8,ColorAlpha(C.card,218)); draw.SimpleText(title,'VoxRef.Tiny',12,9,C.text,0,0) end
    local yy=28
    local rowH = 24
    local footerH = footer and 20 or 0
    local maxRows = math.max(1, math.floor((h - yy - footerH - 8) / (rowH + 4)))
    for index,r in ipairs(rows or {}) do
        if index > maxRows then break end
        local row=p:Add(r.click and 'DButton' or 'Panel'); row:SetPos(10,yy); row:SetSize(w-20,rowH); if row.SetText then row:SetText('') end; yy=yy+rowH+4
        if r.click then row.DoClick = r.click end
        row.Paint=function(panel,rw,rh)
            rr(0,0,rw,rh,5,ColorAlpha(C.card2,panel:IsHovered() and 235 or 210)); outline(0,0,rw,rh,5,ColorAlpha(r.color or C.accent,panel:IsHovered() and 100 or 35))
            if r.icon then iconBubble(r.icon,6,4,16,r.color or C.accent) end
            draw.SimpleText(r.title or r[1] or '', 'VoxRef.Tiny', r.icon and 30 or 12, 4, C.text, 0, 0)
            draw.SimpleText(r.desc or r[2] or '', 'VoxRef.Tiny', r.icon and 30 or 12, 14, C.soft, 0, 0)
            if r.meta or r[3] then draw.SimpleText(r.meta or r[3], 'VoxRef.Tiny', rw-10, rh*.5, (r.meta == 'WANTED') and C.red or (r.color or C.green), 2, 1) end
        end
    end
    if footer then
        local b=p:Add('DButton'); b:SetText(''); b:SetPos(10,h-25); b:SetSize(w-20,18); b.DoClick=footer.click
        b.Paint=function(panel,bw,bh) rr(0,0,bw,bh,5,ColorAlpha(C.accent,panel:IsHovered() and 70 or 38)); outline(0,0,bw,bh,5,ColorAlpha(C.accent,120)); draw.SimpleText(footer.text or footer,'VoxRef.Tiny',bw*.5,bh*.5,C.text,1,1) end
    end
    return p
end
function PANEL:BuildJobs(c)
    local scroll=c:Add('DScrollPanel'); scroll:SetPos(18,76); scroll:SetSize(c:GetWide()-36,c:GetTall()-92)
    local teams=RPExtraTeams or {}; local y=0; local cats={Citizens={},['Civil Protection']={},Gangsters={},Other={}}
    for k,v in pairs(teams) do local cat=(v.category or 'Other'); if not cats[cat] then cats[cat]={} end table.insert(cats[cat],v) end
    for cat,list in pairs(cats) do
        local head=scroll:Add('Panel'); head:SetPos(0,y); head:SetSize(scroll:GetWide()-20,38); head.Paint=function(_,w,h) rr(0,0,w,h,8,Color(3,12,25,238)); draw.SimpleText(string.upper(cat),'VoxRef.Text',14,19,C.text,0,1); draw.SimpleText('⌄','VoxRef.Title',w-18,19,C.text,1,1) end; y=y+46
        for _,job in ipairs(list) do local card=scroll:Add('DButton'); card:SetText(''); card:SetPos(0,y); card:SetSize(scroll:GetWide()-20,50); y=y+58
            card.Paint=function(p,w,h) glass(0,0,w,h,6,C.accent); rr(10,10,30,30,6,Color(20,40,70)); draw.SimpleText(string.sub(job.name or '?',1,1),'VoxRef.Text',25,25,C.text,1,1); draw.SimpleText(job.name or 'Job','VoxRef.Text',52,10,C.text,0,0); draw.SimpleText('Salary: '..money(job.salary or 0),'VoxRef.Tiny',52,29,C.green,0,0); draw.SimpleText((team.NumPlayers(job.team or 0) or 0)..' / '..(job.max == 0 and '∞' or job.max or 0),'VoxRef.Text',w-20,25,C.text,2,1) end
        end; y=y+10
    end
end
function PANEL:BuildShop(c) self:ListPanel(c,18,86,350,240,'SHOP',{{'Entities','Browse entities'},{'Weapons','Browse weapons'},{'Shipments','Restricted shipments'},{'Ammo','Purchase ammo'},{'Food','Purchase food'}}) end
function PANEL:BuildPlaceholder(c,title) addCard(c,18,86,300,120,title,'Coming Soon','This Vox panel uses the new visual system.',C.accent) end
function PANEL:OnKeyCodePressed(key) if key==KEY_F4 or key==KEY_ESCAPE then self:Remove() end end
vox.gui.Register('vox.f4.Frame', PANEL, 'VoxRootFrame')
