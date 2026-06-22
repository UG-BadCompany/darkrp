vox.f4.tabs = vox.f4.tabs or {}
vox.f4.actions = vox.f4.actions or {}

vox.wimg.Register('favorite_fill', 'https://i.imgur.com/wviPFMQ.png')
vox.wimg.Register('favorite_outline', 'https://i.imgur.com/FCXcBsu.png')

function vox.f4:RegisterTab(id, data)
    vox.AssertType(id, 'string', 'RegisterTab', 1)
    vox.AssertType(data, 'table', 'RegisterTab', 2)

    data.id = id
    data.order = data.order or 99
    self.tabs[id] = data
end

function vox.f4:RegisterAction(data)
    vox.AssertType(data, 'table', 'RegisterAction', 1)

    table.insert(self.actions, data)
end

function vox.f4.IsAdmin(ply)
    local jobOnly = vox.f4:GetOptionValue('admin_on_duty')
    local jobName = vox.f4:GetOptionValue('admin_on_duty_job')
    if (jobOnly) then
        local userGroup = ply:GetUserGroup()
        local jobTable = RPExtraTeams[ply:Team()]
        if (jobTable and userGroup ~= 'user' and jobTable.name == jobName) then
            return true
        else
            return false
        end
    else
        return ply:IsAdmin()
    end
end

function vox.f4:GetSortedTabs()
    local sorted = {}

    for id, tab in pairs(vox.f4.tabs) do
        table.insert(sorted, tab)
    end

    table.sort(sorted, function(a, b)
        return a.order < b.order
    end)

    return sorted
end

function vox.f4.ConvertJobColor(color)
    local bEnabled = vox.f4:GetOptionValue('edit_job_colors')
    if (bEnabled) then
        local h, s, v = ColorToHSV(color)
        return vox.ColorEditHSV(color, nil, s - .2, v + .2)
    else
        return color
    end
end

function vox.f4.OpenFrame()
    local frame = vgui.Create('vox.f4.Frame')
    frame:SetSize(ScrW() * .65, ScrH() * .65)
    frame:Center()
    frame:MakePopup()

    return frame
end

function vox.f4.OpenAdminSettings()
    local frame = vgui.Create('vox.Frame')
    frame:SetSize(ScrW() * .66, ScrH() * .66)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('Vox Admin')

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
        desc = vox.lang:Get('addon_settings_desc'),
        icon = 'https://i.imgur.com/ECLKU9s.png',
        class = 'vox.Configuration',
        onSelected = function(panel)
            panel:LoadAddonSettings('f4')
            panel:OpenCategories()
        end
    })

    sidebar:AddTab({
        name = vox.lang:Get('addon_stats_u'),
        desc = vox.lang:Get('addon_stats_desc'),
        icon = 'https://i.imgur.com/L6jCQe0.png',
        class = 'vox.f4.AdminStats'
    })

    sidebar:AddTab({
        name = vox.lang:Get('addon_return_u'),
        desc = vox.lang:Get('addon_return_desc'),
        icon = 'https://i.imgur.com/gCI6kX5.png',
        onClick = function()
            vox.f4.OpenFrame()
            frame:Remove()
            return false
        end
    })

    sidebar:ChooseTab(1)

    return frame
end

hook.Add('ShowSpare2', 'vox.f4', function(ply)
    if (not IsValid(vox.f4.frame)) then
        vox.f4.OpenFrame()
    end
    return true
end)
