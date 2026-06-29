vox.scoreboard = vox.scoreboard or {}
vox.scoreboard.db = vox.scoreboard.db or {}
assert(vox.scoreboard.db.Create, 'vox.scoreboard.db is not initialized before scoreboard ranks load')

util.AddNetworkString('vox.scoreboard:SyncRanks')
util.AddNetworkString('vox.scoreboard:ReplaceRank')
util.AddNetworkString('vox.scoreboard:DeleteRank')

do
    local q = vox.scoreboard.db:Create('vox_scoreboard_ranks')
        q:Create('uniqueID', 'VARCHAR(32) NOT NULL')
        q:Create('name', 'VARCHAR(64) NOT NULL')
        q:Create('effect', 'TEXT NOT NULL')
        q:PrimaryKey('uniqueID')
    q:Execute()
end

local function syncRanks(receiver)
    local data = pon.encode(vox.scoreboard.ranks)
    local length = #data

    net.Start('vox.scoreboard:SyncRanks')

    net.WriteData(data, length)

    if (receiver) then
        net.Send(receiver)
    else
        net.Broadcast()
    end
end

local function saveRank(uniqueID, name, effectID, color)
    local db = vox.scoreboard.db
    local data = pon.encode({
        effectID = effectID,
        color = color
    })

    db:RawQuery(string.format([[
        REPLACE INTO
            `vox_scoreboard_ranks`
        VALUES ('%s', '%s', '%s');
    ]], db:Escape(uniqueID), db:Escape(name), db:Escape(data)), function()
        vox.scoreboard.ranks[uniqueID] = {
            name = name,
            effectID = effectID,
            color = color
        }

        syncRanks()
    end)
end

local function deleteRank(uniqueID)
    local q = vox.scoreboard.db:Delete('vox_scoreboard_ranks')
        q:Where('uniqueID', uniqueID)
        q:Limit(1)
        q:Callback(function()
            vox.scoreboard.ranks[uniqueID] = nil
            syncRanks()
        end)
    q:Execute()
end

local function loadRanks()
    local q = vox.scoreboard.db:Select('vox_scoreboard_ranks')
        q:Callback(function(result)
            vox.scoreboard.ranks = {}

            for _, row in ipairs(result or {}) do
                local uniqueID = row.uniqueID
                local name = row.name
                local data = pon.decode(row.effect)

                vox.scoreboard.ranks[uniqueID] = {
                    name = name,
                    effectID = data.effectID,
                    color = data.color
                }
            end

            syncRanks()
            vox.scoreboard:PrintSuccess('Loaded ranks.')
        end)
    q:Execute()
end

hook.Add('PostGamemodeLoaded', 'vox.scoreboard.LoadRanks', loadRanks)
hook.Add('vox.PlayerNetworkReady', 'vox.scoreboard.SyncRanks', syncRanks)

net.Receive('vox.scoreboard:DeleteRank', function(len, ply)
    if ((ply.vox_scoreboard_NextNetRequest or 0) > CurTime()) then return end
    ply.vox_scoreboard_NextNetRequest = CurTime() + .33

    local uniqueID = net.ReadString()

    if (not vox.scoreboard.ranks[uniqueID]) then return end

    CAMI.PlayerHasAccess(ply, 'vox_scoreboard_edit', function(bHasAccess)
        if (bHasAccess) then
            deleteRank(uniqueID)
        end
    end)
end)

net.Receive('vox.scoreboard:ReplaceRank', function(len, ply)
    if ((ply.vox_scoreboard_NextNetRequest or 0) > CurTime()) then return end
    ply.vox_scoreboard_NextNetRequest = CurTime() + .33

    local uniqueID = net.ReadString()
    local name = net.ReadString()
    local effectID = net.ReadString()
    local color = net.ReadColor()

    if (
            utf8.len(uniqueID) < 1
        or  utf8.len(uniqueID) > 24
        or  utf8.len(name) > 24
    ) then
        return
    end

    CAMI.PlayerHasAccess(ply, 'vox_scoreboard_edit', function(bHasAccess)
        if (bHasAccess) then
            saveRank(uniqueID, name, effectID, color)
        end
    end)
end)
