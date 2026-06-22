local colorSecondary = vox:Config('colors.secondary')
local colorAccent = vox:Config('colors.accent')
local colorGray = Color(197, 197, 197)
local colorGradient = vox.LerpColor(.5, colorAccent, colorSecondary)

do
    local PANEL = {}

    AccessorFunc(PANEL, 'm_Name', 'Name')
    AccessorFunc(PANEL, 'm_Font', 'Font')
    AccessorFunc(PANEL, 'm_iRoundness', 'Roundness')
    AccessorFunc(PANEL, 'm_iIconSize', 'IconSize')
    AccessorFunc(PANEL, 'm_iIconMargin', 'IconMargin')
    AccessorFunc(PANEL, 'm_bMasking', 'Masking')
    AccessorFunc(PANEL, 'm_matMaterial', 'Material')
    AccessorFunc(PANEL, 'm_wimgObject', 'WebImage')

    function PANEL:Init()
        self:SetWide(vox.ScaleWide(120))
        self:SetName('Tab')
        self:SetFont(vox.Font('Comfortaa Bold@16'))
        self:SetRoundness(8)
        self:SetIconSize(vox.ScaleTall(14))
        self:SetIconMargin(vox.ScaleTall(5))
        self:Import('click')
        self.animActiveFraction = 0
    end

    function PANEL:Paint(w, h)
        local x0, y0 = w * .5, h * .5
        local textColor = self:IsHovered() and color_white or colorGray
        local animActiveFraction = self.animActiveFraction
        local screenX, screenY = self:LocalToScreen(0, 0)

        -- unactive text
        if (animActiveFraction < 1) then
            self:DrawContent(x0, y0, ColorAlpha(textColor, (1 - animActiveFraction) * 255))
        end

        -- active text
        if (animActiveFraction > 0) then
            local animHeight = h * animActiveFraction
            local animHeightHalf = animHeight * .5

            render.SetScissorRect(screenX, screenY + h * .5 - animHeightHalf, screenX + w, screenY + h * .5 + animHeightHalf, true)
                self:DrawContent(x0, y0, colorAccent)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    end

    function PANEL:DrawContent(x0, y0, color)
        local name = self.m_Name
        local font = self.m_Font
        local material = self.m_matMaterial
        local webimage = self.m_wimgObject
        local iconSize = self.m_iIconSize
        local iconMargin = self.m_iIconMargin

        if (material or webimage) then
            local textW = vox.GetTextSize(name, font)
            local totalW = textW + iconSize + iconMargin
            local x = x0 - totalW * .5

            if (material) then
                vox.DrawMaterial(material, x, y0 - iconSize * .5, iconSize, iconSize, color)
            else
                webimage:Draw(x, y0 - iconSize * .5, iconSize, iconSize, color)
            end

            draw.SimpleText(name, font, x + iconSize + iconMargin, y0, color, 0, 1)
        else
            draw.SimpleText(name, font, x0, y0, color, 1, 1)
        end
    end

    function PANEL:SetupTab(data)
        self:SetName(data.name)
        self:SetMaterial(data.material)

        if (data.icon) then
            self:SetWebImage(vox.wimg.Simple(data.icon, 'smooth mips'))
        elseif (data.wimg) then
            self:SetWebImage(data.wimg)
        end
    end

    function PANEL:SizeToContents(space)
        local space = space or 0
        local textW = vox.GetTextSize(self.m_Name, self.m_Font)
        local totalW = textW + space

        if (self:HasIcon()) then
            totalW = totalW + self:GetIconSize() + self:GetIconMargin()
        end

        self:SetWide(totalW)
    end

    function PANEL:HasIcon()
        return (self.m_matMaterial ~= nil)
    end

    function PANEL:SetActive(bActiveBool)
        self.active = bActiveBool

        vox.anim.Create(self, .33, {
            index = 1,
            target = {
                animActiveFraction = (bActiveBool and 1 or 0)
            }
        })
    end

    function PANEL:PerformLayout(w, h)
        if (self.m_bMasking) then
            self.mask = vox.CalculateRoundedBoxEx(self.m_iRoundness, 0, 0, w, h, false, false, true)
        end
    end

    vox.gui.Register('vox.Navbar.Tab', PANEL)
end

