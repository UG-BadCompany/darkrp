local hud = vox.hud
local COLOR_BAR = Color( 200, 200, 200, 10 )
local COLOR_GRAY = Color( 183, 183, 183)
local COLOR_XP = Color( 245, 197, 66 )

local WIMG_HEART = vox.wimg.Create( 'hud_heart', 'smooth mips' )
local WIMG_SHIELD = vox.wimg.Create( 'hud_shield', 'smooth mips' )
local WIMG_FOOD = vox.wimg.Create( 'hud_food', 'smooth mips' )
local WIMG_LICENSE = vox.wimg.Create( 'hud_license', 'smooth mips' )
local WIMG_STAR = vox.wimg.Create( 'hud_wanted', 'smooth mips' )
local WIMG_MICROPHONE = vox.wimg.Create( 'hud_microphone', 'smooth mips' )
local CONVAR_COMPACT = CreateClientConVar( 'cl_vox_hud_compact', '0', true, false, '', 0, 1 )
local CONVAR_3D = CreateClientConVar( 'cl_vox_hud_3d_models', '0', true, false, '', 0, 1 )
local CONVAR_HELP = CreateClientConVar( 'cl_vox_hud_show_help', '1', true, false, '', 0, 1 )

-- They are scaled after
local UNSCALED_BAR_H = 6
local UNSCALED_BAR_ICON_SIZE = 12
local UNSCALED_ICON_SIZE = 18
local UNSCALED_SPACE = 5

local slowLabels = {}
local lastMaskY
local lerpHealth, lerpArmor, lerpHunger
local lerpMoney

local function formatSalary( salary )
    -- local iters = ( 3600 / GAMEMODE.Config.paydelay )
    -- local full = math.Round( salary * iters )
    -- local formatted = '+' .. DarkRP.formatMoney( full ) .. '/h'
    return '+ ' .. ( DarkRP and DarkRP.formatMoney and DarkRP.formatMoney( salary ) or tostring( salary ) )
end

local function drawIndicator( x, y, w, h, material, color, fraction, label, valueText )
    if ( valueText == nil and isstring( label ) and label:find( '%%' ) ) then
        valueText = label
        label = nil
    end

    fraction = math.Clamp( fraction or 0, 0, 1 )

    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local colorTextPrimary = colors.textPrimary
    local colorTextSecondary = colors.textSecondary
    local iconSize = hud.ScaleTall( 14 )
    local iconSpace = hud.ScaleWide( 8 )
    local valueW = hud.ScaleWide( 36 )
    local labelW = hud.ScaleWide( 52 )
    local trackH = hud.ScaleTall( 7 )
    local trackX = x + iconSize + iconSpace + labelW
    local trackW = w - ( trackX - x ) - valueW - hud.ScaleWide( 8 )
    local trackY = math.floor( y + h * .5 - trackH * .5 )
    local radius = trackH * .5

    material:Draw( x, y + h * .5 - iconSize * .5, iconSize, iconSize, color )
    draw.SimpleText( label or '', hud.fonts.ExtraTinyBold, x + iconSize + iconSpace, y + h * .5, colorTextSecondary, 0, 1 )

    draw.RoundedBox( radius, trackX, trackY, trackW, trackH, ColorAlpha( colorTextPrimary, theme.isDark and 20 or 85 ) )
    draw.RoundedBox( radius + hud.ScaleTall( 2 ), trackX - hud.ScaleWide( 2 ), trackY - hud.ScaleTall( 2 ), trackW + hud.ScaleWide( 4 ), trackH + hud.ScaleTall( 4 ), ColorAlpha( color, 18 ) )

    if ( fraction > 0 ) then
        render.SetScissorRect( trackX, trackY, trackX + trackW * fraction, trackY + trackH, true )
            draw.RoundedBox( radius, trackX, trackY, trackW, trackH, color )
        render.SetScissorRect( 0, 0, 0, 0, false )
    end

    draw.SimpleText( valueText or ( math.Round( fraction * 100 ) .. '%' ), hud.fonts.ExtraTinyBold, x + w, y + h * .5, colorTextPrimary, 2, 1 )
