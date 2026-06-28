util.AddNetworkString('vox.f4.zupgrades.request')
util.AddNetworkString('vox.f4.zupgrades.purchase')
util.AddNetworkString('vox.f4.zupgrades.sync')

local CATEGORY_LABELS = {
    props = 'Props',
    jobs = 'Job',
    shipments = 'Shipment',
    entities = 'Entities'
}

local function getZUpgrades()
    return istable(ZUpgrades) and ZUpgrades or nil
end

local function safeCall(fn, ...)
    if not isfunction(fn) then return nil end

    local ok, result = pcall(fn, ...)
    if ok then return result end

    return nil
end

local function canAfford(z, fnName, ply, key)
    local result = safeCall(z[fnName], ply, key)
    if result == nil then return true end

    return result == true
end

local function addUnlockRows(rows, z, category, statusFnName, fallbackTable, unlockedFnName, affordFnName, ply)
    local status = safeCall(z[statusFnName], ply)

    if not istable(status) and istable(z[fallbackTable]) then
        status = {}
        for key, info in pairs(z[fallbackTable]) do
            local unlocked = safeCall(z[unlockedFnName], ply, key)
            status[key] = {
                name = info.name or tostring(key),
                price = tonumber(info.price) or 0,
                description = info.description or '',
                unlocked = unlocked == true
            }
        end
    end

    if not istable(status) then return end

    for key, info in pairs(status) do
        local unlocked = info.unlocked == true
        table.insert(rows, {
            id = tostring(key),
            key = tostring(key),
            category = category,
            categoryName = CATEGORY_LABELS[category],
            name = tostring(info.name or key),
            description = tostring(info.description or ''),
            price = tonumber(info.price) or 0,
            unlocked = unlocked,
            canAfford = unlocked or canAfford(z, affordFnName, ply, key)
        })
    end
end

local function addPropRow(rows, z, ply)
    local cfg = z.Config or {}
    local info = safeCall(z.GetPropUpgradeInfo, ply)

    if not istable(info) then
        local level = tonumber(safeCall(z.GetPlayerPropLevel, ply)) or ply:GetNWInt('ZUpgrades_PropLevel', 0)
        local maxLevel = tonumber(cfg.MaxPropUpgrades) or 0
        local perUpgrade = tonumber(cfg.PropLimitPerUpgrade) or 0
        local baseLimit = tonumber(cfg.BasePropLimit) or 0
        local limit = tonumber(safeCall(z.GetPropLimit, ply)) or (baseLimit + level * perUpgrade)
        local maxed = maxLevel > 0 and level >= maxLevel

        info = {
            level = level,
            maxLevel = maxLevel,
            limit = limit,
            maxLimit = baseLimit + maxLevel * perUpgrade,
            nextCost = not maxed and safeCall(z.GetUpgradeCost, level) or nil,
            maxed = maxed
        }
    end

    local maxed = info.maxed == true
    table.insert(rows, {
        id = 'prop_limit',
        key = 'prop_limit',
        category = 'props',
        categoryName = CATEGORY_LABELS.props,
        name = 'Prop Limit',
        description = 'Increase your personal prop limit.',
        price = tonumber(info.nextCost) or 0,
        unlocked = maxed,
        maxed = maxed,
        canAfford = maxed or canAfford(z, 'CanAffordPropUpgrade', ply),
        level = tonumber(info.level) or 0,
        maxLevel = tonumber(info.maxLevel) or 0,
        limit = tonumber(info.limit) or 0,
        maxLimit = tonumber(info.maxLimit) or 0,
        nextCost = tonumber(info.nextCost) or 0,
        propLimitPerUpgrade = tonumber(cfg.PropLimitPerUpgrade) or 0
    })
end

local function collectZUpgrades(ply)
    local z = getZUpgrades()
    local rows = {}

    if not z then return rows end

    addPropRow(rows, z, ply)
    addUnlockRows(rows, z, 'jobs', 'GetAllJobsWithStatus', 'JobUnlocks', 'IsJobUnlocked', 'CanAffordJobUnlock', ply)
    addUnlockRows(rows, z, 'shipments', 'GetAllShipmentsWithStatus', 'ShipmentUnlocks', 'IsShipmentUnlocked', 'CanAffordShipmentUnlock', ply)
    addUnlockRows(rows, z, 'entities', 'GetAllEntitiesWithStatus', 'EntityUnlocks', 'IsEntityUnlocked', 'CanAffordEntityUnlock', ply)

    table.SortByMember(rows, 'name', true)
    return rows
end

local function purchaseZUpgrade(ply, category, key)
    local z = getZUpgrades()
    if not z or not istable(z.Purchase) then return false, 'ZUpgrades is not loaded.' end

    if category == 'props' then
        return safeCall(z.Purchase.PropUpgrade, ply)
    elseif category == 'jobs' then
        return safeCall(z.Purchase.JobUnlock, ply, key)
    elseif category == 'shipments' then
        return safeCall(z.Purchase.ShipmentUnlock, ply, key)
    elseif category == 'entities' then
        return safeCall(z.Purchase.EntityUnlock, ply, key)
    end

    return false, 'Invalid upgrade category.'
end

local function sendZUpgrades(ply)
    net.Start('vox.f4.zupgrades.sync')
    net.WriteString(util.TableToJSON(collectZUpgrades(ply)) or '[]')
    net.Send(ply)
end

net.Receive('vox.f4.zupgrades.request', function(_, ply)
    sendZUpgrades(ply)
end)

net.Receive('vox.f4.zupgrades.purchase', function(_, ply)
    local category = net.ReadString()
    local key = net.ReadString()

    if category == '' then return end

    purchaseZUpgrade(ply, category, key)
    timer.Simple(.2, function()
        if IsValid(ply) then sendZUpgrades(ply) end
    end)
end)
