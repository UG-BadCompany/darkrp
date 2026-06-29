local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_ACCENT = vox:Config('colors.accent')
local COLOR_TEXT = Color(238, 244, 255)
local COLOR_MUTED = Color(145, 160, 178)

local function getThemeColors()
    local ref = vox.f4 and vox.f4.GetReferenceColors and vox.f4.GetReferenceColors()
    if ref then
        return {
            bg = ref.bg,
            panel = ref.panel,
            card = ref.card,
            card2 = ref.card2,
            border = ref.border,
            primary = ref.bg,
            secondary = ref.card,
            tertiary = ref.card2,
            accent = ref.accent,
            money = ref.money,
            negative = ref.negative,
            warning = ref.warning,
            text = ref.text,
            muted = ref.muted
        }
    end

    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return {
        primary = colors.primary or COLOR_PRIMARY,
        secondary = colors.secondary or COLOR_SECONDARY,
        tertiary = colors.secondary or COLOR_SECONDARY,
        accent = colors.accent or Color(70, 135, 255),
        money = colors.money or Color(35, 225, 120),
        negative = colors.negative or Color(255, 75, 95),
        warning = Color(88, 166, 255),
        text = colors.textPrimary or COLOR_TEXT,
        muted = colors.textSecondary or COLOR_MUTED
    }
end

local function money(v)
    return DarkRP and DarkRP.formatMoney and DarkRP.formatMoney(v or 0) or tostring(v or 0)
end

local function paintCommandRow(panel, w, h, title, desc, state, action)
    local colors = getThemeColors()
    local hovered = panel:IsHovered()
    if vox.f4 and vox.f4.DrawReferenceRow then
        vox.f4.DrawReferenceRow(panel, 0, 0, w, h, { colors = colors, color = colors.secondary, accent = colors.accent, radius = 8 })
    else
        draw.RoundedBox(8, 0, 0, w, h, colors.secondary)
        surface.SetDrawColor(ColorAlpha(colors.accent, hovered and 100 or 58))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    draw.SimpleText(title, vox.Font('Comfortaa Bold@17'), vox.ScaleWide(28), vox.ScaleTall(14), colors.text, 0, 0)
    draw.SimpleText(desc, vox.Font('Comfortaa@13'), vox.ScaleWide(28), vox.ScaleTall(38), colors.muted, 0, 0)

    if state then
        local pillW = vox.ScaleWide(92)
        draw.RoundedBox(7, w - pillW - vox.ScaleWide(16), vox.ScaleTall(15), pillW, vox.ScaleTall(24), ColorAlpha(colors.accent, hovered and 42 or 26))
        draw.SimpleText(state, vox.Font('Comfortaa Bold@11'), w - pillW * .5 - vox.ScaleWide(16), vox.ScaleTall(27), colors.text, 1, 1)
    end

    if action then
        draw.SimpleText(action, vox.Font('Comfortaa Bold@11'), w - vox.ScaleWide(18), h - vox.ScaleTall(18), colors.accent, 2, 1)
    end
end

local function buildHeader(parent, title, subtitle)
    local header = parent:Add('Panel')
    header:Dock(TOP)
    header:SetTall(vox.ScaleTall(70))
    header:DockMargin(0, 0, 0, vox.ScaleTall(10))
    header.Paint = function(_, w, h)
        local colors = getThemeColors()
        if vox.f4 and vox.f4.DrawReferencePanel then
            vox.f4.DrawReferencePanel(0, 0, w, h, { colors = colors, color = ColorAlpha(colors.card or colors.secondary, 232), accent = colors.accent, radius = 8 })
        else
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(colors.primary, 245))
            surface.SetDrawColor(ColorAlpha(colors.accent, 80))
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        draw.SimpleText(title, vox.Font('Comfortaa Bold@24'), vox.ScaleWide(32), vox.ScaleTall(15), colors.text, 0, 0)
        draw.SimpleText(subtitle, vox.Font('Comfortaa@14'), vox.ScaleWide(34), vox.ScaleTall(43), colors.muted, 0, 0)
    end
