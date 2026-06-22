--[[

Author: tochnonement
Email: tochnonement@gmail.com

02/03/2024

--]]

local COLOR_PRIMARY = onyx:Config('colors.primary')
local COLOR_SECONDARY = onyx:Config('colors.secondary')
local COLOR_TERTIARY = onyx:Config('colors.tertiary')
local COLOR_ACCENT = onyx:Config('colors.accent')
local COLOR_GRAY = Color(149, 149, 149)
local COLOR_GRAY_LIGHT = Color(198, 198, 198)

local WIMG_ARROW = onyx.wimg.Simple('https://i.imgur.com/oOoWQAG.png', 'smooth mips')

local function parseString(str)
    return onyx.utf8.lower(str)
end

local function processSearch(prompt, parentList)
    local prompt = string.lower(prompt):Trim()
    local categories = parentList:GetItems()

    for _, category in ipairs(categories) do
        if (category.ClassName ~= 'onyx.Category') then continue end

        for _, panel in ipairs(category:GetItems()) do
            local line = panel.button:GetChild(0)
            local name = line.parsedName
            local steamID32 = line.steamID32

            if (string.find(name, prompt, nil, true) or steamID32 == prompt or (prompt == '^' and line.isLocalPlayer)) then
                panel:Show()
                category:SetExpanded(true)
            else
                panel:Hide()
            end
        end

        category:Update()
    end
end

--[[------------------------------
// PANEL
--------------------------------]]
local PANEL = {}

function PANEL:Init()
    local toolbarPadding = onyx.ScaleTall(5)
    local elementSpace = onyx.ScaleTall(10)
    local playerLineHeight = onyx.ScaleTall(30)
    local playerLinePadding = onyx.ScaleTall(5)
    local playerLineRealHeight = playerLineHeight - playerLinePadding * 2

    self.toolbarPadding = toolbarPadding
    self.playerLineHeight = playerLineHeight
    self.playerLinePadding = playerLinePadding

    self.toolbar = self:Add('Panel')
    self.toolbar.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLOR_SECONDARY)
    end
    self.toolbar.PerformLayout = function(panel, w, h)
        local contentMarginLeft = toolbarPadding * 3 + playerLineRealHeight * 2
        local scroll = self.list.scroll

        if (scroll:IsVisible()) then
            contentMarginLeft = contentMarginLeft + scroll:GetWide() + select(1, scroll:GetDockMargin())
        end

        panel:DockPadding(toolbarPadding, toolbarPadding, contentMarginLeft, toolbarPadding)
        panel:DockMargin(0, 0, 0, elementSpace)
    end

    self.search = self.toolbar:Add('onyx.TextEntry')
    self.search:SetPlaceholderText(onyx.lang:Get('scoreboard_search'))
    self.search:SetPlaceholderIcon('https://i.imgur.com/Nk3IUJT.png', 'smooth mips')
    self.search:SetUpdateOnType(true)
    self.search:Dock(LEFT)
    self.search:SetWide(onyx.ScaleWide(175))
    self.search:SetCursor('beam')
    self.search.OnValueChange = function(panel, value)
        processSearch(value, self.list)
    end

    self.search.textEntry:SetTabbingDisabled(true)
    self.search.textEntry:SetMouseInputEnabled(false) -- this one is required to get access to parent, which triggers SetKeyboardInputEnabled on parent
    self.search.OnMousePressed = function(panel)
        onyx.scoreboard.Frame:SetKeyboardInputEnabled(true)
        onyx.scoreboard.Frame:ShowCloseButton(true)
        onyx.scoreboard.Frame.closeDisabled = true

        panel.textEntry:SetMouseInputEnabled(true)
        panel.textEntry:RequestFocus()
    end

    self.columns = self.toolbar:Add('onyx.Scoreboard.ColumnsRow')
    self.columns:Dock(FILL)
    self.columns:DockMargin(toolbarPadding, 0, 0, 0)
    self.columns:SetFont(onyx.Font('Comfortaa Bold@16'))
    self.columns:SetHeader(true)
    self.columns:InitColumns()

    self:AddSorting(self.columns)

    self.list = self:Add('onyx.ScrollPanel')
    self.list:SetSpace(onyx.ScaleTall(1))
    self.list.canvas:On('OnContainerTallUpdated', function()
        self.toolbar:InvalidateLayout()
    end)

    self.players = {}
    self:LoadPlayers()
end

function PANEL:PerformLayout(w, h)
    self.toolbar:Dock(TOP)
    self.toolbar:SetTall(onyx.ScaleTall(35))

    self.list:Dock(FILL)
end

