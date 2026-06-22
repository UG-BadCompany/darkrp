local colorPrimary = vox:Config('colors.primary')
local colorTertiary = vox:Config('colors.tertiary')
local colorAccent = vox:Config('colors.accent')
local wimgLoading = vox.wimg.Simple('https://i.imgur.com/VVswRpx.png', 'smooth mips')
local lastChosenTab = 1

local L = function(...) return vox.lang:Get(...) end

DEFINE_BASECLASS('vox.Frame')

local PANEL = {}

function PANEL:Init()
    vox.f4.frame = self

    local padding = vox.ScaleTall(14)
    self.containerPadding = padding
    self:SetAlpha(0)
    self:AlphaTo(255, .22, 0)
    self:SetSize(ScrW() * .82, ScrH() * .82)
    self:Center()

    self.container = self:Add('Panel')
    self.container:DockPadding(padding * 1.4, padding * 1.4, padding * 1.4, padding * 1.4)
    self.container.Paint = function(panel, w, h)
        vox.DrawVoxGlass(0, 0, w, h, { radius = 22, alpha = 238, accent = colorAccent })
        vox.DrawVoxCornerTicks(16, 16, w - 32, h - 32, ColorAlpha(colorAccent, 80), 28)
        draw.SimpleText('COMMAND CENTER', vox.Font('Comfortaa Bold@18'), vox.ScaleWide(24), vox.ScaleTall(18), ColorAlpha(color_white, 230), 0, 1)
    end

    self.sidebar = self:Add('vox.Sidebar')
    self.sidebar:SetDescriptionEnabled(true)
    self.sidebar:SetContainer(self.container)
    self.sidebar:SetKeepTabContent(true)
    self:Combine(self.sidebar, 'ChooseTab')
    self.sidebar:On('OnTabSwitched', function(panel, tab)
        if (tab.data.class ~= 'HTML') then
            lastChosenTab = tab.tabIndex
        end
    end)

    self.profile = self:InitProfile()

    self:SetTitle(vox.f4:GetOptionValue('title'))
    self:LoadTabs()
    self:ChooseTab(lastChosenTab)
    self.currentJob = LocalPlayer():Team()
end

function PANEL:PerformLayout(w, h)
    BaseClass.PerformLayout(self, w, h)

    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(math.max(vox.ScaleWide(230), w * .22))

    self.container:Dock(FILL)
end

function PANEL:InitProfile()
    local sidebar = self.sidebar
    local padding = vox.ScaleTall(7.5)
    local client = LocalPlayer()

    local labelText = team.GetName(client:Team())
    local labelColor = vox.f4.ConvertJobColor(team.GetColor(client:Team()))
    local labelFont = vox.Font('Comfortaa@14')

    local profile = sidebar:Add('Panel')
    profile:SetTall(vox.ScaleTall(82))
    profile:Dock(TOP)
    profile:DockMargin(0, 0, 0, vox.ScaleTall(5))
    profile:DockPadding(padding, padding, padding, padding)
    profile.Paint = function(panel, w, h)
        vox.DrawVoxPremiumCard(0, 0, w, h, { accent = labelColor, radius = 18, alpha = 230 })
        vox.DrawMatGradient(w * .55, 0, w * .45, h, RIGHT, ColorAlpha(labelColor, 36))
    end
    profile.Think = function(panel)
        if ((panel.nextThink or 0) > CurTime()) then return end
        panel.nextThink = CurTime() + .25

        local lblJob = panel.lblJob

        labelColor = vox.f4.ConvertJobColor(team.GetColor(client:Team()))
        labelText = team.GetName(client:Team())

        if (IsValid(lblJob)) then
            lblJob:SetText(labelText)
        end
    end

    local avatar = profile:Add('vox.RoundedAvatar')
    avatar:Dock(LEFT)
    avatar:SetWide(profile:GetTall() - padding * 2)
    avatar:SetPlayer(LocalPlayer(), 64)
    avatar:DockMargin(0, 0, vox.ScaleWide(10), 0)
    avatar.PaintOver = function(panel, w, h)
        vox.DrawOutlinedCircle(w * .5, h * .5, w * .5, 4, labelColor)
    end

    local lblTitle = profile:Add('vox.Label')
    lblTitle:Dock(TOP)
    lblTitle:SetText(client:Name())
    lblTitle:Font('Comfortaa Bold@16')
    lblTitle:SetContentAlignment(4)

    local lblJob = profile:Add('vox.Label')
    lblJob:Dock(FILL)
    lblJob:SetText(labelText)
    lblJob:SetTextColor(labelColor)
    lblJob:SetFont(labelFont)
    lblJob:SetContentAlignment(7)
    profile.lblJob = lblJob

    profile.PerformLayout = function(panel, w, h)
        lblTitle:SetTall((h - padding * 2) / 2)
    end

    return profile