end

local function addRowList(parent)
    local scroll = parent:Add('vox.ScrollPanel')
    scroll:Dock(FILL)
    local list = scroll:Add('DIconLayout')
    list:Dock(TOP)
    list:SetSpaceY(vox.ScaleTall(8))
    list:SetSpaceX(0)
    list.PerformLayout = function(panel, w)
        local y = 0
        for _, child in ipairs(panel:GetChildren()) do
            child:SetPos(0, y)
            child:SetWide(w)
            y = y + child:GetTall() + panel:GetSpaceY()
        end
        panel:SetTall(y)
    end
    return list
end

local function addRows(parent, rows, onClick)
    local list = addRowList(parent)
    for _, data in ipairs(rows) do
        local row = list:Add('DButton')
        row:SetText('')
        row:SetTall(vox.ScaleTall(72))
        row.Paint = function(panel, w, h) paintCommandRow(panel, w, h, data[1], data[2], data[3], data[4]) end
        row.DoClick = onClick or function() end
    end
end

local UPGRADE_TABS = {
    { id = 'props', label = 'Props' },
    { id = 'jobs', label = 'Jobs' },
    { id = 'shipments', label = 'Shipments' },
    { id = 'entities', label = 'Entities' },
    { id = 'bank', label = 'Bank' }
}

local SUBCATEGORY_ORDER = {
    props = {'Prop Limit'},
    jobs = {'Citizens', 'Dealers', 'Criminals', 'Government', 'Other'},
    shipments = {'Assault Rifles', 'Pistols', 'SMGs', 'Shotguns', 'Sniper Rifles', 'LMGs', 'Melee', 'Grenades', 'Explosives', 'Other'},
    entities = {'Printers', 'Drugs', 'Tools', 'Explosives', 'Other'},
    bank = {'Storage'}
}

local TAB_TITLES = {
    props = 'Props',
    jobs = 'Jobs',
    shipments = 'Shipments',
    entities = 'Entities',
    bank = 'Bank'
}

local PURCHASE_REFRESH_DELAY = .35
local zupgradeRows = {}
local zupgradeByCategory = {}
local zupgradeLoaded = false
local sortRows

local function rebuildZUpgradeCache(rows)
    zupgradeRows = istable(rows) and rows or {}
    zupgradeByCategory = {
        props = {},
        jobs = {},
        shipments = {},
        entities = {},
        bank = {}
    }

    for _, row in ipairs(zupgradeRows) do
        if (istable(row) and zupgradeByCategory[row.category]) then
            table.insert(zupgradeByCategory[row.category], row)
        end
    end

    for _, rowsByCategory in pairs(zupgradeByCategory) do
        sortRows(rowsByCategory)
    end
end

local function requestZUpgrades()
    net.Start('vox.f4.zupgrades.request')
    net.SendToServer()
end

local function addMessage(parent, title, body)
    local pnl = parent:Add('DPanel')
    pnl:Dock(TOP)
    pnl:SetTall(vox.ScaleTall(92))
    pnl:DockMargin(0, 0, 0, vox.ScaleTall(8))
    pnl.Paint = function(_, w, h)
        local colors = getThemeColors()
        if vox.f4 and vox.f4.DrawReferencePanel then
            vox.f4.DrawReferencePanel(0, 0, w, h, { colors = colors, color = colors.secondary, accent = colors.accent, radius = 8 })
        else
            draw.RoundedBox(8, 0, 0, w, h, colors.secondary)
            surface.SetDrawColor(ColorAlpha(colors.accent, 58))
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        draw.SimpleText(title, vox.Font('Comfortaa Bold@17'), vox.ScaleWide(30), vox.ScaleTall(20), colors.text, 0, 0)
        draw.SimpleText(body, vox.Font('Comfortaa@13'), vox.ScaleWide(30), vox.ScaleTall(48), colors.muted, 0, 0)
    end
