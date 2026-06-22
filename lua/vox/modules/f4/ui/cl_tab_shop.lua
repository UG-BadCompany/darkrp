local colorPrimary = vox:Config('colors.primary')
local colorSecondary = vox:Config('colors.secondary')
local colorTertiary = vox:Config('colors.tertiary')
local colorLine = Color(75, 75, 75)
local colorCanAfford = Color(121, 255, 141)
local colorCannotAfford = Color(253, 120, 120)
local oldScrollValues = {}
local convars = {}
local itemTypes = {'entities', 'weapons', 'shipments', 'ammo'}
for _, itemType in ipairs(itemTypes) do
    convars[itemType] = CreateClientConVar('cl_vox_f4_show_favorite_' .. itemType, '1', true, false)
end

local L = function(...) return vox.lang:Get(...) end

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
        draw.RoundedBox(8, 0, 0, w, h, colorSecondary)
    end
    self.toolbar.PerformLayout = function(panel, w, h)
        self.topRow:SetTall(h / 2)
        self.favToggler:SetWide(self.favToggler:GetContentWidth())
    end

    self.topRow = self.toolbar:Add('Panel')
    self.topRow:Dock(BOTTOM)
    self.topRow:DockPadding(toolbarPadding, toolbarPadding, toolbarPadding * 2, toolbarPadding)

    self.navbar = self.toolbar:Add('vox.Navbar')
    self.navbar:Dock(FILL)
    self.navbar:SetContainer(self.container)
    self.navbar:SetKeepTabContent(true)
    -- self.navbar:SetRoundness(8)
    self.navbar.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, colorTertiary, true, true)
        surface.SetDrawColor(colorLine)
        surface.DrawRect(0, h - 1, w, 1)
    end
    self.navbar.OnTabSelected = function(panel, tab, content)
        local convar = convars[tab.ItemType]

        self.search:SetValue('')
        self.favToggler:SetVisible(convar ~= nil)

        if (convar) then
            self.favToggler:SetChecked(convar:GetBool())
            self.favToggler.OnChange = function(panel, bool)
                convar:SetBool(bool)

                tab.content:Remove()
                self.navbar:SelectTab(tab, true)
                tab.content:SetAlpha(0)
                tab.content:AlphaTo(255, .3)
            end
        end
    end

    self.favToggler = self.topRow:Add('vox.TogglerLabel')
    self.favToggler:Dock(RIGHT)
    self.favToggler:SetText(L('f4_show_favorite'))
    self.favToggler:SetBackgroundColor(vox.OffsetColor(colorTertiary, 10))
    self.favToggler:Font('Comfortaa Bold@18')
    self.favToggler:SetTextMargin(vox.ScaleTall(10))

    self.search = self.topRow:Add('vox.TextEntry')
    self.search:SetPlaceholderText(vox.lang:Get('f4_search_text'))
    self.search:SetPlaceholderIcon('https://i.imgur.com/Nk3IUJT.png', 'smooth mips')
    self.search:Dock(LEFT)
    self.search:SetWide(vox.ScaleWide(150))
    self.search:SetUpdateOnType(true)
    self.search.OnValueChange = function(panel, value)
        value = vox.utf8.lower(value)

        local activeTab = self.navbar:GetActiveTab()
        if (not IsValid(activeTab)) then return end

        local plist = activeTab.content

        for _, cat in ipairs(plist:GetItems()) do
            local layout = cat.canvas:GetChild(0)
            local items = layout:GetChildren()
            local visibleItemAmount = 0

            for _, item in ipairs(items) do
                if (vox.utf8.lower(item:GetName()):find(value, nil, true)) then
                    item:SetVisible(true)
                    visibleItemAmount = visibleItemAmount + 1
                else
                    item:SetVisible(false)
                end
            end

            layout:InvalidateLayout()

            cat:SetVisible(value == '' or visibleItemAmount > 0)
            cat:UpdateInTick()
        end

        plist:InvalidateLayout()
    end

    self.enabledFirst = false
    self.categories = {}
    self:AddItemCategory('entities', L('f4_entities_u'), 'https://i.imgur.com/JnNGizM.png', Color(141, 208, 255), 'canBuyCustomEntity', function(item)
        RunConsoleCommand('darkrp', item.cmd)
    end)

    self:AddItemCategory('weapons', L('f4_weapons_u'), 'https://i.imgur.com/IJQlezA.png', Color(255, 73, 73), 'canBuyCustomWeapon', function(item)
        RunConsoleCommand('darkrp', 'buy', item.name)
    end)

    self:AddItemCategory('shipments', L('f4_shipments_u'), 'https://i.imgur.com/9uyTLgB.png', Color(255, 173, 67), 'canBuyCustomShipment', function(item)
        RunConsoleCommand('darkrp', 'buyshipment', item.name)
    end)

    self:AddItemCategory('ammo', L('f4_ammo_u'), 'https://i.imgur.com/oRqB4Cl.png', Color(255, 246, 141), 'canBuyCustomAmmo', function(item)
        RunConsoleCommand('darkrp', 'buyammo', item.id)
    end)

    if (DarkRP.getFoodItems) then
        local food = DarkRP.getFoodItems()
        if (food) then
            self:AddItemCategory({{
                name = L('f4_food_u'),
                members = food,
            }}, L('f4_food_u'), 'https://i.imgur.com/sJWsDi6.png', Color(171, 255, 141), nil, function(item)
                RunConsoleCommand('darkrp', 'buyfood', item.name)
            end)
        end
    end