end
local function drawStatusIcon( x, y, w, h, material, color )
    material:Draw( x, y, w, h, color or hud:GetColor( 'textTertiary' ) )
end

local function recreateAvatar( self )
    local bUse3DModel = CONVAR_3D:GetBool()
    local bUseModel = hud:GetOptionValue( 'main_avatar_mode' ) == 1
    local client = LocalPlayer()

    if ( IsValid( self.AvatarPanel ) ) then
        self.AvatarPanel:Remove()
    end

    if ( bUseModel ) then
        if ( bUse3DModel ) then
            self.AvatarPanel = vgui.Create( 'DModelPanel' )
            self.AvatarPanel.LayoutEntity = function() end
            self.AvatarPanel.PostUpdateLook = function( panel, model )
                local ent = panel.Entity

                if ( IsValid( ent ) ) then
                    local boneID = ent:LookupBone( 'ValveBiped.Bip01_Head1' )
                    if ( boneID ) then
                        local bonePos = ent:GetBonePosition( boneID )
                        if ( bonePos ) then
                            bonePos:Add( Vector( 0, 0, 2 ) )

                            panel:SetLookAt( bonePos )
                            panel:SetCamPos( bonePos + Vector( 24, 0, 3 ) )
                            panel:SetFOV( 32 )

                            ent:SetEyeTarget( bonePos + Vector( 24, 0, 3 ) )
                        end
                    end
                end
            end
        else
            self.AvatarPanel = vgui.Create( 'SpawnIcon' )
        end

        self.AvatarPanel.UpdateLook = function( panel, modelData )
            panel.modelData = modelData

            hud.UpdateModelIcon( panel, modelData )

            if ( panel.PostUpdateLook ) then
                panel:PostUpdateLook()
            end
        end

        local nextComparison = 0
        self.AvatarPanel.Think = function( panel )
            if ( nextComparison <= CurTime() ) then
                nextComparison = CurTime() + 1

                local actualData = hud.GetModelData( LocalPlayer() )
                local currentData = panel.modelData

                if ( not currentData or not hud.CompareModelData( currentData, actualData ) ) then
                    panel:UpdateLook( actualData )
                end
            end
        end
    else
        self.AvatarPanel = vgui.Create( 'AvatarImage' )
        self.AvatarPanel:SetPlayer( client, 128 )
    end

    self.AvatarPanel:SetPaintedManually( true )
    self.AvatarPanel:ParentToHUD()
end

local updateSlowLabels do
    local nextUpdate = 0
    local thinkRate = 1 / 10

    local function findBestFont( text, maxWidth, ... )
        local bestFont = select( 1, ... )
        assert( bestFont, 'no fonts given' )

        local lastWidth = math.huge
        for _, font in ipairs( { ... } ) do
            local width = vox.GetTextSize( text, font )
            local isGood = width <= maxWidth

            if ( isGood or width < lastWidth ) then
                bestFont = font
                lastWidth = width

                if ( isGood ) then
                    break
                end
            end
        end

        return bestFont
    end

    function updateSlowLabels( client, maxWidth )
        if ( nextUpdate <= CurTime() ) then
            nextUpdate = CurTime() + thinkRate
            slowLabels = {}

            local name = client:Name()
            local job = ( client:getDarkRPVar( 'job' ) or team.GetName( client:Team() ) )

            slowLabels.name = {
                text = name,
                font = findBestFont( name, maxWidth, hud.fonts.Name, hud.fonts.SmallBold, hud.fonts.TinyBold, hud.fonts.ExtraTinyBold )
            }

            slowLabels.job = {
                text = job,
                font = findBestFont( job, maxWidth, hud.fonts.Small, hud.fonts.Tiny )
            }
        end
    end
end