do
    function PANEL:FetchCategory(ply)
        if (DarkRP and onyx.scoreboard:GetOptionValue('group_teams')) then
            local jobData = RPExtraTeams[ply:Team()]
            if (jobData) then
                return jobData.category
            end
        end

        if (onyx.scoreboard.IsTTT()) then
            local _, name, color = onyx.scoreboard.GetTeamTTT(ply)
            return name, color
        end

        return team.GetName(ply:Team()), team.GetColor(ply:Team())
    end
end

function PANEL:LoadPlayers()
    local categories = {}
    local players = {}

    -- add players
    for _, ply in ipairs(player.GetAll()) do
        local bShouldHide = hook.Run('onyx.scoreboard.ShouldHidePlayer', ply) -- for possible custom integrations
        if (bShouldHide ~= true) then
            table.insert(players, ply)
        end
    end

    -- default sorting
    table.sort(players, function(a, b)
        return a:Team() < b:Team()
    end)

    for _, ply in ipairs(players) do
        local catName, catColor = self:FetchCategory(ply)
        local foundIndex

        for index, category in ipairs(categories) do
            if (category.name == catName) then
                foundIndex = index
                break
            end
        end

        if (not foundIndex) then
            local panel = self:AddCategory(onyx.utf8.upper(catName), catColor) -- utf-8 support

            foundIndex = table.insert(categories, {
                panel = panel,
                name = catName,
                color = catColor, -- might be nil
                players = {}
            })
        end

        table.insert(categories[foundIndex].players, ply)
    end

    self.queue = {}
    for _, category in ipairs(categories) do
        for _, ply in ipairs(category.players) do
            table.insert(self.queue, {
                category = category.panel,
                ply = ply
            })
        end
    end
end

function PANEL:Think()
    local queue = self.queue
    if (queue) then
        local object = queue[1]
        if (object) then
            local ply = object.ply
            local cat = object.category

            table.remove(queue, 1)

            if (IsValid(ply)) then
                self:AddPlayer(ply, cat)
                cat:Update()
            end
        end
    end
end

function PANEL:AddSorting(panel)
    for index, column in ipairs(panel.columns) do
        panel:SetClickFunc(index, function()
            self:SortByColumn(index, column)
        end)

        column.arrowAngle = 0
        column.PaintOver = function(panel, w, h)
            if (not panel.active) then return end

            local text = panel:GetText()
            local xOffset = -ScreenScale(3)
            local size = math.min(h, onyx.ScaleTall(12))
            local xPosOverride

            if (text ~= '') then
                local textW = panel:GetContentSize()
                if (panel.TextLeft) then
                    xPosOverride = textW + size * .5 - xOffset
                else
                    xOffset = xOffset - textW * .5
                end
            else
                xOffset = xOffset - size * .5
            end

            local targetAngle = panel.ascending and 90 or -90
            column.arrowAngle = Lerp(FrameTime() * 16, column.arrowAngle, targetAngle)

            DisableClipping(true)
                WIMG_ARROW:DrawRotated(xPosOverride or (w * .5 + xOffset - size * .5), h * .5, size, size, column.arrowAngle)
            DisableClipping(false)
        end
    end
end

function PANEL:SortByColumn(index, column)
    local oldColumn = self.currentColumn
    local data = column.data
    local resorted = {}

    if (IsValid(oldColumn)) then
        oldColumn:SetTextColor(COLOR_GRAY)
        oldColumn.hoverBlocked = false
        oldColumn.active = false
    end

    column.hoverBlocked = true
    column.ascending = not column.ascending
    column.active = true
    column:SetTextColor(COLOR_ACCENT)

    self.currentColumn = column

    -- sort
    table.sort(self.players, function(aPlayer, bPlayer)
        local aColumn = aPlayer.content.columns[index]
        local bColumn = bPlayer.content.columns[index]

        local aValue = aColumn.Value
        local bValue = bColumn.Value

        if (column.ascending) then
            return aValue > bValue
        else
            return aValue < bValue
        end
    end)

    -- rearrange elements
    for index, playerLine in ipairs(self.players) do
        local parent = playerLine.category
        local parentCategory = parent:GetParent():GetParent()

        parent:SetZPos(index)

        if (not resorted[parentCategory]) then
            parentCategory:SetZPos(index)
            parentCategory:SetAlpha(0)
            parentCategory:AlphaTo(255, .1)

            resorted[parentCategory] = index
        end
    end

    self.list:InvalidateLayout()
end

