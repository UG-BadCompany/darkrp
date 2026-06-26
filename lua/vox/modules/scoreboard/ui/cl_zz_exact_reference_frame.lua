-- Vox UI exact reference scoreboard remake
surface.CreateFont('VoxScore.Title', {font='Comfortaa', size=18, weight=900, extended=true})
surface.CreateFont('VoxScore.Text', {font='Comfortaa', size=14, weight=700, extended=true})
surface.CreateFont('VoxScore.Small', {font='Comfortaa', size=12, weight=700, extended=true})
surface.CreateFont('VoxScore.Tiny', {font='Comfortaa', size=10, weight=700, extended=true})

local FALLBACK = {
    bg = Color(3, 11, 24, 248),
    panel = Color(6, 20, 40, 238),
    card = Color(8, 27, 52, 232),
    row = Color(7, 24, 46, 218),
    accent = Color(0, 174, 255),
    green = Color(35, 225, 120),
    red = Color(255, 75, 95),
    amber = Color(255, 190, 65),
    text = Color(238, 246, 255),
    soft = Color(145, 172, 200)
}
local C = FALLBACK

local ICON = {
    players = Material('vox_scoreboard/player_list.png', 'smooth mips'),
    settings = Material('vox_scoreboard/settings_user.png', 'smooth mips'),
    ping = Material('vox_scoreboard/ping.png', 'smooth mips'),
    microphone = Material('vox_scoreboard/microphone.png', 'smooth mips'),
    microphoneMuted = Material('vox_scoreboard/microphone_muted.png', 'smooth mips'),
    ranks = Material('vox_scoreboard/ranks_user.png', 'smooth mips'),
    admin = Material('vox_scoreboard/settings_admin.png', 'smooth mips'),
    arrow = Material('vox_scoreboard/arrow_right.png', 'smooth mips')
}

local function palette()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    C = {
        bg = colors.primary or FALLBACK.bg,
        panel = colors.secondary or FALLBACK.panel,
        card = colors.tertiary or FALLBACK.card,
        row = colors.secondary or FALLBACK.row,
        accent = colors.accent or FALLBACK.accent,
        green = colors.money or colors.positive or FALLBACK.green,
        red = colors.negative or FALLBACK.red,
        amber = colors.warning or FALLBACK.amber,
        text = colors.textPrimary or colors.text or FALLBACK.text,
        soft = colors.textSecondary or colors.muted or FALLBACK.soft
    }
end

local function rr(x, y, w, h, r, col) draw.RoundedBox(r or 8, x, y, w, h, col) end
local function outline(x, y, w, h, col) surface.SetDrawColor(col or ColorAlpha(C.accent, 70)); surface.DrawOutlinedRect(x, y, w, h, 1) end
local function icon(mat, x, y, w, h, col) surface.SetMaterial(mat); surface.SetDrawColor(col or C.text); surface.DrawTexturedRect(x, y, w, h) end
local function money(v) return DarkRP and DarkRP.formatMoney and DarkRP.formatMoney(v or 0) or ('$' .. string.Comma(v or 0)) end
local function safeJob(ply) return IsValid(ply) and (ply:getDarkRPVar('job') or team.GetName(ply:Team()) or 'Citizen') or 'Citizen' end
local function teamColor(ply) return (IsValid(ply) and team.GetColor(ply:Team())) or C.accent end
local function level(ply) return (IsValid(ply) and ((ply.getDarkRPVar and ply:getDarkRPVar('level')) or (ply.GetLevel and ply:GetLevel()))) or 0 end

local function getCategory(ply)
    if not IsValid(ply) then return 'Other' end
    local job = string.lower(safeJob(ply))
    if ply:IsAdmin() then return 'Staff' end
    if ply.isCP and ply:isCP() then return 'Law Enforcement' end
    if job:find('medic', 1, true) or job:find('doctor', 1, true) then return 'Medical' end
    if job:find('gang', 1, true) or job:find('thief', 1, true) or job:find('mob', 1, true) then return 'Gangsters' end
    if job == 'citizen' then return 'Citizens' end
    return 'Other'
end

