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

    return 'INF'
end

local function drawClippedText( text, font, x, y, color, alignX, alignY, clipX, clipY, clipW, clipH )
    if ( clipW <= 0 or clipH <= 0 ) then return end

    render.SetScissorRect( clipX, clipY, clipX + clipW, clipY + clipH, true )
        draw.SimpleText( text, font, x, y, color, alignX, alignY )
    render.SetScissorRect( 0, 0, 0, 0, false )
end

local function drawWeaponIcon( wep, x, y, w, h, alpha )
    if ( not IsValid( wep ) ) then return end

    local ok = false
    local iconColor = Color( 255, 255, 255, alpha or 255 )

    render.SetScissorRect( x, y, x + w, y + h, true )

    if ( wep.DrawWeaponSelection ) then
        ok = pcall( function()
            wep:DrawWeaponSelection( x, y, w, h, alpha or 255 )
        end )
    end

    if ( not ok ) then
        if killicon and killicon.Exists and killicon.Exists( wep:GetClass() ) then
            killicon.Draw( x + w * .5, y + h * .5, wep:GetClass(), iconColor )
        else
            draw.SimpleText( '-', vox.hud.fonts.SmallBold, x + w * .5, y + h * .5, iconColor, 1, 1 )
        end
    end

    render.SetScissorRect( 0, 0, 0, 0, false )
end

local function getFlatWeaponList()
    local weapons = {}

    for slotIndex = 1, MAX_SLOTS do
        for _, wep in ipairs( slotsCache[ slotIndex ] or {} ) do
            if ( IsValid( wep ) ) then
                weapons[ #weapons + 1 ] = {
                    weapon = wep,
                    slot = slotIndex,
                    pos = getWeaponSlotPos( wep ) + 1
                }
            end
        end
    end

    return weapons
end

