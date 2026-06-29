vox.scoreboard.columns = vox.scoreboard.columns or {}
vox.scoreboard.columnsCustomizable = vox.scoreboard.columnsCustomizable or {}
vox.scoreboard.columnsMaxAmount = 5
vox.scoreboard.columnsDefault = {
    [1] = 'team',
    [2] = 'rank',
    [3] = 'money',
    [4] = 'playtime',
}

function vox.scoreboard:RegisterColumn(id, data)
    if (SERVER) then data = {} end -- server doesn't need that

    data.name = 'scoreboard_col_' .. id
    data.id = id

    vox.scoreboard.columns[id] = data
end

do
    local BASE_COLUMNS = {
        {
            name = '',
            icon = 'https://i.imgur.com/FQK7XQx.png',
            small = true,
            getValue = function(client)
                return client:Frags()
            end
        },
        {
            name = '',
            icon = 'https://i.imgur.com/13t90iD.png',
            small = true,
            getValue = function(client)
                return client:Deaths()
            end
        }
    }

    function vox.scoreboard:GetActiveColumns()
        local columns = {}

        -- configurable options
        for index = 1, self.columnsMaxAmount do
            local cfgID = self.columnsCustomizable[index]
            if (cfgID) then
                local cfgData = self.columns[cfgID]
                if (cfgData and (not cfgData.customCheck or cfgData.customCheck())) then
                    table.insert(columns, cfgData)
                end
            else
                local defaultID = vox.scoreboard.columnsDefault[index]
                if (defaultID) then
                    local defaultData = self.columns[defaultID]
                    if (defaultData and (not defaultData.customCheck or defaultData.customCheck())) then
                        table.insert(columns, defaultData)
                    end
                end
            end
        end

        -- default columns
        for _, column in ipairs(BASE_COLUMNS) do
            table.insert(columns, column)
        end

        return columns
    end
end
