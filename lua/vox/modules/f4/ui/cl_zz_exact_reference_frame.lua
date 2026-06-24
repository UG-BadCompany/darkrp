-- Vox UI exact reference F4 remake
surface.CreateFont('VoxRef.Title', {font='Tahoma', size=18, weight=800, extended=true})
surface.CreateFont('VoxRef.Text', {font='Tahoma', size=14, weight=500, extended=true})
surface.CreateFont('VoxRef.Small', {font='Tahoma', size=12, weight=500, extended=true})
surface.CreateFont('VoxRef.Tiny', {font='Tahoma', size=10, weight=600, extended=true})
surface.CreateFont('VoxRef.CardTitle', {font='Tahoma', size=20, weight=900, extended=true})

local C={bg=Color(5,13,30,246),panel=Color(8,21,44,238),card=Color(12,28,58,232),card2=Color(15,36,70,232),border=Color(54,91,145,110),accent=Color(70,135,255),green=Color(35,225,120),red=Color(255,75,95),amber=Color(255,190,65),text=Color(240,248,255),soft=Color(145,172,200)}
local WIMG_WALLET = vox.wimg.Simple('https://i.imgur.com/gltIVYm.png', 'smooth mips')
local WIMG_JOB = vox.wimg.Simple('https://i.imgur.com/6Bvc6jX.png', 'smooth mips')
local WIMG_SHIELD = vox.wimg.Simple('https://i.imgur.com/6Bvc6jX.png', 'smooth mips')
local WIMG_PLAYERS = vox.wimg.Simple('https://i.imgur.com/q5Lw2qs.png', 'smooth mips')
local WIMG_TIME = vox.wimg.Simple('https://i.imgur.com/4K2lTOO.png', 'smooth mips')
local WIMG_ALERT = vox.wimg.Simple('https://i.imgur.com/gcM94Fk.png', 'smooth mips')
local WIMG_STAR = vox.wimg.Simple('https://i.imgur.com/rFyMifb.png', 'smooth mips')
local WIMG_ACTION = vox.wimg.Simple('https://i.imgur.com/gcM94Fk.png', 'smooth mips')
local function rr(x,y,w,h,r,col) draw.RoundedBox(r or 8,x,y,w,h,col) end
local function outline(x,y,w,h,r,col) surface.SetDrawColor(col or C.border); surface.DrawOutlinedRect(x,y,w,h,1) end
local function glass(x,y,w,h,r,accent) rr(x,y,w,h,r or 10,C.bg); rr(x+1,y+1,w-2,h-2,r or 10,Color(8,21,44,225)); outline(x,y,w,h,r,accent or C.border) end
local function softCard(x,y,w,h,r,col) rr(x,y,w,h,r or 8,col or C.card); outline(x,y,w,h,r,ColorAlpha(C.border,70)) end
local function matIcon(txt,x,y,col) draw.SimpleText(txt,'VoxRef.Title',x,y,col or C.text,1,1) end
local function money(v) if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(v or 0) end return '$'..string.Comma(v or 0) end
local function iconBubble(icon,x,y,size,col)
    rr(x,y,size,size,size*.5,ColorAlpha(col or C.accent,36))
    icon:Draw(x+size*.24,y+size*.24,size*.52,size*.52,col or C.accent)
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
    self.closeButton=self:Add('DButton'); self.closeButton:SetText(''); self.closeButton.DoClick=function() self:Remove() end
    self.closeButton.Paint=function(p,w,h) draw.SimpleText('×','VoxRef.Title',w*.5,h*.5,p:IsHovered() and C.red or C.text,1,1) end
    self.tabs={
        {'dashboard','Dashboard','Overview & statistics','▦'}, {'jobs','Jobs','Choose your path','♜'}, {'shop','Shop','Purchase items','▣'},
        {'inventory','Inventory','Your items & equipment','▦'}, {'upgrades','Upgrades','Enhance your abilities','⚙'}, {'settings','Settings','Personalize your experience','⚙'}, {'admin','Admin Panel','Staff management','⚙'}
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
    glass(0,0,w,h,14,ColorAlpha(C.accent,135))
    draw.SimpleText('F4 MENU','VoxRef.Title',14,15,C.text,0,1)
    draw.SimpleText('(COMMAND CENTER)','VoxRef.Tiny',92,15,C.soft,0,1)
    draw.SimpleText('⚙  ●  🔔','VoxRef.Text',w-42,15,C.text,2,1)
end
function PANEL:BuildSidebar()
    local s=self.sidebar
    s.Paint=function(_,w,h) softCard(0,0,w,h,12,Color(5,17,38,225)) end
    local profile=s:Add('Panel'); profile:SetPos(10,12); profile:SetSize(200,64)
    profile.Paint=function(_,w,h)
        rr(0,0,w,h,10,Color(8,22,48,170))
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
            local active=self.active==t[1]
            rr(0,0,w,h,7, active and Color(30,80,150,215) or Color(10,31,58,180))
            if active then rr(0,0,4,h,3,C.accent) end
            if p:IsHovered() then outline(0,0,w,h,7,ColorAlpha(C.accent,80)) end
            matIcon(t[4],24,21,active and C.text or C.soft)
            draw.SimpleText(t[2],'VoxRef.Small',48,8,C.text,0,0)
            draw.SimpleText(t[3],'VoxRef.Tiny',48,24,C.soft,0,0)
        end
        b.DoClick=function() self.active=t[1]; self:BuildContent() end
    end
    s.PaintOver=function(_,w,h)
        draw.SimpleText('Online Players','VoxRef.Tiny',18,h-48,C.soft,0,0); draw.SimpleText(#player.GetAll()..' / 64','VoxRef.Tiny',w-18,h-48,C.text,2,0)
        draw.SimpleText('Server Uptime','VoxRef.Tiny',18,h-30,C.soft,0,0); draw.SimpleText('2h 45m','VoxRef.Tiny',w-18,h-30,C.text,2,0)
    end
end
local function addCard(parent,x,y,w,h,title,value,sub,col,icon)
    local p=parent:Add('Panel'); p:SetPos(x,y); p:SetSize(w,h); p.Paint=function(_,cw,ch)
        softCard(0,0,cw,ch,8,Color(10,27,57,224))
        if icon then iconBubble(icon,10,9,18,col or C.accent) end
        draw.SimpleText(string.upper(title),'VoxRef.Tiny',icon and 34 or 14,10,C.soft,0,0)
        draw.SimpleText(value,'VoxRef.CardTitle',14,31,C.text,0,0)
        draw.SimpleText(sub or '', 'VoxRef.Tiny',14,58,col or C.green,0,0)
    end; return p
end
function PANEL:BuildContent()
    self.content:Clear()
    local c=self.content
    c.Paint=function(_,w,h) softCard(0,0,w,h,12,Color(5,15,34,225)) end
    local search=c:Add('DTextEntry'); self.search=search; search:SetPos(18,14); search:SetSize(math.max(c:GetWide()-36,220),30); search:SetText(''); search:SetPlaceholderText('Search the menu...')
    search.Paint=function(p,w,h) rr(0,0,w,h,7,Color(5,18,39,230)); outline(0,0,w,h,7,Color(37,65,110,120)); p:DrawTextEntryText(C.text,C.accent,C.text) end
    c.PerformLayout=function(_,w,h) if IsValid(search) then search:SetPos(18,14); search:SetSize(w-36,30) end end
    if self.active=='dashboard' then self:BuildDashboard(c) elseif self.active=='jobs' then self:BuildJobs(c) elseif self.active=='shop' then self:BuildShop(c) else self:BuildPlaceholder(c,string.upper(self.active)) end
end
function PANEL:BuildDashboard(c)
    local lp=LocalPlayer(); local moneyVal=IsValid(lp) and (lp:getDarkRPVar('money') or 0) or 0
    draw.SimpleText('', 'VoxRef.Text',0,0,C.text)
    draw.SimpleText('DASHBOARD','VoxRef.Small',18,58,C.text,0,0)
    addCard(c,18,78,150,66,'Wallet',money(moneyVal),'Bank Balance',C.green,WIMG_WALLET)
    addCard(c,178,78,150,66,'Current Job',IsValid(lp) and (lp:getDarkRPVar('job') or 'Citizen') or 'Citizen','View Jobs →',C.accent,WIMG_JOB)
    addCard(c,338,78,150,66,'Players Online',#player.GetAll()..' / 64','Join the community',C.accent,WIMG_PLAYERS)
    addCard(c,498,78,150,66,'Server Time',os.date('%H:%M'),'Today',C.accent,WIMG_TIME)
    self:ListPanel(c,18,158,300,132,'ANNOUNCEMENTS',{{'Welcome to Vox City','Make sure to read the rules','2h ago',WIMG_ALERT,C.green},{'Double XP Weekend','Enjoy 2x XP on all jobs','1d ago',WIMG_STAR,C.amber},{'Update v1.0.5','View changelog on Discord','2d ago',WIMG_PLAYERS,C.accent}},'VIEW ALL')
    self:ListPanel(c,330,158,230,132,'POPULAR JOBS',{{'Police Officer','$75 / min','8/10',WIMG_JOB,C.accent},{'Medic','$85 / min','3/6',WIMG_WALLET,C.amber},{'SWAT','$95 / min','2/4',WIMG_SHIELD or WIMG_JOB,C.red}},'VIEW ALL JOBS')
    self:ListPanel(c,572,158,180,132,'QUICK ACTIONS',{{'Laws of the Land','',nil,WIMG_ACTION,C.text},{'Wanted Players','',nil,WIMG_STAR,C.text},{'Report Player','',nil,WIMG_ALERT,C.text},{'Open Inventory','',nil,WIMG_WALLET,C.text}})
    self:ListPanel(c,18,304,300,116,'STAFF ONLINE',{{'superadmin','Owner','●',WIMG_PLAYERS,C.green},{'Voxberg','Administrator','●',WIMG_PLAYERS,C.green}})
    self:ListPanel(c,330,304,422,116,'WANTED PLAYERS',{{'John Wick','★★★★★','$5,000',WIMG_STAR,C.amber},{'Tony Montana','★★★★☆','$2,500',WIMG_STAR,C.amber}})
end
function PANEL:ListPanel(parent,x,y,w,h,title,rows,footer)
    local p=parent:Add('Panel'); p:SetPos(x,y); p:SetSize(w,h); p.Paint=function(_,cw,ch) softCard(0,0,cw,ch,8,Color(8,22,48,218)); draw.SimpleText(title,'VoxRef.Tiny',12,9,C.text,0,0) end
    local yy=28
    for _,r in ipairs(rows) do local row=p:Add('Panel'); row:SetPos(10,yy); row:SetSize(w-20,23); yy=yy+26; row.Paint=function(_,rw,rh) rr(0,0,rw,rh,5,Color(13,35,68,210)); if r[4] then iconBubble(r[4],6,4,15,r[5] or C.accent) end; draw.SimpleText(r[1],'VoxRef.Tiny',r[4] and 28 or 12,4,C.text,0,0); draw.SimpleText(r[2] or '','VoxRef.Tiny',r[4] and 28 or 12,14,C.soft,0,0); if r[3] then draw.SimpleText(r[3],'VoxRef.Tiny',rw-12,9,(r[3]:find('%$') or r[3]=='●') and C.green or C.soft,2,1) end end end
    if footer then local b=p:Add('Panel'); b:SetPos(10,h-25); b:SetSize(w-20,18); b.Paint=function(_,bw,bh) rr(0,0,bw,bh,5,Color(14,40,76,210)); draw.SimpleText(footer,'VoxRef.Tiny',bw*.5,bh*.5,C.accent,1,1) end end
end
function PANEL:BuildJobs(c)
    local scroll=c:Add('DScrollPanel'); scroll:SetPos(18,76); scroll:SetSize(c:GetWide()-36,c:GetTall()-92)
    local teams=RPExtraTeams or {}; local y=0; local cats={Citizens={},['Civil Protection']={},Gangsters={},Other={}}
    for k,v in pairs(teams) do local cat=(v.category or 'Other'); if not cats[cat] then cats[cat]={} end table.insert(cats[cat],v) end
    for cat,list in pairs(cats) do
        local head=scroll:Add('Panel'); head:SetPos(0,y); head:SetSize(scroll:GetWide()-20,38); head.Paint=function(_,w,h) rr(0,0,w,h,8,Color(3,12,25,238)); draw.SimpleText(string.upper(cat),'VoxRef.Text',14,19,C.text,0,1); draw.SimpleText('⌄','VoxRef.Title',w-18,19,C.text,1,1) end; y=y+46
        local x=0; for _,job in ipairs(list) do local card=scroll:Add('DButton'); card:SetText(''); card:SetPos(x,y); card:SetSize((scroll:GetWide()-36)/2,70); x=x+card:GetWide()+16; if x+card:GetWide()>scroll:GetWide() then x=0; y=y+82 end
            card.Paint=function(p,w,h) glass(0,0,w,h,6,job.color or C.accent); rr(10,12,46,46,23,Color(20,40,70)); draw.SimpleText(string.sub(job.name or '?',1,1),'VoxRef.Title',33,35,C.text,1,1); draw.SimpleText(job.name or 'Job','VoxRef.Title',70,15,C.text,0,0); draw.SimpleText('Salary: '..money(job.salary or 0),'VoxRef.Text',70,40,C.green,0,0); draw.SimpleText((team.NumPlayers(job.team or 0) or 0)..' / '..(job.max == 0 and '∞' or job.max or 0),'VoxRef.Text',w-20,35,C.text,2,1) end
        end; y=y+90
    end
end
function PANEL:BuildShop(c) self:ListPanel(c,18,86,350,240,'SHOP',{{'Entities','Browse entities'},{'Weapons','Browse weapons'},{'Shipments','Restricted shipments'},{'Ammo','Purchase ammo'},{'Food','Purchase food'}}) end
function PANEL:BuildPlaceholder(c,title) addCard(c,18,86,300,120,title,'Coming Soon','This Vox panel uses the new visual system.',C.accent) end
function PANEL:OnKeyCodePressed(key) if key==KEY_F4 or key==KEY_ESCAPE then self:Remove() end end
vox.gui.Register('vox.f4.Frame', PANEL, 'VoxRootFrame')