do
    local PANEL = {}

    AccessorFunc(PANEL, 'm_pnlContainer', 'Container')
    AccessorFunc(PANEL, 'm_pnlActiveTab', 'ActiveTab')
    AccessorFunc(PANEL, 'm_iRoundness', 'Roundness')
    AccessorFunc(PANEL, 'm_bKeepTabContent', 'KeepTabContent')
    AccessorFunc(PANEL, 'm_iSpace', 'Space')

    function PANEL:Init()
        self.tabs = {}
        self:SetRoundness(0)
        self:SetSpace(0)
        self.animLineCurrent = 0
        self.animLineTarget = 0

        self.animLineX = 0
        self.animLineW = 0
    end

    function PANEL:AddTab(data)
        local tab = self:Add('vox.Navbar.Tab')
        tab:Dock(LEFT)
        tab:DockMargin(0, 0, self.m_iSpace, 0)
        tab:SetupTab(data)
        tab.DoClick = function(panel)
            self:SelectTab(panel)
        end

        tab.tabData = data
        tab.tabIndex = table.insert(self.tabs, tab)
        tab.cornerTab = tab.tabIndex == 1
        tab:SetMasking(tab.cornerTab)
        tab:SetRoundness(self:GetRoundness())

        self:Call('OnTabAdded', nil, tab)

        return tab
    end

    function PANEL:GetTabs()
        return self.tabs
    end

    function PANEL:ChooseTab(index, force)
        local tab = self.tabs[index]
        assert(IsValid(tab), 'tried to choose invalid tab')
        self:SelectTab(tab, force)
    end

    function PANEL:SelectTab(tab, force)
        local shouldKeepTabContent = self.m_bKeepTabContent
        local container = self:GetContainer()
        assert(IsValid(container), string.format('Invalid container (%s) linked to the NavBar', tostring(container)))

        local data = tab.tabData

        if (data.onClick and not data.onClick()) then
            return
        end

        local currentActiveTab = self:GetActiveTab()
        if (IsValid(currentActiveTab)) then
            if (currentActiveTab == tab and not force) then
                return
            end

            currentActiveTab:SetActive(false)
        end

        self:SetActiveTab(tab)
        tab:SetActive(true)

        if (IsValid(currentActiveTab) and IsValid(currentActiveTab.content)) then
            if (shouldKeepTabContent) then
                currentActiveTab.content:Hide()
            else
                currentActiveTab.content:Remove()
            end
        end

        if (IsValid(tab.content)) then
            tab.content:Show()
        else
            tab.content = container:Add(data.class)
            tab.content:Dock(FILL)
            tab.content.tab = tab

            if (data.onBuild) then
                data.onBuild(tab.content)
            end
        end

        self:Call('OnTabSelected', nil, tab, tab.content)

        self.animLineTarget = tab.tabIndex

        if (not self.animLineStart) then
            self.animLineCurrent = self.animLineTarget
            self.animLineX = tab:GetPos()
            self.animLineW = tab:GetWide()
        else
            vox.anim.Create(self, .33, {
                index = 1,
                easing = 'inOutSine',
                target = {
                    animLineCurrent = self.animLineTarget,
                    animLineX = tab:GetPos(),
                    animLineW = tab:GetWide()
                }
            })
        end

        self.animLineStart = self.animLineCurrent
    end

    function PANEL:PaintOver(w, h)
        local current = self.animLineCurrent
        if (current <= 0) then return end

        local target = self.animLineTarget
        if (target <= 0) then return end

        local gradientHeight = h * .25

        local x = self.animLineX
        local wide = self.animLineW
        if (wide == 0 and current == target) then
            local tab = self:GetChild(target - 1)

            x = tab:GetPos()
            wide = tab:GetWide()
        end

        surface.SetDrawColor(colorAccent)
        surface.DrawRect(x, h - 2, wide, 2)

        vox.DrawMatGradient(x, h - gradientHeight, wide, gradientHeight, TOP, ColorAlpha(colorGradient, 25))
    end

    vox.gui.Register('vox.Navbar', PANEL)
end

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .65, .65, function(self, w, h)
--     self:MakePopup()

--     local content = self:Add('Panel')
--     content:DockPadding(10, 10, 10, 10)
--     content:Dock(FILL)

--     -- local sidebar = self:Add('vox.Sidebar')
--     local navbar = content:Add('vox.Navbar')
--     navbar:SetTall(48)
--     navbar:Dock(TOP)
--     navbar.Paint = function(panel, w, h)
--         draw.RoundedBox(8, 0, 0, w, h, colorSecondary)
--     end

--     local container = content:Add('Panel')
--     container:Dock(FILL)

--     navbar:SetContainer(container)
--     navbar:AddTab({
--         name = 'DASHBOARD',
--         desc = 'Main things',
--         class = 'DButton',
--         onSelected = function(panel)
--             panel:SetText('Meow')
--         end
--     })
--     navbar:AddTab({
--         name = 'JOBS',
--         desc = 'Choose your destiny',
--         material = Material('ut_darkrp/ui/box.png', 'mips smooth'),
--         class = 'DButton',
--     })
--     navbar:AddTab({
--         name = 'SHOP',
--         desc = 'Find items you need',
--         material = Material('ut_darkrp/ui/hat.png', 'mips smooth'),
--         class = 'DButton',
--     })
--     navbar:AddTab({
--         name = 'SETTINGS',
--         desc = 'Configure the game as you wish',
--         material = Material('ut_darkrp/ui/gear.png', 'mips smooth'),
--         class = 'DButton',
--     })
-- end)
