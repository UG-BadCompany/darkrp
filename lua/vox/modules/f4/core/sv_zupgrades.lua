util.AddNetworkString('vox.f4.zupgrades.request')
util.AddNetworkString('vox.f4.zupgrades.purchase')
util.AddNetworkString('vox.f4.zupgrades.sync')

local API_NAMES = {'ZUpgrades', 'zUpgrades', 'zupgrades', 'ZUPGRADES', 'ZUpgrade', 'zUpgrade', 'zupgrade', 'ZUPGRADE', 'ZUpgradesAPI', 'zUpgradesAPI'}

local function isZUpgradesTable(name, tbl)
    if not istable(tbl) then return false end

    local lowerName = isstring(name) and string.lower(name) or ''
    if string.find(lowerName, 'zupgrade', 1, true) or string.find(lowerName, 'z_upgrade', 1, true) then return true end

    return istable(tbl.Upgrades) or istable(tbl.upgrades) or isfunction(tbl.GetUpgrades)
end

local function addAPI(apis, seen, api)
    if not istable(api) or seen[api] then return end

    seen[api] = true
    table.insert(apis, api)
end

local function getZUpgradesAPIs()
    local apis = {}
    local seen = {}

    for _, name in ipairs(API_NAMES) do
        addAPI(apis, seen, _G[name])
    end

    for name, value in pairs(_G) do
        if isZUpgradesTable(name, value) then
            addAPI(apis, seen, value)
        end
    end

    return apis
end

local function getUpgradeValue(upgrade, keys, fallback)
    if not istable(upgrade) then return fallback end

    for _, key in ipairs(keys) do
        local value = upgrade[key]
        if value ~= nil and not isfunction(value) then return value end
    end

    return fallback
end

local SOURCE_KEYS = {'Upgrades', 'upgrades', 'RegisteredUpgrades', 'registeredUpgrades', 'Items', 'items', 'Shop', 'shop'}
local SOURCE_FUNCTIONS = {'GetUpgrades', 'GetUpgradeList', 'GetRegisteredUpgrades', 'GetItems'}

local function getUpgradeSource(api)
    if not api then return {} end

    for _, fnName in ipairs(SOURCE_FUNCTIONS) do
        local fn = api[fnName]
        if isfunction(fn) then
            local ok, result = pcall(fn, api)
            if ok and istable(result) then return result end
        end
    end

    for _, key in ipairs(SOURCE_KEYS) do
        if istable(api[key]) then return api[key] end
    end

    if istable(api.Config) then
        for _, key in ipairs(SOURCE_KEYS) do
            if istable(api.Config[key]) then return api.Config[key] end
        end
    end

    if istable(api.Categories) then return api.Categories end
    if istable(api.Config) and istable(api.Config.Categories) then return api.Config.Categories end

    return {}
end

local function collectZUpgrades()
    local apis = getZUpgradesAPIs()
    local upgrades = {}

    local function addUpgrade(key, upgrade)
        if not istable(upgrade) then return end

        local id = getUpgradeValue(upgrade, {'id', 'ID', 'uniqueID', 'uniqueId', 'uid', 'key', 'class', 'name'}, key)
        table.insert(upgrades, {
            id = tostring(id),
            name = tostring(getUpgradeValue(upgrade, {'name', 'Name', 'title', 'Title', 'label', 'Label'}, id)),
            description = tostring(getUpgradeValue(upgrade, {'description', 'Description', 'desc', 'Desc', 'summary', 'Summary'}, 'Upgrade available for purchase.')),
            price = tonumber(getUpgradeValue(upgrade, {'price', 'Price', 'cost', 'Cost', 'money', 'Money'}, 0)) or 0,
            maxLevel = tonumber(getUpgradeValue(upgrade, {'max', 'Max', 'maxLevel', 'MaxLevel', 'levels', 'Levels'}, 0)) or 0
        })
    end

    for _, api in ipairs(apis) do
        local source = getUpgradeSource(api)
        for key, upgrade in pairs(source) do
            if istable(upgrade) and istable(upgrade.members) then
                for memberKey, member in pairs(upgrade.members) do
                    addUpgrade(memberKey, member)
                end
            elseif istable(upgrade) and istable(upgrade.Members) then
                for memberKey, member in pairs(upgrade.Members) do
                    addUpgrade(memberKey, member)
                end
            else
                addUpgrade(key, upgrade)
            end
        end
    end

    table.SortByMember(upgrades, 'name', true)
    return upgrades
end

local PURCHASE_FUNCTIONS = {'PurchaseUpgrade', 'BuyUpgrade', 'Buy', 'Upgrade', 'UnlockUpgrade', 'Unlock'}

local function callPurchase(owner, fn, ply, id)
    if not isfunction(fn) then return false end

    local ok = pcall(fn, owner, ply, id)
    if ok then return true end

    ok = pcall(fn, owner, id, ply)
    if ok then return true end

    ok = pcall(fn, ply, id)
    if ok then return true end

    ok = pcall(fn, id, ply)
    return ok == true
end

local function purchaseZUpgrade(ply, id)
    for _, api in ipairs(getZUpgradesAPIs()) do
        for _, fnName in ipairs(PURCHASE_FUNCTIONS) do
            if callPurchase(api, api[fnName], ply, id) then return true end
        end

        if istable(api.Upgrades) then
            for _, fnName in ipairs(PURCHASE_FUNCTIONS) do
                if callPurchase(api.Upgrades, api.Upgrades[fnName], ply, id) then return true end
            end
        end
    end

    return false
end

local function sendZUpgrades(ply)
    net.Start('vox.f4.zupgrades.sync')
    net.WriteString(util.TableToJSON(collectZUpgrades()) or '[]')
    net.Send(ply)
end

net.Receive('vox.f4.zupgrades.request', function(_, ply)
    sendZUpgrades(ply)
end)

net.Receive('vox.f4.zupgrades.purchase', function(_, ply)
    local id = net.ReadString()
    if id == '' then return end

    purchaseZUpgrade(ply, id)
    timer.Simple(.2, function()
        if IsValid(ply) then sendZUpgrades(ply) end
    end)
end)
