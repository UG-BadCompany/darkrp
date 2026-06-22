util.AddNetworkString('vox.scoreboard:SyncColumns')
util.AddNetworkString('vox.scoreboard:SetColumn')
util.AddNetworkString('vox.scoreboard:SetColumns')

do
    local q = vox.scoreboard.db:Create('vox_scoreboard_columns')
        q:Create('index', 'INT UNSIGNED NOT NULL')
        q:Create('columnID', 'VARCHAR(64) NOT NULL')
        q:PrimaryKey('index')
    q:Execute()
end

local function syncColumns(receiver)
    local columnsCustomizable = vox.scoreboard.columnsCustomizable
    local columnsAmount = table.Count(columnsCustomizable)

    net.Start('vox.scoreboard:SyncColumns')

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
    local q = vox.scoreboard.db:Select('vox_scoreboard_columns')
        q:Callback(function(result)
            vox.scoreboard.columnsCustomizable = {}

            for _, row in ipairs(result or {}) do
                vox.scoreboard.columnsCustomizable[tonumber(row.index)] = row.columnID
            end

            syncColumns()
            vox.scoreboard:PrintSuccess('Loaded columns.')
        end)
    q:Execute()
end
hook.Add('PostGamemodeLoaded', 'vox.scoreboard.LoadColumns', loadColumns)
hook.Add('vox.PlayerNetworkReady', 'vox.scoreboard.SyncColumns', syncColumns)

local function setColumn(index, columnID)
    assert(isnumber(index), string.format('bad argument #1 (expected number, got %s)', type(index)))

    local db = vox.scoreboard.db

    db:RawQuery(string.format([[
        REPLACE INTO
            `vox_scoreboard_columns`
        VALUES (%d, '%s');
    ]], index, db:Escape(columnID)), function()
        vox.scoreboard.columnsCustomizable[index] = columnID
        syncColumns()
    end)
end

net.Receive('vox.scoreboard:SetColumns', function(len, ply)
    if ((ply.vox_scoreboard_NextNetRequest or 0) > CurTime()) then return end
    ply.vox_scoreboard_NextNetRequest = CurTime() + .33

    local amount = net.ReadUInt(6)
    local changes = {}

    for _ = 1, amount do
        local columnIndex = net.ReadUInt(8)
        local columnID = net.ReadString()

        if (columnIndex < 1 or columnIndex > vox.scoreboard.columnsMaxAmount) then
            return
        elseif (columnID ~= 'none' and not vox.scoreboard.columns[columnID]) then
            return
        end

        changes[columnIndex] = columnID
    end

    CAMI.PlayerHasAccess(ply, 'vox_scoreboard_edit', function(bHasAccess)
        if (bHasAccess) then
            for columnIndex, columnID in pairs(changes) do
                setColumn(columnIndex, columnID)
            end
        end
    end)
end)
