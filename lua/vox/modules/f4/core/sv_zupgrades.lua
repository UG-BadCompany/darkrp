util.AddNetworkString('vox.f4.zupgrades.request')
util.AddNetworkString('vox.f4.zupgrades.purchase')
util.AddNetworkString('vox.f4.zupgrades.sync')

local CATEGORY_LABELS = {
    props = 'Props',
    jobs = 'Jobs',
    shipments = 'Shipments',
    entities = 'Entities',
    bank = 'Bank'
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

local function findDarkRPJob(command)
    command = tostring(command or '')
    for _, job in pairs(RPExtraTeams or {}) do
        if tostring(job.command or '') == command then return job end
    end
end

local function normalizeJobSubcategory(raw, name)
    local text = string.lower(tostring(raw or '') .. ' ' .. tostring(name or ''))

    if text:find('dealer', 1, true) then return 'Dealers' end
    if text:find('civil protection', 1, true) or text:find('government', 1, true) or text:find('police', 1, true) or text:find('swat', 1, true) or text:find('mayor', 1, true) then return 'Government' end
    if text:find('criminal', 1, true) or text:find('gang', 1, true) or text:find('mob', 1, true) or text:find('thief', 1, true) or text:find('hitman', 1, true) or text:find('spy', 1, true) or text:find('explosive', 1, true) then return 'Criminals' end
    if text:find('citizen', 1, true) or text:find('hobo', 1, true) or text:find('medic', 1, true) or text:find('security', 1, true) then return 'Citizens' end

    return raw and tostring(raw) ~= '' and tostring(raw) or 'Other'
end

local function findDarkRPShipment(name)
    name = tostring(name or '')
    for _, shipment in pairs(CustomShipments or {}) do
        if tostring(shipment.name or '') == name then return shipment end
    end
end

local function normalizeShipmentSubcategory(raw, name)
    local label = tostring(raw or '')
    local lower = string.lower(label .. ' ' .. tostring(name or ''))

    if lower:find('assault', 1, true) or lower:find('rifle', 1, true) or lower:find('ar%-') then return 'Assault Rifles' end
    if lower:find('pistol', 1, true) or lower:find('handgun', 1, true) then return 'Pistols' end
    if lower:find('smg', 1, true) or lower:find('submachine', 1, true) then return 'SMGs' end
    if lower:find('shotgun', 1, true) then return 'Shotguns' end
    if lower:find('sniper', 1, true) or lower:find('marksman', 1, true) then return 'Sniper Rifles' end
    if lower:find('lmg', 1, true) or lower:find('machine gun', 1, true) then return 'LMGs' end
    if lower:find('melee', 1, true) or lower:find('knife', 1, true) or lower:find('crowbar', 1, true) then return 'Melee' end
    if lower:find('grenade', 1, true) or lower:find('smoke', 1, true) or lower:find('flash', 1, true) then return 'Grenades' end
    if lower:find('explosive', 1, true) or lower:find('bomb', 1, true) then return 'Explosives' end

    return label ~= '' and label or 'Other'
end

local function findDarkRPEntity(name)
    name = tostring(name or '')
    for _, ent in pairs(DarkRPEntities or {}) do
        if tostring(ent.name or '') == name then return ent end
    end
end

local function normalizeEntitySubcategory(raw, name)
    local label = tostring(raw or '')
    local lower = string.lower(label .. ' ' .. tostring(name or ''))

    if lower:find('printer', 1, true) then return 'Printers' end
    if lower:find('drug', 1, true) or lower:find('lab', 1, true) then return 'Drugs' end
    if lower:find('keycard', 1, true) or lower:find('cracker', 1, true) or lower:find('tool', 1, true) then return 'Tools' end
    if lower:find('bomb', 1, true) or lower:find('explosive', 1, true) then return 'Explosives' end

    return label ~= '' and label or 'Other'
end

local function getUnlockSubcategory(category, key, info)
    info = info or {}
    if isstring(info.subcategory) and info.subcategory ~= '' then return info.subcategory end
    if isstring(info.category) and info.category ~= '' then return info.category end

    if category == 'jobs' then
        local job = findDarkRPJob(key)
        return normalizeJobSubcategory(job and job.category, info.name or key)
    elseif category == 'shipments' then
        local shipment = findDarkRPShipment(info.name or key)
        return normalizeShipmentSubcategory(shipment and shipment.category, info.name or key)
    elseif category == 'entities' then
        local ent = findDarkRPEntity(info.name or key)
        return normalizeEntitySubcategory(ent and ent.category, info.name or key)
    elseif category == 'bank' then
        return 'Storage'
    end

    return 'General'
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
            subcategory = getUnlockSubcategory(category, key, info),
            name = tostring(info.name or key),
            description = tostring(info.description or ''),
            price = tonumber(info.price) or 0,
            unlocked = unlocked,
            canAfford = unlocked or canAfford(z, affordFnName, ply, key)
        })
    end
end

local function addBankRows(rows, z, ply)
    if not istable(z.BankPageUnlocks) then return end

    for page, info in pairs(z.BankPageUnlocks) do
        local unlocked = safeCall(z.HasBankPageUnlock, ply, page) == true
        local price = tonumber(info.price) or 0
        table.insert(rows, {
            id = tostring(page),
            key = tostring(page),
            category = 'bank',
            categoryName = CATEGORY_LABELS.bank,
            subcategory = getUnlockSubcategory('bank', page, info),
            name = tostring(info.name or ('Bank Page ' .. tostring(page))),
            description = tostring(info.description or ''),
            price = price,
            unlocked = unlocked,
            canAfford = unlocked or not ply.canAfford or ply:canAfford(price)
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
    addBankRows(rows, z, ply)

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
    elseif category == 'bank' then
        return safeCall(z.Purchase.BankPageUnlock, ply, tonumber(key))
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
