local colorSecondary = vox:Config('colors.secondary')
local colorAccent = vox:Config('colors.accent')
local colorTertiary = vox:Config('colors.tertiary')
local colorGray = Color(141, 141, 141)
local colorDark = Color(30, 30, 30)

local PANEL = {}

AccessorFunc(PANEL, 'm_iRoundness', 'Roundness')
AccessorFunc(PANEL, 'm_bHiddenLabels', 'HiddenLabels')

function PANEL:Init()
    self.color = Color(255, 255, 255)
    self.curLineThickness = 0
    self.animFraction = 0
    self.textColor = Color(255, 255, 255)
    self.subtextColor = vox.CopyColor(colorGray)
    self.m_iRoundness = 8
    self.m_bHiddenLabels = false

    self:Import('click')
    self:Import('hovercolor')
    self:SetTall(vox.ScaleTall(40))
    self:SetColorKey('color')
    self:SetColorIdle(vox.OffsetColor(vox:Config('colors.secondary'), 0))
    self:SetColorHover(colorTertiary)
    self:SetColorPressed(vox:Config('colors.quaternary'))

    self.divIcon = self:Add('vox.Image')
    self.divIcon:SetImageSize(20, 20)
    self.divIcon:SetMouseInputEnabled(false)

    self.lblTitle = self:Add('vox.Label')
    self.lblTitle:SetText('NAME')
    self.lblTitle:SetFont(vox.Font('Comfortaa Bold@16'))

    self.lblDesc = self:Add('vox.Label')
    self.lblDesc:SetText('Description')
    self.lblDesc:SetContentAlignment(7)
    self.lblDesc:SetFont(vox.Font('Comfortaa@14'))
    self.lblDesc:SetTextColor(self.subtextColor)
    self.lblDesc:Hide()
end

function PANEL:SetHiddenLabels(bBool)
    self.m_bHiddenLabels = bBool
    self.lblTitle:SetVisible(not bBool)
end

function PANEL:EnableDescription()
    self.lblTitle:SetContentAlignment(1)
    self.lblTitle:Font('Comfortaa Bold@14')
    self.lblDesc:Show()

    self:SetTall(vox.ScaleTall(45))
end

function PANEL:PerformLayout(w, h)
    self.divIcon:Dock(LEFT)
    self.divIcon:SetWide(h)

    self.lblTitle:Dock(FILL)

    self.lblDesc:Dock(BOTTOM)
    self.lblDesc:SetTall(h * .5)

    self.lineThickness = math.ceil(ScreenScale(1))
    self.mask = vox.CalculateRoundedBox(self.m_iRoundness, 0, 0, w, h)
end

local colorGradient = vox.OffsetColor(colorAccent, -75)
function PANEL:Paint(w, h)
    local inset = 0
    local accent = ( self.data and self.data.iconColor ) or colorAccent

    if vox.DrawVoxPanel then
        vox.DrawVoxPanel( inset, inset, w - inset * 2, h - inset * 2, { primary = self.color, secondary = colorTertiary, accent = accent }, self.m_iRoundness )
        if vox.DrawVoxBlade then vox.DrawVoxBlade( 0, vox.ScaleTall( 7 ), vox.ScaleWide( 5 ), h - vox.ScaleTall( 14 ), accent ) end
        vox.DrawAngledRect( w - vox.ScaleWide( 34 ), 0, vox.ScaleWide( 34 ), h, vox.ScaleWide( 9 ), ColorAlpha( accent, self.state and 70 or 24 ) )
    else
        draw.RoundedBox(self.m_iRoundness, inset, inset, w - inset * 2, h - inset * 2, self.color)
    end

    if (self.state) then
        if (self.m_Roundness == 0) then
            vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(colorGradient, self.animFraction * 255))
        else
            vox.DrawWithPolyMask(self.mask, function()
                vox.DrawMatGradient(0, 0, w, h, RIGHT, ColorAlpha(colorGradient, self.animFraction * 255))
            end)
        end
    end
end

function PANEL:Setup(data)
    assert(data.name, 'The \"name\" field is missing')
    assert(data.desc, 'The \"desc\" field is missing')

    self.lblTitle:SetText(data.name)
    self.lblDesc:SetText(data.desc)

    if (data.nameColor) then
        self.lblTitle:SetTextColor(data.nameColor)
    end

    if (data.descColor) then
        self.lblDesc:SetTextColor(data.descColor)
    end

    if (data.iconColor) then
        self.divIcon:SetColor(data.iconColor)
    end

    if data.wimg then
        self.divIcon:SetWebImage(data.wimg, 'smooth mips')
    elseif data.svg then
        self.divIcon:SetSVG(data.svg, 32)
    elseif data.icon then
        self.divIcon:SetURL(data.icon, 'smooth mips')
    elseif data.mat then
        self.divIcon:SetMaterial(data.mat)
    end

    self.data = data
end

function PANEL:SetState(bool)
    local target = bool and 1 or 0

    self:SetHoverBlocked(bool)
    self.state = bool

    if not bool then
        self:Call('OnCursorExited')
    else
        vox.anim.Remove(self, vox.anim.ANIM_HOVER)
        vox.anim.Create(self, .33, {
            index = vox.anim.ANIM_HOVER,
            target = {
                ['color'] = vox.ColorEditHSV(colorAccent, nil, .7, .7)
            }
        })
    end

    vox.anim.Create(self, .33, {
        index = 1,
        target = {
            textColor = (bool and colorDark or color_white),
            subtextColor = (bool and colorDark or colorGray)
        },
        think = function(anim, panel)
            panel.lblTitle:SetTextColor(panel.textColor)
            panel.divIcon:SetColor(panel.textColor)
            panel.lblDesc:SetColor(panel.subtextColor)
        end
    })

    vox.anim.Create(self, .1, {
        index = 44,
        target = {
            animFraction = target
        }
    })
