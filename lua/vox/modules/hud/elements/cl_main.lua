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

local function drawIndicator( x, y, w, h, material, color, fraction, label )
    local iconSize = h
    local iconSpace = hud.ScaleTall( UNSCALED_SPACE )
    local cut = hud.ScaleWide( 5 )

    local theme = hud:GetCurrentTheme()
    local isDark = theme.isDark
    local colors = theme.colors
    local colorTextPrimary = colors.textPrimary
    local colorTextSecondary = colors.textSecondary

    local rectX, rectW = x + ( iconSize + iconSpace ), w - ( iconSize + iconSpace )
    local rectH = math.min( h, hud.ScaleTall( UNSCALED_BAR_H ) )
    local rectY = math.floor( y + iconSize * .5 - rectH * .5 )
    local segments = 12
    local segmentGap = hud.ScaleWide( 2 )
    local segmentW = ( rectW - segmentGap * ( segments - 1 ) ) / segments

    material:Draw( x, y, iconSize, iconSize, color )

    vox.DrawAngledRect( rectX - hud.ScaleWide( 3 ), rectY - hud.ScaleTall( 3 ), rectW + hud.ScaleWide( 6 ), rectH + hud.ScaleTall( 6 ), cut, ColorAlpha( colorTextPrimary, isDark and 12 or 110 ) )

    for i = 1, segments do
        local sx = rectX + ( i - 1 ) * ( segmentW + segmentGap )
        local fill = math.Clamp( fraction * segments - ( i - 1 ), 0, 1 )
        local idleColor = ColorAlpha( colorTextPrimary, isDark and 18 or 95 )

        vox.DrawAngledRect( sx, rectY, segmentW, rectH, cut * .55, idleColor )

        if ( fill > 0 ) then
            render.SetScissorRect( sx, rectY, sx + segmentW * fill, rectY + rectH, true )
                vox.DrawAngledRect( sx, rectY, segmentW, rectH, cut * .55, color )
            render.SetScissorRect( 0, 0, 0, 0, false )
        end
    end

    surface.SetDrawColor( ColorAlpha( color, 130 ) )
    surface.DrawLine( rectX, rectY - 2, rectX + rectW * fraction, rectY - 2 )

    if ( label ) then
        draw.SimpleText( label, hud.fonts.ExtraTinyBold, rectX + rectW, rectY - hud.ScaleTall( 2 ), colorTextSecondary, 2, 4 )
    end
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

                            panel:SetLookAt (bonePos)
                            panel:SetCamPos( bonePos - Vector(-20, 0, 0) )
                            panel:SetFOV( 45 )

                            ent:SetEyeTarget( bonePos - Vector(-20, 0, 0) )
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
    local showJob = not CONVAR_COMPACT:GetBool() and hud:GetOptionValue( 'display_job' )
    local space = hud.GetScreenPadding()
    local padding = hud.ScaleTall( 10 )
    local w, h = hud.ScaleWide( 340 ), hud.ScaleTall( showJob and 128 or 108 )
    local x, y = space, scrH - h - space

    -- Colors
    local theme = hud:GetCurrentTheme()
    local colors = theme.colors

    local colorPrimary = colors.primary
    local colorSecondary = colors.secondary
    local colorTertiary = colors.tertiary
    local colorTextPrimary = colors.textPrimary
    local colorTextSecondary = colors.textSecondary
    local isDark = theme.isDark

    -- Player variables
    local animSpeed = FrameTime() * ( hud:GetOptionValue( 'reduce_motion' ) and 64 or hud:GetOptionValue( 'animation_speed' ) or 16 )
    local healthFraction = math.Clamp( client:Health() / client:GetMaxHealth(), 0, 1 )
    local maxArmor = math.max( client:GetMaxArmor() or 100, 1 )
    local armorFraction = math.Clamp( client:Armor() / maxArmor, 0, 1 )
    local money = client:getDarkRPVar( 'money' ) or 0

    lerpHealth = Lerp( animSpeed, lerpHealth or healthFraction, healthFraction )
    lerpArmor = Lerp( animSpeed, lerpArmor or armorFraction, armorFraction )
    lerpMoney = Lerp( animSpeed, lerpMoney or money, money )

    local name = client:Name()
    local teamColor = team.GetColor( client:Team() )
    local moneyFormatted = ( DarkRP and DarkRP.formatMoney and DarkRP.formatMoney( math.Round( lerpMoney ) ) or tostring( math.Round( lerpMoney ) ) )
    local salary = client:getDarkRPVar( 'salary' ) or 0
    local salaryFormatted = formatSalary( salary )
    local darkRPDefaults = DarkRP and DarkRP.disabledDefaults and DarkRP.disabledDefaults[ 'modules' ]
    local hasHunger = hud:GetOptionValue( 'display_hunger' ) and not ( darkRPDefaults and darkRPDefaults[ 'hungermod' ] )
    local hasArmor = hud:GetOptionValue( 'display_armor' ) and math.Round( lerpArmor, 2 ) > 0
    local rectAmount = ( hasHunger or hasArmor ) and 2 or 1
    local rectH = hud.ScaleTall( UNSCALED_BAR_ICON_SIZE )

    -- Increase HUD height if there is multiple bars
    if ( rectAmount > 1 ) then
        local extraHeight = hud.ScaleTall( 10 )
        h = h + extraHeight
        y = y - extraHeight
    end

    local avatarSpaceWidth = hud.ScaleWide( 92 )
    local labelX = x + avatarSpaceWidth + padding
    local labelY = y + padding

    -- Vox Tactical Card: dark glass body, angled electric blade, and integrated economy cluster.
    if vox.DrawVoxPanel then
        vox.DrawVoxPanel( x, y, w, h, colors, hud.GetRoundness() )
    else
        hud.DrawRoundedBox( x, y, w, h, ColorAlpha( colorPrimary, 238 ) )
    end
    vox.DrawMatGradient( x, y, w, h, RIGHT, ColorAlpha( colors.secondaryAccent or Color( 142, 84, 255 ), 16 ) )
    if vox.DrawVoxBlade then
        vox.DrawVoxBlade( x - hud.ScaleWide( 6 ), y + hud.ScaleTall( 10 ), hud.ScaleWide( 12 ), h - hud.ScaleTall( 20 ), colors.accent )
    else
        surface.SetDrawColor( colors.accent )
        surface.DrawRect( x, y, hud.ScaleWide( 3 ), h )
    end
    vox.DrawAngledRect( x + hud.ScaleWide( 10 ), y + hud.ScaleTall( 8 ), avatarSpaceWidth - hud.ScaleWide( 12 ), h - hud.ScaleTall( 16 ), hud.ScaleWide( 12 ), ColorAlpha( colorSecondary, 205 ) )
    surface.SetDrawColor( ColorAlpha( colors.accent, 100 ) )
    surface.DrawLine( x + avatarSpaceWidth, y + 1, x + avatarSpaceWidth + hud.ScaleWide( 36 ), y + 1 )
    surface.DrawLine( x + w - hud.ScaleWide( 48 ), y + h - 2, x + w - 2, y + h - 2 )

    -- Draw labels
    local labelMaxW = w - avatarSpaceWidth - padding * 2

    updateSlowLabels( client, labelMaxW )

    -- Limited render bounds for labels
    render.SetScissorRect( 0, 0, labelX + labelMaxW, ScrH(), true )

    local _, nameHeight = draw.SimpleText( slowLabels.name.text, slowLabels.name.font, labelX, labelY, colorTextPrimary, 0, 0 )

    local teamHeight
    if ( showJob ) then
        _, teamHeight = draw.SimpleText( slowLabels.job.text, slowLabels.job.font, labelX, labelY + nameHeight, teamColor, 0, 0 )
    else
        teamHeight = 0
    end

    local moneyHeight = 0
    if ( hud:GetOptionValue( 'display_money' ) ) then
        local econW = hud.ScaleWide( 124 )
        vox.DrawAngledRect( x + w - padding - econW, y + padding, econW, hud.ScaleTall( 26 ), hud.ScaleWide( 8 ), ColorAlpha( colorSecondary, 205 ) )
        draw.SimpleText( 'BALANCE', hud.fonts.ExtraTinyBold, x + w - padding - econW + hud.ScaleWide( 10 ), y + padding + hud.ScaleTall( 4 ), colorTextSecondary, 0, 0 )
        _, moneyHeight = draw.SimpleText( moneyFormatted, hud.fonts.SmallBold, x + w - padding - hud.ScaleWide( 8 ), y + padding + hud.ScaleTall( 14 ), colors.money or colors.positive, 2, 1 )
    end
    if ( hud:GetOptionValue( 'display_salary' ) ) then
        draw.SimpleText( 'STIPEND ' .. salaryFormatted, hud.fonts.ExtraTinyBold, x + w - padding, y + padding + hud.ScaleTall( 34 ), colorTextSecondary, 2, 0 )
    end

    render.SetScissorRect( 0, 0, 0, 0, false )

    local contentH = nameHeight + teamHeight + moneyHeight
    local topPartH = contentH + padding * 2
    local lineY = labelY + contentH + padding
    local lineW = w - avatarSpaceWidth - padding * 2
    local lineH = math.max( 1, hud.ScaleTall( 2 ) )

    -- Prepare a mask for avatar
    local avatarY = y + padding
    local avatarSize = math.min( contentH, avatarSpaceWidth - padding * 2 )
    local circleRadius = math.Round( avatarSize * .5 )
    local circleOutlineThickness = hud.ScaleTall( 2.5 )

    local maskX0 = x + math.Round( avatarSpaceWidth * .5 )
    local maskY0 = avatarY + circleRadius
    local maskX, maskY = maskX0 - circleRadius, avatarY

    if ( not self.AvatarMask or not lastMaskY or lastMaskY ~= maskY0 ) then
        lastMaskY = maskY0
        self.AvatarMask = vox.CalculateCircle( maskX0, maskY0, circleRadius, 32 )
    end

    -- Draw avatar
    if ( IsValid( self.AvatarPanel ) ) then
        vox.DrawWithPolyMask( self.AvatarMask, function()
            if ( self.AvatarPanel:GetClassName() ~= 'AvatarImage' ) then
                -- Draw fancy background for model icons
                vox.DrawCircle( maskX0, maskY0, circleRadius, colorPrimary )
                vox.DrawMatGradient( maskX, maskY, avatarSize, avatarSize, BOTTOM, ColorAlpha( teamColor, isDark and 25 or 150 )  )
            end

            self.AvatarPanel:SetPos( maskX, maskY )
            self.AvatarPanel:SetSize( avatarSize, avatarSize )
            self.AvatarPanel:PaintManual()

            if ( client:IsSpeaking() ) then
                local micSize = avatarSize * .5

                micSize = micSize + ( micSize * .2 * math.abs( math.sin( CurTime() * 2 ) ) )

                surface.SetDrawColor( 0, 0, 0, 225 )
                surface.DrawRect( maskX, maskY, avatarSize, avatarSize )

                WIMG_MICROPHONE:DrawRotated( maskX0, maskY0, micSize, micSize, 0 )
            end
        end )

        vox.DrawOutlinedCircle( maskX0, maskY0, circleRadius + circleOutlineThickness * .5, circleOutlineThickness, teamColor )
        vox.DrawAngledRect( maskX0 - circleRadius, maskY0 + circleRadius - hud.ScaleTall( 13 ), circleRadius * 2, hud.ScaleTall( 18 ), hud.ScaleWide( 6 ), ColorAlpha( colorPrimary, 230 ) )
        draw.SimpleText( 'ID', hud.fonts.ExtraTinyBold, maskX0, maskY0 + circleRadius - hud.ScaleTall( 4 ), colorTextSecondary, 1, 1 )
    end

    -- Draw separator
    if ( isDark ) then
        surface.SetDrawColor( 0, 0, 0, 50 )
    else
        surface.SetDrawColor( 100, 100, 100, 100 )
    end
    surface.DrawRect( x, lineY, w, lineH )

    local footerH = h - topPartH
    local footerY0 = lineY + footerH * .5

    -- Draw icons
    local iconSize = hud.ScaleTall( UNSCALED_ICON_SIZE )
    local iconSpace = hud.ScaleTall( UNSCALED_SPACE ) * .75
    local iconX0 = x + avatarSpaceWidth * .5
    local iconY0 = footerY0 - iconSize * .5

    drawStatusIcon( iconX0 - iconSize - iconSpace, iconY0, iconSize, iconSize, WIMG_LICENSE, client:getDarkRPVar( 'HasGunlicense' ) and hud:GetColor( 'accent' )  )
    drawStatusIcon( iconX0 + iconSpace, iconY0, iconSize, iconSize, WIMG_STAR, client:getDarkRPVar( 'wanted' ) and hud.GetAnimColor( 0 ) )

    -- Draw indicators
    local rectSpace = hud.ScaleTall( 3 )
    local totalIndictatorsH = rectAmount * rectH + ( rectAmount - 1 ) * rectSpace
    local rectY = footerY0 - totalIndictatorsH * .5

    if ( hud:GetOptionValue( 'display_health' ) ) then
        drawIndicator( labelX, rectY, lineW, rectH, WIMG_HEART, colors.negative, lerpHealth, math.Round( lerpHealth * 100 ) .. '%' )
    end

    rectY = rectY + rectH + rectSpace

    if ( hasHunger ) then
        local iconSpace = hud.ScaleTall( UNSCALED_SPACE * 1 )
        local halfLineWidth = lineW * .5 - iconSpace * .5
        local hungerFraction = math.Clamp( client:getDarkRPVar( 'Energy', 0 ) / 100, 0, 1 )

        lerpHunger = Lerp( animSpeed, lerpHunger or hungerFraction, hungerFraction )

        drawIndicator( labelX, rectY, halfLineWidth, rectH, WIMG_FOOD, colors.hunger or Color( 245, 197, 66 ), lerpHunger )
        drawIndicator( labelX + halfLineWidth + iconSpace, rectY, halfLineWidth, rectH, WIMG_SHIELD, colors.armor or Color( 88, 166, 255 ), lerpArmor )
    elseif ( hasArmor ) then
        drawIndicator( labelX, rectY, lineW, rectH, WIMG_SHIELD, colors.armor or Color( 88, 166, 255 ), lerpArmor )
    end

    -- Draw help
    local addBlockSpace = hud.ScaleTall( 7.5 )

    if ( CONVAR_HELP:GetBool() ) then
        local addBlockH = hud.ScaleTall( 50 )
        local blockY = y - addBlockH - addBlockSpace

        hud.OverrideAlpha( 0.5 + 0.5 * math.abs( math.sin( CurTime() * 2 ) ), function()
            local helpFont = hud.fonts.Small
            local helpText1 = vox.lang:Get( 'hud_help_type' ) .. ' '
            local helpText2 = '!hud'
            local helpText3 = ' ' .. vox.lang:Get( 'hud_help_to' )

            surface.SetFont( helpFont )
            local helpTextW1 = surface.GetTextSize( helpText1 )
            local helpTextW3 = surface.GetTextSize( helpText3 )
            surface.SetFont( hud.fonts.SmallBold )
            local helpTextW2 = surface.GetTextSize( helpText2 )
            local helpTextTotalW = ( helpTextW1 + helpTextW2 + helpTextW3 )
            local helpTextX = x + w * .5 - helpTextTotalW * .5

            hud.DrawRoundedBox( x, blockY, w, addBlockH, colorPrimary )

            draw.SimpleText( vox.lang:Get( 'introduction_u' ), hud.fonts.TinyBold, x + w * .5, blockY + addBlockH * .5, colorTextSecondary, 1, 4 )

            draw.SimpleText( helpText1, helpFont, helpTextX, blockY + addBlockH * .5, colorTextPrimary, 0, 0 )
            draw.SimpleText( helpText2, hud.fonts.SmallBold, helpTextX + helpTextW1, blockY + addBlockH * .5, colors.accent, 0, 0 )
            draw.SimpleText( helpText3, helpFont, helpTextX + helpTextW1 + helpTextW2, blockY + addBlockH * .5, colorTextPrimary, 0, 0 )
        end )
    elseif ( vox.hud:GetOptionValue( 'display_level' ) and vox.hud.IsLevellingEnabled() ) then
        local addBlockH = hud.ScaleTall( 47.5 )
        local blockY = y - addBlockH - addBlockSpace
        local level, xp, maxXP = vox.hud.GetLevelData( client )
        local nextLevelFraction = xp / maxXP
        local rectH = math.min( h, hud.ScaleTall( UNSCALED_BAR_H ) )

        hud.DrawRoundedBox( x, blockY, w, addBlockH, colorPrimary )

        local textW = draw.SimpleText( vox.lang:Get( 'hud.level.name' ) .. ': ', hud.fonts.Tiny, x + padding, blockY + padding, colorTextSecondary, 0, 0 )
        draw.SimpleText( level, hud.fonts.SmallBold, x + padding + textW, blockY + padding, ( isDark and ( colors.xp or COLOR_XP ) or colorTextPrimary ), 0, 0 )

        local textW2 = draw.SimpleText( ' / ' .. maxXP, hud.fonts.Tiny, x + w - padding, blockY + padding, colorTextSecondary, 2, 0 )
        draw.SimpleText( xp, hud.fonts.TinyBold, x + w - padding - textW2, blockY + padding, colorTextPrimary, 2, 0 )

        hud.DrawRoundedBox( x + padding, blockY + addBlockH - padding - rectH, w - padding * 2, rectH, ColorAlpha( colorTextPrimary, isDark and 10 or 200 ) )
        vox.hud.ScissorRect( x + padding, blockY + addBlockH - padding - rectH, ( w - padding * 2 ) * nextLevelFraction, rectH, function()
            hud.DrawRoundedBox( x + padding, blockY + addBlockH - padding - rectH, w - padding * 2, rectH, ( colors.xp or COLOR_XP ) )
        end )
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

hud:RegisterHUDPreset( 'tactical_card', { name = 'Vox Tactical Card', style = 0, drawFn = drawMainHUD } )
hud:RegisterHUDPreset( 'command_strip', { name = 'Vox Command Strip', style = 1, drawFn = drawCommandStripHUD } )
hud:RegisterHUDPreset( 'minimal_edge', { name = 'Vox Minimal Edge', style = 2, drawFn = drawMinimalEdgeHUD } )
hud:RegisterHUDPreset( 'roleplay_profile', { name = 'Vox Roleplay Profile', style = 3, drawFn = drawRoleplayProfileHUD } )

hud.Presets = hud.PresetRegistry

hud.DrawVoxTacticalCard = drawMainHUD
hud.DrawVoxCommandStrip = drawCommandStripHUD
hud.DrawVoxMinimalEdge = drawMinimalEdgeHUD
hud.DrawVoxRoleplayProfile = drawRoleplayProfileHUD

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
