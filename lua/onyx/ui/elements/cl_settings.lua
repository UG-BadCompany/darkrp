--[[

Author: tochnonement
Email: tochnonement@gmail.com

08/03/2023

--]]

local PANEL = {}

local colorPrimary = onyx:Config('colors.primary')
local colorSecondary = onyx:Config('colors.secondary')
local colorAccent = onyx:Config('colors.accent')
local colorNegative = onyx:Config('colors.negative')

local font0 = onyx.Font('Comfortaa Bold@16')
local font3 = onyx.Font('Comfortaa@14')

local MAT_SAVE = Material('onyx_framework/save.png', 'smooth mips')

function PANEL:Init()
    self.list = self:Add('onyx.ScrollPanel')
    self.list:Dock(FILL)

    self.categories = {}
    self.options = {}

    self.confirmPopup = self:Add('DPanel')
    self.confirmPopup:SetWide(onyx.ScaleWide(225))
    self.confirmPopup:SetTall(onyx.ScaleTall(75))
    self.confirmPopup:Hide()
    self.confirmPopup.Paint = function(panel, w, h)
        local x, y = panel:LocalToScreen(0, 0)

        if (panel.anim == 0 or panel.anim == 1) then
            onyx.bshadows.BeginShadow()
                draw.RoundedBox(8, x, y, w, h, colorSecondary)
            onyx.bshadows.EndShadow(1, 2, 2)
        else
            draw.RoundedBox(8, 0, 0, w, h, colorSecondary)
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

        surface.SetDrawColor(colorNegative)
        surface.SetMaterial(MAT_SAVE)
        surface.DrawTexturedRect(h * .5 - size * .5, h * .5 - size * .5, size, size)

        draw.SimpleText(panel.text1, font0, h, h * .5, colorNegative, 0, 4)
        draw.SimpleText(panel.text2, font3, h, h * .5, color_white, 0, 0)
    end

    self.confirmPopup.button = self.confirmPopup:Add('onyx.Button')
    self.confirmPopup.button:SetText(onyx.lang:GetWFallback('save_u', 'SAVE'))
    self.confirmPopup.button:SetFont(font0)
    self.confirmPopup.button:SetColorIdle(colorNegative)
    self.confirmPopup.button:SetColorHover(onyx.OffsetColor(colorNegative, -20))
    self.confirmPopup.button.DoClick = function()
        local changes = self:GetChanges()
        if (changes) then
            local amount = table.Count(changes)
            if (amount > 0) then

                -- better than sending multiple packets bc a lot of large-scale servers have anti net spam and etc.
                net.Start('onyx.inconfig:SetTable')
                    net.WriteUInt(amount, 6)
                    for id, value in pairs(changes) do
                        net.WriteString(id)
                        net.WriteString(onyx.TypeToString(value))
                    end
                net.SendToServer()
            end
        end
    end
end

local translate do
    local enums = {}
    enums[onyx.inconfig.Error.INVALID_VALUE] = 'The value must be valid!'
    enums[onyx.inconfig.Error.NUMBER_EXPECTED] = 'The must enter a valid number!'
    enums[onyx.inconfig.Error.STRING_EXPECTED] = 'The text entry cannot be empty!'
    enums[onyx.inconfig.Error.MIN_CHARS] = 'The text must contain more than %i characters!'
    enums[onyx.inconfig.Error.MAX_CHARS] = 'The text must contain less than %i characters!'
    enums[onyx.inconfig.Error.MIN_NUMBER] = 'The number must be higher than %i!'
    enums[onyx.inconfig.Error.MAX_NUMBER] = 'The number must be lower than %i!'
    enums[onyx.inconfig.Error.INVALID_MODEL] = 'The model path must be valid!'

    function translate(enumError, argument)
        local text = enums[enumError] or 'invalid'
        return Format(text, argument)
    end
end