end

do
    local LINKS = {
        {
            name = 'discord_url',
            desc = 'f4.discord_url.desc',
            icon = 'https://i.imgur.com/tYNtgoR.png'
        },
        {
            name = 'forum_url',
            desc = 'f4.forum_url.desc',
            icon = 'https://i.imgur.com/RH3sx4q.png'
        },
        {
            name = 'steam_url',
            desc = 'f4.steam_url.desc',
            icon = 'https://i.imgur.com/jB5T1Wo.png'
        },
        {
            name = 'rules_url',
            desc = 'f4.rules_url.desc',
            icon = 'https://i.imgur.com/JFhx1xW.png'
        },
        {
            name = 'donate_url',
            icon = 'https://i.imgur.com/MrgKOkL.png',
            desc = 'f4_donate_desc',
            donate = true
        },
    }

    function PANEL:LoadTabs()
        local tabs = vox.f4:GetSortedTabs()
        local hideDonateTab = vox.f4:GetOptionValue('hide_donate_tab')
        local donateTabAdded = false

        for _, tab in ipairs(tabs) do
            self.sidebar:AddTab({
                name = L(tab.name),
                desc = L(tab.desc),
                icon = tab.icon,
                class = tab.class
            })
        end

        if (vox.creditstore and not hideDonateTab) then
            local colorGold = Color(255, 225, 106)
            local colorGoldDesc = Color(157, 143, 84)

            self.sidebar:AddTab({
                name = vox.lang:Get('f4_donate_u'),
                desc = vox.lang:Get('f4_donate_desc'),
                wimg = 'creditstore_currency',
                nameColor = colorGold,
                descColor = colorGoldDesc,
                iconColor = colorGold,
                onClick = function()
                    RunConsoleCommand('vox_store_open')
                    self:Close()
                    return false
                end
            })

            donateTabAdded = true
        end

        for _, link in ipairs(LINKS) do
            local option = vox.inconfig.options['f4_' .. link.name]
            local name = L(option.title)
            local url = vox.f4:GetOptionValue(link.name):Trim()

            if (link.donate and donateTabAdded) then continue end

            if (url ~= '') then
                self.sidebar:AddTab({
                    name = name:upper(),
                    desc = (link.desc and L(link.desc) or ''),
                    icon = link.icon,
                    wimg = link.wimg,
                    class = 'HTML',
                    onSelected = function(content)
                        content:OpenURL(url)
                        content.OnBeginLoadingDocument = function(panel)
                            if (not panel.bLoaded) then
                                panel.bLoading = true
                            end
                        end
                        content.OnFinishLoadingDocument = function(panel)
                            panel.bLoading = nil
                            panel.bLoaded = true
                        end
                        content.PaintOver = function(panel, w, h)
                            if (panel.bLoading) then
                                local maxSize = vox.ScaleTall(64)
                                local size = maxSize * .5 + maxSize * .5 * math.abs(math.sin(CurTime()))

                                wimgLoading:DrawRotated(w * .5, h * .5, size, size, (CurTime() * 100) % 360)
                            end
                        end
                    end,
                    onClick = function()
                        if (not vox.f4:GetOptionValue('website_ingame')) then
                            gui.OpenURL(url)
                            self:Close()
                            return false
                        end
                        return true
                    end
                })
            end
        end

        CAMI.PlayerHasAccess(LocalPlayer(), 'vox_f4_edit', function(bAllowed)
            if (not bAllowed) then return end
            self.sidebar:AddTab({
                name = L('f4_admin_u'),
                desc = L('f4_admin_desc'),
                icon = 'https://i.imgur.com/l4M12dO.png',
                onClick = function()
                    vox.f4.OpenAdminSettings()
                    self:Remove()
                    return false
                end
            })
        end)
    end
end

function PANEL:Think()
    if (self.currentJob ~= LocalPlayer():Team() and not self.jobRemoveCalled) then
        self:Remove()
        self.jobRemoveCalled = true
    end

    local keyName = input.LookupBinding('gm_showspare2', true)
    if (keyName) then
        local keyIndex = input.GetKeyCode(keyName)
        if (keyIndex and keyIndex > 0) then
            local keyDown = input.IsKeyDown(keyIndex)

            if (self.keyDown == nil) then
                self.keyDown = keyDown
            elseif (self.keyDown ~= keyDown) then
                self.keyDown = keyDown
                if (keyDown) then
                    self:Remove()
                end
            end
        end
    end
end

vox.gui.Register('vox.f4.Frame', PANEL, 'vox.Frame')

-- Vox local preview helper
-- vox.gui.Test('vox.f4.Frame', .65, .65, function(panel)
--     panel:MakePopup()
-- end)
