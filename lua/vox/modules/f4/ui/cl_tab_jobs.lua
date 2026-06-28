local fallbackJobTabColors = {
    primary = Color(8, 19, 38),
    secondary = Color(12, 32, 62),
    tertiary = Color(16, 42, 78),
    accent = Color(70, 135, 255)
}
local colorGray = Color(159, 159, 159)
local font0 = vox.Font('Montserrat@14')
local oldScrollValue = 0
local matSearch = Material('vox_f4menu/search.png', 'smooth mips')

local L = function(...) return vox.lang:Get(...) end

local function getThemeColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackJobTabColors.primary, colors.secondary or fallbackJobTabColors.secondary, colors.secondary or fallbackJobTabColors.secondary, colors.accent or fallbackJobTabColors.accent
end


local function getThemeColorValue(key, fallback)
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors[key] or fallback
end

local PANEL = {}

local cvShowFavorite = CreateClientConVar('cl_vox_f4_show_favorite_jobs', '1', true, false)

function PANEL:Init()
    local toolbarPadding = vox.ScaleTall(5)

    self.list = self:Add('vox.ScrollPanel')
    self.list:Dock(FILL)
    self.list.OnRemove = function(panel)
        if (panel.scrollInitialized) then
            oldScrollValue = panel.scroll:GetScroll()
        end
    end

    if (oldScrollValue) then
        self:SetScroll(4, oldScrollValue)
    end

    self.toolbar = self:Add('DPanel')
    self.toolbar:Dock(TOP)
    self.toolbar:SetTall(vox.ScaleTall(40))
    self.toolbar:DockPadding(toolbarPadding, toolbarPadding, toolbarPadding * 2, toolbarPadding)
    self.toolbar:DockMargin(0, 0, 0, vox.ScaleTall(10))
    self.toolbar.Paint = function(panel, w, h)
        local themePrimary, themeSecondary, themeTertiary, themeAccent = getThemeColors()
        if vox.DrawVoxPanel then
            vox.DrawVoxPanel(0, 0, w, h, { primary = themeSecondary, secondary = themeTertiary, accent = themeAccent }, 8)
        else
            draw.RoundedBox(8, 0, 0, w, h, themeSecondary)
        end
    end
    self.toolbar.PerformLayout = function(panel, w, h)
        self.favToggler:SetWide(self.favToggler:GetContentWidth())
    end

    self.favToggler = self.toolbar:Add('vox.TogglerLabel')
    self.favToggler:Dock(RIGHT)
    self.favToggler:SetText(L('f4_show_favorite'))
    local _, _, themeTertiary = getThemeColors()
    self.favToggler:SetBackgroundColor(themeTertiary)
    self.favToggler:Font('Comfortaa Bold@18')
    self.favToggler:SetTextMargin(vox.ScaleTall(10))
    self.favToggler:SetChecked(cvShowFavorite:GetBool(), true)
    self.favToggler.OnChange = function(panle, bool)
        cvShowFavorite:SetBool(bool)
        self:Reload()
    end

    self.search = self.toolbar:Add('vox.TextEntry')
    self.search:SetPlaceholderText(vox.lang:Get('f4_search_text'))
    self.search:SetPlaceholderMaterial(matSearch)
    self.search:Dock(LEFT)
    self.search:SetWide(vox.ScaleWide(150))
    self.search:SetUpdateOnType(true)
    self.search.OnValueChange = function(panel, value)
        value = vox.utf8.lower(value)

        for _, cat in ipairs(self.list:GetItems()) do
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

        self.list:InvalidateLayout()
    end

    self.preview = self:Add('vox.Panel')
    self.preview:Hide()
    self.preview.blur = 0
    self.preview.pos = 0
    self.preview.Paint = function(panel, w, h)
        local frame = vox.f4.frame
        if (not IsValid(frame)) then return end -- just in case

        local container = frame.container or frame.content or frame
        local realW, realH = container:GetSize()
        local padding = frame.containerPadding or vox.ScaleTall(18)

        if (panel.blur > 0) then
            vox.DrawBlurExpensive(panel, panel.blur)
        end

        DisableClipping(true)
            surface.SetDrawColor(ColorAlpha(color_black, panel.pos * 100))
            surface.DrawRect(-padding, -padding, realW, realH)
        DisableClipping(false)
    end
    self.preview.PerformLayout = function(panel, w, h)
        panel.content:SetTall(h)
        panel.content:SetWide(w * .6)
    end
    self.preview.OnMouseReleased = function(panel)
        self:DisablePreview()
    end

    self.preview.content = self.preview:Add('vox.f4.JobPreview')
    self.preview.content.OnFavoriteStateSwitched = function()
        self:Reload()
    end

    self.categories = {}
    self:LoadJobs()
