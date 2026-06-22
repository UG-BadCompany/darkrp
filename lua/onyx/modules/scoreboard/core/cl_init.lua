-- by p1ng :D

onyx.scoreboard.Buttons = onyx.scoreboard.Buttons or {}

local function openFrame()
    local ratio = 1.641
    local scale = onyx.scoreboard:GetOptionValue('scale') / 100
    local height = math.min(math.ceil((702 / 1080 * ScrH()) * scale), ScrH() * .9)
    local width = math.ceil(height * ratio)

    onyx.scoreboard.Frame = vgui.Create('onyx.Scoreboard.Frame')
    onyx.scoreboard.Frame:SetSize(width, height)
    onyx.scoreboard.Frame:Center()
    onyx.scoreboard.Frame:MakePopup()
    onyx.scoreboard.Frame:SetKeyboardInputEnabled(false)
    onyx.scoreboard.Frame:ShowCloseButton(false)

    hook.Run('onyx.scoreboard.OnOpened', onyx.scoreboard.Frame)

    return onyx.scoreboard.Frame
end

function onyx.scoreboard:RegisterButton(name, data)
    assert(isstring(name), string.format('bad argument #1 (expected string, got %s)', type(name)))
    assert(istable(data), string.format('bad argument #2 (expected table, got %s)', type(data)))

    data.name = name
    table.insert(self.Buttons, data)
end

function onyx.scoreboard.IsBlurActive()
    return onyx.scoreboard:GetOptionValue('blur')
end

do
    local TTT_Names = {
        ['GROUP_TERROR'] = {'terrorists', Color(0, 200, 0)},
        ['GROUP_SPEC'] = {'spectators', Color(200, 200, 0)},
        ['GROUP_NOTFOUND'] = {'sb_mia', Color(130, 190, 130)},
        ['GROUP_FOUND'] = {'sb_confirmed', Color(130, 170, 10)},
    }

    local TTT_RoleColors = {
        default = Color(121, 121, 121),
        traitor = Color(255, 96, 96),
        detective = Color(60, 112, 255)
    }

    function onyx.scoreboard.IsTTT()
        return (engine.ActiveGamemode() == 'terrortown')
    end

    function onyx.scoreboard.GetTeamTTT(ply)
        local group = ScoreGroup(ply)
        local color = color_white
        local name = ''

        if (group) then
            for globalKey, data in pairs(TTT_Names) do
                local index = _G[globalKey]
                if (index == group) then
                    local langID = data[1]
                    local groupColor = data[2]

                    name = LANG.GetTranslation(langID)
                    color = groupColor

                    break
                end
            end
        end

        return group, name, color
    end

    function onyx.scoreboard.GetRoleColorTTT(ply)
        if (ply:IsTraitor()) then
            return TTT_RoleColors.traitor
        elseif (ply:IsDetective()) then
            return TTT_RoleColors.detective
        end

        return TTT_RoleColors.default
    end
end

function onyx.scoreboard.ConvertTeamColor(color)
    local h, s, v = ColorToHSV(color)
    return onyx.ColorEditHSV(color, nil, s - .2, v + .2)
end

function onyx.scoreboard.OpenAdminSettings(tab)                                                                                                                                                                                                                                         -- f57a421c-13b9-4a6d-beaf-215b44fe1613
    local frame = vgui.Create('onyx.Frame')
    frame:SetSize(ScrW() * .6, ScrH() * .6)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('ONYX SCOREBOARD (ADMIN)')

    local p = onyx.ScaleTall(15)
    local content = frame:Add('Panel')
    content:Dock(FILL)
    content:DockPadding(p, p, p, p)

    local sidebar = frame:Add('onyx.Sidebar')
    sidebar:SetContainer(content)
    sidebar:SetWide(frame:GetWide() * .2)
    sidebar:Dock(LEFT)

    sidebar:AddTab({
        name = onyx.lang:Get('addon_settings_u'),
        desc = '',
        icon = 'https://i.imgur.com/ECLKU9s.png',
        class = 'onyx.Configuration',
        onSelected = function(panel)
            panel:LoadAddonSettings('scoreboard')
            panel:OpenCategories()
        end
    })

    sidebar:AddTab({
        name = onyx.lang:Get('scoreboard_ranks_u'),
        desc = '',
        icon = 'https://i.imgur.com/vaYzFPG.png',
        class = 'onyx.scoreboard.RankEditor'
    })

    sidebar:AddTab({
        name = onyx.lang:Get('scoreboard_columns_u'),
        desc = '',
        icon = 'https://i.imgur.com/fUaIb3B.png',
        class = 'onyx.scoreboard.ColumnEditor'
    })

    sidebar:AddTab({
        name = onyx.lang:Get('addon_return_u'),
        desc = '',
        icon = 'https://i.imgur.com/B9XOMVX.png',
        onClick = function()
            frame:Remove()

            local scoreboard = openFrame()
            scoreboard.closeDisabled = true
            scoreboard:ShowCloseButton(true)

            return false
        end
    })

    sidebar:ChooseTab(tab or 1)

    return frame
end

hook.Add('ScoreboardShow', 'onyx.scoreboard.Show', function()
    if (IsValid(onyx.scoreboard.Frame)) then
        return true
    end

    openFrame()

    return true
end)

hook.Add('ScoreboardHide', 'onyx.scoreboard.Hide', function()
    if (IsValid(onyx.scoreboard.Frame) and not onyx.scoreboard.Frame.closeDisabled) then
        onyx.scoreboard.Frame:Remove()
        onyx.scoreboard.Frame:SetMouseInputEnabled(false)
        hook.Run('onyx.scoreboard.OnClosed')
    end

    return true
end)

onyx.WaitForGamemode('onyx.scoreboard.BlockFAdmin', function()
    hook.Remove('ScoreboardShow', 'FAdmin_scoreboard')
    hook.Remove('ScoreboardHide', 'FAdmin_scoreboard')
end)