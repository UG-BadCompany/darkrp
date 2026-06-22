--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

local COLOR_OUTLINE = vox:Config( 'colors.primary' )
local COLOR_LOW = Color( 255, 98, 98)

local WIMG_SPEC_AMMO = vox.wimg.Simple( 'https://i.imgur.com/CHWwWOq.png', 'smooth mips' )

local BUILD_WEAPONS = {
    [ 'weapon_physgun' ] = true,
    [ 'gmod_tool' ] = true,
}

local lastWeapon = NULL
local lerpClip1

local function drawAmmoHUD( client, scrW, scrH, weapon )
    local primaryAmmoType = weapon:GetPrimaryAmmoType()
    if ( primaryAmmoType < 0 ) then return end

    if ( lastWeapon ~= weapon ) then
        lastWeapon = weapon
        lerpClip1 = nil
    end

    local primaryAmmoCount = client:GetAmmoCount( primaryAmmoType )
    local primaryClip = weapon:Clip1()

    local secondaryAmmoType = weapon:GetSecondaryAmmoType()
    local hasSecondaryAmmo = secondaryAmmoType > 0
    local secondaryClip = weapon:Clip2()
    local secondaryAmmoCount = client:GetAmmoCount( secondaryAmmoType )

    local hideAmmoCount = false

    -- For grenades and etc.
    if ( primaryClip == -1 ) then
        primaryClip = primaryAmmoCount
        hideAmmoCount = true
    end

    local lowAmmoStartRange = math.Round( weapon:GetMaxClip1() / 3 )
    local lowAmmoFraction = lowAmmoStartRange > 0 and math.min( 1, primaryClip / lowAmmoStartRange ) or 1
    if ( primaryClip == 0 ) then lowAmmoFraction = 0 end

    lerpClip1 = Lerp( FrameTime() * 16, lerpClip1 or primaryClip, primaryClip )

    -- Grab text size
    local textClip = math.Round( lerpClip1 )
    local textRemaining = hideAmmoCount and '' or ( ' / ' .. primaryAmmoCount )

    surface.SetFont( vox.hud.fonts.AmmoClip )
    local textW1, textH1 = surface.GetTextSize( textClip )

    surface.SetFont( vox.hud.fonts.AmmoRemaining )
    local textW2, textH2 = surface.GetTextSize( textRemaining )
    local totalW = textW1 + textW2

    -- Calculate positions and sizes
    local space = vox.hud.GetScreenPadding()
    local padding = vox.hud.ScaleTall( 20 )
    local w = totalW + padding * 2
    local h = vox.hud.ScaleTall( 50 )

    local x = scrW - w - space
    local y = scrH - h - space

    local colorTextPrimary = vox.hud:GetColor( 'textPrimary' )
    local colorTextSecondary = vox.hud:GetColor( 'textSecondary' )

    -- Draw secondary ammo
    if ( hasSecondaryAmmo ) then
        local iconSize = h * .35
        surface.SetFont( vox.hud.fonts.AmmoRemaining )
        local secAmmoTextW, secAmmoTextH = surface.GetTextSize( secondaryAmmoCount )
        local secAmmoTextSpace = vox.hud.ScaleTall( 2 )
        local secAmmoTotalW = secAmmoTextW + secAmmoTextSpace + iconSize

        local secAmmoBlockWidth = secAmmoTotalW + padding * 1
        x = x - secAmmoBlockWidth

        local secAmmoStartX = x + w + secAmmoBlockWidth * .5 - secAmmoTotalW * .5
        local secAmmoColor = secondaryAmmoCount == 0 and colorTextSecondary or colorTextPrimary

        vox.hud.DrawRoundedBoxEx( x + w, y, secAmmoBlockWidth, h, vox.hud:GetColor( 'secondary' ), false, true, false, true )

        WIMG_SPEC_AMMO:Draw( secAmmoStartX, y + h * .5 - iconSize * .5, iconSize, iconSize, colorTextSecondary )
        vox.hud.DrawCheapText( secondaryAmmoCount, vox.hud.fonts.AmmoRemaining, secAmmoStartX + secAmmoTextSpace + iconSize, y + h * .5 - secAmmoTextH * .5, secAmmoColor )
    end

    -- Draw primary ammo
    local x0, y0 = x + w * .5, y + h * .5
    local textStartX = x0 - totalW * .5
    local colorClip = vox.LerpColor( lowAmmoFraction, COLOR_LOW, colorTextPrimary )

    vox.hud.DrawRoundedBoxEx( x, y, w, h, vox.hud:GetColor( 'primary' ), true, not hasSecondaryAmmo, true, not hasSecondaryAmmo )
    vox.hud.DrawCheapText( textClip, vox.hud.fonts.AmmoClip, textStartX, y0 - textH1 * .5, colorClip, 0, 1 )
    vox.hud.DrawCheapText( textRemaining, vox.hud.fonts.AmmoRemaining, textStartX + textW1, y0 - textH2 * .5, colorTextSecondary, 0, 1 )

    -- Draw weapon name
    local name = weapon:GetPrintName()
    draw.SimpleTextOutlined( name, vox.hud.fonts.SmallBold, scrW - space, y - vox.hud.ScaleTall( 5 ), color_white, 2, 4, 1, COLOR_OUTLINE )