local function drawMainHUD( self, client, scrW, scrH )
    local isCompact = CONVAR_COMPACT:GetBool() or hud:GetOptionValue( 'compact_mode' )
    local showJob = not isCompact and hud:GetOptionValue( 'display_job' )
    local space = hud.GetScreenPadding()
    local padding = hud.ScaleTall( 12 )

    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local colorPrimary = colors.primary
    local colorSecondary = colors.secondary
    local colorTextPrimary = colors.textPrimary
    local colorTextSecondary = colors.textSecondary
    local isDark = theme.isDark
    local accent = colors.accent
    local moneyColor = colors.money or colors.positive or accent
    local teamColor = team.GetColor( client:Team() )

    local animSpeed = FrameTime() * ( hud:GetOptionValue( 'reduce_motion' ) and 64 or hud:GetOptionValue( 'animation_speed' ) or 16 )
    local healthFraction = math.Clamp( client:Health() / math.max( client:GetMaxHealth(), 1 ), 0, 1 )
    local maxArmor = math.max( client:GetMaxArmor() or 100, 1 )
    local armorFraction = math.Clamp( client:Armor() / maxArmor, 0, 1 )
    local money = client:getDarkRPVar( 'money' ) or 0

    lerpHealth = Lerp( animSpeed, lerpHealth or healthFraction, healthFraction )
    lerpArmor = Lerp( animSpeed, lerpArmor or armorFraction, armorFraction )
    lerpMoney = Lerp( animSpeed, lerpMoney or money, money )

    local salary = client:getDarkRPVar( 'salary' ) or 0
    local moneyFormatted = ( DarkRP and DarkRP.formatMoney and DarkRP.formatMoney( math.Round( lerpMoney ) ) or tostring( math.Round( lerpMoney ) ) )
    local salaryFormatted = formatSalary( salary )
    local darkRPDefaults = DarkRP and DarkRP.disabledDefaults and DarkRP.disabledDefaults[ 'modules' ]
    local hasHunger = hud:GetOptionValue( 'display_hunger' ) and not ( darkRPDefaults and darkRPDefaults[ 'hungermod' ] )
    local hasArmor = hud:GetOptionValue( 'display_armor' )
    local showLevel = ( not CONVAR_HELP:GetBool() ) and vox.hud:GetOptionValue( 'display_level' ) and vox.hud.IsLevellingEnabled()

    local rowH = hud.ScaleTall( 18 )
    local rowGap = hud.ScaleTall( 5 )
    local rowCount = ( hud:GetOptionValue( 'display_health' ) and 1 or 0 ) + ( hasArmor and 1 or 0 ) + ( hasHunger and 1 or 0 )
    local levelH = showLevel and hud.ScaleTall( 30 ) or 0
    local w = hud.ScaleWide( 304 )
    local h = padding * 2 + hud.ScaleTall( 45 ) + hud.ScaleTall( 44 ) + rowCount * rowH + math.max( rowCount - 1, 0 ) * rowGap + levelH + hud.ScaleTall( 8 )
    local x, y = space, scrH - h - space

    local avatarSize = hud.ScaleTall( 72 )
    local avatarX = x + padding
    local avatarY = y + hud.ScaleTall( 17 )
    local contentX = avatarX + avatarSize + hud.ScaleWide( 14 )
    local contentW = w - ( contentX - x ) - padding
    local nameY = y + padding + hud.ScaleTall( 4 )

    if vox.DrawVoxPanel then
        vox.DrawVoxPanel( x, y, w, h, colors, math.max( hud.GetRoundness(), hud.ScaleTall( 12 ) ) )
    else
        hud.DrawRoundedBox( x, y, w, h, ColorAlpha( colorPrimary, 238 ) )
    end
    vox.DrawMatGradient( x, y, w, h, BOTTOM, ColorAlpha( colorSecondary, isDark and 82 or 120 ) )
    vox.DrawMatGradient( x, y, w, h, RIGHT, ColorAlpha( accent, 18 ) )
    surface.SetDrawColor( ColorAlpha( accent, 120 ) )
    surface.DrawOutlinedRect( x, y, w, h, math.max( 1, hud.ScaleTall( 1 ) ) )

    updateSlowLabels( client, contentW - hud.ScaleWide( 20 ) )
    render.SetScissorRect( 0, 0, contentX + contentW - hud.ScaleWide( 22 ), ScrH(), true )
        local _, nameHeight = draw.SimpleText( slowLabels.name.text, slowLabels.name.font, contentX, nameY, colorTextPrimary, 0, 0 )
        if ( showJob ) then
            draw.SimpleText( slowLabels.job.text, slowLabels.job.font, contentX, nameY + nameHeight - hud.ScaleTall( 1 ), teamColor, 0, 0 )
        end
    render.SetScissorRect( 0, 0, 0, 0, false )

    local dotSize = hud.ScaleTall( 10 )
    vox.DrawCircle( x + w - padding - dotSize * .5, y + padding + dotSize * .5, dotSize * .55, ColorAlpha( colors.positive or accent, 45 ) )
    vox.DrawCircle( x + w - padding - dotSize * .5, y + padding + dotSize * .5, dotSize * .32, colors.positive or accent )

    if ( IsValid( self.AvatarPanel ) ) then
        local circleRadius = avatarSize * .5
        local maskX0, maskY0 = avatarX + circleRadius, avatarY + circleRadius
        if ( not self.AvatarMask or self.AvatarMaskRadius ~= circleRadius or self.AvatarMaskX ~= maskX0 or self.AvatarMaskY ~= maskY0 ) then
            self.AvatarMaskRadius, self.AvatarMaskX, self.AvatarMaskY = circleRadius, maskX0, maskY0
            self.AvatarMask = vox.CalculateCircle( maskX0, maskY0, circleRadius, 48 )
        end

        vox.DrawCircle( maskX0, maskY0, circleRadius + hud.ScaleTall( 4 ), ColorAlpha( colorSecondary, 220 ) )
        vox.DrawWithPolyMask( self.AvatarMask, function()
            vox.DrawCircle( maskX0, maskY0, circleRadius, colorPrimary )
            vox.DrawMatGradient( avatarX, avatarY, avatarSize, avatarSize, BOTTOM, ColorAlpha( teamColor, isDark and 35 or 120 ) )
            self.AvatarPanel:SetPos( avatarX, avatarY )
            self.AvatarPanel:SetSize( avatarSize, avatarSize )
            self.AvatarPanel:PaintManual()
        end )
        vox.DrawOutlinedCircle( maskX0, maskY0, circleRadius + hud.ScaleTall( 1.5 ), hud.ScaleTall( 3 ), ColorAlpha( teamColor, 230 ) )
    end

    local walletY = y + hud.ScaleTall( 64 )
    local walletH = hud.ScaleTall( 43 )
    draw.RoundedBox( hud.ScaleTall( 9 ), contentX, walletY, contentW, walletH, ColorAlpha( colorSecondary, 155 ) )
    vox.DrawMatGradient( contentX, walletY, contentW * .52, walletH, RIGHT, ColorAlpha( moneyColor, 34 ) )
    draw.RoundedBox( hud.ScaleTall( 3 ), contentX + hud.ScaleWide( 7 ), walletY + hud.ScaleTall( 8 ), hud.ScaleWide( 4 ), walletH - hud.ScaleTall( 16 ), ColorAlpha( moneyColor, 210 ) )
    surface.SetDrawColor( ColorAlpha( colorTextSecondary, isDark and 52 or 120 ) )
    surface.DrawRect( contentX + contentW * .56, walletY + hud.ScaleTall( 9 ), hud.ScaleWide( 1 ), walletH - hud.ScaleTall( 18 ) )

    draw.SimpleText( moneyFormatted, hud.fonts.SmallBold, contentX + hud.ScaleWide( 17 ), walletY + hud.ScaleTall( 13 ), colorTextPrimary, 0, 1 )
    draw.SimpleText( 'Wallet', hud.fonts.ExtraTinyBold, contentX + hud.ScaleWide( 17 ), walletY + hud.ScaleTall( 31 ), colorTextSecondary, 0, 1 )
    draw.SimpleText( salaryFormatted:gsub( '%+%s+', '+' ), hud.fonts.SmallBold, contentX + contentW - hud.ScaleWide( 10 ), walletY + hud.ScaleTall( 13 ), moneyColor, 2, 1 )
    draw.SimpleText( 'Salary', hud.fonts.ExtraTinyBold, contentX + contentW - hud.ScaleWide( 10 ), walletY + hud.ScaleTall( 31 ), colorTextSecondary, 2, 1 )

    local barsX = x + padding + hud.ScaleWide( 10 )
    local barsY = walletY + walletH + hud.ScaleTall( 10 )
    local barsW = w - padding * 2 - hud.ScaleWide( 20 )
    if ( hud:GetOptionValue( 'display_health' ) ) then
        drawIndicator( barsX, barsY, barsW, rowH, WIMG_HEART, colors.negative, lerpHealth, 'Health' )
        barsY = barsY + rowH + rowGap
    end
    if ( hasArmor ) then
        drawIndicator( barsX, barsY, barsW, rowH, WIMG_SHIELD, colors.armor or Color( 88, 166, 255 ), lerpArmor, 'Armor' )
        barsY = barsY + rowH + rowGap
    end
    if ( hasHunger ) then
        local hungerFraction = math.Clamp( client:getDarkRPVar( 'Energy', 0 ) / 100, 0, 1 )
        lerpHunger = Lerp( animSpeed, lerpHunger or hungerFraction, hungerFraction )
        drawIndicator( barsX, barsY, barsW, rowH, WIMG_FOOD, colors.hunger or Color( 245, 197, 66 ), lerpHunger, 'Hunger' )
        barsY = barsY + rowH + rowGap
    end

    if ( showLevel ) then
        local level, xp, maxXP = vox.hud.GetLevelData( client )
        local nextLevelFraction = math.Clamp( xp / math.max( maxXP, 1 ), 0, 1 )
        local levelY = barsY + hud.ScaleTall( 2 )
        draw.SimpleText( vox.lang:Get( 'hud.level.name' ) .. ' ' .. level, hud.fonts.ExtraTinyBold, barsX, levelY + hud.ScaleTall( 7 ), colorTextPrimary, 0, 1 )
        draw.SimpleText( xp .. '/' .. maxXP .. ' XP', hud.fonts.ExtraTinyBold, barsX + barsW, levelY + hud.ScaleTall( 7 ), colorTextSecondary, 2, 1 )
        draw.RoundedBox( hud.ScaleTall( 4 ), barsX + hud.ScaleWide( 70 ), levelY + hud.ScaleTall( 17 ), barsW - hud.ScaleWide( 70 ), hud.ScaleTall( 7 ), ColorAlpha( colorTextPrimary, isDark and 18 or 90 ) )
        render.SetScissorRect( barsX + hud.ScaleWide( 70 ), levelY + hud.ScaleTall( 17 ), barsX + hud.ScaleWide( 70 ) + ( barsW - hud.ScaleWide( 70 ) ) * nextLevelFraction, levelY + hud.ScaleTall( 24 ), true )
            draw.RoundedBox( hud.ScaleTall( 4 ), barsX + hud.ScaleWide( 70 ), levelY + hud.ScaleTall( 17 ), barsW - hud.ScaleWide( 70 ), hud.ScaleTall( 7 ), colors.xp or COLOR_XP )
        render.SetScissorRect( 0, 0, 0, 0, false )
    end
