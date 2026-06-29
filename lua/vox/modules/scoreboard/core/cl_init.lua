vox.scoreboard.Buttons = vox.scoreboard.Buttons or {}

local function openFrame()
    local ratio = 1.641
    local scale = vox.scoreboard:GetOptionValue('scale') / 100
    local height = math.min(math.ceil((702 / 1080 * ScrH()) * scale), ScrH() * .9)
    local width = math.ceil(height * ratio)

    vox.scoreboard.Frame = vgui.Create('vox.Scoreboard.Frame')
    vox.scoreboard.Frame:SetSize(width, height)
    vox.scoreboard.Frame:Center()
    vox.scoreboard.Frame:MakePopup()
    vox.scoreboard.Frame:SetKeyboardInputEnabled(false)
    vox.scoreboard.Frame:ShowCloseButton(false)

    hook.Run('vox.scoreboard.OnOpened', vox.scoreboard.Frame)

    return vox.scoreboard.Frame
end

function vox.scoreboard:RegisterButton(name, data)
    assert(isstring(name), string.format('bad argument #1 (expected string, got %s)', type(name)))
    assert(istable(data), string.format('bad argument #2 (expected table, got %s)', type(data)))

    data.name = name
    table.insert(self.Buttons, data)
end

function vox.scoreboard.IsBlurActive()
    return vox.scoreboard:GetOptionValue('blur')
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

    function vox.scoreboard.IsTTT()
        return (engine.ActiveGamemode() == 'terrortown')
    end

    function vox.scoreboard.GetTeamTTT(ply)
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

    function vox.scoreboard.GetRoleColorTTT(ply)
        if (ply:IsTraitor()) then
            return TTT_RoleColors.traitor
        elseif (ply:IsDetective()) then
            return TTT_RoleColors.detective
        end

        return TTT_RoleColors.default
    end
end

function vox.scoreboard.ConvertTeamColor(color)
    local h, s, v = ColorToHSV(color)
    return vox.ColorEditHSV(color, nil, s - .2, v + .2)
end

function vox.scoreboard.OpenAdminSettings(tab)
    local frame = vgui.Create('vox.Frame')
    frame:SetSize(ScrW() * .6, ScrH() * .6)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('Vox Scoreboard Settings')

    local p = vox.ScaleTall(15)
    local content = frame:Add('Panel')
    content:Dock(FILL)
    content:DockPadding(p, p, p, p)

    local sidebar = frame:Add('vox.Sidebar')
    sidebar:SetContainer(content)
    sidebar:SetWide(frame:GetWide() * .2)
    sidebar:Dock(LEFT)

    sidebar:AddTab({
        name = vox.lang:Get('addon_settings_u'),
        desc = '',
        icon = 'https://i.imgur.com/ECLKU9s.png',
        class = 'vox.Configuration',
        onSelected = function(panel)
            panel:LoadAddonSettings('scoreboard')
            panel:OpenCategories()
        end
    })

    sidebar:AddTab({
        name = vox.lang:Get('scoreboard_ranks_u'),
        desc = '',
        icon = 'https://i.imgur.com/vaYzFPG.png',
        class = 'vox.scoreboard.RankEditor'
    })

    sidebar:AddTab({
        name = vox.lang:Get('scoreboard_columns_u'),
        desc = '',
        icon = 'https://i.imgur.com/fUaIb3B.png',
        class = 'vox.scoreboard.ColumnEditor'
    })

    sidebar:AddTab({
        name = vox.lang:Get('addon_return_u'),
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

hook.Add('ScoreboardShow', 'vox.scoreboard.Show', function()
    if (IsValid(vox.scoreboard.Frame)) then
        return true
    end

    openFrame()

    return true
end)

hook.Add('ScoreboardHide', 'vox.scoreboard.Hide', function()
    if (IsValid(vox.scoreboard.Frame) and not vox.scoreboard.Frame.closeDisabled) then
        vox.scoreboard.Frame:Remove()
        vox.scoreboard.Frame:SetMouseInputEnabled(false)
        hook.Run('vox.scoreboard.OnClosed')
    end

    return true
end)

vox.WaitForGamemode('vox.scoreboard.BlockFAdmin', function()
    hook.Remove('ScoreboardShow', 'FAdmin_scoreboard')
    hook.Remove('ScoreboardHide', 'FAdmin_scoreboard')
end)
