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
            syncSelectionToWeapon( selectorData.activeWeapon )
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

    return 'INF'
end

local function getWeaponMetaText( wep )
    if ( not IsValid( wep ) ) then return '' end

    return string.format( 'SLOT %d  |  POS %d', getWeaponSlotIndex( wep ), getWeaponSlotPos( wep ) + 1 )
end

local function drawClippedText( text, font, x, y, color, alignX, alignY, clipX, clipY, clipW, clipH )
    if ( clipW <= 0 or clipH <= 0 ) then return end

    render.SetScissorRect( clipX, clipY, clipX + clipW, clipY + clipH, true )
        draw.SimpleText( text, font, x, y, color, alignX, alignY )
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
    local panelW = math.min( vox.hud.ScaleWide( 520 ), scrW - screenPadding * 2 )
    local panelH = vox.hud.ScaleTall( 104 )
    local x = scrW * .5 - panelW * .5
    local y = screenPadding + vox.hud.ScaleTall( 18 )
    local pad = vox.hud.ScaleWide( 12 )
    local headerH = vox.hud.ScaleTall( 22 )
    local currentH = vox.hud.ScaleTall( 42 )
    local navH = vox.hud.ScaleTall( 22 )
    local gap = vox.hud.ScaleTall( 5 )
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

    draw.RoundedBox( vox.hud.ScaleTall( 5 ), x, y, panelW, panelH, ColorAlpha( colorPrimary, 224 ) )
    vox.DrawMatGradient( x, y, panelW, panelH, RIGHT, ColorAlpha( colorSecondary, 58 ) )
    vox.DrawMatGradient( x, y, panelW, panelH, BOTTOM, ColorAlpha( colorAccent, 16 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 95 ) )
    surface.DrawOutlinedRect( x, y, panelW, panelH, 1 )
    surface.SetDrawColor( ColorAlpha( colorAccent, 210 ) )
    surface.DrawRect( x + pad, y, vox.hud.ScaleWide( 72 ), 2 )

    draw.SimpleText( 'WEAPON', vox.hud.fonts.SmallBold, x + pad, y + headerH * .5, colorPrimaryText, 0, 1 )
    draw.SimpleText( #weapons > 0 and ( selectedIndex .. ' / ' .. #weapons ) or '', vox.hud.fonts.ExtraTinyBold, x + panelW - pad, y + headerH * .5, colorSecondaryText, 2, 1 )

    if ( #weapons <= 0 or not IsValid( selectedWeapon ) ) then
        local emptyY = y + headerH + gap
        draw.RoundedBox( vox.hud.ScaleTall( 4 ), x + pad, emptyY, panelW - pad * 2, panelH - headerH - gap - pad, ColorAlpha( colorSecondary, 130 ) )
        draw.SimpleText( 'NO WEAPONS', vox.hud.fonts.SmallBold, x + panelW * .5, emptyY + ( panelH - headerH - gap - pad ) * .5, colorSecondaryText, 1, 1 )
        surface.SetAlphaMultiplier( prevAlpha )
        return
    end

    local selectedX = x + pad
    local selectedY = y + headerH + gap
    local selectedW = panelW - pad * 2
    local selectedActive = selectedWeapon == selectorData.activeWeapon
    local selectedData = getWrappedWeaponData( weapons, selectedIndex )

    draw.RoundedBox( vox.hud.ScaleTall( 4 ), selectedX, selectedY, selectedW, currentH, ColorAlpha( colorSecondary, 152 ) )
    vox.DrawMatGradient( selectedX, selectedY, selectedW, currentH, RIGHT, ColorAlpha( colorAccent, 24 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, selectedActive and 165 or 82 ) )
    surface.DrawOutlinedRect( selectedX, selectedY, selectedW, currentH, 1 )
    draw.RoundedBox( 2, selectedX, selectedY, vox.hud.ScaleWide( 4 ), currentH, selectedActive and colorAccent or ColorAlpha( colorAccent, 145 ) )

    local slotW = vox.hud.ScaleWide( 44 )
    local slotX = selectedX + vox.hud.ScaleWide( 10 )
    local slotY = selectedY + vox.hud.ScaleTall( 9 )
    draw.RoundedBox( vox.hud.ScaleTall( 3 ), slotX, slotY, slotW, currentH - vox.hud.ScaleTall( 18 ), ColorAlpha( colorPrimary, 168 ) )
    draw.SimpleText( selectedData and ( 'S' .. selectedData.slot ) or 'S?', vox.hud.fonts.TinyBold, slotX + slotW * .5, selectedY + currentH * .5, colorPrimaryText, 1, 1 )

    local statusLabel = selectedActive and 'EQUIPPED' or ( quickSwitchEnabled and 'AUTO' or 'SELECT' )
    local statusW = vox.hud.ScaleWide( 78 )
    local ammoW = vox.hud.ScaleWide( 78 )
    local nameX = slotX + slotW + vox.hud.ScaleWide( 12 )
    local nameW = math.max( selectedW - ( nameX - selectedX ) - statusW - ammoW - vox.hud.ScaleWide( 30 ), 0 )
    drawClippedText( getWeaponName( selectedWeapon ), vox.hud.fonts.SmallBold, nameX, selectedY + currentH * .5 - vox.hud.ScaleTall( 5 ), colorPrimaryText, 0, 1, nameX, selectedY + vox.hud.ScaleTall( 6 ), nameW, currentH - vox.hud.ScaleTall( 12 ) )
    draw.SimpleText( selectedData and ( 'POS ' .. selectedData.pos ) or '', vox.hud.fonts.ExtraTinyBold, nameX, selectedY + currentH - vox.hud.ScaleTall( 9 ), colorSecondaryText, 0, 1 )
    draw.SimpleText( getWeaponAmmoText( client, selectedWeapon ), vox.hud.fonts.TinyBold, selectedX + selectedW - statusW - vox.hud.ScaleWide( 18 ), selectedY + currentH * .5, colorPrimaryText, 2, 1 )
    draw.RoundedBox( vox.hud.ScaleTall( 3 ), selectedX + selectedW - statusW - vox.hud.ScaleWide( 10 ), selectedY + vox.hud.ScaleTall( 10 ), statusW, currentH - vox.hud.ScaleTall( 20 ), ColorAlpha( selectedActive and colorAccent or colorPrimary, selectedActive and 52 or 170 ) )
    draw.SimpleText( statusLabel, vox.hud.fonts.ExtraTinyBold, selectedX + selectedW - statusW * .5 - vox.hud.ScaleWide( 10 ), selectedY + currentH * .5, selectedActive and colorAccent or colorSecondaryText, 1, 1 )

    local navY = selectedY + currentH + gap
    local navGap = vox.hud.ScaleWide( 6 )
    local navW = math.max( ( selectedW - navGap ) * .5, 0 )
    local prevData = #weapons > 1 and getWrappedWeaponData( weapons, selectedIndex - 1 ) or nil
    local nextData = #weapons > 1 and getWrappedWeaponData( weapons, selectedIndex + 1 ) or nil

    local function drawNavChip( navX, label, weaponData )
        draw.RoundedBox( vox.hud.ScaleTall( 3 ), navX, navY, navW, navH, ColorAlpha( colorSecondary, 118 ) )
        surface.SetDrawColor( ColorAlpha( colorSecondaryText, 32 ) )
        surface.DrawOutlinedRect( navX, navY, navW, navH, 1 )

        if ( not weaponData ) then
            draw.SimpleText( 'ONLY WEAPON', vox.hud.fonts.ExtraTinyBold, navX + navW * .5, navY + navH * .5, colorTertiaryText, 1, 1 )
            return
        end

        local labelW = vox.hud.ScaleWide( 36 )
        draw.RoundedBox( vox.hud.ScaleTall( 3 ), navX + vox.hud.ScaleWide( 5 ), navY + vox.hud.ScaleTall( 4 ), labelW, navH - vox.hud.ScaleTall( 8 ), ColorAlpha( colorPrimary, 150 ) )
        draw.SimpleText( label, vox.hud.fonts.ExtraTinyBold, navX + vox.hud.ScaleWide( 5 ) + labelW * .5, navY + navH * .5, colorSecondaryText, 1, 1 )

        local textX = navX + vox.hud.ScaleWide( 5 ) + labelW + vox.hud.ScaleWide( 8 )
        drawClippedText( getWeaponName( weaponData.weapon ), vox.hud.fonts.ExtraTinyBold, textX, navY + navH * .5, colorSecondaryText, 0, 1, textX, navY, navW - ( textX - navX ) - vox.hud.ScaleWide( 8 ), navH )
    end

    drawNavChip( selectedX, 'PREV', prevData )
    drawNavChip( selectedX + navW + navGap, 'NEXT', nextData )

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
        local wasActive = toggleState

        rebuildSlotsCache( LocalPlayer() )
        toggleWeaponSelector( true )

        local prevSlot = data.selectedSlot
        if ( not wasActive and prevSlot == slot and not quickSwitchEnabled ) then return end

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

        if ( quickSwitchEnabled ) then
            selectWeapon()
        end
    end

    local function scrollWeapons( delta )
        rebuildSlotsCache( LocalPlayer() )
        toggleWeaponSelector( true, true )

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
    rebuildSlotsCache( LocalPlayer() )
end )
