-- by p1ng :D

util.AddNetworkString('onyx.scoreboard:SyncRanks')
util.AddNetworkString('onyx.scoreboard:ReplaceRank')
util.AddNetworkString('onyx.scoreboard:DeleteRank')

do
    local q = onyx.scoreboard.db:Create('onyx_scoreboard_ranks')
        q:Create('uniqueID', 'VARCHAR(32) NOT NULL')
        q:Create('name', 'VARCHAR(64) NOT NULL')
        q:Create('effect', 'TEXT NOT NULL')
        q:PrimaryKey('uniqueID')
    q:Execute()
end

local function syncRanks(receiver)
    local data = pon.encode(onyx.scoreboard.ranks)
    local length = #data

    net.Start('onyx.scoreboard:SyncRanks')

    net.WriteData(data, length)

    if (receiver) then
        net.Send(receiver)
    else
        net.Broadcast()
    end
end

local function saveRank(uniqueID, name, effectID, color)
    local db = onyx.scoreboard.db
    local data = pon.encode({
        effectID = effectID,
        color = color
    })

    db:RawQuery(string.format([[
        REPLACE INTO
            `onyx_scoreboard_ranks`
        VALUES ('%s', '%s', '%s');
    ]], db:Escape(uniqueID), db:Escape(name), db:Escape(data)), function()
        onyx.scoreboard.ranks[uniqueID] = {
            name = name,
            effectID = effectID,
            color = color
        }

        syncRanks()
    end)
end

local function deleteRank(uniqueID)
    local q = onyx.scoreboard.db:Delete('onyx_scoreboard_ranks')
        q:Where('uniqueID', uniqueID)
        q:Limit(1)
        q:Callback(function()
            onyx.scoreboard.ranks[uniqueID] = nil
            syncRanks()
        end)
    q:Execute()
end

local function loadRanks()
    local q = onyx.scoreboard.db:Select('onyx_scoreboard_ranks')
        q:Callback(function(result)
            onyx.scoreboard.ranks = {}

            for _, row in ipairs(result or {}) do
                local uniqueID = row.uniqueID
                local name = row.name
                local data = pon.decode(row.effect)

                onyx.scoreboard.ranks[uniqueID] = {
                    name = name,
                    effectID = data.effectID,
                    color = data.color
                }
            end

            syncRanks()
            onyx.scoreboard:PrintSuccess('Loaded ranks.')
        end)
    q:Execute()
end

hook.Add('PostGamemodeLoaded', 'onyx.scoreboard.LoadRanks', loadRanks)
hook.Add('onyx.PlayerNetworkReady', 'onyx.scoreboard.SyncRanks', syncRanks)

net.Receive('onyx.scoreboard:DeleteRank', function(len, ply)
    if ((ply.onyx_scoreboard_NextNetRequest or 0) > CurTime()) then return end                                                                                                                                                                                                                     -- f57a421c-13b9-4a6d-beaf-215b44fe1613
    ply.onyx_scoreboard_NextNetRequest = CurTime() + .33

    local uniqueID = net.ReadString()

    if (not onyx.scoreboard.ranks[uniqueID]) then return end

    CAMI.PlayerHasAccess(ply, 'onyx_scoreboard_edit', function(bHasAccess)
        if (bHasAccess) then
            deleteRank(uniqueID)
        end
    end)
end)

net.Receive('onyx.scoreboard:ReplaceRank', function(len, ply)
    if ((ply.onyx_scoreboard_NextNetRequest or 0) > CurTime()) then return end
    ply.onyx_scoreboard_NextNetRequest = CurTime() + .33

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

    CAMI.PlayerHasAccess(ply, 'onyx_scoreboard_edit', function(bHasAccess)
        if (bHasAccess) then
            saveRank(uniqueID, name, effectID, color)
        end
    end)
end)