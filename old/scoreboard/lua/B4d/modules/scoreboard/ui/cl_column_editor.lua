-- by p1ng :D

local COLOR_PRIMARY = onyx:Config('colors.primary')
local COLOR_SECONDARY = onyx:Config('colors.secondary')
local COLOR_TERTIARY = onyx:Config('colors.tertiary')
local COLOR_ACCENT = onyx:Config('colors.accent')
local COLOR_BG = onyx.ColorBetween(COLOR_PRIMARY, COLOR_SECONDARY)
local COLOR_NEGATIVE = onyx:Config('colors.negative')

local WIMG_SAVE = onyx.wimg.Simple('https://i.imgur.com/ycSNF3m.png', 'smooth mips')
local PANEL = {}

function PANEL:Init()
    self.list = self:Add('onyx.ScrollPanel')
    self.list:Dock(FILL)

    self.grid = self.list:Add('onyx.Grid')
    self.grid:SetColumnCount(2)
    self.grid:SetSpace(onyx.ScaleTall(5))

    self.columns = {}
    self.default = {}
    self.changes = {}

    hook.Add('onyx.scoreboard.SyncedColumns', self, function(panel)
        panel.grid:Clear()
        panel.columns = {}
        panel.default = {}
        panel.changes = {}
        panel:LoadColumns()
    end)

    self:LoadColumns()
    self:AddSavePopup()
end

function PANEL:AddSavePopup()
    local font0 = onyx.Font('Comfortaa Bold@16')
    local font3 = onyx.Font('Comfortaa@14')

    self.confirmPopup = self:Add('DPanel')
    self.confirmPopup:SetWide(onyx.ScaleWide(225))
    self.confirmPopup:SetTall(onyx.ScaleTall(75))
    self.confirmPopup.Paint = function(panel, w, h)
        local x, y = panel:LocalToScreen(0, 0)

        if (panel.anim == 0 or panel.anim == 1) then
            onyx.bshadows.BeginShadow()
                draw.RoundedBox(8, x, y, w, h, COLOR_SECONDARY)
            onyx.bshadows.EndShadow(1, 2, 2)
        else
            draw.RoundedBox(8, 0, 0, w, h, COLOR_SECONDARY)
        end
    end
    self.confirmPopup.PerformLayout = function(panel, w, h)
        local padding = ScreenScale(2)

        panel:DockPadding(padding, padding, padding, padding)

        panel.info:Dock(FILL)
        panel.info:DockMargin(0, 0, 0, onyx.ScaleTall(5))
        panel.button:Dock(BOTTOM)
        panel.button:SetTall(onyx.ScaleTall(20))
    end

    self.confirmPopup.info = self.confirmPopup:Add('Panel')
    self.confirmPopup.info.text1 = onyx.lang:GetWFallback('unsavedSettings', 'UNSAVED SETTINGS')
    self.confirmPopup.info.text2 = onyx.lang:GetWFallback('confirmSave', 'Confirm to save the changes')
    self.confirmPopup.info.Paint = function(panel, w ,h)
        local size = math.ceil(h * .5)

        WIMG_SAVE:Draw(h * .5 - size * .5, h * .5 - size * .5, size, size, COLOR_NEGATIVE)

        draw.SimpleText(panel.text1, font0, h, h * .5, COLOR_NEGATIVE, 0, 4)
        draw.SimpleText(panel.text2, font3, h, h * .5, color_white, 0, 0)
    end

    self.confirmPopup.button = self.confirmPopup:Add('onyx.Button')
    self.confirmPopup.button:SetText(onyx.lang:GetWFallback('save_u', 'SAVE'))
    self.confirmPopup.button:SetFont(font0)
    self.confirmPopup.button:SetColorIdle(COLOR_NEGATIVE)
    self.confirmPopup.button:SetColorHover(onyx.OffsetColor(COLOR_NEGATIVE, -20))
    self.confirmPopup.button.DoClick = function()
        local changes = self:GetChanges()
        if (changes) then
            local amount = table.Count(changes)
            if (amount > 0) then
                net.Start('onyx.scoreboard:SetColumns')
                    net.WriteUInt(amount, 6)
                    for index, value in pairs(changes) do
                        net.WriteUInt(index, 8)
                        net.WriteString(value)
                    end
                net.SendToServer()
            end
        end
    end
end

function PANEL:GetChanges()
    return self.changes
end

function PANEL:Think()
    if ((self.nextThink or 0) <= CurTime()) then
        local changes = self:GetChanges()
        local anim = table.IsEmpty(changes) and 1 or 0
        local confirmPopup = self.confirmPopup

        if ((confirmPopup.targetAnim or -1) ~= anim) then
            confirmPopup.anim = confirmPopup.anim or anim -- skip first anim

            if (anim < 1) then
                confirmPopup:SetVisible(true)
            end

            onyx.anim.Create(confirmPopup, .33, {
                index = 2,
                easing = 'inQuad',
                target = {
                    anim = anim
                },
                think = function(anim, panel)
                    panel:AlignBottom(panel.anim * -panel:GetTall())
                end,
                onFinished = function(anim, panel)
                    panel:SetVisible(panel.anim < 1)
                end
            })

            confirmPopup.targetAnim = anim
        end

        self.nextThink = CurTime() + .5
    end
end

function PANEL:LoadColumns()
    for index = 1, onyx.scoreboard.columnsMaxAmount do
        self:AddColumn(index)
    end
end

function PANEL:AddColumn(index)
    local padding = onyx.ScaleTall(10)

    local panel = self.grid:Add('Panel')
    panel:SetTall(onyx.ScaleTall(70))
    panel:DockPadding(padding, padding, padding, padding)
    panel.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
    end

    self.grid:AddItem(panel)

    local lblTitle = panel:Add('onyx.Label')
    lblTitle:SetText(onyx.lang:Get('column') .. ' #' .. index)
    lblTitle:Dock(TOP)
    lblTitle:Font('Comfortaa Bold@16')
    lblTitle:SizeToContentsY()
    lblTitle:DockMargin(0, 0, 0, onyx.ScaleTall(5))

    local comboType = panel:Add('onyx.ComboBox')
    comboType:Dock(FILL)
    comboType:AddOption(onyx.lang:Get('scoreboard_col_none'), 'none')
    comboType.OnSelect = function(panel, _, text, data)
        if (not self.default[index] or self.default[index] ~= data) then
            self.changes[index] = data
        else
            self.changes[index] = nil
        end
    end

    for columnID, columnData in pairs(onyx.scoreboard.columns) do
        if (not columnData.customCheck or columnData.customCheck()) then
            comboType:AddOption(onyx.lang:Get(columnData.name), columnID)
        end
    end

    local currentID = onyx.scoreboard.columnsCustomizable[index] or onyx.scoreboard.columnsDefault[index] or 'none'

    if (currentID) then
        local optionData, optionIndex = comboType:FindOptionByData(currentID)
        if (optionIndex) then
            comboType:ChooseOptionID(optionIndex, true)
            self.default[index] = currentID
        else
            comboType:SetCurrentOptionText('invalid : ' .. currentID)
            comboType:Highlight(Color(255, 78, 78))
        end
    end

end

onyx.gui.Register('onyx.scoreboard.ColumnEditor', PANEL)

-- if (IsValid(DebugPanel)) then
--     DebugPanel:Remove()
-- end

-- DebugPanel = onyx.scoreboard.OpenAdminSettings(3)