local function categoryCounts(players)
    local counts = { ['Citizens'] = 0, ['Law Enforcement'] = 0, ['Medical'] = 0, ['Staff'] = 0, ['Gangsters'] = 0, ['Other'] = 0 }
    for _, ply in ipairs(players) do
        local cat = getCategory(ply)
        counts[cat] = (counts[cat] or 0) + 1
    end
    return counts
end

local PANEL = {}

function PANEL:Init()
    vox.scoreboard.Frame = self
    self:SetTitle('')
    self:SetAlpha(0)
    self:AlphaTo(255, .12, 0)
    self.searchText = ''
    self.sortMode = 'name'

    self.sidebar = self:Add('Panel')
    self.content = self:Add('Panel')
    self.list = self.content:Add('DScrollPanel')
    self.search = self.content:Add('DTextEntry')
    self.sort = self.content:Add('DComboBox')
    self.settings = self.sidebar:Add('DButton')

    self.search:SetPlaceholderText('Search players...')
    self.search:SetUpdateOnType(true)
    self.search.OnValueChange = function(_, value)
        self.searchText = string.Trim(string.lower(value or ''))
        self:BuildRows()
    end

    self.sort:AddChoice('Sort by: Name', 'name')
    self.sort:AddChoice('Sort by: Job', 'job')
    self.sort:AddChoice('Sort by: Money', 'money')
    self.sort:AddChoice('Sort by: Ping', 'ping')
    self.sort:ChooseOptionID(1)
    self.sort.OnSelect = function(_, _, _, data)
        self.sortMode = data or 'name'
        self:BuildRows()
    end

    self.sidebar.Paint = function(_, w, h) self:PaintSidebar(w, h) end
    self.content.Paint = function(_, w, h) self:PaintContent(w, h) end
    self.search.Paint = function(panel, w, h)
        rr(0, 0, w, h, 6, ColorAlpha(C.bg, 225))
        outline(0, 0, w, h, ColorAlpha(C.accent, panel:IsEditing() and 120 or 55))
        panel:DrawTextEntryText(C.text, C.accent, C.text)
    end
    self.sort.Paint = function(_, w, h)
        rr(0, 0, w, h, 6, ColorAlpha(C.bg, 225))
        outline(0, 0, w, h, ColorAlpha(C.accent, 55))
        draw.SimpleText(self.sort:GetValue() ~= '' and self.sort:GetValue() or 'Sort by: Name', 'VoxScore.Tiny', 12, h * .5, C.text, 0, 1)
        draw.SimpleText('⌄', 'VoxScore.Small', w - 14, h * .5, C.soft, 1, 1)
    end

    self.settings:SetText('')
    self.settings.Paint = function(panel, w, h)
        rr(0, 0, w, h, 7, ColorAlpha(C.card, panel:IsHovered() and 235 or 205))
        outline(0, 0, w, h, ColorAlpha(C.accent, panel:IsHovered() and 110 or 50))
        icon(ICON.settings, 13, h * .5 - 7, 14, 14, C.text)
        draw.SimpleText('SETTINGS', 'VoxScore.Tiny', w * .5 + 8, h * .5, C.text, 1, 1)
    end
    self.settings.DoClick = function()
        if vox.scoreboard and vox.scoreboard.OpenAdminSettings then vox.scoreboard.OpenAdminSettings() end
    end

    self:BuildRows()
end

function PANEL:PerformLayout(w, h)
    local pad = 14
    self.sidebar:SetPos(pad, 44)
    self.sidebar:SetSize(190, h - 58)
    self.content:SetPos(220, 44)
    self.content:SetSize(w - 236, h - 58)

    self.search:SetPos(260, 14)
    self.search:SetSize(math.max(220, w - 590), 32)
    self.sort:SetPos(w - 185, 14)
    self.sort:SetSize(155, 32)

    self.list:SetPos(12, 86)
    local oldListW = self.list:GetWide()
    self.list:SetSize(self.content:GetWide() - 24, self.content:GetTall() - 98)
    if oldListW ~= self.list:GetWide() then self:BuildRows() end
    self.settings:SetPos(14, self.sidebar:GetTall() - 52)
    self.settings:SetSize(self.sidebar:GetWide() - 28, 36)
end