function PANEL:AddPlayer(ply, parentCategory)
    if (not IsValid(ply)) then return end

    -- create fake category
    local cat = parentCategory:Add('onyx.Category')
    cat:SetCategoryHeight(self.playerLineHeight)
    cat:SetTall(cat:GetCategoryHeight())
    cat:SetInset(onyx.ScaleTall(10))
    cat:SetSpace(0)
    cat:DockMargin(0, 0, 0, onyx.ScaleTall(2.5))
    cat:Dock(TOP)

    -- keep size up to date
    cat:InjectEventHandler('PerformLayout')
    cat:On('PerformLayout', function(panel)
        if (panel.onyxAnims and panel.onyxAnims[1]) then -- fixes unpleasant view glitch
            parentCategory:Update()
        end
    end)

    -- reset inside
    cat.button:Clear()
    cat.button.Paint = nil
    cat.button:DockPadding(0, 0, 0, 0)

    cat.canvas:SetTall(0)
    cat.canvas.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, onyx.LerpColor(.025, COLOR_PRIMARY, color_black), false, false, true, true)
    end

    local profile = cat:Add('onyx.scoreboard.PlayerInspector')
    profile:Dock(TOP)
    profile:SetupPlayer(ply)

    -- create actual playerLine
    local playerLine = cat.button:Add('onyx.Scoreboard.PlayerLine')
    playerLine:SetupPlayer(ply)
    playerLine:Dock(FILL)
    playerLine:Import('click')
    playerLine.DoClick = function()
        cat.button:DoClick()
    end

    -- to perfectly align UI elements
    playerLine.firstElementWidth = self.search:GetWide()
    playerLine.paddingX = self.toolbarPadding
    playerLine.padding = self.playerLinePadding

    -- link to other panels
    playerLine.category = cat
    playerLine.list = self.list

    -- for search
    playerLine.parsedName = parseString(ply:Name())
    playerLine.steamID32 = parseString(ply:SteamID())
    playerLine.isLocalPlayer = LocalPlayer() == ply

    table.insert(self.players, playerLine)
end

function PANEL:AddCategory(name, color)
    local cat = self.list:Add('onyx.Category')
    cat:Dock(TOP)
    cat:SetTitle(name)
    cat:SetSpace(onyx.ScaleTall(5))
    cat:SetInset(0)
    cat:SetTextMargin(self.toolbarPadding + 2)
    cat:DockMargin(0, 0, 0, onyx.ScaleTall(5))

    cat:SetExpanded(true)
    cat:UpdateInTick()

    if (color) then
        cat.button.PaintOver = function(panel, w, h)
            local x, y = panel:LocalToScreen(0, 0)
            local lineWidth = 2

            render.SetScissorRect(x, y, x + lineWidth, y + h, true)
            -- render.SetScissorRect(x, y + h - lineWidth, x + w, y + h, true)
                draw.RoundedBox(8, 0, 0, w, h, color)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    end

    return cat
end

onyx.gui.Register('onyx.Scoreboard.PlayerList', PANEL)

--[[------------------------------
--//ANCHOR onyx.scoreboard.PlayerInspector
--------------------------------]]
local COLOR_GOLD = Color(255, 224, 101)
local COLOR_FRIEND = Color(134, 249, 124)
local wimgCopy = onyx.wimg.Simple('https://i.imgur.com/OolNq4H.png', 'smooth mips')

local function setTextColor(label, color)
    label.colorIdle = color
    label:SetTextColor(color)
end

local PANEL = {}

AccessorFunc(PANEL, 'm_ePlayer', 'Player')

function PANEL:Init()
    self.buttonHeight = onyx.ScaleTall(20)

    local avatarOutline = 2
    local avatarRoundness = 16

    self._avatar = self:Add('Panel')
    self._avatar.PerformLayout = function(panel, w, h)
        local size = math.min(h, self._avatar:GetWide()) - avatarOutline * 2

        self.avatar:SetSize(size, size)
        self.avatar:Center()

        local x, y = self.avatar:GetPos()

        panel.poly = onyx.CalculateRoundedBox(avatarRoundness, x, y, size, size)
    end
    self._avatar.Paint = function(panel, w, h)
        local x, y = self.avatar:GetPos()
        local size = self.avatar:GetWide() + avatarOutline * 2

        draw.RoundedBox(avatarRoundness, x - avatarOutline, y - avatarOutline, size, size, color_white)

        onyx.DrawWithPolyMask(panel.poly, function()
            self.avatar:PaintManual()
        end)
    end

    self.avatar = self._avatar:Add('AvatarImage')
    self.avatar:SetPaintedManually(true)

    self.buttons = self:Add('onyx.Grid')
    self.buttons:SetColumnCount(3)
    self.buttons:SetSpace(onyx.ScaleTall(5))

    self.info = self:Add('Panel')

    for _, buttonTable in ipairs(onyx.scoreboard.Buttons) do
        local getVisible = buttonTable.getVisible

        if (getVisible and getVisible(LocalPlayer()) == false) then continue end

        self:AddButton(onyx.lang:Get('scoreboard_btn_' .. buttonTable.name), function()
            local ply = self:GetPlayer()
            if (IsValid(ply)) then
                buttonTable.callback(ply)
            end
        end)
    end

    self.labels = {}
    self:AddLabel('name', 'Name')
    self:AddLabel('rank', 'Rank')
    self:AddLabel('steamid32', 'SteamID32')
    self:AddLabel('steamid64', 'SteamID64')

    self:UpdateHeight()
