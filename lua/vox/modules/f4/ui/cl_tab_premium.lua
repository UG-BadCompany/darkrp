local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_ACCENT = vox:Config('colors.accent')
local COLOR_TEXT = Color(238, 244, 255)
local COLOR_MUTED = Color(145, 160, 178)

local function getThemeColors()
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
    vox.DrawVoxPanel(0, 0, w, h, { primary = colors.secondary, secondary = colors.tertiary, accent = colors.accent }, 9)
    draw.RoundedBox(9, 1, 1, w - 2, h - 2, ColorAlpha(colors.primary, 82))
    vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(colors.accent, hovered and 18 or 7))

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
        vox.DrawVoxPanel(0, 0, w, h, { primary = ColorAlpha(colors.primary, 245), secondary = colors.secondary, accent = colors.accent }, 12)
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
    { id = 'jobs', label = 'Job' },
    { id = 'shipments', label = 'Shipment' },
    { id = 'entities', label = 'Entities' }
}

local REFRESH_DELAYS = { .2, .75, 1.5 }
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
        entities = {}
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
        vox.DrawVoxPanel(0, 0, w, h, { primary = colors.secondary, secondary = colors.tertiary, accent = colors.accent }, 9)
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

    vox.DrawVoxPanel(0, 0, w, h, { primary = colors.secondary, secondary = colors.tertiary, accent = colors.accent }, 9)
    draw.RoundedBox(9, 1, 1, w - 2, h - 2, ColorAlpha(colors.primary, 82))
    vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(data.disabled and colors.muted or colors.accent, hovered and 18 or 7))

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
            price = unlocked and nil or money(info.price or 0),
            affordable = info.canAfford ~= false,
            action = unlocked and 'UNLOCKED' or 'BUY',
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
            if (data.pendingKey) then markPending(panel.ownerPanel, data.pendingKey) end
            if (data.onClick) then data.onClick() end
            panel.ownerPanel:RefreshSoon()
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

local UP = {}
function UP:Init()
    timer.Remove('vox_f4_zupgrades_refresh')

    self:DockPadding(vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14), vox.ScaleTall(14))
    self.pendingUntil = {}
    self.activeUpgradeTab = 'props'
    self.zupgradesHook = 'vox.f4.zupgrades.updated.' .. tostring(self)

    buildHeader(self, 'ZUpgrades', 'Buy prop, job, shipment, and entity upgrades from the server upgrade system.')

    self.tabBar = self:Add('Panel')
    self.tabBar:Dock(TOP)
    self.tabBar:SetTall(vox.ScaleTall(42))
    self.tabBar:DockMargin(0, 0, 0, vox.ScaleTall(10))

    self.content = self:Add('Panel')
    self.content:Dock(FILL)

    self.tabButtons = {}
    for _, tab in ipairs(UPGRADE_TABS) do
        local button = self.tabBar:Add('DButton')
        button:Dock(LEFT)
        button:DockMargin(0, 0, vox.ScaleWide(8), 0)
        button:SetWide(vox.ScaleWide(tab.id == 'shipments' and 122 or 96))
        button:SetText('')
        button.tabId = tab.id
        button.Paint = function(panel, w, h)
            local colors = getThemeColors()
            local active = self.activeUpgradeTab == panel.tabId
            local bg = active and ColorAlpha(colors.accent, 46) or ColorAlpha(colors.tertiary, panel:IsHovered() and 210 or 165)
            draw.RoundedBox(8, 0, 0, w, h, bg)
            surface.SetDrawColor(ColorAlpha(active and colors.accent or colors.secondary, active and 150 or 90))
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(tab.label, vox.Font('Comfortaa Bold@13'), w * .5, h * .5, active and colors.text or colors.muted, 1, 1)
        end
        button.DoClick = function()
            self:SelectUpgradeTab(tab.id)
        end

        self.tabButtons[tab.id] = button
    end

    self:SelectUpgradeTab('props', true)
    requestZUpgrades()

    hook.Add('vox.f4.zupgrades.updated', self.zupgradesHook, function()
        if (not IsValid(self)) then
            hook.Remove('vox.f4.zupgrades.updated', self.zupgradesHook)
            return
        end

        self:BuildActiveUpgradeTab()
    end)

    timer.Create('vox_f4_zupgrades_refresh', 1, 0, function()
        if (not IsValid(self)) then
            timer.Remove('vox_f4_zupgrades_refresh')
            return
        end

        requestZUpgrades()
    end)
end

function UP:OnRemove()
    timer.Remove('vox_f4_zupgrades_refresh')
    if (self.zupgradesHook) then
        hook.Remove('vox.f4.zupgrades.updated', self.zupgradesHook)
    end
end

function UP:RefreshSoon()
    self:BuildActiveUpgradeTab()
    requestZUpgrades()

    for _, delay in ipairs(REFRESH_DELAYS) do
        timer.Simple(delay, function()
            if (IsValid(self)) then
                requestZUpgrades()
            end
        end)
    end
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
        addMessage(self.content, 'Loading ZUpgrades', 'Fetching upgrade data from the server.')
        requestZUpgrades()
        return
    end

    if (#zupgradeRows == 0) then
        addMessage(self.content, 'ZUpgrades Not Loaded', 'Install and enable ZUpgrades to use this F4 upgrade tab.')
        return
    end

    if (self.activeUpgradeTab == 'props') then
        self:BuildPropsTab(zupgradeByCategory.props or {})
    elseif (self.activeUpgradeTab == 'jobs') then
        self:BuildUnlockTab('jobs')
    elseif (self.activeUpgradeTab == 'shipments') then
        self:BuildUnlockTab('shipments')
    elseif (self.activeUpgradeTab == 'entities') then
        self:BuildUnlockTab('entities')
    end
end

function UP:BuildPropsTab(rows)
    local info = rows and rows[1]

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

    addUpgradeRows(self.content, {
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
        addMessage(self.content, 'Upgrades Unavailable', 'ZUpgrades did not expose data for this upgrade type on the server.')
        return
    end

    addUpgradeRows(self.content, collectUnlockRows(status, sectionId, self))
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
