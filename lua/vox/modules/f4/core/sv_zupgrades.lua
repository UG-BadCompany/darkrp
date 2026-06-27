util.AddNetworkString('vox.f4.zupgrades.request')
util.AddNetworkString('vox.f4.zupgrades.purchase')
util.AddNetworkString('vox.f4.zupgrades.sync')

local API_NAMES = {'ZUpgrades', 'zupgrades', 'ZUPGRADES', 'ZUpgrade', 'zupgrade'}

local function isZUpgradesTable(name, tbl)
    if not istable(tbl) then return false end
    if isstring(name) and string.find(string.lower(name), 'upgrade', 1, true) then return true end
    return istable(tbl.Upgrades) or istable(tbl.upgrades) or isfunction(tbl.GetUpgrades)
end

local function getZUpgradesAPI()
    for _, name in ipairs(API_NAMES) do
        if istable(_G[name]) then return _G[name] end
    end

    for name, value in pairs(_G) do
        if isZUpgradesTable(name, value) then return value end
    end
end

local function getUpgradeValue(upgrade, keys, fallback)
    if not istable(upgrade) then return fallback end

    for _, key in ipairs(keys) do
        local value = upgrade[key]
        if value ~= nil and not isfunction(value) then return value end
    end

    return fallback
end

local function getUpgradeSource(api)
    if not api then return {} end
    if isfunction(api.GetUpgrades) then
        local ok, result = pcall(api.GetUpgrades, api)
        if ok and istable(result) then return result end
    end

    return api.Upgrades or api.upgrades or api.Config and (api.Config.Upgrades or api.Config.upgrades) or {}
end

local function collectZUpgrades()
    local api = getZUpgradesAPI()
    local source = getUpgradeSource(api)
    local upgrades = {}

    for key, upgrade in pairs(source) do
        if istable(upgrade) then
            local id = getUpgradeValue(upgrade, {'id', 'ID', 'uniqueID', 'uniqueId', 'uid', 'key', 'class', 'name'}, key)
            table.insert(upgrades, {
                id = tostring(id),
                name = tostring(getUpgradeValue(upgrade, {'name', 'Name', 'title', 'Title', 'label', 'Label'}, id)),
                description = tostring(getUpgradeValue(upgrade, {'description', 'Description', 'desc', 'Desc', 'summary', 'Summary'}, 'Upgrade available for purchase.')),
                price = tonumber(getUpgradeValue(upgrade, {'price', 'Price', 'cost', 'Cost', 'money', 'Money'}, 0)) or 0,
                maxLevel = tonumber(getUpgradeValue(upgrade, {'max', 'Max', 'maxLevel', 'MaxLevel', 'levels', 'Levels'}, 0)) or 0
            })
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
    local api = getZUpgradesAPI()
    if not api then return false end

    for _, fnName in ipairs(PURCHASE_FUNCTIONS) do
        if callPurchase(api, api[fnName], ply, id) then return true end
    end

    if istable(api.Upgrades) then
        for _, fnName in ipairs(PURCHASE_FUNCTIONS) do
            if callPurchase(api.Upgrades, api.Upgrades[fnName], ply, id) then return true end
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