end

function PANEL:DoClick()
    self.bool = not self.bool
    self:SetState(self.bool)
end

vox.gui.Register('vox.Sidebar.Tab', PANEL)

--[[------------------------------
Main
--------------------------------]]

PANEL = {}

AccessorFunc(PANEL, 'm_pContainer', 'Container')
AccessorFunc(PANEL, 'm_bDescriptionEnabled', 'DescriptionEnabled')
AccessorFunc(PANEL, 'm_bKeepTabContent', 'KeepTabContent')

function PANEL:Init(arguments)
    local padding = vox.ScaleTall(10)

    self.padding = padding
    self.tabs = {}
    self.m_bDescriptionEnabled = false
    self.m_bKeepTabContent = false

    self:DockPadding(padding, 0, padding, padding)
end

function PANEL:Paint(w, h)
    if vox.DrawVoxPanel then
        vox.DrawVoxPanel(0, 0, w, h, { primary = colorSecondary, secondary = colorTertiary, accent = colorAccent }, 8)
        vox.DrawVoxScanlines( vox.ScaleWide( 10 ), vox.ScaleTall( 10 ), w - vox.ScaleWide( 20 ), h - vox.ScaleTall( 20 ), ColorAlpha( colorAccent, 8 ), vox.ScaleTall( 8 ) )
    else
        draw.RoundedBoxEx(8, 0, 0, w, h, colorSecondary, nil, nil, true)
    end
end

function PANEL:AddTab(data)
    local btnTab = self:Add('vox.Sidebar.Tab')
    btnTab:Setup(data)
    btnTab:Dock(TOP)
    btnTab:DockMargin(0, 0, 0, vox.ScaleTall(5))
    btnTab.DoClick = function(panel)
        self:Call('OnTabSelected', nil, panel)
    end

    if (self:GetDescriptionEnabled()) then
        btnTab:EnableDescription()
    end

    btnTab.tabIndex = table.insert(self.tabs, btnTab)

    self:Call('OnTabAdded', nil, btnTab)

    return btnTab
end

function PANEL:ChooseTab(index)
    local tab = self.tabs[index]
    if (tab) then
        self:Call('OnTabSelected', nil, tab)
    end
end

function PANEL:OnTabSelected(panel)
    local data = panel.data

    assert(data, 'No data for a tab')

    if (self.oldTabPanel == panel) then
        return
    end

    if data.onClick and not data.onClick() then
        return
    end

    if IsValid(self.oldTabPanel) then
        self.oldTabPanel:SetState(false)
    end

    panel:Call('OnCursorEntered')
    panel:SetState(true)
    self.oldTabPanel = panel

    local container = self:GetContainer()

    assert(IsValid(container), 'You must link a valid container to the sidebar!')
    assert(data.class, 'The tab must be blocked via `onClick` or create a panel!')

    if IsValid(container.content) then
        if (self.m_bKeepTabContent) then
            container.content:Hide()
        else
            container.content:Remove()
        end
    end

    if (self.m_bKeepTabContent) then
        if (IsValid(panel.content)) then
            panel.content:Show()
        else
            panel.content = vgui.Create(data.class)
            panel.content:SetParent(container)
            panel.content:Dock(FILL)
        end
    else
        panel.content = vgui.Create(data.class)
        panel.content:SetParent(container)
        panel.content:Dock(FILL)
    end

    container.content = panel.content
    -- container.content:SetAlpha(0)
    -- container.content:AlphaTo(255, .1)

    if data.onSelected then
        data.onSelected(container.content)
    end

    -- bc OnTabSelected might be blocked by `onClick`
    self:Call('OnTabSwitched', nil, panel)
end

vox.gui.Register('vox.Sidebar', PANEL)

--[[------------------------------
MiniSidebar
--------------------------------]]
local PANEL = {}

function PANEL:Init()
    self.padding = 0
    self:DockPadding(0, 0, 0, 0)
end

function PANEL:OnTabAdded(tab)
    tab:SetRoundness(0)
    tab:SetHiddenLabels(true)
    tab:SetTall(self:GetWide())
end

vox.gui.Register('vox.MiniSidebar', PANEL, 'vox.Sidebar')

-- ANCHOR Test

-- vox.gui.Test('vox.Frame', .65, .65, function(self, w, h)
--     self:MakePopup()

--     -- local sidebar = self:Add('vox.Sidebar')
--     local sidebar = self:Add('vox.MiniSidebar')
--     sidebar:SetWide(w * .04)
--     sidebar:Dock(LEFT)
--     -- sidebar:SetDescriptionEnabled(true)

--     local container = self:Add('Panel')
--     container:Dock(FILL)

--     sidebar:SetContainer(container)
--     sidebar:AddTab({
--         name = 'DASHBOARD',
--         desc = 'Main things',
--         class = 'DButton',
--         onSelected = function(panel)
--             panel:SetText('Meow')
--         end
--     })
--     sidebar:AddTab({
--         name = 'JOBS',
--         desc = 'Choose your destiny',
--         class = 'DButton',
--     })
--     sidebar:AddTab({
--         name = 'SHOP',
--         desc = 'Find items you need',
--         class = 'DButton',
--     })
--     sidebar:AddTab({
--         name = 'SETTINGS',
--         desc = 'Configure the game as you wish',
--         class = 'DButton',
--     })
-- end)