function PANEL:GetChanges(doNotify)
    local changes = {}

    for _, option in ipairs(self.options) do
        local id = option.id
        local newValue = option.getNewValue()
        local curValue = onyx.inconfig:Get(id)
        local valid, err, arg1 = onyx.inconfig:CheckValue(id, newValue)
        local field = option.field
        if (valid) then
            if (field._oldDesc) then
                field.lblDesc:SetText(field._oldDesc)
                field.lblDesc:SetTextColor(color_white)

                if (field.textEntry) then
                    field.textEntry:ResetHighlight()
                end

                field._oldDesc = nil
            end

            if (newValue ~= curValue) then
                changes[id] = newValue
            end
        else
            local entry = field.textEntry
            local textError = isstring(err) and err or translate(err, arg1)

            field._oldDesc = field._oldDesc or field.lblDesc:GetText()
            field.lblDesc:SetTextColor(colorNegative)
            field.lblDesc:SetText(textError)

            if (IsValid(entry)) then
                entry:Highlight(colorNegative)
            end

            if (doNotify) then
                notification.AddLegacy(textError, 1, 5)
            end
        end
    end

    return changes
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

            onyx.anim.Create(confirmPopup, .2, {
                index = 2,
                easing = 'inOutQuad',
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

        self.nextThink = CurTime() + .25
    end
end

function PANEL:PerformLayout(w, h)
end

function PANEL:LoadAddonSettings(addonID)
    for _, id in ipairs(onyx.inconfig.index) do
        local option = onyx.inconfig.options[id]
        if (option and option.addon and option.addon == addonID) then
            self:AddOption(table.Copy(option))
        end
    end
end

function PANEL:OpenCategories()
    for name, cat in pairs(self.categories) do
        cat:SetExpanded(true)
        cat:UpdateInTick(1)
        cat:UpdateInTick(10)
    end
end

function PANEL:AddOption(option)
    local category = option.category or 'Other'

    table.insert(self.options, option)

    local categoryPanel = self.categories[category]
    if (not categoryPanel) then
        local translatedName = onyx.utf8.upper( onyx.lang:Get( category ) )

        categoryPanel = self.list:Add('onyx.Category')
        categoryPanel:Dock(TOP)
        categoryPanel:SetTitle(translatedName)
        categoryPanel:SetSpace(0)
        categoryPanel:SetInset(onyx.ScaleTall(5))
        categoryPanel:SetTextMargin(onyx.ScaleTall(10))
        categoryPanel:DockMargin(0, 0, 0, onyx.ScaleTall(10))

        categoryPanel.grid = categoryPanel:Add('onyx.Grid')
        categoryPanel.grid:Dock(TOP)
        categoryPanel.grid:SetColumnCount(2)
        categoryPanel.grid:SetSpace(onyx.ScaleTall(5))

        categoryPanel.canvas.Paint = function(p, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colorPrimary)
        end

        self.categories[category] = categoryPanel
    end

    local padding = onyx.ScaleTall(7.5)
    local value = onyx.inconfig:Get(option.id)
    local desc = onyx.lang:Get(option.desc)
    local sType = option.type

    if (sType == 'int' and (option.min or option.max) and not option.combo) then
        desc = desc .. ' (' .. (option.min or '∞') .. ' - ' .. (option.max or '∞') .. ')'
    end

    local field = categoryPanel.grid:Add('DPanel')
    field:SetTall(onyx.ScaleTall(45))
    field:DockPadding(padding, padding, padding, padding)
    field.Paint = function(p, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colorSecondary)
    end

    option.field = field

    local lblName = field:Add('onyx.Label')
    lblName:Font('Comfortaa Bold@16')
    lblName:SetText(onyx.lang:Get(option.title))
    lblName:Color(colorAccent)
    lblName:SetContentAlignment(1)
    lblName:Dock(FILL)

    local lblDesc = field:Add('onyx.Label')
    lblDesc:Font('Comfortaa@14')
    lblDesc:SetText(desc)
    lblDesc:SetContentAlignment(7)
    lblDesc:SetTall((field:GetTall() - padding * 2) * .5)
    lblDesc:Dock(BOTTOM)
    field.lblDesc = lblDesc

    local container = field:Add('Panel')
    container:Dock(RIGHT)
    container:SetWide(onyx.ScaleWide(150))
    container:SetZPos(-1)

    if (option.combo) then
        local combo = container:Add('onyx.ComboBox')
        combo:Dock(FILL)

        for i, opt in ipairs(option.combo) do
            combo:AddOption(onyx.lang:Get(opt[1]), opt[2])

            if (opt[2] == value) then
                combo:ChooseOptionID(i)
            end
        end

        container:SetWide(onyx.ScaleWide(200))

        option.getNewValue = function()
            return combo:GetOptionData( combo:GetSelectedID() )
        end

        field.combo = textEntry

        return
    end

    if (sType == 'string' or sType == 'int' or sType == 'model') then
        local textEntry = container:Add('onyx.TextEntry')
        textEntry:Dock(FILL)
        textEntry:SetValue(value)

        if (sType == 'int') then
            container:SetWide(onyx.ScaleWide(75))
        else
            container:SetWide(onyx.ScaleWide(200))
        end

        option.getNewValue = function()
            if (sType == 'int') then
                return tonumber(textEntry:GetValue())
            else
                return textEntry:GetValue()
            end
        end

        field.textEntry = textEntry
    elseif (sType == 'bool') then
        local check = container:Add('onyx.CheckBox')
        check:SetValue(value)

        option.getNewValue = function()
            return check:GetChecked()
        end

        container:SetWide(onyx.ScaleWide(75))

        container.PerformLayout = function(panel, w, h)
            local child = panel:GetChild(0)
            if (IsValid(child)) then
                child:AlignRight(0)
                child:CenterVertical()
            end
        end
    end
end

onyx.gui.Register('onyx.Configuration', PANEL)