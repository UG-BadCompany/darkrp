-- Vox UI exact reference visual HUD override
local hud = vox.hud
if not hud then return end

surface.CreateFont('VoxRef.Title', { font = 'Tahoma', size = 18, weight = 800, extended = true })
surface.CreateFont('VoxRef.Text', { font = 'Tahoma', size = 14, weight = 500, extended = true })
surface.CreateFont('VoxRef.Small', { font = 'Tahoma', size = 12, weight = 500, extended = true })
surface.CreateFont('VoxRef.Tiny', { font = 'Tahoma', size = 10, weight = 600, extended = true })
surface.CreateFont('VoxRef.Big', { font = 'Tahoma', size = 24, weight = 900, extended = true })

local C = {
    bg = Color(5, 14, 28, 232),
    panel = Color(9, 28, 52, 232),
    card = Color(12, 35, 65, 232),
    border = Color(0, 174, 255, 95),
    accent = Color(0, 174, 255),
    green = Color(35, 225, 120),
    red = Color(255, 75, 95),
    blue = Color(70, 135, 255),
    amber = Color(255, 190, 65),
    text = Color(240, 248, 255),
    soft = Color(150, 178, 205)
}

local function rr(x,y,w,h,r,col)
    draw.RoundedBox(r or 8, math.floor(x), math.floor(y), math.floor(w), math.floor(h), col)
end

local function glass(x,y,w,h,r,accent)
    rr(x,y,w,h,r or 10,C.bg)
    rr(x+1,y+1,w-2,h-2,r or 10,Color(8,24,45,210))
    surface.SetDrawColor(accent or C.border)
    surface.DrawOutlinedRect(x,y,w,h,1)
    surface.SetDrawColor(ColorAlpha(accent or C.accent,26))
    surface.DrawRect(x+1,y+1,3,h-2)
end

local function bar(x,y,w,h,frac,col,label)
    frac = math.Clamp(frac or 0,0,1)
    rr(x,y,w,h,h/2,Color(20,38,58,230))
    rr(x,y,w*frac,h,h/2,col)
    surface.SetDrawColor(ColorAlpha(col,160)); surface.DrawOutlinedRect(x,y,w,h,1)
    if label then draw.SimpleText(label,'VoxRef.Tiny',x+w+6,y+h/2,C.text,0,1) end
end

local smooth = { hp = 1, ar = 0, hu = 1, xp = .65, money = 0 }
local function formatMoney(v)
    if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(v or 0) end
    return '$' .. string.Comma(v or 0)
end

local function drawReferenceMain(self, client, sw, sh)
    if not IsValid(client) then return end
    local pad = 16
    local x, y, w, h = pad, sh - 190, 270, 172
    local hp = math.Clamp(client:Health() / math.max(client:GetMaxHealth(),1), 0, 1)
    local ar = math.Clamp(client:Armor() / math.max(client:GetMaxArmor() or 100,1), 0, 1)
    local hunger = math.Clamp((client:getDarkRPVar('Energy') or 100) / 100, 0, 1)
    smooth.hp = Lerp(FrameTime()*10, smooth.hp, hp)
    smooth.ar = Lerp(FrameTime()*10, smooth.ar, ar)
    smooth.hu = Lerp(FrameTime()*10, smooth.hu, hunger)
    local money = client:getDarkRPVar('money') or 0
    local salary = client:getDarkRPVar('salary') or 0
    local job = client:getDarkRPVar('job') or team.GetName(client:Team()) or 'Citizen'
    glass(x,y,w,h,12,C.accent)
    draw.SimpleText('IN-GAME HUD','VoxRef.Tiny',x+w/2,y-13,C.text,1,1)
    -- avatar frame
    local avSize = 62
    rr(x+12,y+14,avSize,avSize,10,Color(5,15,25,255))
    surface.SetDrawColor(C.accent); surface.DrawOutlinedRect(x+12,y+14,avSize,avSize,1)
    draw.SimpleText(string.sub(client:Name(),1,1),'VoxRef.Big',x+12+avSize/2,y+14+avSize/2,C.text,1,1)
    rr(x+w-29,y+18,8,8,4,C.green)
    draw.SimpleText(client:Name(),'VoxRef.Title',x+86,y+18,C.text,0,0)
    draw.SimpleText(job,'VoxRef.Small',x+86,y+40,C.green,0,0)
    draw.SimpleText(formatMoney(money),'VoxRef.Big',x+86,y+66,C.text,0,0)
    draw.SimpleText('Wallet','VoxRef.Tiny',x+86,y+92,C.soft,0,0)
    draw.SimpleText('+'..formatMoney(salary),'VoxRef.Title',x+w-16,y+67,C.green,2,0)
    draw.SimpleText('Salary','VoxRef.Tiny',x+w-16,y+92,C.soft,2,0)
    local bx, by = x+26, y+114
    draw.SimpleText('♥','VoxRef.Small',x+14,by+2,C.red,0,1); bar(bx,by,160,9,smooth.hp,C.red,math.floor(hp*100)..'%')
    draw.SimpleText('♦','VoxRef.Small',x+14,by+19,C.blue,0,1); bar(bx,by+17,160,9,smooth.ar,C.blue,math.floor(ar*100)..'%')
    draw.SimpleText('★','VoxRef.Small',x+14,by+36,C.amber,0,1); bar(bx,by+34,160,9,smooth.hu,C.amber,math.floor(hunger*100)..'%')
    draw.SimpleText('◎ Level 12','VoxRef.Small',x+18,y+h-19,C.accent,0,1)
    bar(x+104,y+h-24,100,8,.65,C.blue,nil)