local function getWrappedWeaponData( weapons, index )
    local amount = #weapons
    if ( amount <= 0 ) then return nil end

    return weapons[ ( ( index - 1 ) % amount ) + 1 ]
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
    local availableW = scrW - screenPadding * 2
    local cardGap = vox.hud.ScaleWide( 5 )
    local cardW = vox.hud.ScaleWide( 76 )
    local cardH = vox.hud.ScaleTall( 92 )
    local iconH = vox.hud.ScaleTall( 34 )
    local maxCards = math.max( 1, math.min( 6, math.floor( ( availableW + cardGap ) / ( cardW + cardGap ) ) ) )
    local weapons = getFlatWeaponList()
    local selectedWeapon = getSelectedWeapon()
    local selectedIndex = 1
    local foundSelected = false

    for index, weaponData in ipairs( weapons ) do
        if ( weaponData.weapon == selectedWeapon ) then
            selectedIndex = index
            foundSelected = true
            break
        end
    end

    if ( #weapons > 0 and ( not IsValid( selectedWeapon ) or not foundSelected ) ) then
        selectedWeapon = weapons[ selectedIndex ].weapon
    end

    local visibleCount = math.min( #weapons, maxCards )
    local panelW = visibleCount > 0 and ( visibleCount * cardW + math.max( visibleCount - 1, 0 ) * cardGap ) or math.min( vox.hud.ScaleWide( 190 ), availableW )
    local panelH = cardH
    local x = scrW * .5 - panelW * .5
    local y = screenPadding + vox.hud.ScaleTall( 18 )

    draw.RoundedBox( vox.hud.ScaleTall( 5 ), x - vox.hud.ScaleWide( 5 ), y - vox.hud.ScaleTall( 5 ), panelW + vox.hud.ScaleWide( 10 ), panelH + vox.hud.ScaleTall( 10 ), ColorAlpha( colorPrimary, 202 ) )
    vox.DrawMatGradient( x - vox.hud.ScaleWide( 5 ), y - vox.hud.ScaleTall( 5 ), panelW + vox.hud.ScaleWide( 10 ), panelH + vox.hud.ScaleTall( 10 ), RIGHT, ColorAlpha( colorSecondary, 38 ) )

    if ( #weapons <= 0 or not IsValid( selectedWeapon ) ) then
        draw.RoundedBox( vox.hud.ScaleTall( 4 ), x, y, panelW, panelH, ColorAlpha( colorSecondary, 130 ) )
        draw.SimpleText( 'NO WEAPONS', vox.hud.fonts.SmallBold, x + panelW * .5, y + panelH * .5, colorSecondaryText, 1, 1 )
        surface.SetAlphaMultiplier( prevAlpha )
        return
    end

    local firstIndex = math.Clamp( selectedIndex - math.floor( visibleCount * .5 ), 1, math.max( #weapons - visibleCount + 1, 1 ) )
    if ( selectedIndex > firstIndex + visibleCount - 1 ) then
        firstIndex = selectedIndex - visibleCount + 1
    end

    local function drawWeaponCard( weaponData, drawIndex )
        if ( not weaponData or not IsValid( weaponData.weapon ) ) then return end

        local weapon = weaponData.weapon
        local selected = weapon == selectedWeapon
        local active = weapon == selectorData.activeWeapon
        local cardX = x + ( drawIndex - 1 ) * ( cardW + cardGap )
        local cardY = y
        local cardColor = selected and ColorAlpha( colorAccent, 60 ) or ColorAlpha( colorSecondary, active and 132 or 112 )
        local borderColor = selected and ColorAlpha( colorAccent, 225 ) or ColorAlpha( active and colorAccent or colorSecondaryText, active and 115 or 30 )

        draw.RoundedBox( vox.hud.ScaleTall( 4 ), cardX, cardY, cardW, cardH, cardColor )
        vox.DrawMatGradient( cardX, cardY, cardW, cardH, BOTTOM, ColorAlpha( colorPrimary, selected and 54 or 28 ) )
        surface.SetDrawColor( borderColor )
        surface.DrawOutlinedRect( cardX, cardY, cardW, cardH, 1 )

        if ( selected ) then
            surface.SetDrawColor( colorAccent )
            surface.DrawRect( cardX, cardY, cardW, 2 )
        end

        draw.SimpleText( tostring( weaponData.slot ), vox.hud.fonts.ExtraTinyBold, cardX + vox.hud.ScaleWide( 7 ), cardY + vox.hud.ScaleTall( 8 ), selected and colorPrimaryText or colorSecondaryText, 0, 1 )

        if ( active ) then
            draw.RoundedBox( 2, cardX + cardW - vox.hud.ScaleWide( 12 ), cardY + vox.hud.ScaleTall( 7 ), vox.hud.ScaleWide( 5 ), vox.hud.ScaleTall( 5 ), colorAccent )
        end

        local iconX = cardX + vox.hud.ScaleWide( 8 )
        local iconY = cardY + vox.hud.ScaleTall( 18 )
        local iconW = cardW - vox.hud.ScaleWide( 16 )
        drawWeaponIcon( weapon, iconX, iconY, iconW, iconH, selected and 255 or 205 )

        local nameY = cardY + vox.hud.ScaleTall( 61 )
        local textX = cardX + vox.hud.ScaleWide( 7 )
        local textW = cardW - vox.hud.ScaleWide( 14 )
        drawClippedText( getWeaponName( weapon ), selected and vox.hud.fonts.ExtraTinyBold or vox.hud.fonts.ExtraTinyBold, textX, nameY, selected and colorPrimaryText or colorSecondaryText, 0, 1, textX, nameY - vox.hud.ScaleTall( 8 ), textW, vox.hud.ScaleTall( 16 ) )

        local ammoText = active and getWeaponAmmoText( client, weapon ) or ( selected and ( quickSwitchEnabled and 'AUTO' or 'READY' ) or getWeaponAmmoText( client, weapon ) )
        drawClippedText( ammoText, vox.hud.fonts.ExtraTinyBold, textX, cardY + cardH - vox.hud.ScaleTall( 11 ), selected and colorAccent or colorTertiaryText, 0, 1, textX, cardY + cardH - vox.hud.ScaleTall( 18 ), textW, vox.hud.ScaleTall( 14 ) )
    end

    for drawIndex = 1, visibleCount do
        drawWeaponCard( weapons[ firstIndex + drawIndex - 1 ], drawIndex )
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
