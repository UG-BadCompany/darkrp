-- by p1ng :D

--[[------------------------------
**WARNING**
This is an advanced config.
Most of the things you need should be configurable through the game.
Do not edit anything if you do not understand what you are doing.
--------------------------------]]

onyx.scoreboard.columns = {}

--[[------------------------------
Default ones
--------------------------------]]
onyx.scoreboard:RegisterColumn('team', {
    getValue = function(client)
        if (onyx.scoreboard.IsTTT()) then
            return select(2, onyx.scoreboard.GetTeamTTT(client))
        end

        return client:Team()
    end,
    formatValue = function(value)
        if (onyx.scoreboard.IsTTT()) then
            return value
        end

        return team.GetName(value)
    end,
    getColor = function(client)
        if (onyx.scoreboard.IsTTT()) then
            return select(3, onyx.scoreboard.GetTeamTTT(client))
        end

        return onyx.scoreboard.ConvertTeamColor(team.GetColor(client:Team()))
    end
})

onyx.scoreboard:RegisterColumn('rank', {
    getValue = function(client)
        local rank = client:GetUserGroup()
        local data = onyx.scoreboard:GetRankData(rank)
        if (data) then
            return data.name
        end
        return rank
    end
})

onyx.scoreboard:RegisterColumn('health', {
    getValue = function(client)
        local health = client:Alive() and client:Health() or -1
        return health
    end,
    formatValue = function(value)
        if (value > 0) then
            return string.Comma(value) .. ' HP'
        else
            return onyx.lang:Get('dead')
        end
    end
})

--[[------------------------------
DarkRP
--------------------------------]]
onyx.scoreboard:RegisterColumn('money', {
    getValue = function(client)
        return (client:getDarkRPVar('money') or 0)
    end,
    formatValue = function(value)
        return DarkRP.formatMoney(value)
    end,
    customCheck = function()
        return DarkRP ~= nil
    end
})

--[[------------------------------
TTT
--------------------------------]]
onyx.scoreboard:RegisterColumn('karma', {
    getValue = function(client)
        return client:GetBaseKarma()
    end,
    formatValue = function(value)
        return string.Comma(math.Round(value))
    end,
    customCheck = function()
        return (engine.ActiveGamemode() == 'terrortown')
    end
})

--[[------------------------------
Custom
--------------------------------]]
do
    local handlers = {
        {
            key = 'GlorifiedLeveling',
            func = function(ply)
                return ply:getLevel()
            end
        },
        {
            key = 'LevelSystemConfiguration',
            func = function(ply)
                -- Vrondakis
                if (ply.getDarkRPVar) then
                    return ply:getDarkRPVar('level')
                end
            end
        },
        {
            key = 'levelup',
            func = function(ply)
                return levelup.getLevel(ply)
            end
        }
    }

    onyx.scoreboard:RegisterColumn('level', {
        getValue = function(client)
            for _, data in ipairs(handlers) do
                if (_G[data.key]) then
                    local value = data.func(client)
                    return (value or 0)
                end
            end
            return 0
        end,
        formatValue = function(level)
            return string.Comma(level)
        end,
        customCheck = function()
            for _, data in ipairs(handlers) do
                if (_G[data.key]) then
                    return true
                end
            end

            return false
        end
    })
end

do
    local handlers = {
        {
            -- SAM
            valid = function()
                return sam ~= nil
            end,
            func = function(ply)
                return ply:sam_get_play_time() -- seconds
            end
        },
        {
            -- Utime
            valid = function()
                return Utime ~= nil
            end,
            func = function(ply)
                return ply:GetUTimeTotalTime()
            end
        }
    }

    onyx.scoreboard:RegisterColumn('playtime', {
        getValue = function(client)
            for _, data in ipairs(handlers) do
                if (data.valid()) then
                    local value = data.func(client)
                    return (value or 0)
                end
            end
            return 0
        end,
        formatValue = function(seconds)
            local minutes = math.Round(seconds / 60)
            local hours = math.Round(minutes / 60)
            if (hours < 1) then
                return string.Comma(minutes) .. 'm'
            else
                return string.Comma(hours) .. 'h'
            end
        end,
        customCheck = function()
            for _, data in ipairs(handlers) do
                if (data.valid()) then
                    return true
                end
            end

            return false
        end
    })
end

-- Ashop
onyx.scoreboard:RegisterColumn('ashop_badges', {
    getValue = function(client)
        local badges = ashop.GetPlayerBadges(client) or {}
        return table.Count(badges)
    end,
    buildFunc = function(columnPanel, ply)
        local badges = ashop.GetPlayerBadges(ply) or {}

        columnPanel.PerformLayout = function(panel, w, h)
            local space = onyx.ScaleTall(5)
            local children = panel:GetChildren()
            local amount = #children
            local size = math.min(h, (w - space * (amount - 1)) / amount)
            local totalWidth = size * amount + space * (amount - 1)
            local x = w * .5 - totalWidth * .5

            for index, child in ipairs(children) do
                if (IsValid(child)) then
                    child:SetSize(size, size)
                    child:SetPos(x, 0)
                    child:CenterVertical()

                    x = x + size + space
                end
            end
        end

        for slot, data in pairs(badges) do
            local badge = vgui.Create("DPanel", columnPanel)
            badge.Paint = function(panel, w, h)
                xpcall(function()
                    local mat = data.mat()
                    if (mat) then
                        surface.SetMaterial(mat)
                        surface.SetDrawColor(color_white)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end
                end, function(errText)
                    onyx.scoreboard:PrintError('(AShop) Error during badge display: #', errText)
                end)
            end
        end
    end,
    customCheck = function()
        return ashop ~= nil
    end
})

-- Brick's Gangs
onyx.scoreboard:RegisterColumn('gang', {
    getValue = function(client)
        local gangID = client:GetGangID()
        local gangName = onyx.scoreboard.GetBricksGangName(gangID)
        return gangName
    end,
    customCheck = function()
        if (BRICKS_SERVER and BRICKS_SERVER.GANGS) then
            return true
        end
        return false
    end
})

-- VoidFactions
onyx.scoreboard:RegisterColumn('faction', {
    getValue = function(client)
        return client:VF_GetFactionName('')
    end,
    getColor = function(client)
        return client:VF_GetFactionColor(color_white)
    end,
    customCheck = function()
        return VoidFactions ~= nil
    end
})