end

local function drawCommandStripHUD( self, client, scrW, scrH )
    local space = hud.GetScreenPadding()
    local w, h = scrW - space * 2, hud.ScaleTall( 54 )
    local x, y = space, scrH - h - space
    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local accent = colors.accent
    local teamColor = team.GetColor( client:Team() )
    local animSpeed = FrameTime() * ( hud:GetOptionValue( 'reduce_motion' ) and 64 or hud:GetOptionValue( 'animation_speed' ) or 16 )
    local healthFraction = math.Clamp( client:Health() / client:GetMaxHealth(), 0, 1 )
    local maxArmor = math.max( client:GetMaxArmor() or 100, 1 )
    local armorFraction = math.Clamp( client:Armor() / maxArmor, 0, 1 )
    local money = client:getDarkRPVar( 'money' ) or 0

    lerpHealth = Lerp( animSpeed, lerpHealth or healthFraction, healthFraction )
    lerpArmor = Lerp( animSpeed, lerpArmor or armorFraction, armorFraction )
    lerpMoney = Lerp( animSpeed, lerpMoney or money, money )

    vox.DrawVoxPanel( x, y, w, h, colors, hud.GetRoundness() )
    vox.DrawVoxBlade( x + hud.ScaleWide( 10 ), y + hud.ScaleTall( 8 ), hud.ScaleWide( 8 ), h - hud.ScaleTall( 16 ), accent )
    vox.DrawVoxBlade( x + w - hud.ScaleWide( 20 ), y + hud.ScaleTall( 8 ), hud.ScaleWide( 8 ), h - hud.ScaleTall( 16 ), teamColor )
    vox.DrawVoxScanlines( x + hud.ScaleWide( 22 ), y + hud.ScaleTall( 7 ), w - hud.ScaleWide( 44 ), h - hud.ScaleTall( 14 ), ColorAlpha( accent, 10 ), hud.ScaleTall( 7 ) )
    vox.DrawVoxCornerTicks( x + hud.ScaleWide( 4 ), y + hud.ScaleTall( 4 ), w - hud.ScaleWide( 8 ), h - hud.ScaleTall( 8 ), ColorAlpha( accent, 100 ), hud.ScaleWide( 18 ) )

    local nameW = hud.ScaleWide( 260 )
    local job = client:getDarkRPVar( 'job' ) or team.GetName( client:Team() )
    draw.SimpleText( string.upper( client:Name() ), hud.fonts.SmallBold, x + hud.ScaleWide( 34 ), y + hud.ScaleTall( 14 ), colors.textPrimary, 0, 1 )
    draw.SimpleText( string.upper( job ), hud.fonts.ExtraTinyBold, x + hud.ScaleWide( 34 ), y + hud.ScaleTall( 34 ), teamColor, 0, 1 )

    local statX = x + nameW + hud.ScaleWide( 18 )
    local statW = ( w - nameW - hud.ScaleWide( 360 ) ) * .5
    drawIndicator( statX, y + hud.ScaleTall( 18 ), statW, hud.ScaleTall( 16 ), WIMG_HEART, colors.negative, lerpHealth, math.Round( lerpHealth * 100 ) .. '%' )
    drawIndicator( statX + statW + hud.ScaleWide( 22 ), y + hud.ScaleTall( 18 ), statW, hud.ScaleTall( 16 ), WIMG_SHIELD, colors.armor or Color( 88, 166, 255 ), lerpArmor, math.Round( lerpArmor * 100 ) .. '%' )

    local econX = x + w - hud.ScaleWide( 310 )
    local moneyFormatted = DarkRP and DarkRP.formatMoney and DarkRP.formatMoney( math.Round( lerpMoney ) ) or tostring( math.Round( lerpMoney ) )
    vox.DrawVoxStatModule( econX, y + hud.ScaleTall( 8 ), hud.ScaleWide( 128 ), h - hud.ScaleTall( 16 ), 'BALANCE', moneyFormatted, colors, { accent = colors.money or colors.positive, labelFont = hud.fonts.ExtraTinyBold, valueFont = hud.fonts.TinyBold, radius = 4, bladeWidth = 4 } )
    vox.DrawVoxStatModule( econX + hud.ScaleWide( 140 ), y + hud.ScaleTall( 8 ), hud.ScaleWide( 138 ), h - hud.ScaleTall( 16 ), 'SALARY', formatSalary( client:getDarkRPVar( 'salary' ) or 0 ), colors, { accent = colors.money or colors.positive, labelFont = hud.fonts.ExtraTinyBold, valueFont = hud.fonts.TinyBold, radius = 4, bladeWidth = 4 } )
