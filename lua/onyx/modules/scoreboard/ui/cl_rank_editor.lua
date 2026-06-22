-- by p1ng :D

local COLOR_PRIMARY = onyx:Config('colors.primary')
local COLOR_SECONDARY = onyx:Config('colors.secondary')
local COLOR_TERTIARY = onyx:Config('colors.tertiary')
local COLOR_ACCENT = onyx:Config('colors.accent')

local PANEL = {}

function PANEL:Init()
    self.list = self:Add('onyx.ScrollPanel')

    self.grid = self.list:Add('onyx.Grid')
    self.grid:SetColumnCount(2)
    self.grid:SetSpace(onyx.ScaleTall(5))

    self.editor = self:Add('onyx.ScrollPanel')
    self.editor:Hide()

    self:InitEditor(self.editor)
    self:LoadRanks()

    hook.Add('onyx.scoreboard.SyncedRanks', self, function()
        self.grid:Clear()
        self:LoadRanks()
    end)
end

function PANEL:ShowEditor()
    self.editor:Show()
    self.editor:SetAlpha(0)
    self.editor:AlphaTo(255, .1)

    self.list:Hide()
end

function PANEL:HideEditor()
    self.list:Show()
    self.list:SetAlpha(0)
    self.list:AlphaTo(255, .1)

    self.editor:Hide()
end

function PANEL:PerformLayout(w, h)
    self.list:Dock(FILL)
    self.editor:Dock(FILL)
end

function PANEL:LoadRanks()
    local btnCreate = self.grid:Add('onyx.Button')
    btnCreate:SetText(onyx.utf8.upper(onyx.lang:Get('create_new')))
    btnCreate:SetTall(onyx.ScaleTall(40))
    btnCreate:SetColorIdle(COLOR_SECONDARY)
    btnCreate:SetColorHover(COLOR_TERTIARY)
    btnCreate.DoClick = function(panel)
        self:LoadEditorRank()
        self:ShowEditor()
    end

    self.grid:AddItem(btnCreate)

    for uniqueID, data in pairs(onyx.scoreboard.ranks) do
        local name = data.name
        local title = uniqueID .. (name ~= '' and string.format(' (%s)', name) or '')

        local btnRank = self.grid:Add('onyx.Button')
        btnRank:SetText(title)
        btnRank:SetTall(onyx.ScaleTall(40))
        btnRank:SetColorIdle(COLOR_SECONDARY)
        btnRank:SetColorHover(COLOR_TERTIARY)
        btnRank.DoClick = function(panel)
            self:LoadEditorRank(data, uniqueID)
            self:ShowEditor()
        end
        self.grid:AddItem(btnRank)
    end
end

function PANEL:LoadEditorRank(data, uniqueID)
    local fields = self.fields
    if (istable(data)) then
        -- load
        self.editor.header:SetText(data.name)
        self.btnDelete:Show()
        self.btnDelete.DoClick = function(panel)
            net.Start('onyx.scoreboard:DeleteRank')
                net.WriteString(uniqueID)
            net.SendToServer()

            self:HideEditor()
        end

        fields['uniqueID'].input:SetDisabled(true)
        fields['uniqueID'].input:SetValue(uniqueID)
        fields['name'].input:SetValue(data.name)
        fields['color'].input.picker:SetColor(data.color)

        local option, index = fields['effect'].input:FindOptionByData(data.effectID)
        if (option) then
            fields['effect'].input:ChooseOptionID(index)
        end
    else
        -- reset
        self.editor.header:SetText(onyx.utf8.upper(onyx.lang:Get('creation')))
        self.btnDelete:Hide()

        fields['uniqueID'].input:SetDisabled(false)
        fields['uniqueID'].input:SetValue('')
        fields['name'].input:SetValue('')
        fields['color'].input.picker:SetColor(color_white)
        fields['effect'].input:Reset()
    end
end

