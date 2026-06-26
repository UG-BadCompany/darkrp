local SHOW_DURATION = 1.5
local MAX_SLOTS = 6

local hud = vox.hud
local toggleFraction = 0
local toggleState = false
local slotsCache = {}
local selectorData = {
    selectedSlot = 1,
    selectedPos = 0,
    activeWeapon = NULL
}

local quickSwitchEnabled = GetConVar( 'hud_fastswitch' ):GetBool()

cvars.AddChangeCallback( 'hud_fastswitch', function(cname, old, new)
    quickSwitchEnabled = tobool( new )
end, 'vox.hud' )

local function resetSlotsCache()
    slotsCache = {}
    for index = 1, MAX_SLOTS do
        slotsCache[ index ] = {}
    end
end

local function toggleWeaponSelector( state, bScroll )
    local oldState = toggleState

    toggleState = state

    if ( not state ) then
        toggleFraction = 0
        timer.Remove( 'vox.hud.HideWeaponSelector' )
    else
        timer.Create( 'vox.hud.HideWeaponSelector', SHOW_DURATION, 1, function()
            toggleWeaponSelector( false )
        end )

        if ( bScroll and not oldState and toggleFraction == 0 ) then
            local activeWeapon = selectorData.activeWeapon
            for slotIndex, slotWeapons in ipairs( slotsCache ) do
                for pos, weapon in ipairs( slotWeapons ) do
                    if ( weapon == activeWeapon ) then
                        selectorData.selectedSlot = slotIndex
                        selectorData.selectedPos = pos
                        break
                    end
                end
            end
        end
    end
end

local function getWeaponName( wep )
    local name = wep:GetPrintName()
    if ( not name or name == '' ) then name = wep:GetClass() end
    return language.GetPhrase( name ) or name
end

local function getWeaponAmmoText( client, wep )
    local ammoType = wep:GetPrimaryAmmoType()
    local clip = wep:Clip1()

    if ( ammoType and ammoType >= 0 ) then
        local reserve = client:GetAmmoCount( ammoType ) or 0
        if ( clip and clip >= 0 ) then
            return clip .. ' / ' .. reserve
        end
        return tostring( reserve )
    end

    return '∞'
end

local function drawClippedText( text, font, x, y, color, alignX, alignY, clipX, clipY, clipW, clipH )
    render.SetScissorRect( clipX, clipY, clipX + clipW, clipY + clipH, true )
        draw.SimpleText( text, font, x, y, color, alignX, alignY )
    render.SetScissorRect( 0, 0, 0, 0, false )
end

local function drawWeaponIcon( wep, x, y, w, h, alpha )
    local ok = false
    if ( wep.DrawWeaponSelection ) then
        ok = pcall( function() wep:DrawWeaponSelection( x, y, w, h, alpha or 255 ) end )
    end

    if ( ok ) then return end

    if killicon and killicon.Exists and killicon.Exists( wep:GetClass() ) then
        killicon.Draw( x + w * .5, y + h * .5, wep:GetClass(), Color( 255, 255, 255, alpha or 255 ) )
    else
        draw.SimpleText( '●', vox.hud.fonts.SmallBold, x + w * .5, y + h * .5, Color( 255, 255, 255, alpha or 255 ), 1, 1 )
    end
end

