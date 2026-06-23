-- Vox UI exact reference scoreboard remake
surface.CreateFont('VoxRef.Title', {font='Tahoma', size=18, weight=800, extended=true})
surface.CreateFont('VoxRef.Text', {font='Tahoma', size=14, weight=500, extended=true})
surface.CreateFont('VoxRef.Small', {font='Tahoma', size=12, weight=500, extended=true})
surface.CreateFont('VoxRef.Tiny', {font='Tahoma', size=10, weight=600, extended=true})
local C={bg=Color(5,14,28,245),panel=Color(8,25,48,238),card=Color(11,32,60,232),border=Color(0,174,255,80),accent=Color(0,174,255),green=Color(35,225,120),red=Color(255,75,95),amber=Color(255,190,65),text=Color(240,248,255),soft=Color(145,172,200)}
local function rr(x,y,w,h,r,col) draw.RoundedBox(r or 8,x,y,w,h,col) end
local function glass(x,y,w,h,r,accent) rr(x,y,w,h,r or 10,C.bg); rr(x+1,y+1,w-2,h-2,r or 10,Color(8,25,48,225)); surface.SetDrawColor(accent or C.border); surface.DrawOutlinedRect(x,y,w,h,1) end
local function money(v) if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(v or 0) end return '$'..string.Comma(v or 0) end
local PANEL={}
function PANEL:Init()
    vox.scoreboard.Frame=self; self:SetTitle(''); self:SetSize(math.min(ScrW()*0.88,1120), math.min(ScrH()*0.82,690)); self:Center(); self:SetAlpha(0); self:AlphaTo(255,.12,0)
    self.sidebar=self:Add('Panel'); self.list=self:Add('DScrollPanel'); self.search=self:Add('DTextEntry'); self.sort=self:Add('DComboBox')
    self.search:SetPlaceholderText('Search players...'); self.sort:AddChoice('Sort by: Name'); self.sort:ChooseOptionID(1)
    self:BuildRows()
end
function PANEL:PerformLayout(w,h)
    self.sidebar:SetPos(12,46); self.sidebar:SetSize(185,h-70)
    self.search:SetPos(520,28); self.search:SetSize(260,34)
    self.sort:SetPos(w-180,28); self.sort:SetSize(150,34)
    self.list:SetPos(220,78); self.list:SetSize(w-250,h-110)
end
function PANEL:Paint(w,h)
    glass(0,0,w,h,12,C.accent)
    draw.SimpleText('SCOREBOARD','VoxRef.Title',16,18,C.text,0,1)
    glass(210,24,w-235,h-48,10,C.border)
    draw.SimpleText('◉  VOX SCOREBOARD','VoxRef.Title',236,49,C.text,0,1)
end
function PANEL:PaintOver(w,h)
    draw.SimpleText('Player','VoxRef.Small',238,92,C.soft,0,1); draw.SimpleText('Job','VoxRef.Small',445,92,C.soft,0,1); draw.SimpleText('Rank','VoxRef.Small',595,92,C.soft,0,1); draw.SimpleText('Money','VoxRef.Small',735,92,C.soft,0,1); draw.SimpleText('Level','VoxRef.Small',850,92,C.soft,0,1); draw.SimpleText('Ping','VoxRef.Small',930,92,C.soft,0,1); draw.SimpleText('Voice','VoxRef.Small',1010,92,C.soft,0,1)
end
function PANEL:BuildRows()
    self.sidebar.Paint=function(_,w,h)
        glass(0,0,w,h,10,C.border); rr(0,0,4,60,2,C.accent)
        local cats={{'⚙','',0},{'♟','Citizens',18},{'★','Law Enforcement',4},{'✚','Medical',2},{'♜','Staff',3},{'♞','Gangsters',5},{'♙','Other',1}}
        local y=55
        for _,c in ipairs(cats) do draw.SimpleText(c[1],'VoxRef.Small',22,y,C.text,1,1); draw.SimpleText(c[2],'VoxRef.Small',45,y,C.text,0,1); if c[3]>0 then draw.SimpleText(c[3],'VoxRef.Small',w-20,y,C.soft,2,1) end y=y+44 end
        rr(14,h-50,w-28,36,7,Color(12,35,65,210)); draw.SimpleText('⚙  SETTINGS','VoxRef.Small',w/2,h-32,C.text,1,1)
    end
    self.search.Paint=function(p,w,h) rr(0,0,w,h,6,Color(3,12,25,235)); surface.SetDrawColor(Color(24,61,105,160)); surface.DrawOutlinedRect(0,0,w,h,1); p:DrawTextEntryText(C.text,C.accent,C.text) end
    self.sort.Paint=function(p,w,h) rr(0,0,w,h,6,Color(3,12,25,235)); draw.SimpleText(p:GetValue() or 'Sort by: Name','VoxRef.Small',12,h/2,C.text,0,1) end
    local y=32
    local players=player.GetAll(); if #players==0 then players={LocalPlayer()} end
    for i,ply in ipairs(players) do if IsValid(ply) then
        local row=self.list:Add('DButton'); row:SetText(''); row:SetPos(0,y); row:SetSize(self:GetWide()-280,42); y=y+46
        row.Paint=function(p,w,h)
            local job=ply:getDarkRPVar('job') or team.GetName(ply:Team()) or 'Citizen'; local jc=team.GetColor(ply:Team()) or C.green
            rr(0,0,w,h,7,p:IsHovered() and Color(18,48,80,235) or Color(10,30,52,215)); rr(0,0,3,h,2,jc)
            rr(12,7,28,28,14,Color(20,40,70)); draw.SimpleText(string.sub(ply:Name(),1,1),'VoxRef.Small',26,21,C.text,1,1)
            draw.SimpleText(ply:Name(),'VoxRef.Small',50,21,C.text,0,1); draw.SimpleText(job,'VoxRef.Small',225,21,jc,0,1); draw.SimpleText(ply:GetUserGroup() or 'user','VoxRef.Small',370,21,C.text,0,1); draw.SimpleText(money(ply:getDarkRPVar('money') or 0),'VoxRef.Small',510,21,C.text,0,1); draw.SimpleText('12','VoxRef.Small',630,21,C.text,0,1); draw.SimpleText('▂▃▅▇ '..ply:Ping(),'VoxRef.Small',710,21,C.green,0,1); draw.SimpleText('◉','VoxRef.Small',w-35,21,C.green,1,1)
        end
        row.DoRightClick=function() local m=DermaMenu(); for _,a in ipairs({'View Profile','Message','Add Friend','Report Player','Mute','Kick Player'}) do m:AddOption(a,function() end) end m:Open() end
    end end
end
function PANEL:Think()
    if self.closeDisabled then local bind=input.LookupBinding('+showscores',true); local key=bind and input.GetKeyCode(bind); if key and not input.IsKeyDown(key) then self:Remove() end end
end
vox.gui.Register('vox.Scoreboard.Frame', PANEL, 'VoxRootFrame')
