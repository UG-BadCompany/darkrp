local fallbackJobPreviewColors = {
    primary = Color(8, 19, 38),
    secondary = Color(12, 32, 62),
    tertiary = Color(16, 42, 78),
    accent = Color(70, 135, 255),
    money = Color(35, 225, 120)
}
local colorBG = vox.OffsetColor(fallbackJobPreviewColors.primary, -3)

local function getThemeColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    return colors.primary or fallbackJobPreviewColors.primary, colors.secondary or fallbackJobPreviewColors.secondary, colors.tertiary or fallbackJobPreviewColors.tertiary, colors.accent or fallbackJobPreviewColors.accent, colors.money or fallbackJobPreviewColors.money
end
local colorFavoriteIconIdle = Color(235, 235, 235)
local colorFavoriteIconActive = Color(255, 241, 93)

local L = function(...) return vox.lang:Get(...) end

local function generateDescHTML(desc)
    -- white-space: pre-wrap -- supports /t aswell
    local size = vox.ScaleTall(12)
    local html = [[
        <head>
            <meta charset="UTF-8">
            <style>
                @import url('https://fonts.googleapis.com/css2?family=Comfortaa&family=Roboto:wght@400;600&display=swap');
                body {
                    color: white;
                    font-family: 'Comfortaa';
                    font-size: %dpx;
                    opacity: 0.999;
                    padding: 0;
                    margin: 0;
                    white-space: pre-line;
                    scroll-margin: 20px;
                    line-height: 1.5;
                }

                li {
                    line-height: 5px;
                }

                img {
                    text-align: center;
                    vertical-align: middle;
                    width: 24px;
                    height: 24px;
                }

                /* width */
                ::-webkit-scrollbar {
                    width: 4px;
                }

                /* Track */
                ::-webkit-scrollbar-track {
                    background: rgba(0, 0, 0, 0.1);
                    border-radius: 5px;
                }

                /* Handle */
                ::-webkit-scrollbar-thumb {
                    background: ]] .. vox.ColorToHex(fallbackJobPreviewColors.accent) .. [[;
                    border-radius: 5px;
                }

                /* Handle on hover */
                ::-webkit-scrollbar-thumb:hover {
                    background: ]] .. vox.ColorToHex(vox.OffsetColor(fallbackJobPreviewColors.accent, -30)) .. [[;
                }
            </style>
        </head>
        <body>
            %s
        </body>
    ]]
    return string.format(html, size, desc)
end

local PANEL = {}