end

function PANEL:UpdateHeight()
    local infoHeight = 0

    -- this one should be pairs
    for _, label in pairs(self.labels) do
        infoHeight = infoHeight + label:GetParent():GetTall()
    end

    self:SetTall(math.max(self.buttons:GetContentHeight(), infoHeight))
end

function PANEL:PerformLayout(w, h)
    self._avatar:Dock(LEFT)
    self._avatar:SetWide(h * .75)
    self._avatar:DockMargin(0, 0, onyx.ScaleTall(10), 0)

    self.buttons:SetWide(w * .5)
    self.buttons:Dock(RIGHT)

    self.info:Dock(FILL)
end

function PANEL:SetupPlayer(ply)
    local yourself = ply == LocalPlayer()
    local name = ply:Name()
    local formattedName = name

    self.avatar:SetPlayer(ply, 128)

    if (yourself) then
        formattedName = formattedName .. ' (' .. onyx.lang:Get('you') .. ')'
        setTextColor(self.labels.name, COLOR_GOLD)
    elseif (ply:GetFriendStatus() == 'friend') then
        formattedName = formattedName .. ' (' .. onyx.lang:Get('friend') .. ')'
        setTextColor(self.labels.name, COLOR_FRIEND)
    end

    self:SetPlayer(ply)

    self:SetLabelValue('name', formattedName, name)
    self:SetLabelValue('rank', ply:GetUserGroup())
    self:SetLabelValue('steamid32', ply:SteamID())
    self:SetLabelValue('steamid64', ply:SteamID64())
end

function PANEL:SetLabelValue(id, value, rawValue)
    self.labels[id]:SetText(value)
    self.labels[id]:SizeToContentsX()
    self.labels[id].Value = rawValue or value
end

function PANEL:AddLabel(id, title)
    local row = self.info:Add('Panel')
    row:SetTall(onyx.ScaleTall(20))
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 0)

    local lblTitle = row:Add('onyx.Label')
    lblTitle:SetText(title .. ': ')
    lblTitle:SetTextColor(COLOR_GRAY_LIGHT)
    lblTitle:Dock(LEFT)
    lblTitle:SizeToContentsX()
    lblTitle:SetContentAlignment(7)

    local lblValue = row:Add('onyx.Label')
    lblValue:SetText('Example')
    lblValue:SetContentAlignment(7)
    lblValue:Dock(LEFT)
    lblValue:Font('Comfortaa Bold@16')
    lblValue:SizeToContentsX()
    lblValue:Import('click')
    lblValue.Value = 'Example'
    setTextColor(lblValue, color_white)
    lblValue.Think = function(panel)
        panel:SetTextColor(panel:IsHovered() and COLOR_ACCENT or panel.colorIdle)
    end
    lblValue.Paint =function(panel, w, h)
        if (not panel:IsHovered()) then return end

        local size = h * .66
        local space = onyx.ScaleTall(5)
        DisableClipping(true)
            wimgCopy:Draw(w + space, h * .5 - size * .5, size, size, COLOR_ACCENT)
        DisableClipping(false)
    end
    lblValue.DoClick = function(panel)
        SetClipboardText(panel.Value)
        notification.AddLegacy(onyx.lang:Get('copied_clipboard'), 0, 5)
    end

    self.labels[id] = lblValue
end

function PANEL:AddButton(text, func)
    local button = self.buttons:Add('onyx.Button')
    button:SetText(text)
    button:SetTall(onyx.ScaleTall(25))
    button:SetColorIdle(COLOR_SECONDARY)
    button:SetColorHover(COLOR_TERTIARY)
    button:AddHoverSound()
    button:AddClickEffect()
    button:Font('Comfortaa SemiBold@16')
    button.Think = function(panel)
        panel:SetTextColor(panel:IsHovered() and color_white or COLOR_GRAY_LIGHT)
    end
    button.DoClick = func

    self.buttons:AddItem(button)
end

onyx.gui.Register('onyx.scoreboard.PlayerInspector', PANEL)

--[[------------------------------
// ANCHOR Debug
--------------------------------]]
-- onyx.gui.Test('onyx.Scoreboard.Frame', .6, .6, function(self)
--     onyx.scoreboard.Frame = self
--     self:Center()
--     self:MakePopup()
-- end)