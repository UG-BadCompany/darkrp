local colorPrimary = vox:Config('colors.primary')
local colorSecondary = vox:Config('colors.secondary')
local colorTertiary = vox:Config('colors.tertiary')
local colorLine = Color(75, 75, 75)

local L = function(...) return vox.lang:Get(...) end
local function getThemeColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or colorPrimary, colors.secondary or colorSecondary, colors.tertiary or colorTertiary, colors.accent or Color(70,135,255)
end

do
    local PANEL = {}

    function PANEL:Init()
        local toolbarPadding = vox.ScaleTall(5)

        self.container = self:Add('Panel')
        self.container:Dock(FILL)

        self.toolbar = self:Add('DPanel')
        self.toolbar:Dock(TOP)
        self.toolbar:SetTall(vox.ScaleTall(80))
        self.toolbar:DockMargin(0, 0, 0, vox.ScaleTall(10))
        self.toolbar.Paint = function(panel, w, h)
            local _, secondary = getThemeColors()
            draw.RoundedBox(8, 0, 0, w, h, secondary)
        end
        self.toolbar.PerformLayout = function(panel, w, h)
            self.topRow:SetTall(h / 2)
        end

        self.topRow = self.toolbar:Add('Panel')
        self.topRow:Dock(BOTTOM)
        self.topRow:DockPadding(toolbarPadding, toolbarPadding, toolbarPadding, toolbarPadding)

        self.combo = self.topRow:Add('vox.ComboBox')
        self.combo:Dock(LEFT)
        self.combo:SetWide(vox.ScaleWide(200))
        self.combo:AddOption('Today')
        self.combo:AddOption('Week')
        self.combo:AddOption('Month')
        self.combo:ChooseOptionID(1)
        self.combo.OnSelect = function(panel, index)
            local tab = self.navbar:GetActiveTab()
            if (IsValid(tab)) then
                local content = tab.content
                if (IsValid(content)) then
                    content.timeSelected = index
                    content:RequestData()
                end
            end
        end

        self.navbar = self.toolbar:Add('vox.Navbar')
        self.navbar:Dock(FILL)
        self.navbar:SetContainer(self.container)
        self.navbar:SetKeepTabContent(true)
        self.navbar.Paint = function(panel, w, h)
            local _, _, tertiary, accent = getThemeColors()
            draw.RoundedBoxEx(8, 0, 0, w, h, tertiary, true, true)
            surface.SetDrawColor(ColorAlpha(accent, 90))
            surface.DrawRect(0, h - 1, w, 1)
        end
        self.navbar.OnTabSelected = function(panel, tab, content)
            content.timeSelected = self.combo.current
            content:RequestData()
        end

        self.navbar:AddTab({
            name = L('f4_jobs_u'),
            class = 'vox.f4.AdminStatsBase',
            onBuild = function(content)
                content:SetObjectType('job')
                content:LoadObjects(RPExtraTeams, 'command', L('f4_switches'))
            end
        })

        self.navbar:AddTab({
            name = L('f4_entities_u'),
            class = 'vox.f4.AdminStatsBase',
            onBuild = function(content)
                content:SetObjectType('entity')
                content:LoadObjects(DarkRPEntities, 'ent')
            end
        })

        self.navbar:AddTab({
            name = L('f4_weapons_u'),
            class = 'vox.f4.AdminStatsBase',
            onBuild = function(content)
                local guns = {}
                for _, shipment in ipairs(CustomShipments) do
                    if (shipment.separate) then
                        table.insert(guns, shipment)
                    end
                end

                content:SetObjectType('gun')
                content:LoadObjects(guns, 'entity')
            end
        })

        self.navbar:AddTab({
            name = L('f4_shipments_u'),
            class = 'vox.f4.AdminStatsBase',
            onBuild = function(content)
                local shipments = {}
                for _, shipment in ipairs(CustomShipments) do
                    if (not shipment.noship) then
                        table.insert(shipments, shipment)
                    end
                end

                content:SetObjectType('shipment')
                content:LoadObjects(shipments, 'entity')
            end
        })

        self.navbar:ChooseTab(1)
    end

    vox.gui.Register('vox.f4.AdminStats', PANEL)
end