function PANEL:Init()
    local _, _, themeTertiary = getThemeColors()
    self.colorSlightGradient = themeTertiary

    self.divInfo = self:Add('Panel')

    self.divModel = self:Add('Panel')

    self.iconModel = self.divModel:Add('DModelPanel')
    self.iconModel:Dock(FILL)
    self.iconModel:SetCursor('arrow')
    self.iconModel.LayoutEntity = function(panel, ent) end
    self.iconModel.slots = {}
    self.iconModel.PerformLayout = function(panel, w, h)
        local children = panel.slots
        local amount = #children
        local columns = 2
        local rows = math.ceil(amount / columns)
        local size = vox.ScaleTall(36)
        local padding = vox.ScaleTall(10)
        local space = vox.ScaleTall(5)
        local X = w - size * columns - padding - space
        local Y = h - size * rows - padding - space * (rows - 1)

        local x = X
        for index = 1, amount do
            local button = children[index]

            button:SetSize(size, size)
            button:SetPos(x, Y)

            if (index % columns == 0) then
                x = X
                Y = Y + size + space
            else
                x = x + size + space
            end
        end
    end

    self.lblName = self.divInfo:Add('vox.Label')
    self.lblName:Font('Comfortaa Bold@20')
    self.lblName:SetWrap(true)
    self.lblName:SetTextColor(color_white)
    self.lblName:SetAutoStretchVertical(true)
    self.lblName:Dock(TOP)

    self.lblSalary = self.divInfo:Add('vox.Label')
    self.lblSalary:Font('Comfortaa Bold@16')
    local _, _, _, _, themeMoney = getThemeColors()
    self.lblSalary:SetTextColor(themeMoney or Color(35, 225, 120))
    self.lblSalary:Dock(TOP)
    self.lblSalary:DockMargin(0, 0, 0, vox.ScaleTall(20))

    self.navbar = self.divInfo:Add('vox.Navbar')
    self.navbar:Dock(TOP)
    self.navbar:SetTall(vox.ScaleTall(35))
    self.navbar:DockMargin(0, 0, 0, vox.ScaleTall(5))
    self.navbar:SetSpace(vox.ScaleWide(15))
    self.navbar.Paint = function(panel, w, h)
        local x1 = -self.padding
        local w1 = w + self.padding * 2

        local parent = self:GetParent()
        local x, y = parent:LocalToScreen(0, 0)
        local realW, realH = parent:GetSize()

        DisableClipping(true)
            render.SetScissorRect(x, y, x + realW, y + realH, true)
                surface.SetDrawColor(colorLine)
                surface.DrawRect(x1, h - 1, w1, 1)
            render.SetScissorRect(0, 0, 0, 0, false)
        DisableClipping(false)
    end
    self.navbar.OnTabAdded = function(panel, tab)
        tab:SizeToContents()
        tab:SetFont(vox.Font('Comfortaa Bold@14'))
    end

    self.navbarContent = self.divInfo:Add('Panel')
    self.navbarContent:Dock(FILL)

    self.navbar:SetKeepTabContent(true)
    self.navbar:SetContainer(self.navbarContent)

    self.footer = self.divInfo:Add('Panel')
    self.footer:Dock(BOTTOM)
    self.footer:SetTall(vox.ScaleTall(30))

    self.btnChoose = self.footer:Add('vox.Button')
    self.btnChoose:SetText(L('f4_become_u'))
    self.btnChoose:SetGradientColor(vox.OffsetColor(fallbackJobPreviewColors.accent, -50))
    self.btnChoose:SetMasking(true)
    self.btnChoose:Font('Comfortaa Bold@16')
    self.btnChoose:Dock(FILL)

    self.btnFavorite = self.footer:Add('vox.ImageButton')
    self.btnFavorite:Dock(RIGHT)
    self.btnFavorite:SetWide(self.footer:GetTall( ))
    self.btnFavorite:DockMargin(vox.ScaleTall(10), 0, 0, 0)
    self.btnFavorite.SetState = function(panel, state, ignore)
        panel.bState = state

        if (not ignore) then
            vox.f4:SetFavorite(self.teamCommand, state)
            self:Call('OnFavoriteStateSwitched', nil, self.teamCommand, state)
        end

        local targetColor = state and colorFavoriteIconActive or colorFavoriteIconIdle

        if (state) then
            panel:SetImage('vox_f4menu/favorite_fill.png', 'smooth mips')
        else
            panel:SetImage('vox_f4menu/favorite_outline.png', 'smooth mips')
        end

        vox.anim.Create(panel, .33, {
            index = vox.anim.ANIM_HOVER,
            target = {
                m_colColor = targetColor
            }
        })
    end

    self.btnFavorite.m_Angle = 0
    self.btnFavorite.voxEvents['OnCursorEntered'] = nil
    self.btnFavorite.voxEvents['OnCursorExited'] = nil
    self.btnFavorite.voxEvents['OnRelease'] = nil
    self.btnFavorite.voxEvents['OnPress'] = nil
    self.btnFavorite:InstallRotationAnim()
    self.btnFavorite.m_iImageScale = 1
    self.btnFavorite.m_iImageScaleInitial = 1

    self.btnFavorite.DoClick = function(panel)
        panel:SetState(not panel.bState)
    end

    self.spacer = self.divInfo:Add('Panel')
    self.spacer:Dock(BOTTOM)
    self.spacer:DockMargin(0, vox.ScaleTall(10), 0, vox.ScaleTall(5))
    self.spacer.Paint = function(panel, w, h)
        local x1 = -self.padding
        local w1 = w + self.padding * 2

        local parent = self:GetParent()
        local x, y = parent:LocalToScreen(0, 0)
        local realW, realH = parent:GetSize()

        DisableClipping(true)
            render.SetScissorRect(x, y, x + realW, y + realH, true)
                surface.SetDrawColor(colorLine)
                surface.DrawRect(x1, h * .5, w1, 1)
            render.SetScissorRect(0, 0, 0, 0, false)
        DisableClipping(false)
    end

    self.navbar:AddTab({
        name = L('f4_description_u'),
        class = 'DHTML',
        onBuild = function(content)
            content:SetHTML(generateDescHTML(''))
        end
    })

    self.navbar:AddTab({
        name = L('f4_weapons_u'),
        class = 'vox.ScrollPanel'
    })