end

local function drawPropsHUD( client, scrW, scrH )
    local curProps = client:GetCount( 'props' )
    local maxProps = vox.hud.GetMaxProps( client)
    if ( maxProps < 1 ) then
        maxProps = '∞'
    end

    local clipText = curProps
    local maxText = ' / ' .. maxProps

    surface.SetFont( vox.hud.fonts.AmmoRemaining )
    local clipTextW, clipTextH = surface.GetTextSize( clipText )
    local maxTextW, maxTextH = surface.GetTextSize( maxText )
    local totalTextW = clipTextW + maxTextW

    -- Positions
    local space = vox.hud.GetScreenPadding()
    local horPadding = vox.hud.ScaleTall( 20 )
    local verPadding = vox.hud.ScaleTall( 5 )
    local w = totalTextW + horPadding * 2
    local h = vox.hud.ScaleTall( 55 )

    local x = scrW - w - space
    local y = scrH - h - space

    local colorTextPrimary = vox.hud:GetColor( 'textPrimary' )
    local colorTextSecondary = vox.hud:GetColor( 'textSecondary' )

    -- Draw
    vox.hud.DrawRoundedBox( x, y, w, h, vox.hud:GetColor( 'primary' ) )
    draw.SimpleText( vox.lang:Get( 'props' ), vox.hud.fonts.Small, x + w * .5, y + verPadding, colorTextSecondary, 1, 0 )
    vox.hud.DrawCheapText( clipText, vox.hud.fonts.AmmoRemaining, x + horPadding, y + h - clipTextH - verPadding, colorTextPrimary )
    vox.hud.DrawCheapText( maxText, vox.hud.fonts.AmmoRemaining, x + horPadding + clipTextW, y + h - clipTextH - verPadding, colorTextSecondary )
end

vox.hud:RegisterElement( 'ammo', {
    drawFn = function( self, client, scrW, scrH )
        local weapon = client:GetActiveWeapon()
        if ( not IsValid( weapon ) ) then return end
        if ( client:InVehicle() ) then return end

        local class = weapon:GetClass()
        if ( BUILD_WEAPONS[ class ] ) then
            if ( vox.hud:GetOptionValue( 'props_counter' ) ) then
                drawPropsHUD( client, scrW, scrH )
            end
        else
            drawAmmoHUD( client, scrW, scrH, weapon )
        end
    end,
    hideElements = {
        [ 'CHudAmmo' ] = true,
        [ 'CHudSecondaryAmmo' ] = true
    }
} )