end

function PANEL:Reload()
    local scrollValue = self.list.scroll:GetScroll()
    local container = self.list:GetContainer()

    container:Clear()
    self.search:SetValue('')
    self.categories = {}
    self:LoadJobs()
    self:SetScroll(4, scrollValue)
    container:SetAlpha(0)
    container:AlphaTo(255, .3)
end

function PANEL:SetScroll(tickAmount, scrollValue)
    timer.Simple(engine.TickInterval() * tickAmount, function()
        if (IsValid(self.list)) then
            self.list.scrollInitialized = true
            self.list.scroll:SetScroll(scrollValue)
            self.list.scroll.Current = scrollValue
            self.list.canvas.container:SetPos(0, -scrollValue)
        end
    end)
end

function PANEL:EnablePreview(member, reason)
    local preview = self.preview
    local available = reason == nil

    preview:Show()
    preview.pos = 0
    preview.content:SetPos(preview:GetWide())

    preview.content:SetupJob(member)

    preview.content.btnChoose:SetVisible(available)
    preview.content.spacer:SetVisible(available)

    if (member.team == LocalPlayer():Team()) then
        preview.content.btnChoose:SetVisible(false)
        preview.content.spacer:SetVisible(false)
    end

    vox.anim.Create(preview, .2, {
        index = 1,
        target = {
            blur = 2,
            pos = 1
        },
        think = function(anim, panel)
            local w = panel:GetSize()
            local contentW = panel.content:GetWide()

            panel.content:SetPos(w - contentW * panel.pos, 0)
        end,
        onFinished = function(anim, panel)
            panel.content.enabled = true
        end,
        easing = 'inQuad'
    })
end

function PANEL:DisablePreview()
    local preview = self.preview

    if (not preview.content.enabled) then
        return
    end

    preview.content.enabled = false
    vox.anim.Create(preview, .2, {
        index = 1,
        target = {
            blur = 0,
            pos = 0
        },
        think = function(anim, panel)
            local w = panel:GetSize()
            local contentW = panel.content:GetWide()

            panel.content:SetPos(w - contentW * panel.pos, 0)
        end,
        onFinished = function(anim, panel)
            panel:Hide()
        end,
        easing = 'inQuad'
    })
end

function PANEL:PerformLayout(w, h)
    self.preview:SetSize(w, h)
end

function PANEL:LoadJobs()
    local client = LocalPlayer()
    local categories = DarkRP.getCategories()['jobs']
    local showUnavailable = vox.f4:GetOptionValue('job_show_unavailable')
    local showWrong = vox.f4:GetOptionValue('job_show_requirejob')
    local teamIndex = client:Team()

    if (cvShowFavorite:GetBool()) then
        self:CreateCategory(L('f4_favorite_u'), vox.f4:FetchFavoriteObjects('jobs'))
    end

    for _, category in ipairs(categories) do
        local canSee = category.canSee
        local members = {}

        if (canSee and not canSee(client)) then continue end

        for _, member in ipairs(category.members) do
            local customCheck = member.customCheck
            local needToChangeFrom = member.NeedToChangeFrom
            local reason

            if (customCheck and not customCheck(client)) then
                if (showUnavailable) then
                    reason = L('f4_unavailable')
                else
                    continue
                end
            end

            if (needToChangeFrom and needToChangeFrom ~= teamIndex) then
                if (showWrong) then
                    reason = L('f4_unavailable')
                else
                    continue
                end
            end

            table.insert(members, {
                job = member,
                reason = reason
            })
        end

        table.sort(members, function(a, b)
            return a.job.team < b.job.team
        end)

        self:CreateCategory(category.name, members)
    end
end