end

local function getPending(panel, key)
    return panel.pendingUntil and (panel.pendingUntil[key] or 0) > CurTime()
end

local function markPending(panel, key)
    panel.pendingUntil = panel.pendingUntil or {}
    panel.pendingUntil[key] = CurTime() + 1
end

local function paintUpgradeRow(panel, w, h, data)
    local colors = getThemeColors()
    local hovered = panel:IsHovered() and not data.disabled
    local rightPad = vox.ScaleWide(16)
    local actionW = vox.ScaleWide(118)
    local priceW = vox.ScaleWide(108)
    local actionX = w - rightPad - actionW
    local priceX = actionX - priceW - vox.ScaleWide(10)
    local textRight = priceX - vox.ScaleWide(14)
    local actionText = data.pending and 'PROCESSING' or data.action
    local actionBg = data.disabled and ColorAlpha(colors.muted, 24) or ColorAlpha(colors.accent, hovered and 70 or 42)
    local actionColor = data.disabled and colors.muted or colors.text

    if vox.f4 and vox.f4.DrawReferenceRow then
        vox.f4.DrawReferenceRow(panel, 0, 0, w, h, { colors = colors, color = colors.secondary, accent = data.disabled and colors.muted or colors.accent, radius = 8 })
    else
        draw.RoundedBox(8, 0, 0, w, h, colors.secondary)
        surface.SetDrawColor(ColorAlpha(data.disabled and colors.muted or colors.accent, hovered and 100 or 58))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    draw.SimpleText(data.title, vox.Font('Comfortaa Bold@17'), vox.ScaleWide(28), vox.ScaleTall(13), colors.text, 0, 0)
    draw.SimpleText(data.desc or '', vox.Font('Comfortaa@13'), vox.ScaleWide(28), vox.ScaleTall(38), colors.muted, 0, 0)

    if (data.detail) then
        draw.SimpleText(data.detail, vox.Font('Comfortaa@12'), math.max(vox.ScaleWide(28), textRight), vox.ScaleTall(38), colors.muted, 2, 0)
    end

    if (data.price) then
        local priceColor = data.affordable == false and colors.negative or colors.money
        draw.RoundedBox(7, priceX, vox.ScaleTall(16), priceW, vox.ScaleTall(26), ColorAlpha(priceColor, 24))
        draw.SimpleText(data.price, vox.Font('Comfortaa Bold@12'), priceX + priceW * .5, vox.ScaleTall(29), priceColor, 1, 1)
    end

    draw.RoundedBox(7, actionX, vox.ScaleTall(16), actionW, vox.ScaleTall(26), actionBg)
    surface.SetDrawColor(ColorAlpha(data.disabled and colors.muted or colors.accent, data.disabled and 50 or 110))
    surface.DrawOutlinedRect(actionX, vox.ScaleTall(16), actionW, vox.ScaleTall(26), 1)
    draw.SimpleText(actionText, vox.Font('Comfortaa Bold@11'), actionX + actionW * .5, vox.ScaleTall(29), actionColor, 1, 1)
end

function sortRows(rows)
    table.sort(rows, function(a, b)
        return string.lower(a.title or a.name or '') < string.lower(b.title or b.name or '')
    end)
end

local function purchaseUpgrade(category, key)
    net.Start('vox.f4.zupgrades.purchase')
    net.WriteString(category or '')
    net.WriteString(key or '')
    net.SendToServer()
end

