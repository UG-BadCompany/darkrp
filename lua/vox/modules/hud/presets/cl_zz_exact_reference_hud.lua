-- Vox UI exact reference visual HUD override
local hud = vox.hud
if not hud then return end

local lastFontScale
local function createReferenceFonts()
    local scale = (hud.GetScale and hud.GetScale() or 1)
    local fontScale = 1
    if vox.inconfig and vox.inconfig.options and vox.inconfig.options['hud_font_size'] then
        local option = vox.inconfig.options['hud_font_size']
        local serverFontSize = hud:GetOptionValue('font_size')
        if serverFontSize ~= nil and serverFontSize ~= option.default then
            fontScale = serverFontSize / 100
        end
    end

    local combined = math.Round(scale * fontScale * 1000)
    if lastFontScale == combined then return end
    lastFontScale = combined

    local function size(px)
        return math.max(math.Round(px * scale * fontScale), 8)
    end

    surface.CreateFont('VoxRef.Title', { font = 'Tahoma', size = size(18), weight = 800, extended = true })
    surface.CreateFont('VoxRef.Text', { font = 'Tahoma', size = size(14), weight = 500, extended = true })
    surface.CreateFont('VoxRef.Small', { font = 'Tahoma', size = size(12), weight = 500, extended = true })
    surface.CreateFont('VoxRef.Tiny', { font = 'Tahoma', size = size(10), weight = 600, extended = true })
    surface.CreateFont('VoxRef.Big', { font = 'Tahoma', size = size(24), weight = 900, extended = true })
end
createReferenceFonts()

local WIMG_HEART = vox.wimg.Create( 'hud_heart', 'smooth mips' )
local WIMG_SHIELD = vox.wimg.Create( 'hud_shield', 'smooth mips' )
local WIMG_FOOD = vox.wimg.Create( 'hud_food', 'smooth mips' )
local WIMG_LICENSE = vox.wimg.Create( 'hud_license', 'smooth mips' )
local WIMG_WANTED = vox.wimg.Create( 'hud_wanted', 'smooth mips' )

local C = {
    bg = Color(3, 9, 26, 218),
    panel = Color(5, 14, 34, 198),
    card = Color(7, 18, 43, 178),
    border = Color(0, 130, 255, 135),
    accent = Color(0, 174, 255),
    green = Color(35, 225, 120),
    red = Color(255, 75, 95),
    blue = Color(70, 135, 255),
    amber = Color(255, 190, 65),
    text = Color(240, 248, 255),
    soft = Color(150, 178, 205),
    track = Color(18, 35, 58, 235)
}

local function syncThemeColors()
    local theme = hud.GetCurrentTheme and hud:GetCurrentTheme()
    local colors = theme and theme.colors
    if not colors then return end

    C.bg = ColorAlpha(colors.primary or C.bg, 218)
    C.panel = ColorAlpha(colors.secondary or C.panel, 198)
    C.card = ColorAlpha(colors.secondary or C.card, 178)
    C.border = ColorAlpha(colors.accent or C.border, 135)
    C.accent = colors.accent or C.accent
    C.green = colors.money or colors.positive or C.green
    C.red = colors.negative or C.red
    C.blue = colors.armor or C.blue
    C.amber = colors.hunger or C.amber
    C.text = colors.textPrimary or C.text
    C.soft = colors.textSecondary or C.soft
    C.track = ColorAlpha(colors.textPrimary or C.track, (theme.isDark or theme.dark) and 26 or 95)
end

local function rr(x,y,w,h,r,col)
    draw.RoundedBox(r or 8, math.floor(x), math.floor(y), math.floor(w), math.floor(h), col)
end

