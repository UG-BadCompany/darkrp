-- Vox UI exact reference F4 remake
surface.CreateFont('VoxRef.Title', {font='Tahoma', size=18, weight=800, extended=true})
surface.CreateFont('VoxRef.Text', {font='Tahoma', size=14, weight=500, extended=true})
surface.CreateFont('VoxRef.Small', {font='Tahoma', size=12, weight=500, extended=true})
surface.CreateFont('VoxRef.Tiny', {font='Tahoma', size=10, weight=600, extended=true})
surface.CreateFont('VoxRef.CardTitle', {font='Tahoma', size=20, weight=900, extended=true})

local C={bg=Color(5,14,28,245),panel=Color(8,25,48,238),card=Color(11,32,60,232),card2=Color(13,39,72,232),border=Color(0,174,255,80),accent=Color(0,174,255),green=Color(35,225,120),red=Color(255,75,95),amber=Color(255,190,65),text=Color(240,248,255),soft=Color(145,172,200),line=Color(38,77,118,120)}
local function rr(x,y,w,h,r,col) draw.RoundedBox(r or 8,x,y,w,h,col) end
local function glass(x,y,w,h,r,accent) rr(x,y,w,h,r or 10,C.bg); rr(x+1,y+1,w-2,h-2,r or 10,Color(8,25,48,225)); surface.SetDrawColor(ColorAlpha(accent or C.border, 85)); surface.DrawOutlinedRect(x,y,w,h,1); surface.SetDrawColor(ColorAlpha(accent or C.accent, 18)); surface.DrawRect(x+2,y+2,w-4,24) end
local function matIcon(txt,x,y,col) draw.SimpleText(txt,'VoxRef.Title',x,y,col or C.text,1,1) end
local function money(v) if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(v or 0) end return '$'..string.Comma(v or 0) end

local PANEL={}
function PANEL:Init()
    vox.f4.frame=self
    self:SetSize(math.min(ScrW()*0.96,1220), math.min(ScrH()*0.90,760)); self:Center(); self:SetTitle('')
    self:SetAlpha(0); self:AlphaTo(255,.15,0); self:MakePopup()
    self.active='dashboard'
    self.sidebar=self:Add('Panel'); self.content=self:Add('Panel')
    self.tabs={
        {'dashboard','Dashboard','Overview & statistics','▦'}, {'jobs','Jobs','Choose your path','♜'}, {'shop','Shop','Purchase items','▣'},
        {'inventory','Inventory','Your items & equipment','▦'}, {'upgrades','Upgrades','Enhance your abilities','⚙'}, {'settings','Settings','Personalize your experience','⚙'}, {'admin','Admin Panel','Staff management','⚙'}
    }
    self:BuildSidebar(); self:BuildContent()
end
function PANEL:PerformLayout(w,h)
    local pad=12
    self.sidebar:SetPos(pad,34); self.sidebar:SetSize(250,h-46)
    self.content:SetPos(274,34); self.content:SetSize(w-286,h-46)
end
function PANEL:Paint(w,h)
    glass(0,0,w,h,12,C.accent)
    draw.SimpleText('F4 MENU','VoxRef.Title',14,16,C.text,0,1)
    draw.SimpleText('(COMMAND CENTER)','VoxRef.Small',92,16,C.soft,0,1)
    surface.SetDrawColor(C.line); surface.DrawLine(12,31,w-12,31)
    draw.SimpleText('⚙  ●  🔔  ×','VoxRef.Title',w-14,16,C.text,2,1)