local function collectUnlockRows(statusRows, sectionId, pendingOwner)
    local rows = {}

    for _, info in ipairs(statusRows or {}) do
        local key = tostring(info.key or info.id or '')
        local pendingKey = sectionId .. ':' .. tostring(key)
        local unlocked = info.unlocked == true

        rows[#rows + 1] = {
            key = key,
            pendingKey = pendingKey,
            title = info.name or tostring(key),
            desc = info.description or '',
            subcategory = info.subcategory,
            price = unlocked and nil or money(info.price or 0),
            affordable = info.canAfford ~= false,
            action = unlocked and 'UNLOCKED' or 'UNLOCK',
            disabled = unlocked,
            pending = getPending(pendingOwner, pendingKey),
            onClick = function()
                purchaseUpgrade(info.category or sectionId, key)
            end
        }
    end

    sortRows(rows)
    return rows
end

local function inferShipmentSubcategory(name)
    local lower = string.lower(tostring(name or ''))

    if lower:find('pistol', 1, true) or lower:find('m9', 1, true) or lower:find('glock', 1, true) or lower:find('m45', 1, true) or lower:find('50ds', 1, true) then return 'Pistols' end
    if lower:find('smg', 1, true) or lower:find('mp5', 1, true) or lower:find('mp7', 1, true) or lower:find('mp9', 1, true) or lower:find('mpx', 1, true) or lower:find('ump', 1, true) or lower:find('uzi', 1, true) or lower:find('vector', 1, true) then return 'SMGs' end
    if lower:find('shotgun', 1, true) or lower:find('saiga%-12') or lower:find('aa%-12') or lower:find('m870', 1, true) or lower:find('590a1', 1, true) then return 'Shotguns' end
    if lower:find('sniper', 1, true) or lower:find('mosin', 1, true) or lower:find('sv%-98') or lower:find('m700', 1, true) or lower:find('rsass', 1, true) then return 'Sniper Rifles' end
    if lower:find('lmg', 1, true) or lower:find('m60', 1, true) or lower:find('pkm', 1, true) or lower:find('rpk', 1, true) or lower:find('rpd', 1, true) then return 'LMGs' end
    if lower:find('knife', 1, true) or lower:find('bayonet', 1, true) or lower:find('crowbar', 1, true) or lower:find('melee', 1, true) then return 'Melee' end
    if lower:find('grenade', 1, true) or lower:find('smoke', 1, true) or lower:find('flash', 1, true) or lower:find('vog', 1, true) then return 'Grenades' end
    if lower:find('explosive', 1, true) or lower:find('bomb', 1, true) or lower:find('rshg', 1, true) then return 'Explosives' end
    if lower:find('ak', 1, true) or lower:find('ar%-') or lower:find('m4', 1, true) or lower:find('m16', 1, true) or lower:find('rifle', 1, true) or lower:find('scar', 1, true) or lower:find('aug', 1, true) then return 'Assault Rifles' end

    return 'Other'
end

local function getRowSubcategory(row, sectionId)
    local subcategory = tostring(row.subcategory or '')
    if subcategory ~= '' then return subcategory end

    local name = row.name or row.title or row.key
    if sectionId == 'props' then return 'Prop Limit' end
    if sectionId == 'shipments' then return inferShipmentSubcategory(name) end
    if sectionId == 'bank' then return 'Storage' end

    return 'Other'
end

