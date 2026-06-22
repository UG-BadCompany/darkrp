-- by p1ng :D

util.AddNetworkString('onyx.scoreboard:SyncColumns')
util.AddNetworkString('onyx.scoreboard:SetColumn')
util.AddNetworkString('onyx.scoreboard:SetColumns')

do
    local q = onyx.scoreboard.db:Create('onyx_scoreboard_columns')
        q:Create('index', 'INT UNSIGNED NOT NULL')
        q:Create('columnID', 'VARCHAR(64) NOT NULL')
        q:PrimaryKey('index')
    q:Execute()
end

local function syncColumns(receiver)
    local columnsCustomizable = onyx.scoreboard.columnsCustomizable
    local columnsAmount = table.Count(columnsCustomizable)

    net.Start('onyx.scoreboard:SyncColumns')

    net.WriteUInt(columnsAmount, 8)
    for index, id in pairs(columnsCustomizable) do
        net.WriteUInt(index, 8)
        net.WriteString(id)
    end

    if (receiver) then
        net.Send(receiver)
    else
        net.Broadcast()
    end
end

local function loadColumns()
    local q = onyx.scoreboard.db:Select('onyx_scoreboard_columns')
        q:Callback(function(result)
            onyx.scoreboard.columnsCustomizable = {}

            for _, row in ipairs(result or {}) do
                onyx.scoreboard.columnsCustomizable[tonumber(row.index)] = row.columnID
            end

            syncColumns()
            onyx.scoreboard:PrintSuccess('Loaded columns.')
        end)
    q:Execute()
end
hook.Add('PostGamemodeLoaded', 'onyx.scoreboard.LoadColumns', loadColumns)
hook.Add('onyx.PlayerNetworkReady', 'onyx.scoreboard.SyncColumns', syncColumns)

local function setColumn(index, columnID)
    assert(isnumber(index), string.format('bad argument #1 (expected number, got %s)', type(index)))

    local db = onyx.scoreboard.db

    db:RawQuery(string.format([[
        REPLACE INTO
            `onyx_scoreboard_columns`
        VALUES (%d, '%s');
    ]], index, db:Escape(columnID)), function()
        onyx.scoreboard.columnsCustomizable[index] = columnID
        syncColumns()
    end)
end

net.Receive('onyx.scoreboard:SetColumns', function(len, ply)
    if ((ply.onyx_scoreboard_NextNetRequest or 0) > CurTime()) then return end
    ply.onyx_scoreboard_NextNetRequest = CurTime() + .33

    local amount = net.ReadUInt(6)
    local changes = {}

    for _ = 1, amount do
        local columnIndex = net.ReadUInt(8)
        local columnID = net.ReadString()

        if (columnIndex < 1 or columnIndex > onyx.scoreboard.columnsMaxAmount) then
            return
        elseif (columnID ~= 'none' and not onyx.scoreboard.columns[columnID]) then
            return
        end

        changes[columnIndex] = columnID
    end

    CAMI.PlayerHasAccess(ply, 'onyx_scoreboard_edit', function(bHasAccess)
        if (bHasAccess) then
            for columnIndex, columnID in pairs(changes) do
                setColumn(columnIndex, columnID)
            end
        end
    end)
end)