end


local function drawMinimalEdgeHUD( self, client, scrW, scrH )
    local space = hud.GetScreenPadding()
    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local teamColor = team.GetColor( client:Team() )
    local animSpeed = FrameTime() * ( hud:GetOptionValue( 'reduce_motion' ) and 64 or hud:GetOptionValue( 'animation_speed' ) or 16 )
    local healthFraction = math.Clamp( client:Health() / client:GetMaxHealth(), 0, 1 )
    local maxArmor = math.max( client:GetMaxArmor() or 100, 1 )
    local armorFraction = math.Clamp( client:Armor() / maxArmor, 0, 1 )

    lerpHealth = Lerp( animSpeed, lerpHealth or healthFraction, healthFraction )
    lerpArmor = Lerp( animSpeed, lerpArmor or armorFraction, armorFraction )

    local railW = hud.ScaleWide( 8 )
    local railH = scrH - space * 2
    vox.DrawVoxBlade( space, space, railW, railH, ColorAlpha( colors.accent, 215 ), colors.accent )
    vox.DrawVoxBlade( scrW - space - railW, space, railW, railH, ColorAlpha( teamColor, 215 ), teamColor )

    local podW, podH = hud.ScaleWide( 300 ), hud.ScaleTall( 40 )
    local x, y = space + hud.ScaleWide( 18 ), scrH - space - podH
    vox.DrawVoxPanel( x, y, podW, podH, colors, 8 )
    draw.SimpleText( string.upper( client:Name() ), hud.fonts.TinyBold, x + hud.ScaleWide( 14 ), y + hud.ScaleTall( 11 ), colors.textPrimary, 0, 1 )
    draw.SimpleText( string.upper( client:getDarkRPVar( 'job' ) or team.GetName( client:Team() ) ), hud.fonts.ExtraTinyBold, x + hud.ScaleWide( 14 ), y + hud.ScaleTall( 28 ), teamColor, 0, 1 )
    drawIndicator( x + hud.ScaleWide( 128 ), y + hud.ScaleTall( 12 ), hud.ScaleWide( 150 ), hud.ScaleTall( 14 ), WIMG_HEART, colors.negative, lerpHealth, math.Round( lerpHealth * 100 ) .. '%' )

    local money = client:getDarkRPVar( 'money' ) or 0
    local moneyFormatted = DarkRP and DarkRP.formatMoney and DarkRP.formatMoney( money ) or tostring( money )
    local econW = hud.ScaleWide( 220 )
    local ex = scrW - space - railW - hud.ScaleWide( 18 ) - econW
    vox.DrawVoxPanel( ex, y, econW, podH, colors, 8 )
    vox.DrawVoxBlade( ex, y + hud.ScaleTall( 7 ), hud.ScaleWide( 6 ), podH - hud.ScaleTall( 14 ), colors.money or colors.positive )
    draw.SimpleText( 'BALANCE', hud.fonts.ExtraTinyBold, ex + hud.ScaleWide( 18 ), y + hud.ScaleTall( 11 ), colors.textSecondary, 0, 1 )
    draw.SimpleText( moneyFormatted, hud.fonts.TinyBold, ex + econW - hud.ScaleWide( 14 ), y + hud.ScaleTall( 25 ), colors.money or colors.positive, 2, 1 )