local function getOrderedSubcategories(sectionId, grouped)
    local order = {}
    local seen = {}

    for _, label in ipairs(SUBCATEGORY_ORDER[sectionId] or {}) do
        if grouped[label] and #grouped[label] > 0 then
            order[#order + 1] = label
            seen[label] = true
        end
    end

    local extra = {}
    for label, rows in pairs(grouped) do
        if not seen[label] and #rows > 0 then
            extra[#extra + 1] = label
        end
    end
    table.sort(extra)

    for _, label in ipairs(extra) do
        order[#order + 1] = label
    end

    return order
end

local function groupUpgradeRows(sectionId, rows)
    local grouped = {}

    for _, row in ipairs(rows or {}) do
        local label = getRowSubcategory(row, sectionId)
        grouped[label] = grouped[label] or {}
        grouped[label][#grouped[label] + 1] = row
    end

    for _, groupRows in pairs(grouped) do
        sortRows(groupRows)
    end

    return grouped, getOrderedSubcategories(sectionId, grouped)
end

local function rowMatchesSearch(row, search)
    search = tostring(search or ''):Trim():lower()
    if search == '' then return true end

    local haystack = table.concat({
        tostring(row.title or ''),
        tostring(row.name or ''),
        tostring(row.desc or ''),
        tostring(row.description or ''),
        tostring(row.key or '')
    }, ' '):lower()

    return haystack:find(search, 1, true) ~= nil
end

net.Receive('vox.f4.zupgrades.sync', function()
    rebuildZUpgradeCache(util.JSONToTable(net.ReadString()) or {})
    zupgradeLoaded = true
    hook.Run('vox.f4.zupgrades.updated')
end)

local function addUpgradeRows(panel, rows)
    local list = addRowList(panel)

    if (#rows == 0) then
        addMessage(list, 'No Upgrades Found', 'ZUpgrades has no items configured for this tab.')
        return
    end

    for _, data in ipairs(rows) do
        local row = list:Add('DButton')
        row:SetText('')
        row:SetTall(vox.ScaleTall(74))
        row.data = data
        row.Paint = function(button, w, h)
            paintUpgradeRow(button, w, h, button.data)
        end
        row.DoClick = function()
            if (data.disabled or data.pending) then return end
            local owner = panel.ownerPanel
            if (not IsValid(owner)) then return end

            if (data.pendingKey) then markPending(owner, data.pendingKey) end
            if (data.onClick) then data.onClick() end
            owner:RefreshSoon()
        end
    end
end

local INV = {}
function INV:Init()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Inventory', 'Compact command inventory with readable status rows and quick actions.')
    addRows(self, {
        {'Pocket Cash', money(LocalPlayer():getDarkRPVar('money') or 0), 'WALLET', 'DARKRP'},
        {'Weapon License', LocalPlayer():getDarkRPVar('HasGunlicense') and 'Active permit' or 'No permit', 'PERMIT', 'DETAILS'},
        {'Identity Card', team.GetName(LocalPlayer():Team()), 'ROLE', 'VIEW'},
        {'Shipment Slot', 'Server inventory hook ready', 'LOCKED', 'COMING SOON'},
        {'Evidence Pouch', 'DarkRP pocket compatible', 'READY', 'OPEN'},
        {'Quick Actions', 'Use dashboard actions for commands', 'TOOLS', 'RUN'}
    })
end
vox.gui.Register('vox.f4.Inventory', INV)

local function paintUpgradeRailButton(panel, w, h, label, active, count)
    local colors = getThemeColors()
    local hovered = panel:IsHovered()
    local bg = active and ColorAlpha(colors.accent, 54) or ColorAlpha(colors.secondary, hovered and 190 or 120)

    draw.RoundedBox(7, 0, 0, w, h, bg)
    if active then
        draw.RoundedBox(3, 0, 0, vox.ScaleWide(4), h, ColorAlpha(colors.accent, 245))
    end

    surface.SetDrawColor(ColorAlpha(active and colors.accent or colors.secondary, active and 125 or 55))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    draw.SimpleText(label, vox.Font('Comfortaa Bold@12'), vox.ScaleWide(12), h * .5, active and colors.text or colors.muted, 0, 1)

    if count and count > 0 then
        draw.SimpleText(tostring(count), vox.Font('Comfortaa Bold@10'), w - vox.ScaleWide(10), h * .5, colors.muted, 2, 1)
    end
end

local UP = {}
function UP:Init()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    self.pendingUntil = {}
    self.activeUpgradeTab = self.activeUpgradeTab or 'props'
    self.activeSubCategory = self.activeSubCategory or {}
    self.searchByTab = self.searchByTab or {}
    self.zupgradesHook = 'vox.f4.zupgrades.updated.' .. tostring(self)

    buildHeader(self, 'ZUpgrades', 'Buy prop, job, shipment, entity, and bank upgrades from the server upgrade system.')

    self.body = self:Add('Panel')
    self.body:Dock(FILL)

    self.mainRail = self.body:Add('Panel')
    self.mainRail:Dock(LEFT)
    self.mainRail:SetWide(vox.ScaleWide(146))
    self.mainRail:DockMargin(0, 0, vox.ScaleWide(10), 0)
    self.mainRail.Paint = function(_, w, h)
        local colors = getThemeColors()
        if vox.f4 and vox.f4.DrawReferencePanel then
            vox.f4.DrawReferencePanel(0, 0, w, h, { colors = colors, color = ColorAlpha(colors.bg, 220), accent = colors.accent, radius = 8 })
        else
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(colors.primary, 225))
        end
        draw.SimpleText('MENU', vox.Font('Comfortaa@11'), vox.ScaleWide(12), vox.ScaleTall(13), colors.muted, 0, 0)
    end

    self.subRail = self.body:Add('Panel')
    self.subRail:Dock(LEFT)
    self.subRail:SetWide(vox.ScaleWide(154))
    self.subRail:DockMargin(0, 0, vox.ScaleWide(12), 0)
    self.subRail.Paint = function(_, w, h)
        local colors = getThemeColors()
        if vox.f4 and vox.f4.DrawReferencePanel then
            vox.f4.DrawReferencePanel(0, 0, w, h, { colors = colors, color = ColorAlpha(colors.bg, 205), accent = colors.accent, radius = 8 })
        else
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(colors.primary, 205))
        end
        draw.SimpleText('CATEGORIES', vox.Font('Comfortaa@11'), vox.ScaleWide(12), vox.ScaleTall(13), colors.muted, 0, 0)
    end

    self.content = self.body:Add('Panel')
    self.content:Dock(FILL)
    self.content.ownerPanel = self

    self:BuildMainRail()
    self:SelectUpgradeTab(self.activeUpgradeTab, true)

    if zupgradeLoaded then requestZUpgrades() end

    hook.Add('vox.f4.zupgrades.updated', self.zupgradesHook, function()
        if (not IsValid(self)) then
            hook.Remove('vox.f4.zupgrades.updated', self.zupgradesHook)
            return
        end

        self:BuildActiveUpgradeTab()
    end)
end

function UP:OnRemove()
    if (self.zupgradesHook) then
        hook.Remove('vox.f4.zupgrades.updated', self.zupgradesHook)
    end
end

function UP:BuildMainRail()
    self.mainRail:Clear()
    self.mainButtons = {}

    local spacer = self.mainRail:Add('Panel')
    spacer:Dock(TOP)
    spacer:SetTall(vox.ScaleTall(34))

    for _, tab in ipairs(UPGRADE_TABS) do
        local button = self.mainRail:Add('DButton')
        button:Dock(TOP)
        button:DockMargin(vox.ScaleWide(8), 0, vox.ScaleWide(8), vox.ScaleTall(8))
        button:SetTall(vox.ScaleTall(36))
        button:SetText('')
        button.tabId = tab.id
        button.Paint = function(panel, w, h)
            local count = #(zupgradeByCategory[panel.tabId] or {})
            paintUpgradeRailButton(panel, w, h, tab.label, self.activeUpgradeTab == panel.tabId, count)
        end
        button.DoClick = function()
            self:SelectUpgradeTab(tab.id)
        end

        self.mainButtons[tab.id] = button
    end
end

function UP:BuildSubRail(order)
    self.subRail:Clear()

    local spacer = self.subRail:Add('Panel')
    spacer:Dock(TOP)
    spacer:SetTall(vox.ScaleTall(34))

    if not order or #order == 0 then
        local empty = self.subRail:Add('Panel')
        empty:Dock(TOP)
        empty:SetTall(vox.ScaleTall(42))
        empty.Paint = function(_, w, h)
            local colors = getThemeColors()
            draw.SimpleText('No categories', vox.Font('Comfortaa@12'), vox.ScaleWide(12), h * .5, colors.muted, 0, 1)
        end
        return
    end

    for _, label in ipairs(order) do
        local button = self.subRail:Add('DButton')
        button:Dock(TOP)
        button:DockMargin(vox.ScaleWide(8), 0, vox.ScaleWide(8), vox.ScaleTall(7))
        button:SetTall(vox.ScaleTall(32))
        button:SetText('')
        button.subcategory = label
        button.Paint = function(panel, w, h)
            paintUpgradeRailButton(panel, w, h, label, self.activeSubCategory[self.activeUpgradeTab] == panel.subcategory)
        end
        button.DoClick = function()
            self.activeSubCategory[self.activeUpgradeTab] = label
            self:BuildActiveUpgradeTab()
        end
    end
end

function UP:RefreshSoon()
    self:BuildActiveUpgradeTab()

    timer.Simple(PURCHASE_REFRESH_DELAY, function()
        if (IsValid(self)) then
            requestZUpgrades()
        end
    end)
end

function UP:SelectUpgradeTab(tabId, force)
    if (self.activeUpgradeTab == tabId and not force) then return end

    self.activeUpgradeTab = tabId
    self:BuildActiveUpgradeTab()
end

function UP:BuildActiveUpgradeTab()
    if (not IsValid(self.content)) then return end

    self.content:Clear()
    self.content.ownerPanel = self

    if (not zupgradeLoaded) then
        self:BuildSubRail({})
        addMessage(self.content, 'Loading ZUpgrades', 'Fetching upgrade data from the server.')
        requestZUpgrades()
        return
    end

    if (#zupgradeRows == 0) then
        self:BuildSubRail({})
        addMessage(self.content, 'ZUpgrades Not Loaded', 'Install and enable ZUpgrades to use this F4 upgrade tab.')
        return
    end

    if (self.activeUpgradeTab == 'props') then
        self:BuildPropsTab(zupgradeByCategory.props or {})
    else
        self:BuildUnlockTab(self.activeUpgradeTab)
    end
end

function UP:BuildUpgradeListView(title, rows)
    rows = rows or {}
    self.currentRows = rows

    local heading = self.content:Add('Panel')
    heading:Dock(TOP)
    heading:SetTall(vox.ScaleTall(46))
    heading:DockMargin(0, 0, 0, vox.ScaleTall(8))
    heading.Paint = function(_, w, h)
        local colors = getThemeColors()
        draw.SimpleText(title or TAB_TITLES[self.activeUpgradeTab] or 'Upgrades', vox.Font('Comfortaa Bold@24'), 0, vox.ScaleTall(2), colors.text, 0, 0)
        draw.SimpleText(#rows .. ' upgrades', vox.Font('Comfortaa@12'), 0, vox.ScaleTall(31), colors.muted, 0, 0)
    end

    self.searchEntry = self.content:Add('vox.TextEntry')
    self.searchEntry:Dock(TOP)
    self.searchEntry:SetTall(vox.ScaleTall(30))
    self.searchEntry:DockMargin(0, 0, 0, vox.ScaleTall(10))
    self.searchEntry:SetPlaceholderText('Search ' .. tostring(title or 'upgrades') .. '...')
    self.searchEntry:SetValue(self.searchByTab[self.activeUpgradeTab] or '')
    self.searchEntry.OnValueChange = function(_, value)
        self.searchByTab[self.activeUpgradeTab] = tostring(value or '')
        self:RefreshVisibleRows()
    end

    self.rowHost = self.content:Add('Panel')
    self.rowHost:Dock(FILL)
    self.rowHost.ownerPanel = self

    self:RefreshVisibleRows()
end

function UP:RefreshVisibleRows()
    if not IsValid(self.rowHost) then return end

    self.rowHost:Clear()
    self.rowHost.ownerPanel = self

    local search = self.searchByTab[self.activeUpgradeTab] or ''
    local filtered = {}
    for _, row in ipairs(self.currentRows or {}) do
        if rowMatchesSearch(row, search) then
            filtered[#filtered + 1] = row
        end
    end

    if #filtered == 0 then
        addMessage(self.rowHost, 'No Matches', 'No upgrades match the current search in this category.')
        return
    end

    addUpgradeRows(self.rowHost, filtered)
end

function UP:BuildPropsTab(rows)
    local info = rows and rows[1]
    self.activeSubCategory.props = self.activeSubCategory.props or 'Prop Limit'
    self:BuildSubRail({'Prop Limit'})

    if (not info) then
        addMessage(self.content, 'Props Unavailable', 'ZUpgrades did not expose prop upgrade data on the server.')
        return
    end

    local pendingKey = 'props:level'
    local maxed = info.maxed == true
    local level = tonumber(info.level) or 0
    local maxLevel = tonumber(info.maxLevel) or 0
    local currentLimit = tonumber(info.limit) or 0
    local maxLimit = tonumber(info.maxLimit) or 0
    local nextCost = tonumber(info.nextCost) or 0
    local canAfford = info.canAfford ~= false
    local perUpgrade = tonumber(info.propLimitPerUpgrade) or 0

    self:BuildUpgradeListView('Prop Limit', {
        {
            pendingKey = pendingKey,
            title = 'Prop Limit',
            desc = 'Current limit: ' .. currentLimit .. ' props. Level ' .. level .. ' of ' .. maxLevel .. '.',
            detail = maxed and ('Max limit: ' .. maxLimit) or ('Next limit: ' .. (currentLimit + perUpgrade)),
            price = maxed and nil or money(nextCost),
            affordable = canAfford,
            action = maxed and 'MAXED' or 'UPGRADE',
            disabled = maxed,
            pending = getPending(self, pendingKey),
            onClick = function()
                purchaseUpgrade('props', info.key or info.id or 'prop_limit')
            end
        }
    })
end

function UP:BuildUnlockTab(sectionId)
    local status = zupgradeByCategory[sectionId] or {}

    if (#status == 0) then
        self:BuildSubRail({})
        addMessage(self.content, 'Upgrades Unavailable', 'ZUpgrades did not expose data for this upgrade type on the server.')
        return
    end

    local grouped, order = groupUpgradeRows(sectionId, status)
    local selected = self.activeSubCategory[sectionId]
    if not selected or not grouped[selected] or #grouped[selected] == 0 then
        selected = order[1]
        self.activeSubCategory[sectionId] = selected
    end

    self:BuildSubRail(order)
    self:BuildUpgradeListView(selected or TAB_TITLES[sectionId] or 'Upgrades', collectUnlockRows(grouped[selected] or {}, sectionId, self))
end
vox.gui.Register('vox.f4.Upgrades', UP)

local SET = {}
function SET:Init()
    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    buildHeader(self, 'Vox Settings', 'Live F4 configuration using the same settings controls as the admin menu.')

    local config = self:Add('vox.Configuration')
    config:Dock(FILL)
    config:LoadAddonSettings('f4')
    config:OpenCategories()

    local hudButton = self:Add('DButton')
    hudButton:Dock(BOTTOM)
    hudButton:DockMargin(0, vox.ScaleTall(10), 0, 0)
    hudButton:SetTall(vox.ScaleTall(34))
    hudButton:SetText('')
    hudButton.Paint = function(panel, w, h)
        local colors = getThemeColors()
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(colors.accent, panel:IsHovered() and 58 or 34))
        surface.SetDrawColor(ColorAlpha(colors.accent, 130))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText('OPEN FULL HUD SETTINGS', vox.Font('Comfortaa Bold@12'), w * .5, h * .5, colors.text, 1, 1)
    end
    hudButton.DoClick = function()
        if vox.hud and vox.hud.OpenSettings then
            vox.hud.OpenSettings()
        end
    end
end
vox.gui.Register('vox.f4.Settings', SET)