local function glass(x,y,w,h,r,accent)
    r = r or 12
    accent = accent or C.accent
    rr(x - 3,y - 3,w + 6,h + 6,r + 3,ColorAlpha(accent,18))
    rr(x - 1,y - 1,w + 2,h + 2,r + 1,ColorAlpha(accent,54))
    rr(x,y,w,h,r,C.bg)
    rr(x+1,y+1,w-2,h-2,math.max(r - 1, 0),Color(5,15,38,150))
    surface.SetDrawColor(ColorAlpha(accent,10))
    surface.DrawRect(x + 1,y + 1,w - 2,math.floor(h * .26))
    surface.SetDrawColor(ColorAlpha(accent,105))
    surface.DrawOutlinedRect(x,y,w,h,1)
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
    modelPanel:SetFOV(34)
    modelPanel:SetCamPos(Vector(32, 0, 64))
    modelPanel:SetLookAt(Vector(0, 0, 62))

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
                bonePos:Add(Vector(0, 0, 2.5))
                local lookAt = bonePos - Vector(0, 0, 1)
                local camPos = bonePos + Vector(34, 0, 3)
                modelPanel:SetLookAt(lookAt)
                modelPanel:SetCamPos(camPos)
                modelPanel:SetFOV(35)
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

local function drawBottomIcons(x, y, w, scale, client)
    local icons = {
        { mat = WIMG_HEART, active = true },
        { mat = WIMG_SHIELD, active = client:Armor() > 0 },
        { mat = WIMG_WANTED, active = client:getDarkRPVar('wanted') },
        { mat = WIMG_LICENSE, active = client:getDarkRPVar('HasGunlicense') }
    }
    local count = #icons
    local cellW = w / count
    local boxW, boxH = math.floor(42 * scale), math.floor(25 * scale)
    local iconSize = math.floor(13 * scale)
    for i, data in ipairs(icons) do
        local cx = x + (i - .5) * cellW
        local bx, by = cx - boxW * .5, y
        local activeColor = data.active and C.text or ColorAlpha(C.soft, 120)
        rr(bx, by, boxW, boxH, 10 * scale, Color(7, 20, 45, data.active and 142 or 86))
        data.mat:Draw(cx - iconSize * .5, by + boxH * .5 - iconSize * .5, iconSize, iconSize, activeColor)
    end
end