end

local notifyCache = {}
local oldAdd = notification.AddLegacy
notification.AddLegacy = function(text, typ, len)
    table.insert(notifyCache, 1, {text = tostring(text or ''), typ = typ or NOTIFY_GENERIC, len = len or 4, start = CurTime()})
    while #notifyCache > 4 do table.remove(notifyCache) end
end

local function drawRefNotifications(self, client, sw, sh)
    local x, y = 330, sh - 320
    for i=#notifyCache,1,-1 do
        local n = notifyCache[i]
        local life = (CurTime() - n.start) / n.len
        if life >= 1 then table.remove(notifyCache,i) else
            local cy = y + (i-1)*60
            local col = n.typ == NOTIFY_ERROR and C.red or (n.typ == NOTIFY_UNDO and C.green or C.accent)
            glass(x,cy,250,48,8,col)
            rr(x+10,cy+10,28,28,14,ColorAlpha(col,55))
            draw.SimpleText(n.typ == NOTIFY_ERROR and '!' or '$','VoxRef.Title',x+24,cy+24,col,1,1)
            draw.SimpleText(n.typ == NOTIFY_ERROR and 'Warning' or 'Notification','VoxRef.Small',x+48,cy+9,C.text,0,0)
            draw.SimpleText(n.text,'VoxRef.Tiny',x+48,cy+27,C.soft,0,0)
            rr(x,cy+46,250*(1-life),2,1,col)
        end
    end
end

local function drawRefWeaponSelector(self, client, sw, sh)
    local weps = client:GetWeapons()
    if #weps == 0 then return end
    local w,h = 620,80
    local x,y = sw/2 - w/2, sh - 235
    draw.SimpleText('WEAPON SELECTOR','VoxRef.Tiny',x+w/2,y-10,C.text,1,1)
    glass(x,y,w,h,6,C.border)
    local slotW = w/6
    for i=1,6 do
        local sx = x + (i-1)*slotW
        if i == 1 then rr(sx+2,y+2,slotW-4,h-4,5,Color(0,84,160,90)); surface.SetDrawColor(C.accent); surface.DrawOutlinedRect(sx+2,y+2,slotW-4,h-4,1) end
        draw.SimpleText(i,'VoxRef.Small',sx+10,y+8,C.text,0,0)
        local wp = weps[i]
        draw.SimpleText(wp and (wp:GetPrintName() or wp:GetClass()) or '', 'VoxRef.Tiny', sx+slotW/2, y+48, C.text,1,1)
        draw.SimpleText(wp and '30 / 120' or '', 'VoxRef.Tiny', sx+slotW/2, y+63, C.soft,1,1)
        surface.SetDrawColor(Color(35,70,110,90)); surface.DrawLine(sx+slotW-1,y+10,sx+slotW-1,y+h-10)
    end
end

hud:RegisterElement('main', { priority = 10, drawFn = drawReferenceMain, hideElements = {'DarkRP_HUD','DarkRP_LocalPlayerHUD','DarkRP_EntityDisplay'} })
hud:RegisterElement('notifications', { priority = 90, drawFn = drawRefNotifications, hideElements = {} })
hud:RegisterElement('weapon_selector', { priority = 80, drawFn = drawRefWeaponSelector, hideElements = {'CHudWeaponSelection'} })