do
    local PANEL = {}
    local fontTitle = vox.Font('Comfortaa Bold@16')
    local colorLabel = color_white

    AccessorFunc(PANEL, 'm_ObjectType', 'ObjectType')

    function PANEL:Init()
        self.cache = {}
        self.objects = {}
        self.smallHeaderHeight = vox.ScaleTall(25)

        self:InitBlock('List', L('f4_mostpopular_u'), 'vox.ScrollPanel')
        self:InitBlock('Graph', L('f4_chart_u'), 'vox.PieChart')

        local phraseLoading = L('f4_loading_u')
        local phraseEmpty = L('f4_empty_u')

        self.divGraph.content:SetDonut(true)
        self.divGraph.content.loading = true
        self.divGraph.content.PostDrawChart = function(panel, w, h)
            if (panel.loading) then
                draw.SimpleText(phraseLoading, fontTitle, w * .5, h * .5, color_white, 1, 1)
            elseif (#panel.m_Data == 0) then
                draw.SimpleText(phraseEmpty, fontTitle, w * .5, h * .5, color_white, 1, 1)
            end
        end

        hook.Add('vox.f4.StatsReceived', self, function(panel, data)
            if (data.objectType == panel:GetObjectType()) then
                panel:LoadData(data.result)
                panel.cache[panel.timeSelected] = data.result
            end
        end)
    end

    function PANEL:LoadObjects(items, key, label)
        local objectType = self:GetObjectType() or ''
        local scrollPanel = self.divList.content
        for _, item in ipairs(items) do
            local name = item.name
            local model = istable(item.model) and item.model[1] or item.model
            local color = item.color or color_white
            local id = item[key]

            local panel = scrollPanel:Add('vox.f4.Item')
            panel:SetName(name)
            panel:SetModel(model)
            panel:SetColor(color, .1)
            panel:SetDesc(L('f4_loading') .. '...')
            panel:SetDescLabel(label or L('f4_purchases'))
            panel:SetDescColor(color_white)
            panel:SetTall(vox.ScaleTall(50))

            if (objectType == 'job') then
                panel:PositionCamera('face')
                panel.uniqueColor = true
            else
                panel:PositionCamera('center')
            end

            self.objects[id] = panel
        end
    end

    function PANEL:PerformLayout(w, h)
        local margin = vox.ScaleTall(10)

        self.divList:Dock(LEFT)
        self.divList:SetWide(w / 2)
        self.divList:DockMargin(0, 0, vox.ScaleWide(10), 0)
        self.divList.content:DockMargin(margin, 0, margin, margin)

        self.divGraph:Dock(TOP)
        self.divGraph:SetTall(h / 2)
        self.divGraph.content:DockMargin(margin, 0, margin, margin)
    end

    function PANEL:InitBlock(id, title, class)
        local block = self:Add('Panel')
        block.Paint = function(panel, w, h)
            local primary, secondary, _, accent = getThemeColors()
            if vox.DrawVoxPanel then
                vox.DrawVoxPanel(0, 0, w, h, { primary = primary, secondary = secondary, accent = accent }, 8)
            else
                draw.RoundedBox(8, 0, 0, w, h, primary)
            end
        end

        local header = block:Add('vox.Label')
        header:SetText(title)
        header:SetFont(fontTitle)
        header:SetTextColor(colorLabel)
        header:Dock(TOP)
        header:DockMargin(0, 0, 0, vox.ScaleTall(10))
        header:CenterText()
        header:SetTall(self.smallHeaderHeight)
        header.Paint = function(panel, w, h)
            local _, secondary, _, accent = getThemeColors()
            draw.RoundedBoxEx(8, 0, 0, w, h, secondary, true, true)
            surface.SetDrawColor(ColorAlpha(accent, 90))
            surface.DrawRect(vox.ScaleWide(12), h - 1, w - vox.ScaleWide(24), 1)
        end

        local content = block:Add(class or 'Panel')
        content:Dock(FILL)

        block.content = content

        self['div' .. id] = block
    end

    function PANEL:RequestData()
        local timeSelected = self.timeSelected
        if (not self.cache[timeSelected]) then
            net.Start('vox.f4:RequestStats')
                net.WriteString(self:GetObjectType())
                net.WriteUInt(self.timeSelected - 1, 2)
            net.SendToServer()
        else
            self:LoadData(self.cache[timeSelected])
        end
    end

    function PANEL:LoadData(result)
        local records = #result
        local graph = self.divGraph.content
        local angle = math.Round(360 / records)

        table.sort(result, function(a, b)
            return a.amount > b.amount
        end)

        for _, item in pairs(self.objects) do
            item.found = false
        end

        graph:SetData({})
        for index, record in ipairs(result) do
            local id = record.objectID
            local item = self.objects[id]
            if (IsValid(item)) then
                item:SetZPos(index)
                item:SetDesc(record.amount)
                item.found = true

                if (index < 6) then
                    local uniqueColor = vox.ColorEditHSV(color_white, angle * (index - 1), .6)
                    if (item.uniqueColor) then
                        graph:AddRecord(item:GetName(), tonumber(record.amount), item.itemColor)
                    else
                        graph:AddRecord(item:GetName(), tonumber(record.amount), uniqueColor)
                    end
                end
            end
        end

        for _, item in pairs(self.objects) do
            if (not item.found) then
                item:SetZPos(records + 1)
                item:SetDesc(0)
            end
        end

        graph.loading = false
    end

    vox.gui.Register('vox.f4.AdminStatsBase', PANEL)
end

--[[------------------------------
TEST
--------------------------------]]
-- if (IsValid(DebugPanel)) then
--     DebugPanel:Remove()
-- end
-- DebugPanel = vox.f4.OpenAdminSettings()