function PANEL:Paint(w, h)
    palette()
    rr(0, 0, w, h, 12, ColorAlpha(C.bg, 248))
    vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(C.accent, 16))
    outline(0, 0, w, h, ColorAlpha(C.accent, 125))
    draw.SimpleText('SCOREBOARD', 'VoxScore.Tiny', 16, 17, C.text, 0, 1)
end

function PANEL:PaintOver(w, h)
    local cx, cy = self.content:GetPos()
    local headerY = cy + 66
    draw.SimpleText('Player', 'VoxScore.Tiny', cx + 26, headerY, C.soft, 0, 1)
    draw.SimpleText('Job', 'VoxScore.Tiny', cx + self.content:GetWide() * .30, headerY, C.soft, 0, 1)
    draw.SimpleText('Rank', 'VoxScore.Tiny', cx + self.content:GetWide() * .45, headerY, C.soft, 0, 1)
    draw.SimpleText('Money', 'VoxScore.Tiny', cx + self.content:GetWide() * .59, headerY, C.soft, 0, 1)
    draw.SimpleText('Level', 'VoxScore.Tiny', cx + self.content:GetWide() * .72, headerY, C.soft, 0, 1)
    draw.SimpleText('Ping', 'VoxScore.Tiny', cx + self.content:GetWide() * .82, headerY, C.soft, 0, 1)
    draw.SimpleText('Voice', 'VoxScore.Tiny', cx + self.content:GetWide() * .92, headerY, C.soft, 0, 1)
end

function PANEL:PaintSidebar(w, h)
    local players = player.GetAll()
    local counts = categoryCounts(players)
    local cats = {
        { icon = '●', name = 'Citizens', count = counts.Citizens or 0 },
        { icon = '★', name = 'Law Enforcement', count = counts['Law Enforcement'] or 0 },
        { icon = '✚', name = 'Medical', count = counts.Medical or 0 },
        { icon = '♜', name = 'Staff', count = counts.Staff or 0 },
        { icon = '✦', name = 'Gangsters', count = counts.Gangsters or 0 },
        { icon = '◆', name = 'Other', count = counts.Other or 0 }
    }

    rr(0, 0, w, h, 10, ColorAlpha(C.panel, 230))
    vox.DrawMatGradient(0, 0, w, h * .35, BOTTOM, ColorAlpha(C.accent, 30))
    outline(0, 0, w, h, ColorAlpha(C.accent, 80))
    rr(0, 38, 4, 58, 2, C.accent)
    icon(ICON.players, 22, 46, 16, 16, C.text)

    local y = 88
    for _, cat in ipairs(cats) do
        draw.SimpleText(cat.icon, 'VoxScore.Small', 24, y, C.text, 1, 1)
        draw.SimpleText(cat.name, 'VoxScore.Tiny', 48, y, C.text, 0, 1)
        draw.SimpleText(cat.count, 'VoxScore.Tiny', w - 18, y, C.soft, 2, 1)
        y = y + 42
    end
end

function PANEL:PaintContent(w, h)
    rr(0, 0, w, h, 10, ColorAlpha(C.panel, 225))
    outline(0, 0, w, h, ColorAlpha(C.accent, 75))
    icon(ICON.ranks, 18, 18, 18, 18, C.text)
    draw.SimpleText('VOX SCOREBOARD', 'VoxScore.Text', 44, 27, C.text, 0, 1)
end