end

local function drawRoleplayProfileHUD( self, client, scrW, scrH )
    local space = hud.GetScreenPadding()
    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local teamColor = team.GetColor( client:Team() )
    local w, h = hud.ScaleWide( 360 ), hud.ScaleTall( 126 )
    local x, y = space, scrH - space - h
    local animSpeed = FrameTime() * ( hud:GetOptionValue( 'reduce_motion' ) and 64 or hud:GetOptionValue( 'animation_speed' ) or 16 )
    local healthFraction = math.Clamp( client:Health() / client:GetMaxHealth(), 0, 1 )
    local maxArmor = math.max( client:GetMaxArmor() or 100, 1 )
    local armorFraction = math.Clamp( client:Armor() / maxArmor, 0, 1 )
    lerpHealth = Lerp( animSpeed, lerpHealth or healthFraction, healthFraction )
    lerpArmor = Lerp( animSpeed, lerpArmor or armorFraction, armorFraction )

    vox.DrawVoxPanel( x, y, w, h, colors, hud.GetRoundness() )
    vox.DrawVoxBlade( x - hud.ScaleWide( 5 ), y + hud.ScaleTall( 12 ), hud.ScaleWide( 10 ), h - hud.ScaleTall( 24 ), teamColor )
    vox.DrawVoxCornerTicks( x + hud.ScaleWide( 8 ), y + hud.ScaleTall( 8 ), w - hud.ScaleWide( 16 ), h - hud.ScaleTall( 16 ), ColorAlpha( teamColor, 120 ), hud.ScaleWide( 18 ) )

    local avatarSize = hud.ScaleTall( 72 )
    local ax, ay = x + hud.ScaleWide( 18 ), y + hud.ScaleTall( 18 )
    if ( IsValid( self.AvatarPanel ) ) then
        self.AvatarPanel:SetPos( ax, ay )
        self.AvatarPanel:SetSize( avatarSize, avatarSize )
        self.AvatarPanel:PaintManual()
        vox.DrawOutlinedCircle( ax + avatarSize * .5, ay + avatarSize * .5, avatarSize * .5, hud.ScaleTall( 3 ), teamColor )
    end

    local tx = ax + avatarSize + hud.ScaleWide( 16 )
    draw.SimpleText( 'ROLEPLAY PROFILE', hud.fonts.ExtraTinyBold, tx, y + hud.ScaleTall( 17 ), colors.textSecondary, 0, 0 )
    draw.SimpleText( client:Name(), hud.fonts.SmallBold, tx, y + hud.ScaleTall( 34 ), colors.textPrimary, 0, 0 )
    draw.SimpleText( client:getDarkRPVar( 'job' ) or team.GetName( client:Team() ), hud.fonts.TinyBold, tx, y + hud.ScaleTall( 57 ), teamColor, 0, 0 )
    drawIndicator( tx, y + hud.ScaleTall( 84 ), w - ( tx - x ) - hud.ScaleWide( 18 ), hud.ScaleTall( 14 ), WIMG_HEART, colors.negative, lerpHealth, math.Round( lerpHealth * 100 ) .. '%' )
    if ( lerpArmor > 0 ) then
        drawIndicator( tx, y + hud.ScaleTall( 104 ), w - ( tx - x ) - hud.ScaleWide( 18 ), hud.ScaleTall( 12 ), WIMG_SHIELD, colors.armor or Color( 88, 166, 255 ), lerpArmor )
    end
end

hud.Presets = hud.PresetRegistry

local function drawStyledMainHUD( self, client, scrW, scrH )
    local preset = hud:GetCurrentHUDPreset()
    if preset and isfunction( preset.drawFn ) then
        preset.drawFn( self, client, scrW, scrH )
        return
    end

    drawMainHUD( self, client, scrW, scrH )
end

cvars.AddChangeCallback( 'cl_vox_hud_3d_models', function()
    recreateAvatar( hud.elements[ 'main' ] )
end, 'hud.internal' )

hook.Add( 'vox.inconfig.Updated', 'hud.RecreateAvatar', function( id, old, new )
    if ( id and id == 'hud_main_avatar_mode' ) then
        recreateAvatar( hud.elements[ 'main' ] )
    end
end )

hook.Add( 'vox.inconfig.Synchronized', 'hud.RecreateAvatar', function( id )
    recreateAvatar( hud.elements[ 'main' ] )
end )

hud:RegisterElement( 'main', {
    priority = 100,
    drawFn = drawStyledMainHUD,
    initFunc = recreateAvatar,
    onSizeChanged = function( self )
        self.AvatarMask = nil -- It will force to recalculate the circle mask
    end
} )