local function drawWeaponSelector( client, scrW, scrH )
    toggleFraction = math.Approach( toggleFraction, toggleState and 1 or 0, FrameTime() * 8 )
    if ( toggleFraction <= 0 ) then return end

    local theme = hud:GetCurrentTheme() or {}
    local colors = theme.colors or ( vox.GetUIThemeColors and vox.GetUIThemeColors() ) or {}
    local colorPrimary = colors.primary or Color( 3, 11, 24 )
    local colorSecondary = colors.secondary or Color( 8, 27, 52 )
    local colorTertiary = colors.tertiary or Color( 12, 38, 70 )
    local colorAccent = colors.accent or Color( 0, 174, 255 )
    local colorPrimaryText = colors.textPrimary or color_white
    local colorSecondaryText = colors.textSecondary or Color( 145, 172, 200 )
    local colorTertiaryText = colors.textTertiary or Color( 92, 112, 135 )

    local prevAlpha = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier( toggleFraction )

    local screenPadding = vox.hud.GetScreenPadding()
    local slotW = vox.hud.ScaleWide( 126 )
    local titleH = vox.hud.ScaleTall( 24 )
    local headerH = vox.hud.ScaleTall( 28 )
    local selectedH = vox.hud.ScaleTall( 96 )
    local compactH = vox.hud.ScaleTall( 34 )
    local gap = vox.hud.ScaleTall( 3 )
    local totalW = slotW * MAX_SLOTS
    local x = scrW * .5 - totalW * .5
    local y = screenPadding + vox.hud.ScaleTall( 10 )

    local maxColumnH = headerH
    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ] or {}
        local colH = headerH
        for index = 1, #slotWeapons do
            local selected = selectorData.selectedSlot == slotIndex and index == selectorData.selectedPos
            colH = colH + ( selected and selectedH or compactH ) + gap
        end
        maxColumnH = math.max( maxColumnH, colH )
    end

    draw.SimpleText( 'WEAPON SELECTOR', vox.hud.fonts.SmallBold, x, y - vox.hud.ScaleTall( 7 ), colorPrimaryText, 0, 1 )
    draw.RoundedBox( vox.hud.ScaleTall( 5 ), x, y + titleH, totalW, maxColumnH, ColorAlpha( colorPrimary, 25 ) )
    vox.DrawMatGradient( x, y + titleH, totalW, maxColumnH, RIGHT, ColorAlpha( colorAccent, 18 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 95 ) )
    surface.DrawOutlinedRect( x, y + titleH, totalW, maxColumnH, 1 )

    local maxColumnH = headerH
    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ] or {}
        local sx = x + ( slotIndex - 1 ) * slotW
        local slotY = y + titleH

        draw.SimpleText( slotIndex, vox.hud.fonts.SmallBold, sx + vox.hud.ScaleWide( 14 ), slotY + headerH * .5, #slotWeapons > 0 and colorPrimaryText or colorTertiaryText, 0, 1 )
        slotY = slotY + headerH

        for index, wep in ipairs( slotWeapons ) do
            if ( IsValid( wep ) ) then
                local selected = selectorData.selectedSlot == slotIndex and index == selectorData.selectedPos
                local active = selectorData.activeWeapon == wep
                local rowH = selected and selectedH or compactH
                local rowX = sx + vox.hud.ScaleWide( 3 )
                local rowW = slotW - vox.hud.ScaleWide( 6 )

                if ( selected ) then
                    draw.RoundedBox( vox.hud.ScaleTall( 5 ), rowX, slotY, rowW, rowH, ColorAlpha( colorAccent, 72 ) )
                    surface.SetDrawColor( ColorAlpha( colorAccent, 190 ) )
                    surface.DrawOutlinedRect( rowX, slotY, rowW, rowH, 1 )
                    draw.RoundedBox( 2, rowX, slotY, rowW, 3, colorAccent )
                    drawWeaponIcon( wep, rowX + vox.hud.ScaleWide( 22 ), slotY + vox.hud.ScaleTall( 13 ), rowW - vox.hud.ScaleWide( 44 ), vox.hud.ScaleTall( 38 ), 255 )
                    drawClippedText( getWeaponName( wep ), vox.hud.fonts.TinyBold, rowX + rowW * .5, slotY + vox.hud.ScaleTall( 70 ), colorPrimaryText, 1, 1, rowX + vox.hud.ScaleWide( 5 ), slotY + vox.hud.ScaleTall( 58 ), rowW - vox.hud.ScaleWide( 10 ), vox.hud.ScaleTall( 20 ) )
                    drawClippedText( getWeaponAmmoText( client, wep ), vox.hud.fonts.ExtraTinyBold, rowX + rowW * .5, slotY + vox.hud.ScaleTall( 84 ), colorPrimaryText, 1, 1, rowX + vox.hud.ScaleWide( 5 ), slotY + vox.hud.ScaleTall( 74 ), rowW - vox.hud.ScaleWide( 10 ), vox.hud.ScaleTall( 18 ) )
                else
                    draw.RoundedBox( vox.hud.ScaleTall( 4 ), rowX, slotY, rowW, rowH, ColorAlpha( active and colorAccent or colorSecondary, active and 34 or 110 ) )
                    surface.SetDrawColor( ColorAlpha( active and colorAccent or colorSecondaryText, active and 120 or 30 ) )
                    surface.DrawOutlinedRect( rowX, slotY, rowW, rowH, 1 )
                    drawClippedText( getWeaponName( wep ), vox.hud.fonts.ExtraTinyBold, rowX + rowW * .5, slotY + rowH * .5, active and colorPrimaryText or colorSecondaryText, 1, 1, rowX + vox.hud.ScaleWide( 5 ), slotY, rowW - vox.hud.ScaleWide( 10 ), rowH )
                end

                slotY = slotY + rowH + gap
            end
        end

        if ( slotIndex < MAX_SLOTS ) then
            surface.SetDrawColor( ColorAlpha( colorSecondaryText, 35 ) )
            surface.DrawLine( sx + slotW, y + titleH + vox.hud.ScaleTall( 10 ), sx + slotW, y + titleH + maxColumnH - vox.hud.ScaleTall( 10 ) )
        end
    end

    surface.SetAlphaMultiplier( prevAlpha )
end

do
    local binds = {}
    for index = 1, MAX_SLOTS do
        binds[ ( 'slot' .. index ) ] = index
    end

    local lastWeapon = NULL

    local function selectWeapon()
        local data = selectorData
        local slotWeapons = slotsCache[ data.selectedSlot ]

        if ( slotWeapons ) then
            local weapon = slotWeapons[ data.selectedPos ]
            if ( IsValid( weapon ) ) then
                lastWeapon = LocalPlayer():GetActiveWeapon()
                input.SelectWeapon( weapon )
                toggleWeaponSelector( false )
            end
        end
    end

    local function cycleWeapons( slot )
        local data = selectorData
        local wasActive = toggleState
        local prevSlot = data.selectedSlot

        toggleWeaponSelector( true )

        if ( not wasActive and prevSlot == slot and not quickSwitchEnabled ) then return end

        local slotData = slotsCache[ slot ]
        local pos = data.selectedPos or 0
        local weaponsAmount = #slotData

        if ( prevSlot ~= slot ) then
            pos = 0
        end

        data.selectedSlot = slot
        data.selectedPos = pos + 1

        if ( data.selectedPos > weaponsAmount ) then
            data.selectedPos = 1
        end

        if ( quickSwitchEnabled ) then
            selectWeapon()
        end
    end

    local function scrollWeapons( delta )
        toggleWeaponSelector( true, true )

        local data = selectorData
        local slot = data.selectedSlot or 1
        local slotData = slotsCache[ slot ]
        local pos = data.selectedPos or 0
        local weaponsAmount = #slotData

        data.selectedPos = pos + delta

        local bNext = data.selectedPos > weaponsAmount
        local bPrev = data.selectedPos < 1

        if ( bNext or bPrev ) then
            local newSlot = data.selectedSlot
            for _ = 1, MAX_SLOTS do
                newSlot = newSlot + delta
                if ( newSlot < 1 ) then newSlot = MAX_SLOTS end
                if ( newSlot > MAX_SLOTS ) then newSlot = 1 end

                local amount = #slotsCache[ newSlot ]

                if ( amount > 0 ) then
                    data.selectedPos = ( bPrev and amount or 1 )
                    data.selectedSlot = newSlot
                    break
                end
            end
        end

        if ( quickSwitchEnabled ) then
            selectWeapon()
        end
    end

    hook.Add( 'PlayerBindPress', 'vox.hud.HandleBinds', function( ply, bind, pressed, code )
        local slot = binds[ bind ]

        if ( ply:InVehicle() ) then return end

        if ( slot ) then
            cycleWeapons( slot )
            return true
        elseif ( bind == '+attack' and not quickSwitchEnabled ) then
            if ( toggleState ) then
                selectWeapon()
                return true
            end
        elseif ( not ply:KeyDown( IN_ATTACK ) ) then
            if ( bind == 'invprev' ) then
                scrollWeapons( -1 )
                return true
            elseif ( bind == 'invnext' ) then
                scrollWeapons( 1 )
                return true
            elseif ( bind == 'lastinv' ) then
                if ( IsValid( lastWeapon ) ) then
                    local wep = ply:GetActiveWeapon()
                    input.SelectWeapon( lastWeapon )
                    lastWeapon = wep
                end
            end
        end
    end )
end

hook.Add( 'PostDrawHUD', 'vox.hud.DrawWeaponSelector', function()
    -- cam.Start2D fixes weird font issue in this hook
    cam.Start2D()
        drawWeaponSelector( LocalPlayer(), ScrW(), ScrH() )
    cam.End2D()
end )

hook.Add( 'HUDShouldDraw', 'vox.hud.HideWeaponSelector', function( name )
    if ( name == 'CHudWeaponSelection' ) then
        return false
    end
end )

hook.Add( 'Think', 'vox.hud.UpdateWeaponSelector', function()
    local client = LocalPlayer()
    if ( not IsValid( client ) ) then return end

    local weaponsList = client:GetWeapons()

    resetSlotsCache()

    selectorData.activeWeapon = client:GetActiveWeapon()

    for _, wep in ipairs( weaponsList ) do
        if ( IsValid( wep ) ) then
            local slotIndex = math.Clamp( wep:GetSlot() + 1, 1, MAX_SLOTS )
            local slotWeapons = slotsCache[ slotIndex ]
            assert( slotWeapons, string.format( 'invalid slot index %d', slotIndex ) )
            table.insert( slotWeapons, wep )
        end
    end

    for index, cacheList in ipairs( slotsCache ) do
        table.sort( cacheList, function( a, b )
            return a:GetSlotPos() < b:GetSlotPos()
        end )
    end
end )