function PANEL:InitEditor(editor)
    local header = editor:Add('onyx.Label')
    header:SetTall(onyx.ScaleTall(40))
    header:SetText('')
    header:Dock(TOP)
    header:CenterText()
    header.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLOR_SECONDARY)
    end
    editor.header = header

    local btnBack = header:Add('onyx.ImageButton')
    btnBack:SetWide(header:GetTall())
    btnBack:Dock(LEFT)
    btnBack:SetImageScale(.75)
    btnBack:SetURL('https://i.imgur.com/B9XOMVX.png', 'smooth mips')
    btnBack.DoClick = function()
        self:HideEditor()
    end

    self.btnDelete = header:Add('onyx.ImageButton')
    self.btnDelete:SetWide(header:GetTall())
    self.btnDelete:Dock(RIGHT)
    self.btnDelete:SetImageScale(.75)
    self.btnDelete:SetURL('https://i.imgur.com/nmT20xe.png', 'smooth mips')

    self.fields = {}
    self:CreateField(editor, 'uniqueID', onyx.utf8.upper(onyx.lang:Get('rank_id')), function(container)
        local entry = container:Add('onyx.TextEntry')
            entry:SetPlaceholderText('admin')
            entry.textEntry:SetMaximumCharCount(24)
        return entry
    end)

    self:CreateField(editor, 'name', onyx.utf8.upper(onyx.lang:Get('name')), function(container)
        local entry = container:Add('onyx.TextEntry')
            entry:SetPlaceholderText('Administrator')
            entry.textEntry:SetMaximumCharCount(24)
        return entry
    end)

    self:CreateField(editor, 'effect', onyx.utf8.upper(onyx.lang:Get('effect')), function(container)
        local combo = container:Add('onyx.ComboBox')
            for _, data in ipairs(onyx.scoreboard.nameEffects) do
                combo:AddOption(onyx.lang:Get(data.name), data.id)
            end
        return combo
    end)

    self:CreateField(editor, 'color', onyx.utf8.upper(onyx.lang:Get('color')), function(container)
        local panel = container:Add('Panel')

        local picker = panel:Add('DColorMixer')
        picker:Dock(FILL)
        picker:SetAlphaBar(false)
        picker:SetPalette(false)
        panel.picker = picker

        return panel
    end, 150)

    self:CreateField(editor, 'preview', onyx.utf8.upper(onyx.lang:Get('preview')), function(container)
        local name = LocalPlayer():Name()
        local preview = container:Add('onyx.Panel')
            preview.Paint = function(panel, w, h)
                local effectID = self.fields.effect.input:GetOptionData()
                local effectData = onyx.scoreboard:FindNameEffect(effectID or '')
                local color = self.fields.color.input.picker:GetColor()

                draw.RoundedBox(8, 0, 0, w, h, COLOR_SECONDARY)
                draw.RoundedBox(8, 1, 1, w - 2, h - 2, COLOR_PRIMARY)

                if (effectData) then
                    local realX, realY = panel:LocalToScreen(0, 0)
                    local x, y = onyx.ScaleTall(10), h * .5

                    effectData.func(name, x, y, color, 0, 1, realX + x, realY + y)
                end
            end
        return preview
    end)

    self.btnSave = editor:Add('onyx.Button')
    self.btnSave:SetText(onyx.utf8.upper(onyx.lang:Get('save')))
    self.btnSave:Dock(TOP)
    self.btnSave.DoClick = function(panel)
        local fields = self.fields
        local uniqueID = fields['uniqueID'].input:GetValue():Trim()
        local name = fields['name'].input:GetValue():Trim()
        local effect = fields['effect'].input:GetOptionData()
        local color = fields['color'].input.picker:GetColor()

        if (utf8.len(uniqueID) < 1 or utf8.len(uniqueID) > 24) then
            fields['uniqueID'].input:Highlight(Color(255, 0, 0), 1)
            return
        end

        if (utf8.len(name) > 24) then
            fields['name'].input:Highlight(Color(255, 0, 0), 1)
            return
        end

        net.Start('onyx.scoreboard:ReplaceRank')
            net.WriteString(uniqueID)
            net.WriteString(name)
            net.WriteString(effect)
            net.WriteColor(Color(color.r, color.g, color.b)) -- DColorMixer doesn't return Color object...
        net.SendToServer()

        self:HideEditor()
    end
end

function PANEL:CreateField(editor, key, title, buildFunc, size)
    local font = onyx.Font('Comfortaa SemiBold@14')
    local margin = onyx.ScaleTall(7.5)

    local field = editor:Add('Panel')
    field:Dock(TOP)
    field:SetTall(onyx.ScaleTall(size or 70))
    field.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLOR_PRIMARY)
    end

    local header = field:Add('Panel')
    header:SetTall(onyx.ScaleTall(25))
    header:Dock(TOP)
    header.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, COLOR_SECONDARY, true, true)
        draw.SimpleText(title, font, onyx.ScaleTall(10), h * .5, color_white, 0, 1)
    end

    local container = field:Add('Panel')
    container:DockMargin(margin, margin, margin, margin)
    container:Dock(FILL)

    self.fields[key] = field

    if (isfunction(buildFunc)) then
        local panel = buildFunc(container)
        assert(panel, string.format('Invalid panel created (%s)', tostring(panel)))
        panel:Dock(FILL)

        field.input = panel
    end
end

onyx.gui.Register('onyx.scoreboard.RankEditor', PANEL)

-- if (IsValid(DebugPanel)) then
--     DebugPanel:Remove()
-- end

-- DebugPanel = onyx.scoreboard.OpenAdminSettings(2)