end

function PANEL:SetupJob(job)
    local models = job.model
    local multipleModels = istable(models) and #models > 1
    local model = istable(models) and models[1] or models
    local desc = job.description:Trim()
    local weaponsList = job.weapons or {}
    local teamIndex = job.team

    local navbar = self.navbar
    local tabs = navbar.tabs
    local descTab = tabs[1]
    local weaponsTab = tabs[2]
    local btnChoose = self.btnChoose

    self.teamIndex = teamIndex
    self.teamCommand = job.command
    self.teamData = job

    self.btnFavorite:SetState(vox.f4:IsFavorite(job.command), true)

    if (job.vote or job.RequiresVote and job.RequiresVote(LocalPlayer(), job.team)) then
        btnChoose:SetText(L('f4_create_vote_u'))
        btnChoose.DoClick = function(panel)
            RunConsoleCommand('darkrp', 'vote' .. self.teamCommand)
        end
    else
        btnChoose:SetText(L('f4_become_u'))
        btnChoose.DoClick = function(panel)
            RunConsoleCommand('darkrp', self.teamCommand)
        end
    end

    self.lblName:SetText(vox.utf8.upper(job.name))

    self.lblSalary:SetText(L('f4_salary') .. ': ' .. DarkRP.formatMoney(job.salary))

    local _, themeSecondary, _, themeAccent = getThemeColors()
    self.colorSlightGradient = vox.LerpColor(.18, themeSecondary, themeAccent)

    self.iconModel:SetModel(model)
    self.iconModel:SetCamPos(Vector(50, 0, 50))
    self.iconModel:SetFOV(45)

    self.iconModel:Clear()
    self.iconModel.slots = {}

    if (multipleModels) then
        local oldActiveModel
        for index, model in ipairs(models) do
            if (index > 14) then break end

            local button = self.iconModel:Add('DButton')
            button:SetText('')
            button.active = index == 1
            button.PerformLayout = function(panel, w, h)
                panel.mask = vox.CalculateCircle(w * .5, h * .5, h * .5 - 2, 16)
            end
            button.Paint = function(panel, w, h)
                local child = panel:GetChild(0)

                local _, themeSecondary = getThemeColors()
                vox.DrawCircle(w * .5, h * .5, h * .5, themeSecondary)

                if (IsValid(child)) then
                    vox.DrawWithPolyMask(panel.mask, function()
                        child:PaintManual()
                    end)
                end

                vox.DrawOutlinedCircle(w * .5, h * .5, h * .5, 3, panel.active and (select(4, getThemeColors())) or color_white)
            end
            button.DoClick = function(panel)
                if (oldActiveModel) then
                    oldActiveModel.active = false
                end

                self.iconModel:SetModel(model)
                panel.active = true
                oldActiveModel = panel

                DarkRP.setPreferredJobModel(teamIndex, model)
            end

            if (index == 1) then
                oldActiveModel = button
            end

            local modelicon = button:Add('SpawnIcon')
            modelicon:Dock(FILL)
            modelicon:SetModel(model)
            modelicon:SetMouseInputEnabled(false)
            modelicon:SetPaintedManually(true)

            table.insert(self.iconModel.slots, button)
        end
    end

    navbar:SelectTab(descTab, true)

    if (IsValid(descTab.content)) then
        desc = desc:gsub('\t', '')
        desc = string.JavascriptSafe(desc)

        descTab.content:QueueJavascript([[
            document.body.innerHTML = ']] .. desc .. [[';
        ]])
    end

    weaponsTab:SetVisible(#weaponsList > 0)
    weaponsTab.tabData.onBuild = function(content)
        for _, class in ipairs(weaponsList) do
            local swepTable = weapons.Get(class)
            local name
            if (swepTable) then
                name = language.GetPhrase(swepTable.PrintName)
            else
                name = language.GetPhrase(class)
            end

            local panel = content:Add('vox.Label')
            panel:Dock(TOP)
            panel:SetText(name)
            panel:SetTall(vox.ScaleTall(30))
            panel:SetContentAlignment(5)
            panel:SetFont(vox.Font('Comfortaa Bold@16'))
            panel.Paint = function(this, w, h)
                local themePrimary, _, themeTertiary = getThemeColors()
                draw.RoundedBox(8, 0, 0, w, h, themePrimary)
                draw.RoundedBox(8, 1, 1, w - 2, h - 2, themeTertiary)
            end
        end
    end

    if (IsValid(weaponsTab.content)) then
        weaponsTab.content:Remove()
    end
end

function PANEL:PerformLayout(w, h)
    local padding = vox.ScaleTall(15)
    self.padding = padding

    self.divInfo:Dock(FILL)
    self.divInfo:DockPadding(padding, padding, padding, vox.ScaleTall(5))

    self.divModel:Dock(RIGHT)
    self.divModel:SetWide(w * .5)
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen(0, 0)

    local frame = vox.f4.frame
    if (not IsValid(frame)) then return end -- just in case

    local container = frame.container or frame.content or frame
    local realX, realY = container:LocalToScreen(0, 0)
    local realW, realH = container:GetSize()
    local padding = frame.containerPadding or vox.ScaleTall(18)

    local divModel = self.divModel
    local Y = -padding
    local H = h + padding * 2
    local W = w + padding

    local themePrimary, themeSecondary, themeTertiary, themeAccent = getThemeColors()
    colorBG = vox.OffsetColor(themePrimary, -3)

    if (self.enabled) then
        vox.bshadows.BeginShadow()
            surface.SetDrawColor(themeSecondary)
            surface.DrawRect(x, y, w, h)
        vox.bshadows.EndShadow(1, 2, 2, nil, 90, 2, true)
    end

    DisableClipping(true)
        render.SetScissorRect(realX, realY, realX + realW, realY + realH, true)
            vox.DrawVoxPanel(0, Y, W, H, { primary = themeSecondary, secondary = themePrimary, accent = self.colorSlightGradient or themeAccent }, 8)

            local modelX = divModel:GetPos()
            vox.DrawAngledRect(modelX - vox.ScaleWide(24), Y, divModel:GetWide() + padding + vox.ScaleWide(24), H, vox.ScaleWide(28), colorBG)
            vox.DrawVoxBlade(modelX - vox.ScaleWide(12), Y + vox.ScaleTall(18), vox.ScaleWide(8), H - vox.ScaleTall(36), themeAccent)
            vox.DrawAngledRect(0, Y, self.divInfo:GetWide() * .58, vox.ScaleTall(58), vox.ScaleWide(18), ColorAlpha(self.colorSlightGradient, 38))
            vox.DrawMatGradient(0, Y, self.divInfo:GetWide(), H * .5, BOTTOM, ColorAlpha(self.colorSlightGradient, 85))

            surface.SetDrawColor(ColorAlpha(self.colorSlightGradient, 105))
            surface.DrawLine(vox.ScaleWide(18), Y + vox.ScaleTall(10), self.divInfo:GetWide() - vox.ScaleWide(30), Y + vox.ScaleTall(10))
            surface.DrawLine(modelX + vox.ScaleWide(20), Y + H - vox.ScaleTall(12), W - vox.ScaleWide(18), Y + H - vox.ScaleTall(12))
        render.SetScissorRect(0, 0, 0, 0, false)
    DisableClipping(false)
end

vox.gui.Register('vox.f4.JobPreview', PANEL)
