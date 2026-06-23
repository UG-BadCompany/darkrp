-- Vox UI exact reference visual HUD override
local hud = vox.hud
if not hud then return end

surface.CreateFont('VoxRef.Title', { font = 'Tahoma', size = 18, weight = 800, extended = true })
surface.CreateFont('VoxRef.Text', { font = 'Tahoma', size = 14, weight = 500, extended = true })
surface.CreateFont('VoxRef.Small', { font = 'Tahoma', size = 12, weight = 500, extended = true })
surface.CreateFont('VoxRef.Tiny', { font = 'Tahoma', size = 10, weight = 600, extended = true })
surface.CreateFont('VoxRef.Big', { font = 'Tahoma', size = 24, weight = 900, extended = true })

local WIMG_HEART = vox.wimg.Create( 'hud_heart', 'smooth mips' )
local WIMG_SHIELD = vox.wimg.Create( 'hud_shield', 'smooth mips' )
local WIMG_FOOD = vox.wimg.Create( 'hud_food', 'smooth mips' )

local C = {
    bg = Color(4, 10, 24, 205),
    panel = Color(6, 16, 34, 188),
    card = Color(7, 19, 39, 168),
    border = Color(0, 174, 255, 95),
    accent = Color(0, 174, 255),
    green = Color(35, 225, 120),
    red = Color(255, 75, 95),
    blue = Color(70, 135, 255),
    amber = Color(255, 190, 65),
    text = Color(240, 248, 255),
    soft = Color(150, 178, 205),
    track = Color(18, 35, 58, 235)
}

local function rr(x,y,w,h,r,col)
    draw.RoundedBox(r or 8, math.floor(x), math.floor(y), math.floor(w), math.floor(h), col)
end

local function glass(x,y,w,h,r,accent)
    r = r or 12
    accent = accent or C.accent
    rr(x - 1,y - 1,w + 2,h + 2,r + 1,ColorAlpha(accent,34))
    rr(x,y,w,h,r,C.bg)
    rr(x+1,y+1,w-2,h-2,math.max(r - 1, 0),Color(5,15,32,164))
    surface.SetDrawColor(ColorAlpha(accent,6))
    surface.DrawRect(x + 1,y + 1,w - 2,math.floor(h * .22))
end

local function bar(x,y,w,h,frac,col)
    frac = math.Clamp(frac or 0,0,1)
    rr(x - 1,y - 1,w + 2,h + 2,h/2 + 1,ColorAlpha(col,24))
    rr(x,y,w,h,h/2,C.track)
    if frac > 0 then
        render.SetScissorRect(x,y,x + w * frac,y + h,true)
            rr(x,y,w,h,h/2,col)
        render.SetScissorRect(0,0,0,0,false)
    end
end

local smooth = { hp = 1, ar = 0, hu = 1, xp = .65 }
local modelPanel
local lastModelData

local function formatMoney(v)
    if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(v or 0) end
    return '$' .. string.Comma(v or 0)
end

local function hasHunger(client)
    local energy = client:getDarkRPVar('Energy')
    if energy ~= nil then return true, math.Clamp((tonumber(energy) or 0) / 100, 0, 1) end
    if DarkRP and DarkRP.disabledDefaults and DarkRP.disabledDefaults.modules and DarkRP.disabledDefaults.modules.hungermod == false then
        return true, 1
    end
    return false, 0
end

local function getLevelData(client)
    if not hud.IsLevellingEnabled or not hud.IsLevellingEnabled() or not hud.GetLevelData then return end
    local level, xp, maxXP = hud.GetLevelData(client)
    if not level or not xp or not maxXP or maxXP <= 0 then return end
    return level, xp, maxXP, math.Clamp(xp / maxXP, 0, 1)
end