end
function PANEL:BuildSidebar()
    local s=self.sidebar
    s.Paint=function(_,w,h) glass(0,0,w,h,10,C.border) end
    local profile=s:Add('Panel'); profile:SetPos(10,12); profile:SetSize(230,74)
    profile.Paint=function(_,w,h)
        glass(0,0,w,h,10,C.accent)
        rr(10,12,50,50,25,Color(20,40,70,255)); surface.SetDrawColor(C.green); surface.DrawOutlinedRect(10,12,50,50,2)
        local lp=LocalPlayer(); draw.SimpleText(IsValid(lp) and string.sub(lp:Name(),1,1) or 'V','VoxRef.CardTitle',35,37,C.text,1,1)
        draw.SimpleText(IsValid(lp) and lp:Name() or 'Player','VoxRef.Text',72,17,C.text,0,0)
        draw.SimpleText(IsValid(lp) and (lp:getDarkRPVar('job') or team.GetName(lp:Team())) or 'Citizen','VoxRef.Small',72,41,C.green,0,0)
    end
    local y=104
    for _,t in ipairs(self.tabs) do
        local b=s:Add('DButton'); b:SetText(''); b:SetPos(12,y); b:SetSize(226,54); y=y+60
        b.Paint=function(p,w,h)
            local active=self.active==t[1]
            rr(0,0,w,h,7, active and Color(13,76,145,220) or Color(10,31,56,205))
            if active then rr(0,0,4,h,3,C.accent) end
            if p:IsHovered() then rr(1,1,w-2,h-2,7,Color(0,174,255,28)); surface.SetDrawColor(ColorAlpha(C.accent,100)); surface.DrawOutlinedRect(0,0,w,h,1) end
            matIcon(t[4],24,27,active and C.text or C.soft)
            draw.SimpleText(t[2],'VoxRef.Text',50,15,C.text,0,0)
            draw.SimpleText(t[3],'VoxRef.Tiny',50,34,C.soft,0,0)
        end
        b.DoClick=function() self.active=t[1]; self:BuildContent() end
    end
    s.PaintOver=function(_,w,h)
        draw.SimpleText('Online Players','VoxRef.Tiny',18,h-54,C.soft,0,0); draw.SimpleText(#player.GetAll()..' / 64','VoxRef.Tiny',w-18,h-54,C.text,2,0)
        draw.SimpleText('Server Uptime','VoxRef.Tiny',18,h-34,C.soft,0,0); draw.SimpleText('2h 45m','VoxRef.Tiny',w-18,h-34,C.text,2,0)
    end
end
local function addCard(parent,x,y,w,h,title,value,sub,col)
    local p=parent:Add('Panel'); p:SetPos(x,y); p:SetSize(w,h); p.Paint=function(_,cw,ch)
        glass(0,0,cw,ch,10,col or C.border); rr(12,14,22,22,11,ColorAlpha(col or C.accent,45)); draw.SimpleText('●','VoxRef.Tiny',23,25,col or C.accent,1,1); draw.SimpleText(string.upper(title),'VoxRef.Tiny',42,14,C.soft,0,0); draw.SimpleText(value,'VoxRef.CardTitle',14,40,C.text,0,0); draw.SimpleText(sub or '', 'VoxRef.Small',14,68,col or C.green,0,0)
    end; return p
end
function PANEL:BuildContent()
    self.content:Clear()
    local c=self.content
    c.Paint=function(_,w,h) glass(0,0,w,h,10,C.border) end
    local search=c:Add('DTextEntry'); search:SetPos(18,16); search:SetSize(c:GetWide()-36,42); search:SetText(''); search:SetPlaceholderText('Search the menu...')
    search.Paint=function(p,w,h) rr(0,0,w,h,8,Color(3,12,25,230)); surface.SetDrawColor(Color(24,61,105,160)); surface.DrawOutlinedRect(0,0,w,h,1); p:DrawTextEntryText(C.text,C.accent,C.text) end
    if self.active=='dashboard' then self:BuildDashboard(c) elseif self.active=='jobs' then self:BuildJobs(c) elseif self.active=='shop' then self:BuildShop(c) else self:BuildPlaceholder(c,string.upper(self.active)) end
end
function PANEL:BuildDashboard(c)
    local lp=LocalPlayer(); local moneyVal=IsValid(lp) and (lp:getDarkRPVar('money') or 0) or 0
    draw.SimpleText('', 'VoxRef.Text',0,0,C.text)
    addCard(c,18,86,160,92,'Wallet',money(moneyVal),'Bank Balance',C.green)
    addCard(c,190,86,160,92,'Current Job',IsValid(lp) and (lp:getDarkRPVar('job') or 'Citizen') or 'Citizen','View Jobs →',C.accent)
    addCard(c,362,86,160,92,'Players Online',#player.GetAll()..' / 64','Join the community',C.accent)
    addCard(c,534,86,160,92,'Server Time',os.date('%H:%M'),'Today',C.accent)
    self:ListPanel(c,18,200,300,160,'ANNOUNCEMENTS',{{'Welcome to Vox City','Make sure to read the rules'},{'Double XP Weekend','Enjoy 2x XP on all jobs'},{'Update v1.0.5','View changelog on Discord'}})
    self:ListPanel(c,335,200,250,160,'POPULAR JOBS',{{'Police Officer','$75 / min      8/10'},{'Medic','$85 / min      3/6'},{'SWAT','$95 / min      2/4'}})
    self:ListPanel(c,602,200,250,160,'QUICK ACTIONS',{{'Laws of the Land',''},{'Wanted Players',''},{'Report Player',''},{'Open Inventory',''}})
    self:ListPanel(c,18,378,300,135,'STAFF ONLINE',{{'superadmin','Owner'},{'Voxberg','Administrator'}})
    self:ListPanel(c,335,378,520,135,'WANTED PLAYERS',{{'John Wick','★★★★★        $5,000'},{'Tony Montana','★★★★☆        $2,500'}})
end
function PANEL:ListPanel(parent,x,y,w,h,title,rows)
    local p=parent:Add('Panel'); p:SetPos(x,y); p:SetSize(w,h); p.Paint=function(_,cw,ch) glass(0,0,cw,ch,8,C.border); draw.SimpleText(title,'VoxRef.Tiny',12,10,C.text,0,0) end
    local yy=34
    for _,r in ipairs(rows) do local row=p:Add('Panel'); row:SetPos(10,yy); row:SetSize(w-20,30); yy=yy+36; row.Paint=function(_,rw,rh) rr(0,0,rw,rh,7,Color(12,35,65,214)); surface.SetDrawColor(C.line); surface.DrawOutlinedRect(0,0,rw,rh,1); rr(8,8,14,14,7,ColorAlpha(C.accent,45)); draw.SimpleText(r[1],'VoxRef.Small',30,7,C.text,0,0); draw.SimpleText(r[2] or '','VoxRef.Tiny',30,20,C.soft,0,0) end end
end
function PANEL:BuildJobs(c)
    local scroll=c:Add('DScrollPanel'); scroll:SetPos(18,76); scroll:SetSize(c:GetWide()-36,c:GetTall()-92)
    local teams=RPExtraTeams or {}; local y=0; local cats={Citizens={},['Civil Protection']={},Gangsters={},Other={}}
    for k,v in pairs(teams) do local cat=(v.category or 'Other'); if not cats[cat] then cats[cat]={} end table.insert(cats[cat],v) end
    for cat,list in pairs(cats) do
        local head=scroll:Add('Panel'); head:SetPos(0,y); head:SetSize(scroll:GetWide()-20,38); head.Paint=function(_,w,h) rr(0,0,w,h,8,Color(3,12,25,238)); draw.SimpleText(string.upper(cat),'VoxRef.Text',14,19,C.text,0,1); draw.SimpleText('⌄','VoxRef.Title',w-18,19,C.text,1,1) end; y=y+46
        local x=0; for _,job in ipairs(list) do local card=scroll:Add('DButton'); card:SetText(''); card:SetPos(x,y); card:SetSize((scroll:GetWide()-36)/2,70); x=x+card:GetWide()+16; if x+card:GetWide()>scroll:GetWide() then x=0; y=y+82 end
            card.Paint=function(p,w,h) glass(0,0,w,h,8,job.color or C.accent); if p:IsHovered() then rr(1,1,w-2,h-2,8,Color(0,174,255,22)) end; rr(10,12,46,46,23,Color(20,40,70)); surface.SetDrawColor(ColorAlpha(job.color or C.accent,160)); surface.DrawOutlinedRect(10,12,46,46,1); draw.SimpleText(string.sub(job.name or '?',1,1),'VoxRef.Title',33,35,C.text,1,1); draw.SimpleText(job.name or 'Job','VoxRef.Title',70,13,C.text,0,0); draw.SimpleText('Salary: '..money(job.salary or 0),'VoxRef.Text',70,38,C.green,0,0); draw.SimpleText((team.NumPlayers(job.team or 0) or 0)..' / '..(job.max == 0 and '∞' or job.max or 0),'VoxRef.Text',w-20,35,C.text,2,1) end
            card.DoClick=function() if job.command then RunConsoleCommand('say', '/' .. job.command) end end
        end; y=y+90
    end
end
function PANEL:BuildShop(c) self:ListPanel(c,18,86,350,240,'SHOP',{{'Entities','Browse entities'},{'Weapons','Browse weapons'},{'Shipments','Restricted shipments'},{'Ammo','Purchase ammo'},{'Food','Purchase food'}}) end
function PANEL:BuildPlaceholder(c,title) addCard(c,18,86,300,120,title,'Coming Soon','This Vox panel uses the new visual system.',C.accent) end
function PANEL:OnKeyCodePressed(key) if key==KEY_F4 or key==KEY_ESCAPE then self:Remove() end end
vox.gui.Register('vox.f4.Frame', PANEL, 'VoxRootFrame')
