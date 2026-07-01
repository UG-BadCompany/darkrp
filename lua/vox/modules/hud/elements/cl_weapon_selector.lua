local SHOW_DURATION = 1.5
local MAX_SLOTS = 6

local hud = vox.hud
local toggleFraction = 0
local toggleState = false
local slotsCache = {}
local selectorData = {
    selectedSlot = 1,
    selectedPos = 0,
    selectedWeapon = NULL,
    activeWeapon = NULL
}
local selectorAnim = {
    initialized = false,
    x = 0,
    y = 0,
    w = 0,
    h = 0
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

local function getWeaponSlotIndex( wep )
    if ( not IsValid( wep ) ) then return 1 end
    return math.Clamp( ( wep:GetSlot() or 0 ) + 1, 1, MAX_SLOTS )
end

local function getWeaponSlotPos( wep )
    if ( not IsValid( wep ) ) then return 0 end
    return tonumber( wep:GetSlotPos() ) or 0
end

local function setSelectedWeaponPosition( slotIndex, pos )
    local slotWeapons = slotsCache[ slotIndex ]
    local weapon = slotWeapons and slotWeapons[ pos ]

    if ( not IsValid( weapon ) ) then return false end

    selectorData.selectedSlot = slotIndex
    selectorData.selectedPos = pos
    selectorData.selectedWeapon = weapon

    return true
end

local function syncSelectionToWeapon( weapon )
    if ( not IsValid( weapon ) ) then return false end

    for slotIndex, slotWeapons in ipairs( slotsCache ) do
        for pos, slotWeapon in ipairs( slotWeapons ) do
            if ( slotWeapon == weapon ) then
                return setSelectedWeaponPosition( slotIndex, pos )
            end
        end
    end

    return false
end

local function getSelectedWeapon()
    local slotWeapons = slotsCache[ selectorData.selectedSlot ]
    local weapon = slotWeapons and slotWeapons[ selectorData.selectedPos ]

    return IsValid( weapon ) and weapon or selectorData.activeWeapon
end

local function rebuildSlotsCache( client )
    resetSlotsCache()

    if ( not IsValid( client ) ) then return end

    selectorData.activeWeapon = client:GetActiveWeapon()

    for _, wep in ipairs( client:GetWeapons() ) do
        if ( IsValid( wep ) ) then
            table.insert( slotsCache[ getWeaponSlotIndex( wep ) ], wep )
        end
    end

    for _, cacheList in ipairs( slotsCache ) do
        table.sort( cacheList, function( a, b )
            local slotPosA = getWeaponSlotPos( a )
            local slotPosB = getWeaponSlotPos( b )

            if ( slotPosA == slotPosB ) then
                return tostring( a:GetClass() ) < tostring( b:GetClass() )
            end

            return slotPosA < slotPosB
        end )
    end

    if ( not toggleState and syncSelectionToWeapon( selectorData.activeWeapon ) ) then return end

    if ( not syncSelectionToWeapon( selectorData.selectedWeapon ) ) then
        syncSelectionToWeapon( selectorData.activeWeapon )
    end
end

local function toggleWeaponSelector( state )
    toggleState = state

    if ( not state ) then
        toggleFraction = 0
        selectorAnim.initialized = false
        timer.Remove( 'vox.hud.HideWeaponSelector' )
    else
        timer.Create( 'vox.hud.HideWeaponSelector', SHOW_DURATION, 1, function()
            toggleWeaponSelector( false )
        end )
    end
end

local function getWeaponName( wep )
    local name = wep:GetPrintName()
    if ( not name or name == '' ) then name = wep:GetClass() end
    return language.GetPhrase( name ) or name
end

local function drawClippedText( text, font, x, y, color, alignX, alignY, clipX, clipY, clipW, clipH )
    if ( clipW <= 0 or clipH <= 0 ) then return end

    render.SetScissorRect( clipX, clipY, clipX + clipW, clipY + clipH, true )
        draw.SimpleText( text, font, x, y, color, alignX, alignY )
    render.SetScissorRect( 0, 0, 0, 0, false )
end

local function drawWeaponSelector( client, scrW, scrH )
    toggleFraction = math.Approach( toggleFraction, toggleState and 1 or 0, FrameTime() * 8 )
    if ( toggleFraction <= 0 ) then return end

    local theme = hud:GetCurrentTheme() or {}
    local colors = theme.colors or ( vox.GetUIThemeColors and vox.GetUIThemeColors() ) or {}
    local colorPrimary = colors.primary or Color( 3, 11, 24 )
    local colorSecondary = colors.secondary or Color( 8, 27, 52 )
    local colorAccent = colors.accent or Color( 0, 174, 255 )
    local colorPrimaryText = colors.textPrimary or color_white
    local colorSecondaryText = colors.textSecondary or Color( 145, 172, 200 )
    local colorTertiaryText = colors.textTertiary or Color( 92, 112, 135 )

    local prevAlpha = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier( toggleFraction )

    local screenPadding = vox.hud.GetScreenPadding()
    local availableW = math.max( scrW - screenPadding * 2, vox.hud.ScaleWide( 120 ) )
    local filledSlotW = vox.hud.ScaleWide( 148 )
    local emptySlotW = vox.hud.ScaleWide( 34 )
    local gapX = vox.hud.ScaleWide( 4 )
    local gapY = vox.hud.ScaleTall( 5 )
    local headerH = vox.hud.ScaleTall( 26 )
    local rowH = vox.hud.ScaleTall( 26 )
    local selectedWeapon = getSelectedWeapon()

    local slotWidths = {}
    local totalW = 0
    local totalWeapons = 0

    for slotIndex = 1, MAX_SLOTS do
        local amount = #( slotsCache[ slotIndex ] or {} )
        local slotW = amount > 0 and filledSlotW or emptySlotW

        slotWidths[ slotIndex ] = slotW
        totalW = totalW + slotW
        totalWeapons = totalWeapons + amount
    end

    totalW = totalW + ( MAX_SLOTS - 1 ) * gapX

    if ( totalW > availableW ) then
        local scale = availableW / totalW
        totalW = 0
        gapX = math.max( vox.hud.ScaleWide( 2 ), gapX * scale )

        for slotIndex = 1, MAX_SLOTS do
            slotWidths[ slotIndex ] = math.max( vox.hud.ScaleWide( 26 ), slotWidths[ slotIndex ] * scale )
            totalW = totalW + slotWidths[ slotIndex ]
        end

        totalW = totalW + ( MAX_SLOTS - 1 ) * gapX
    end

    local x = scrW * .5 - totalW * .5
    local y = screenPadding + vox.hud.ScaleTall( 18 )

    if ( totalWeapons <= 0 or not IsValid( selectedWeapon ) ) then
        local emptyW = math.min( vox.hud.ScaleWide( 220 ), availableW )
        draw.RoundedBox( vox.hud.ScaleTall( 4 ), scrW * .5 - emptyW * .5, y, emptyW, headerH + rowH + gapY, ColorAlpha( colorPrimary, 210 ) )
        draw.SimpleText( 'NO WEAPONS', vox.hud.fonts.SmallBold, scrW * .5, y + ( headerH + rowH + gapY ) * .5, colorSecondaryText, 1, 1 )
        surface.SetAlphaMultiplier( prevAlpha )
        return
    end

    local slotX = x
    local selectionTarget = nil
    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ] or {}
        local slotW = slotWidths[ slotIndex ]

        draw.RoundedBox( vox.hud.ScaleTall( 4 ), slotX, y, slotW, headerH, ColorAlpha( colorPrimary, #slotWeapons > 0 and 205 or 150 ) )
        surface.SetDrawColor( ColorAlpha( colorSecondaryText, #slotWeapons > 0 and 34 or 18 ) )
        surface.DrawOutlinedRect( slotX, y, slotW, headerH, 1 )
        draw.SimpleText( tostring( slotIndex ), vox.hud.fonts.ExtraTinyBold, slotX + slotW * .5, y + headerH * .5, #slotWeapons > 0 and colorSecondaryText or colorTertiaryText, 1, 1 )

        for weaponIndex, weapon in ipairs( slotWeapons ) do
            if ( IsValid( weapon ) ) then
                local rowY = y + headerH + gapY + ( weaponIndex - 1 ) * ( rowH + gapY )
                local selected = selectorData.selectedSlot == slotIndex and selectorData.selectedPos == weaponIndex
                local active = selectorData.activeWeapon == weapon
                local rowColor = ColorAlpha( colorPrimary, active and 178 or 155 )
                local borderColor = ColorAlpha( active and colorAccent or colorSecondaryText, active and 110 or 24 )

                draw.RoundedBox( vox.hud.ScaleTall( 4 ), slotX, rowY, slotW, rowH, rowColor )
                vox.DrawMatGradient( slotX, rowY, slotW, rowH, RIGHT, ColorAlpha( colorSecondary, selected and 34 or 18 ) )
                surface.SetDrawColor( borderColor )
                surface.DrawOutlinedRect( slotX, rowY, slotW, rowH, 1 )

                if ( selected ) then
                    selectionTarget = {
                        x = slotX,
                        y = rowY,
                        w = slotW,
                        h = rowH
                    }
                end

                local textInset = vox.hud.ScaleWide( 7 )
                local rightPad = active and vox.hud.ScaleWide( 14 ) or vox.hud.ScaleWide( 7 )
                drawClippedText( getWeaponName( weapon ), selected and vox.hud.fonts.ExtraTinyBold or vox.hud.fonts.ExtraTinyBold, slotX + slotW * .5, rowY + rowH * .5, selected and colorPrimaryText or colorSecondaryText, 1, 1, slotX + textInset, rowY, slotW - textInset - rightPad, rowH )

                if ( active ) then
                    draw.RoundedBox( 2, slotX + slotW - vox.hud.ScaleWide( 10 ), rowY + rowH * .5 - vox.hud.ScaleTall( 2 ), vox.hud.ScaleWide( 4 ), vox.hud.ScaleTall( 4 ), colorAccent )
                end
            end
        end

        slotX = slotX + slotW + gapX
    end

    if ( selectionTarget ) then
        local speed = math.Clamp( FrameTime() * 18, 0, 1 )

        if ( not selectorAnim.initialized ) then
            selectorAnim.x = selectionTarget.x
            selectorAnim.y = selectionTarget.y
            selectorAnim.w = selectionTarget.w
            selectorAnim.h = selectionTarget.h
            selectorAnim.initialized = true
        else
            selectorAnim.x = Lerp( speed, selectorAnim.x, selectionTarget.x )
            selectorAnim.y = Lerp( speed, selectorAnim.y, selectionTarget.y )
            selectorAnim.w = Lerp( speed, selectorAnim.w, selectionTarget.w )
            selectorAnim.h = Lerp( speed, selectorAnim.h, selectionTarget.h )
        end

        draw.RoundedBox( vox.hud.ScaleTall( 4 ), selectorAnim.x, selectorAnim.y, selectorAnim.w, selectorAnim.h, ColorAlpha( colorAccent, 48 ) )
        vox.DrawMatGradient( selectorAnim.x, selectorAnim.y, selectorAnim.w, selectorAnim.h, RIGHT, ColorAlpha( colorSecondary, 40 ) )
        surface.SetDrawColor( ColorAlpha( colorAccent, 230 ) )
        surface.DrawOutlinedRect( selectorAnim.x, selectorAnim.y, selectorAnim.w, selectorAnim.h, 1 )
        surface.DrawRect( selectorAnim.x, selectorAnim.y, selectorAnim.w, 2 )
    else
        selectorAnim.initialized = false
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
                data.selectedWeapon = weapon
                input.SelectWeapon( weapon )
                toggleWeaponSelector( false )
            end
        end
    end

    local function cycleWeapons( slot )
        local data = selectorData

        rebuildSlotsCache( LocalPlayer() )

        local prevSlot = data.selectedSlot
        local slotData = slotsCache[ slot ] or {}
        local pos = data.selectedPos or 0
        local weaponsAmount = #slotData

        if ( weaponsAmount == 0 ) then return end

        if ( prevSlot ~= slot ) then
            pos = 0
        end

        local nextPos = pos + 1

        if ( nextPos > weaponsAmount ) then
            nextPos = 1
        end

        setSelectedWeaponPosition( slot, nextPos )
        toggleWeaponSelector( true )

        if ( quickSwitchEnabled ) then
            selectWeapon()
        end
    end

    local function scrollWeapons( delta )
        rebuildSlotsCache( LocalPlayer() )

        local data = selectorData
        local slot = data.selectedSlot or 1
        local slotData = slotsCache[ slot ] or {}
        local pos = data.selectedPos or 0
        local weaponsAmount = #slotData

        local nextPos = pos + delta

        local bNext = nextPos > weaponsAmount
        local bPrev = nextPos < 1

        if ( bNext or bPrev ) then
            local newSlot = data.selectedSlot
            for _ = 1, MAX_SLOTS do
                newSlot = newSlot + delta
                if ( newSlot < 1 ) then newSlot = MAX_SLOTS end
                if ( newSlot > MAX_SLOTS ) then newSlot = 1 end

                local amount = #slotsCache[ newSlot ]

                if ( amount > 0 ) then
                    setSelectedWeaponPosition( newSlot, bPrev and amount or 1 )
                    break
                end
            end
        else
            setSelectedWeaponPosition( slot, nextPos )
        end

        toggleWeaponSelector( true )

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

    if ( toggleState ) then
        if ( IsValid( client ) ) then
            selectorData.activeWeapon = client:GetActiveWeapon()
        end

        return
    end

    rebuildSlotsCache( client )
end )