function PANEL:BuildRows()
    if not IsValid(self.list) then return end
    self.list:Clear()

    local players = player.GetAll()
    table.sort(players, function(a, b)
        if self.sortMode == 'job' then return safeJob(a) < safeJob(b) end
        if self.sortMode == 'money' then return (a:getDarkRPVar('money') or 0) > (b:getDarkRPVar('money') or 0) end
        if self.sortMode == 'ping' then return a:Ping() < b:Ping() end
        return a:Name() < b:Name()
    end)

    local y = 0
    for _, ply in ipairs(players) do
        if not IsValid(ply) then continue end
        local haystack = string.lower(ply:Name() .. ' ' .. safeJob(ply) .. ' ' .. ply:GetUserGroup())
        if self.searchText ~= '' and not haystack:find(self.searchText, 1, true) then continue end

        local row = self.list:Add('DButton')
        row:SetText('')
        row:SetPos(0, y)
        row:SetSize(self.list:GetWide() - 16, 42)
        row.Player = ply
        row.avatar = row:Add('AvatarImage')
        row.avatar:SetPlayer(ply, 64)
        row.avatar:SetPaintedManually(true)
        row.DoRightClick = function()
            if not IsValid(ply) then return end

            local m = vgui.Create('vox.Menu')
            m:SetMinimumWidth(vox.ScaleWide(150))
            local options = {
                {'View Profile', ICON.players, function() ply:ShowProfile() end},
                {'Message', ICON.arrow, function() RunConsoleCommand('say', '/pm ' .. ply:Nick() .. ' ') end},
                {'Add Friend', ICON.ranks, function() gui.OpenURL('steam://friends/add/' .. ply:SteamID64()) end},
                {'Report Player', Material('vox_scoreboard/death.png', 'smooth mips'), function() RunConsoleCommand('say', '@ Reporting ' .. ply:Nick() .. ': ') end},
                {'Mute', ICON.microphoneMuted, function() ply:SetMuted(not ply:IsMuted()) end},
                {'Kick Player', Material('vox_scoreboard/slay.png', 'smooth mips'), function()
                    vox.SimpleQuery('Kick Player', 'Are you sure you want to kick ' .. ply:Nick() .. ' from the server?', true, function(reason)
                        RunConsoleCommand('say', '!kick ' .. ply:SteamID() .. ' ' .. (reason ~= '' and reason or 'No reason provided'))
                    end, 'Kick Player', nil, 'Cancel')
                end}
            }
            for _, data in ipairs(options) do
                local opt = m:AddOption(data[1], data[3])
                opt:SetMaterial(data[2])
            end
            m:ToCursor()
            m:Open()
        end
        row.Paint = function(panel, rw, rh) self:PaintPlayerRow(panel, rw, rh) end
        y = y + 46
    end

    local canvas = self.list:GetCanvas()
    if IsValid(canvas) then canvas:SetTall(y) end
end

function PANEL:PaintPlayerRow(row, w, h)
    local ply = row.Player
    if not IsValid(ply) then return end

    local job = safeJob(ply)
    local jc = teamColor(ply)
    local hovered = row:IsHovered()
    local moneyText = money(ply:getDarkRPVar('money') or 0)
    local rankText = ply:GetUserGroup() or 'user'
    local levelText = tostring(level(ply) or 0)
    local ping = ply:Ping()
    local voiceOn = ply:IsSpeaking()

    rr(0, 0, w, h, 7, hovered and ColorAlpha(C.card, 245) or ColorAlpha(C.row, 220))
    outline(0, 0, w, h, hovered and ColorAlpha(C.accent, 110) or ColorAlpha(C.accent, 30))
    rr(0, 7, 3, h - 14, 2, jc)

    row.avatar:SetPos(14, 7)
    row.avatar:SetSize(28, 28)
    row.avatar:PaintManual()
    vox.DrawOutlinedCircle(28, 21, 15, 2, ColorAlpha(jc, 220))

    local nameX = 52
    draw.SimpleText(ply:Name(), 'VoxScore.Small', nameX, h * .5, C.text, 0, 1)
    draw.SimpleText(job, 'VoxScore.Tiny', w * .30, h * .5, jc, 0, 1)
    draw.SimpleText(rankText, 'VoxScore.Tiny', w * .45, h * .5, C.text, 0, 1)
    draw.SimpleText(moneyText, 'VoxScore.Tiny', w * .59, h * .5, C.text, 0, 1)
    draw.SimpleText(levelText, 'VoxScore.Tiny', w * .72, h * .5, C.text, 0, 1)
    draw.SimpleText('▂▃▅▇ ' .. ping, 'VoxScore.Tiny', w * .82, h * .5, ping > 100 and C.amber or C.green, 0, 1)
    icon(voiceOn and ICON.microphone or ICON.microphoneMuted, w * .93, h * .5 - 7, 14, 14, voiceOn and C.green or C.soft)
end

function PANEL:Think()
    if self.closeDisabled then
        local bind = input.LookupBinding('+showscores', true)
        local key = bind and input.GetKeyCode(bind)
        if key and not input.IsKeyDown(key) then self:Remove() end
    end
end


vox.gui.Register('vox.Scoreboard.Frame', PANEL, 'VoxRootFrame')
