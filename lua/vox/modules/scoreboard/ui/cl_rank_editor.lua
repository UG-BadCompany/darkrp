local COLOR_PRIMARY = vox:Config('colors.primary')
local COLOR_SECONDARY = vox:Config('colors.secondary')
local COLOR_TERTIARY = vox:Config('colors.tertiary')
local COLOR_ACCENT = vox:Config('colors.accent')

local PANEL = {}

function PANEL:Init()
    self.list = self:Add('vox.ScrollPanel')

    self.grid = self.list:Add('vox.Grid')
    self.grid:SetColumnCount(2)
    self.grid:SetSpace(vox.ScaleTall(5))

    self.editor = self:Add('vox.ScrollPanel')
    self.editor:Hide()

    self:InitEditor(self.editor)
    self:LoadRanks()

    hook.Add('vox.scoreboard.SyncedRanks', self, function()
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
    local btnCreate = self.grid:Add('vox.Button')
    btnCreate:SetText(vox.utf8.upper(vox.lang:Get('create_new')))
    btnCreate:SetTall(vox.ScaleTall(40))
    btnCreate:SetColorIdle(COLOR_SECONDARY)
    btnCreate:SetColorHover(COLOR_TERTIARY)
    btnCreate.DoClick = function(panel)
        self:LoadEditorRank()
        self:ShowEditor()
    end

    self.grid:AddItem(btnCreate)

    for uniqueID, data in pairs(vox.scoreboard.ranks) do
        local name = data.name
        local title = uniqueID .. (name ~= '' and string.format(' (%s)', name) or '')

        local btnRank = self.grid:Add('vox.Button')
        btnRank:SetText(title)
        btnRank:SetTall(vox.ScaleTall(40))
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
            net.Start('vox.scoreboard:DeleteRank')
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
        self.editor.header:SetText(vox.utf8.upper(vox.lang:Get('creation')))
        self.btnDelete:Hide()

        fields['uniqueID'].input:SetDisabled(false)
        fields['uniqueID'].input:SetValue('')
        fields['name'].input:SetValue('')
        fields['color'].input.picker:SetColor(color_white)
        fields['effect'].input:Reset()
    end
end

function PANEL:InitEditor(editor)
    local header = editor:Add('vox.Label')
    header:SetTall(vox.ScaleTall(40))
    header:SetText('')
    header:Dock(TOP)
    header:CenterText()
    header.Paint = function(panel, w, h)
        vox.DrawVoxPanel(0, 0, w, h, { primary = COLOR_SECONDARY, secondary = COLOR_PRIMARY, accent = COLOR_ACCENT }, 8)
        vox.DrawAngledRect(w - vox.ScaleWide(70), 0, vox.ScaleWide(70), h, vox.ScaleWide(14), ColorAlpha(COLOR_ACCENT, 45))
    end
    editor.header = header

    local btnBack = header:Add('vox.ImageButton')
    btnBack:SetWide(header:GetTall())
    btnBack:Dock(LEFT)
    btnBack:SetImageScale(.75)
    btnBack:SetURL('https://i.imgur.com/B9XOMVX.png', 'smooth mips')
    btnBack.DoClick = function()
        self:HideEditor()
    end

    self.btnDelete = header:Add('vox.ImageButton')
    self.btnDelete:SetWide(header:GetTall())
    self.btnDelete:Dock(RIGHT)
    self.btnDelete:SetImageScale(.75)
    self.btnDelete:SetURL('https://i.imgur.com/nmT20xe.png', 'smooth mips')

    self.fields = {}
    self:CreateField(editor, 'uniqueID', vox.utf8.upper(vox.lang:Get('rank_id')), function(container)
        local entry = container:Add('vox.TextEntry')
            entry:SetPlaceholderText('admin')
            entry.textEntry:SetMaximumCharCount(24)
        return entry
    end)

    self:CreateField(editor, 'name', vox.utf8.upper(vox.lang:Get('name')), function(container)
        local entry = container:Add('vox.TextEntry')
            entry:SetPlaceholderText('Administrator')
            entry.textEntry:SetMaximumCharCount(24)
        return entry
    end)

    self:CreateField(editor, 'effect', vox.utf8.upper(vox.lang:Get('effect')), function(container)
        local combo = container:Add('vox.ComboBox')
            for _, data in ipairs(vox.scoreboard.nameEffects) do
                combo:AddOption(vox.lang:Get(data.name), data.id)
            end
        return combo
    end)

    self:CreateField(editor, 'color', vox.utf8.upper(vox.lang:Get('color')), function(container)
        local panel = container:Add('Panel')

        local picker = panel:Add('DColorMixer')
        picker:Dock(FILL)
        picker:SetAlphaBar(false)
        picker:SetPalette(false)
        panel.picker = picker

        return panel
    end, 150)

    self:CreateField(editor, 'preview', vox.utf8.upper(vox.lang:Get('preview')), function(container)
        local name = LocalPlayer():Name()
        local preview = container:Add('vox.Panel')
            preview.Paint = function(panel, w, h)
                local effectID = self.fields.effect.input:GetOptionData()
                local effectData = vox.scoreboard:FindNameEffect(effectID or '')
                local color = self.fields.color.input.picker:GetColor()

                vox.DrawVoxPanel(0, 0, w, h, { primary = COLOR_PRIMARY, secondary = COLOR_SECONDARY, accent = color }, 8)

                if (effectData) then
                    local realX, realY = panel:LocalToScreen(0, 0)
                    local x, y = vox.ScaleTall(10), h * .5

                    effectData.func(name, x, y, color, 0, 1, realX + x, realY + y)
                end
            end
        return preview
    end)

    self.btnSave = editor:Add('vox.Button')
    self.btnSave:SetText(vox.utf8.upper(vox.lang:Get('save')))
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

        net.Start('vox.scoreboard:ReplaceRank')
            net.WriteString(uniqueID)
            net.WriteString(name)
            net.WriteString(effect)
            net.WriteColor(Color(color.r, color.g, color.b)) -- DColorMixer doesn't return Color object...
        net.SendToServer()

        self:HideEditor()
    end
end

function PANEL:CreateField(editor, key, title, buildFunc, size)
    local font = vox.Font('Comfortaa SemiBold@14')
    local margin = vox.ScaleTall(7.5)

    local field = editor:Add('Panel')
    field:Dock(TOP)
    field:SetTall(vox.ScaleTall(size or 70))
    field.Paint = function(panel, w, h)
        vox.DrawVoxPanel(0, 0, w, h, { primary = COLOR_PRIMARY, secondary = COLOR_SECONDARY, accent = COLOR_ACCENT }, 8)
    end

    local header = field:Add('Panel')
    header:SetTall(vox.ScaleTall(25))
    header:Dock(TOP)
    header.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, ColorAlpha(COLOR_SECONDARY, 225), true, true)
        vox.DrawVoxBlade(0, vox.ScaleTall(5), vox.ScaleWide(5), h - vox.ScaleTall(10), COLOR_ACCENT)
        draw.SimpleText(title, font, vox.ScaleTall(10), h * .5, color_white, 0, 1)
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

vox.gui.Register('vox.scoreboard.RankEditor', PANEL)

-- if (IsValid(DebugPanel)) then
--     DebugPanel:Remove()
-- end

-- DebugPanel = vox.scoreboard.OpenAdminSettings(2)