local function ensureModelPanel(client, x, y, size)
    if not IsValid(modelPanel) then
        modelPanel = vgui.Create('DModelPanel')
        modelPanel:SetPaintedManually(true)
        modelPanel:SetMouseInputEnabled(false)
        modelPanel:SetKeyboardInputEnabled(false)
        modelPanel.LayoutEntity = function() end
    end

    modelPanel:SetVisible(true)
    modelPanel:SetPos(x, y)
    modelPanel:SetSize(size, size)
    modelPanel:SetFOV(32)
    modelPanel:SetCamPos(Vector(30, 0, 63))
    modelPanel:SetLookAt(Vector(0, 0, 61))

    local current = hud.GetModelData and hud.GetModelData(client)
    if current and (not lastModelData or not hud.CompareModelData(current, lastModelData)) then
        hud.UpdateModelIcon(modelPanel, current)
        lastModelData = current
    elseif not current and modelPanel:GetModel() ~= client:GetModel() then
        modelPanel:SetModel(client:GetModel())
    end

    local ent = modelPanel.Entity
    if IsValid(ent) then
        local boneID = ent:LookupBone('ValveBiped.Bip01_Head1')
        if boneID then
            local bonePos = ent:GetBonePosition(boneID)
            if bonePos then
                bonePos:Add(Vector(0, 0, 1))
                local lookAt = bonePos - Vector(0, 0, 1.5)
                local camPos = bonePos + Vector(30, 0, 2.5)
                modelPanel:SetLookAt(lookAt)
                modelPanel:SetCamPos(camPos)
                ent:SetEyeTarget(camPos)
            end
        end
    end
end

hook.Add('ShutDown', 'VoxRef.RemoveModelPanel', function()
    if IsValid(modelPanel) then modelPanel:Remove() end
end)

local function drawStatRow(x, y, w, icon, label, frac, col, value, scale)
    local iconSize = math.floor(15 * (scale or 1))
    icon:Draw(x, y + math.floor(2 * (scale or 1)), iconSize, iconSize, col)
    draw.SimpleText(label, 'VoxRef.Small', x + math.floor(22 * (scale or 1)), y, C.text, 0, 0)
    bar(x + math.floor(88 * (scale or 1)), y + math.floor(5 * (scale or 1)), w - math.floor(134 * (scale or 1)), math.max(math.floor(8 * (scale or 1)), 5), frac, col)
    draw.SimpleText(value, 'VoxRef.Small', x + w, y, C.text, 2, 0)
end