function PANEL:CreateCategory(name, members, color)
    if (#members < 1) then return end

    local pnlCategory = self.list:Add('vox.Category')
    pnlCategory:Dock(TOP)
    pnlCategory:SetTitle(vox.utf8.upper(name))
    pnlCategory:SetSpace(0)
    pnlCategory:SetInset(vox.ScaleTall(10))
    pnlCategory:DockMargin(0, 0, 0, vox.ScaleTall(10))
    pnlCategory.m_iTextMargin = vox.ScaleTall(10)
    pnlCategory.m_bSquareCorners = true
    pnlCategory:SetExpanded(true)
    pnlCategory.canvas.Paint = function(p, w, h)
        local themePrimary, themeSecondary = getThemeColors()
        draw.RoundedBoxEx(8, 0, 0, w, h, themePrimary, false, false, true, true)
    end

    if (color) then
        pnlCategory.wimage = vox.wimg.Create('favorite_fill', 'smooth mips')
    end

    local content = pnlCategory:Add('vox.Grid')
    content:Dock(TOP)
    content:SetTall(0)
    content:SetSpaceX(vox.ScaleTall(5))
    content:SetSpaceY(content:GetSpaceX())
    content:SetColumnCount(1)
    content.category = pnlCategory

    for _, member in ipairs(members) do
        self:CreateMember(member.job, content, member.reason)
    end

    pnlCategory:UpdateInTick()
    pnlCategory:UpdateInTick(10)
    pnlCategory:UpdateInTick(100)
end

function PANEL:CreateMember(member, content, reason)
    local model = istable(member.model) and member.model[1] or member.model
    local max = member.max
    local inf = max == 0
    local index = member.team
    local salary = DarkRP.formatMoney(member.salary)

    local item = content:Add('vox.f4.Item')
    item:SetTall(vox.ScaleTall(48))
    item:SetModel(model)
    item:SetName(member.name)
    local _, _, _, themeAccent = getThemeColors()
    item:SetColor(themeAccent, .08)
    item:SetDesc(salary)
    item:SetDescLabel(L('f4_salary'))
    if (reason) then
        local _, _, _, themeAccent = getThemeColors()
        item:SetDescColor(getThemeColorValue('negative', Color(255, 88, 104)))
        item:SetDesc(reason)
        item:SetDescLabel('')
    elseif (member.salary == 0) then
        item:SetDescColor(colorGray)
    else
        item:SetDescColor(getThemeColorValue('money', Color(35, 225, 120)))
    end

    item:PositionCamera('face')

    item:Import('click')
    item:Import('hovercolor')
    item:SetColorKey('colorBG')
    local _, themeSecondary, themeTertiary = getThemeColors()
    item:SetColorIdle(themeSecondary)
    item:SetColorHover(themeTertiary)
    item:AddHoverSound()
    item:AddClickEffect()
    item.DoClick = function()
        self:EnablePreview(member, reason)
    end

    local limit = item:Add('Panel')
    limit:Dock(RIGHT)
    limit:SetZPos(-1)
    limit:SetWide((item:GetTall() - item.padding * 2))
    limit:SetMouseInputEnabled(false)
    limit.text = inf and '∞' or ''
    limit.Paint = function(panel, w, h)
        local themePrimary = getThemeColors()
        vox.DrawOutlinedCircle(w * .5, h * .5, math.floor(h * .5), 6, themePrimary)

        if (panel.fraction and panel.fraction > 0) then
            vox.DrawWithPolyMask(panel.mask, function()
                vox.DrawOutlinedCircle(w * .5, h * .5, math.floor(h * .5), 6, themeAccent)
            end)
        end

        draw.SimpleText(panel.text, font0, w * .5, h * .5, color_white, 1, 1)
    end
    limit.PerformLayout = function(panel, w, h)
        if (panel.fraction) then
            local endAngle = math.Round(panel.fraction * 360)
            panel.mask = vox.CalculateArc(w * .5, h * .5, 0, endAngle, h * .5 + 2, 24, true)
        end
    end

    if (not inf) then
        limit.Think = function(panel)
            if ((panel.nextThink or 0) > CurTime()) then return end
            panel.nextThink = CurTime() + .1

            local amount = #team.GetPlayers(index)
            local fraction = math.Clamp(amount / max, 0, 1)

            panel.text = amount .. ' / ' .. max

            if (not panel.fraction or panel.fraction ~= fraction) then
                panel.fraction = fraction
                panel:InvalidateLayout()
            end
        end
    end
end

vox.gui.Register('vox.f4.Jobs', PANEL)