local function drawReferenceMain(self, client, sw, sh)
    if not IsValid(client) then return end
    syncThemeColors()
    createReferenceFonts()

    local scale = math.Clamp(sh / 1080, .82, 1) * (hud.GetScale and hud.GetScale() or 1)
    local pad = hud.GetScreenPadding and hud.GetScreenPadding() or math.floor(16 * scale)
    local x, y, w = pad, sh - math.floor(312 * scale), math.floor(286 * scale)
    local rowH = math.floor(22 * scale)
    local showMoney = hud:GetOptionValue('display_money')
    local showSalary = hud:GetOptionValue('display_salary')
    local compactMode = hud:GetOptionValue('compact_mode')
    local showJob = hud:GetOptionValue('display_job') and not compactMode
    local showHealth = hud:GetOptionValue('display_health')
    local showArmor = hud:GetOptionValue('display_armor')
    local showHunger, hunger = hasHunger(client)
    showHunger = showHunger and hud:GetOptionValue('display_hunger')
    local level, xp, maxXP, xpFrac = getLevelData(client)
    local showLevel = level and (hud:GetOptionValue('display_level') or hud:GetOptionValue('display_xp'))
    local h = math.floor(294 * scale)

    local hp = math.Clamp(client:Health() / math.max(client:GetMaxHealth(),1), 0, 1)
    local ar = math.Clamp(client:Armor() / math.max(client:GetMaxArmor() or 100,1), 0, 1)
    smooth.hp = Lerp(FrameTime()*10, smooth.hp, hp)
    smooth.ar = Lerp(FrameTime()*10, smooth.ar, ar)
    smooth.hu = Lerp(FrameTime()*10, smooth.hu, hunger)
    if xpFrac then smooth.xp = Lerp(FrameTime()*10, smooth.xp, xpFrac) end

    local money = client:getDarkRPVar('money') or 0
    local salary = client:getDarkRPVar('salary') or 0
    local job = client:getDarkRPVar('job') or team.GetName(client:Team()) or 'Citizen'

    glass(x,y,w,h,math.max(hud.GetRoundness and hud.GetRoundness() or 14 * scale, 12 * scale),C.accent)
    draw.SimpleText('IN-GAME HUD','VoxRef.Tiny',x+w/2,y-13 * scale,C.text,1,1)

    local avSize = math.floor(70 * scale)
    local avX, avY = x + math.floor(10 * scale), y + math.floor(17 * scale)
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

    rr(x+w-31 * scale,y+19 * scale,18 * scale,18 * scale,9 * scale,Color(7, 25, 50, 175))
    rr(x+w-25 * scale,y+25 * scale,6 * scale,6 * scale,3 * scale,C.green)
    draw.SimpleText(client:Name(),'VoxRef.Title',x+91 * scale,y+20 * scale,C.text,0,0)
    if showJob then
        draw.SimpleText(job,'VoxRef.Small',x+91 * scale,y+42 * scale,C.green,0,0)
    end

    local moneyX, moneyY = x + 94 * scale, y + 73 * scale
    local moneyW, moneyH = w - 111 * scale, 52 * scale
    local salaryX = moneyX + moneyW - 10 * scale
    local dividerX = moneyX + moneyW * .58
    if showMoney or showSalary then
        rr(moneyX - 8 * scale,moneyY - 4 * scale,moneyW,moneyH,10 * scale,ColorAlpha(C.card,190))
        rr(moneyX - 4 * scale,moneyY + 7 * scale,3 * scale,moneyH - 17 * scale,2 * scale,ColorAlpha(C.green, 220))
        if showMoney and showSalary then
            surface.SetDrawColor(Color(62, 96, 130, 105)); surface.DrawLine(dividerX, moneyY + 8 * scale, dividerX, moneyY + 39 * scale)
        end
        if showMoney then
            render.SetScissorRect(moneyX, moneyY, (showSalary and dividerX - 8 * scale or salaryX), moneyY + 27 * scale, true)
                draw.SimpleText(formatMoney(money),'VoxRef.Big',moneyX + 4 * scale,moneyY + 1 * scale,C.text,0,0)
            render.SetScissorRect(0,0,0,0,false)
            draw.SimpleText('Wallet','VoxRef.Tiny',moneyX + 4 * scale,moneyY + 29 * scale,C.soft,0,0)
        end
        if showSalary then
            render.SetScissorRect(showMoney and dividerX + 7 * scale or moneyX, moneyY, salaryX, moneyY + 27 * scale, true)
                draw.SimpleText('+'..formatMoney(salary),'VoxRef.Title',salaryX,moneyY + 3 * scale,C.green,2,0)
            render.SetScissorRect(0,0,0,0,false)
            draw.SimpleText('Salary','VoxRef.Tiny',salaryX,moneyY + 29 * scale,C.soft,2,0)
        end
    end

    local rowX, rowY, rowW = x + 20 * scale, y + 147 * scale, w - 42 * scale
    if showHealth then
        drawStatRow(rowX, rowY, rowW, WIMG_HEART, 'Health', smooth.hp, C.red, math.floor(hp*100)..'%', scale)
        rowY = rowY + rowH
    end
    if showArmor then
        drawStatRow(rowX, rowY, rowW, WIMG_SHIELD, 'Armor', smooth.ar, C.blue, math.floor(ar*100)..'%', scale)
        rowY = rowY + rowH
    end
    if showHunger then
        drawStatRow(rowX, rowY, rowW, WIMG_FOOD, 'Hunger', smooth.hu, C.amber, math.floor(hunger*100)..'%', scale)
        rowY = rowY + rowH
    end

    if showLevel then
        rowY = math.max(rowY + math.floor(8 * scale), y + math.floor(218 * scale))
        draw.SimpleText('◎  Level ' .. level, 'VoxRef.Small', rowX, rowY, C.text, 0, 0)
        draw.SimpleText(string.Comma(xp) .. '/' .. string.Comma(maxXP) .. ' XP', 'VoxRef.Tiny', rowX + rowW, rowY + 1 * scale, C.soft, 2, 0)
        bar(rowX + 96 * scale, rowY + 20 * scale, rowW - 116 * scale, 8 * scale, smooth.xp, C.blue)
    end

    drawBottomIcons(rowX, y + math.floor(256 * scale), rowW, scale, client)
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

hud:RegisterHUDPreset('tactical_card', { name = 'Reference Card', style = 0, drawFn = drawReferenceMain })
hud:RegisterElement('notifications', { priority = 90, drawFn = drawRefNotifications, hideElements = {} })
-- Weapon selector is provided by lua/vox/modules/hud/elements/cl_weapon_selector.lua.
-- Avoid registering a second bottom-center selector for this preset.