end

function PANEL:AddItemCategory(id, name, icon, color, hookName, purchaseFunc)
    local showUnavailable = vox.f4:GetOptionValue('job_show_unavailable')
    local client = LocalPlayer()
    local teamIndex = client:Team()
    local categories = {}
    local membersAmount = 0

    local darkRPCategories = istable(id) and id or DarkRP.getCategories()[id]
    if (not darkRPCategories) then
        return
    end

    -- No favorites for food, sorry :(
    if (isstring(id)) then
        local members = vox.f4:FetchFavoriteObjects(id)
        if (members) then
            table.insert(categories, {
                members = members,
                name = L('f4_favorite_u'),
                favorite = true
            })
        end
    end

    for _, cat in ipairs(darkRPCategories) do
        local canSee = cat.canSee
        local catName = cat.name
        local catMembers = {}

        if (not canSee or canSee(client)) then

            for _, member in ipairs(cat.members or {}) do
                local customCheck = member.customCheck
                local allowed = member.allowed
                local reason

                if (customCheck and not customCheck(client)) then
                    if (showUnavailable) then
                        reason = L('f4_unavailable')
                    else
                        continue
                    end
                end

                if (hookName) then
                    local canBuy, suppress, message = hook.Call(hookName, nil, client, member)
                    if (canBuy == false) then
                        if (not suppress) then
                            reason = message
                        else
                            continue
                        end
                    end
                end

                if (allowed and not table.HasValue(allowed, teamIndex)) then
                    continue
                end

                if (member.energy and member.requiresCook ~= false and not client:isCook()) then
                    return
                end

                membersAmount = membersAmount + 1
                table.insert(catMembers, {
                    item = member,
                    reason = reason
                })
            end

            table.insert(categories, {
                members = catMembers,
                name = catName
            })

        end
    end

    self.categories[id] = categories

    if (membersAmount > 0) then
        local tab = self.navbar:AddTab({
            name = name,
            icon = icon,
            class = 'vox.ScrollPanel',
            onBuild = function(content)
                self:SetupItemList(content, self.categories[id], color, purchaseFunc, id)

                content.OnRemove = function(panel)
                    if (panel.scrollInitialized) then
                        oldScrollValues[id] = panel.scroll:GetScroll()
                    end
                end

                timer.Simple(engine.TickInterval() * 4, function()
                    if (IsValid(content)) then
                        content.scrollInitialized = true

                        local oldScrollValue = oldScrollValues[id]
                        if (oldScrollValue) then
                            content.scroll:SetScroll(oldScrollValue)
                            content.scroll.Current = oldScrollValue
                            content.canvas.container:SetPos(0, -oldScrollValue)
                        end
                    end
                end)
            end
        })

        tab.ItemType = id

        if (not self.enabledFirst) then
            self.enabledFirst = true
            self.navbar:SelectTab(tab, true)
        end
    end
end

function PANEL:SetupItemList(content, categories, color, purchaseFunc, itemType)
    local convar = convars[itemType]
    for _, category in ipairs(categories) do
        if (convar and category.favorite and not convar:GetBool()) then continue end
        if (#category.members > 0) then
            self:CreateCategory(content, category.name, category.members, color, purchaseFunc, itemType)
        end
    end
end

function PANEL:CreateCategory(container, name, members, color, purchaseFunc, itemType)
    local pnlCategory = container:Add('vox.Category')
    pnlCategory:Dock(TOP)
    pnlCategory:SetTitle(vox.utf8.upper(name))
    pnlCategory:SetSpace(0)
    pnlCategory:SetInset(vox.ScaleTall(10))
    pnlCategory:DockMargin(0, 0, 0, vox.ScaleTall(10))
    pnlCategory:SetExpanded(true)
    pnlCategory.m_iTextMargin = vox.ScaleTall(10)
    pnlCategory.m_bSquareCorners = true
    pnlCategory.canvas.Paint = function(p, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, colorPrimary, false, false, true, true)
    end

    local content = pnlCategory:Add('vox.Grid')
    content:Dock(TOP)
    content:SetTall(0)
    content:SetSpaceX(vox.ScaleTall(5))
    content:SetSpaceY(content:GetSpaceX())
    content:SetColumnCount(vox.f4:GetOptionValue('item_columns'))
    content.category = pnlCategory
    content.parentContainer = container

    for _, member in ipairs(members) do
        self:CreateMember(member.item, content, color, purchaseFunc, member.reason, itemType)
    end

    pnlCategory:UpdateInTick()
    pnlCategory:UpdateInTick(10)
    pnlCategory:UpdateInTick(100)
end

function PANEL:CreateMember(member, content, color, purchaseFunc, reason, itemType)
    local model = member.model
    local price = itemType == 'weapons' and member.pricesep or member.price

    local item = content:Add('vox.f4.Item')
    item:SetTall(vox.ScaleTall(55))
    item:SetModel(model)
    item:SetName(member.name)
    item:SetColor(color or Color(200, 200, 200), .1)
    item:SetDesc(DarkRP.formatMoney(price))
    item:SetDescLabel(L('f4_price'))
    item:SetDescColor(Color(69, 192, 87))
    item.objectIdentifier = (member.ent or member.entity or member.name)
    if (not member.energy) then
        item:AddFavoriteButton()
    end
    item.Think = function(panel)
        if ((panel.nextThink or 0) > CurTime()) then return end
        local balance = LocalPlayer():getDarkRPVar('money') or 0
        panel.nextThink = CurTime() + .33
        panel:SetDescColor(balance >= price and colorCanAfford or colorCannotAfford)
    end
    item.OnFavoriteStateSwitched = function()
        local navbar = self.navbar
        local activeTab = navbar:GetActiveTab()
        local itemType = activeTab.ItemType
        local allCategories = self.categories[itemType]
        local favCategory = allCategories[1]

        if (favCategory and favCategory.favorite) then
            favCategory.members = vox.f4:FetchFavoriteObjects(itemType)
        end

        activeTab.content:Remove()
        navbar:SelectTab(activeTab, true)
        activeTab.content:SetAlpha(0)
        activeTab.content:AlphaTo(255, .3)
    end

    if (reason) then
        item:SetDescColor(Color(221, 107, 107))
        item:SetDesc(reason)
        item:SetDescLabel('')
    end

    item:Import('click')
    item:Import('hovercolor')
    item:SetColorKey('colorBG')
    item:SetColorIdle(colorSecondary)
    item:SetColorHover(colorTertiary)
    item:AddHoverSound()
    item:AddClickEffect()
    item.DoClick = function()
        if (purchaseFunc) then
            purchaseFunc(member)
        end
    end

    item:PositionCamera('center')
end

vox.gui.Register('vox.f4.Shop', PANEL)

-- vox.gui.Test('vox.f4.Frame', .65, .65, function(panel)
--     panel:MakePopup()
--     panel:ChooseTab(3)
-- end)