local function drawReferenceMain(self, client, sw, sh)
    if not IsValid(client) then return end
    local scale = math.Clamp(sh / 1080, .82, 1)
    local pad = math.floor(16 * scale)
    local x, y, w = pad, sh - math.floor(238 * scale), math.floor(282 * scale)
    local rowH = math.floor(21 * scale)
    local showHunger, hunger = hasHunger(client)
    local level, xp, maxXP, xpFrac = getLevelData(client)
    local h = math.floor((level and 246 or 222) * scale)

    local hp = math.Clamp(client:Health() / math.max(client:GetMaxHealth(),1), 0, 1)
    local ar = math.Clamp(client:Armor() / math.max(client:GetMaxArmor() or 100,1), 0, 1)
    smooth.hp = Lerp(FrameTime()*10, smooth.hp, hp)
    smooth.ar = Lerp(FrameTime()*10, smooth.ar, ar)
    smooth.hu = Lerp(FrameTime()*10, smooth.hu, hunger)
    if xpFrac then smooth.xp = Lerp(FrameTime()*10, smooth.xp, xpFrac) end

    local money = client:getDarkRPVar('money') or 0
    local salary = client:getDarkRPVar('salary') or 0
    local job = client:getDarkRPVar('job') or team.GetName(client:Team()) or 'Citizen'

    glass(x,y,w,h,14 * scale,C.accent)
    draw.SimpleText('IN-GAME HUD','VoxRef.Tiny',x+w/2,y-13 * scale,C.text,1,1)

    local avSize = math.floor(68 * scale)
    local avX, avY = x + math.floor(10 * scale), y + math.floor(13 * scale)
    local avR = avSize * .5
    local avCX, avCY = avX + avR, avY + avR
    rr(avX - 4,avY - 4,avSize + 8,avSize + 8,avR + 4,ColorAlpha(C.accent,28))
    rr(avX - 2,avY - 2,avSize + 4,avSize + 4,avR + 2,Color(5,15,25,245))
    ensureModelPanel(client, avX, avY, avSize)
    local avatarMask = vox.CalculateCircle(avCX, avCY, avR, 48)
    vox.DrawWithPolyMask(avatarMask, function()
        rr(avX,avY,avSize,avSize,avR,C.panel)
        modelPanel:PaintManual()
    end)
    vox.DrawOutlinedCircle(avCX, avCY, avR + 1, math.max(2 * scale, 1), C.accent)

    rr(x+w-28 * scale,y+18 * scale,8 * scale,8 * scale,4 * scale,C.green)
    draw.SimpleText(client:Name(),'VoxRef.Title',x+88 * scale,y+19 * scale,C.text,0,0)
    draw.SimpleText(job,'VoxRef.Small',x+88 * scale,y+40 * scale,C.green,0,0)

    local moneyX, moneyY = x + 88 * scale, y + 70 * scale
    local moneyW, moneyH = w - 104 * scale, 42 * scale
    local salaryX = x + w - 24 * scale
    local dividerX = x + w - 102 * scale
    rr(moneyX - 8 * scale,moneyY - 4 * scale,moneyW,moneyH,9 * scale,ColorAlpha(C.card,145))
    rr(moneyX - 4 * scale,moneyY + 7 * scale,3 * scale,moneyH - 17 * scale,2 * scale,Color(16, 115, 76, 220))
    surface.SetDrawColor(Color(62, 96, 130, 105)); surface.DrawLine(dividerX, moneyY + 5 * scale, dividerX, moneyY + 33 * scale)
    render.SetScissorRect(moneyX, moneyY, dividerX - 8 * scale, moneyY + 27 * scale, true)
        draw.SimpleText(formatMoney(money),'VoxRef.Big',moneyX + 4 * scale,moneyY + 1 * scale,C.text,0,0)
    render.SetScissorRect(0,0,0,0,false)
    draw.SimpleText('Wallet','VoxRef.Tiny',moneyX + 4 * scale,moneyY + 27 * scale,C.soft,0,0)
    render.SetScissorRect(dividerX + 7 * scale, moneyY, salaryX, moneyY + 27 * scale, true)
        draw.SimpleText('+'..formatMoney(salary),'VoxRef.Title',salaryX,moneyY + 3 * scale,C.green,2,0)
    render.SetScissorRect(0,0,0,0,false)
    draw.SimpleText('Salary','VoxRef.Tiny',salaryX,moneyY + 28 * scale,C.soft,2,0)

    local rowX, rowY, rowW = x + 20 * scale, y + 128 * scale, w - 42 * scale
    drawStatRow(rowX, rowY, rowW, WIMG_HEART, 'Health', smooth.hp, C.red, math.floor(hp*100)..'%', scale)
    rowY = rowY + rowH
    drawStatRow(rowX, rowY, rowW, WIMG_SHIELD, 'Armor', smooth.ar, C.blue, math.floor(ar*100)..'%', scale)
    rowY = rowY + rowH
    if showHunger then
        drawStatRow(rowX, rowY, rowW, WIMG_FOOD, 'Hunger', smooth.hu, C.amber, math.floor(hunger*100)..'%', scale)
        rowY = rowY + rowH
    end

    if level then
        rowY = rowY + math.floor(8 * scale)
        draw.SimpleText('◎  Level ' .. level, 'VoxRef.Small', rowX, rowY, C.text, 0, 0)
        draw.SimpleText(string.Comma(xp) .. '/' .. string.Comma(maxXP) .. ' XP', 'VoxRef.Tiny', rowX + rowW, rowY + 1 * scale, C.soft, 2, 0)
        bar(rowX + 96 * scale, rowY + 20 * scale, rowW - 116 * scale, 8 * scale, smooth.xp, C.blue)
    end
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
