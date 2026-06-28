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

local function drawWeaponIcon( wep, x, y, w, h, alpha )
    local ok = false

    render.SetScissorRect( x, y, x + w, y + h, true )

    if ( wep.DrawWeaponSelection ) then
        ok = pcall( function() wep:DrawWeaponSelection( x, y, w, h, alpha or 255 ) end )
    end

    if ( ok ) then
        render.SetScissorRect( 0, 0, 0, 0, false )
        return
    end

    if killicon and killicon.Exists and killicon.Exists( wep:GetClass() ) then
        killicon.Draw( x + w * .5, y + h * .5, wep:GetClass(), Color( 255, 255, 255, alpha or 255 ) )
    else
        draw.SimpleText( '-', vox.hud.fonts.SmallBold, x + w * .5, y + h * .5, Color( 255, 255, 255, alpha or 255 ), 1, 1 )
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
    local panelW = math.min( vox.hud.ScaleWide( 720 ), scrW - screenPadding * 2 )
    local panelH = vox.hud.ScaleTall( 166 )
    local x = scrW * .5 - panelW * .5
    local y = screenPadding + vox.hud.ScaleTall( 14 )
    local pad = vox.hud.ScaleWide( 10 )
    local headerH = vox.hud.ScaleTall( 30 )
    local bodyY = y + headerH + vox.hud.ScaleTall( 6 )
    local bodyH = panelH - headerH - vox.hud.ScaleTall( 16 )
    local gap = vox.hud.ScaleWide( 8 )
    local selectedCardW = math.min( vox.hud.ScaleWide( 348 ), panelW * .48 )
    local queueX = x + pad + selectedCardW + gap
    local queueW = x + panelW - pad - queueX
    local rowH = vox.hud.ScaleTall( 24 )
    local rowGap = vox.hud.ScaleTall( 4 )
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

    draw.RoundedBox( vox.hud.ScaleTall( 6 ), x, y, panelW, panelH, ColorAlpha( colorPrimary, 222 ) )
    vox.DrawMatGradient( x, y, panelW, panelH, RIGHT, ColorAlpha( colorSecondary, 70 ) )
    vox.DrawMatGradient( x, y, panelW, panelH, BOTTOM, ColorAlpha( colorAccent, 20 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 95 ) )
    surface.DrawOutlinedRect( x, y, panelW, panelH, 1 )
    surface.SetDrawColor( ColorAlpha( colorAccent, 210 ) )
    surface.DrawRect( x + pad, y, vox.hud.ScaleWide( 86 ), 2 )

    draw.SimpleText( 'WEAPONS', vox.hud.fonts.SmallBold, x + pad, y + headerH * .5, colorPrimaryText, 0, 1 )
    draw.SimpleText( #weapons > 0 and ( selectedIndex .. ' / ' .. #weapons ) or '', vox.hud.fonts.ExtraTinyBold, x + panelW * .5, y + headerH * .5, colorSecondaryText, 1, 1 )
    draw.SimpleText( quickSwitchEnabled and 'AUTO EQUIP' or 'BROWSE MODE', vox.hud.fonts.ExtraTinyBold, x + panelW - pad, y + headerH * .5, colorSecondaryText, 2, 1 )

    if ( #weapons <= 0 or not IsValid( selectedWeapon ) ) then
        draw.RoundedBox( vox.hud.ScaleTall( 5 ), x + pad, bodyY, panelW - pad * 2, bodyH, ColorAlpha( colorSecondary, 130 ) )
        draw.SimpleText( 'NO WEAPONS', vox.hud.fonts.SmallBold, x + panelW * .5, bodyY + bodyH * .5, colorSecondaryText, 1, 1 )
        surface.SetAlphaMultiplier( prevAlpha )
        return
    end

    local selectedX = x + pad
    local selectedY = bodyY
    local selectedH = bodyH
    local selectedActive = selectedWeapon == selectorData.activeWeapon
    local selectedData = getWrappedWeaponData( weapons, selectedIndex )

    draw.RoundedBox( vox.hud.ScaleTall( 5 ), selectedX, selectedY, selectedCardW, selectedH, ColorAlpha( colorSecondary, 160 ) )
    vox.DrawMatGradient( selectedX, selectedY, selectedCardW, selectedH, RIGHT, ColorAlpha( colorAccent, 28 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, selectedActive and 165 or 82 ) )
    surface.DrawOutlinedRect( selectedX, selectedY, selectedCardW, selectedH, 1 )
    draw.RoundedBox( 2, selectedX, selectedY, vox.hud.ScaleWide( 4 ), selectedH, selectedActive and colorAccent or ColorAlpha( colorAccent, 145 ) )

    local visualX = selectedX + vox.hud.ScaleWide( 12 )
    local visualY = selectedY + vox.hud.ScaleTall( 9 )
    local visualW = selectedCardW - vox.hud.ScaleWide( 24 )
    local visualH = math.min( vox.hud.ScaleTall( 58 ), selectedH - vox.hud.ScaleTall( 54 ) )
    draw.RoundedBox( vox.hud.ScaleTall( 4 ), visualX, visualY, visualW, visualH, ColorAlpha( colorPrimary, 166 ) )
    vox.DrawMatGradient( visualX, visualY, visualW, visualH, RIGHT, ColorAlpha( colorAccent, 18 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 45 ) )
    surface.DrawOutlinedRect( visualX, visualY, visualW, visualH, 1 )
    drawWeaponIcon( selectedWeapon, visualX + vox.hud.ScaleWide( 8 ), visualY + vox.hud.ScaleTall( 4 ), visualW - vox.hud.ScaleWide( 16 ), visualH - vox.hud.ScaleTall( 8 ), 255 )

    local textX = selectedX + vox.hud.ScaleWide( 14 )
    local textY = visualY + visualH + vox.hud.ScaleTall( 16 )
    local textW = selectedCardW - vox.hud.ScaleWide( 28 )
    drawClippedText( getWeaponName( selectedWeapon ), vox.hud.fonts.SmallBold, textX, textY, colorPrimaryText, 0, 1, textX, textY - vox.hud.ScaleTall( 13 ), textW, vox.hud.ScaleTall( 26 ) )
    draw.SimpleText( selectedData and ( 'S' .. selectedData.slot .. '  POS ' .. selectedData.pos ) or getWeaponMetaText( selectedWeapon ), vox.hud.fonts.ExtraTinyBold, textX, selectedY + selectedH - vox.hud.ScaleTall( 14 ), colorSecondaryText, 0, 1 )
    draw.SimpleText( getWeaponAmmoText( client, selectedWeapon ), vox.hud.fonts.TinyBold, selectedX + selectedCardW - vox.hud.ScaleWide( 14 ), selectedY + selectedH - vox.hud.ScaleTall( 14 ), colorPrimaryText, 2, 1 )

    local browseRows = {}
    local seenWeapons = {
        [ selectedWeapon ] = true
    }
    local browseOffsets = { -1, 1 }

    for _, offset in ipairs( browseOffsets ) do
        local weaponData = getWrappedWeaponData( weapons, selectedIndex + offset )
        if ( weaponData and not seenWeapons[ weaponData.weapon ] ) then
            seenWeapons[ weaponData.weapon ] = true
            browseRows[ #browseRows + 1 ] = {
                data = weaponData,
                offset = offset
            }

            if ( #browseRows >= 2 ) then break end
        end
    end

    local controlH = vox.hud.ScaleTall( 24 )
    local controlY = bodyY + bodyH - controlH
    local rowsH = #browseRows * rowH + math.max( #browseRows - 1, 0 ) * rowGap
    local queueY = bodyY + math.max( ( bodyH - controlH - rowGap - rowsH ) * .5, 0 )

    if ( #browseRows <= 0 ) then
        local emptyH = bodyH - controlH - rowGap
        draw.RoundedBox( vox.hud.ScaleTall( 4 ), queueX, queueY, queueW, emptyH, ColorAlpha( colorSecondary, 118 ) )
        draw.SimpleText( 'ONLY WEAPON', vox.hud.fonts.ExtraTinyBold, queueX + queueW * .5, queueY + emptyH * .5, colorSecondaryText, 1, 1 )
    else
        for rowIndex, rowData in ipairs( browseRows ) do
            local weaponData = rowData.data
            local wep = weaponData.weapon
            local active = selectorData.activeWeapon == wep
            local rowY = queueY + ( rowIndex - 1 ) * ( rowH + rowGap )
            local rowBorder = ColorAlpha( active and colorAccent or colorSecondaryText, active and 115 or 34 )

            draw.RoundedBox( vox.hud.ScaleTall( 4 ), queueX, rowY, queueW, rowH, ColorAlpha( active and colorAccent or colorSecondary, active and 34 or 128 ) )
            surface.SetDrawColor( rowBorder )
            surface.DrawOutlinedRect( queueX, rowY, queueW, rowH, 1 )

            local labelW = vox.hud.ScaleWide( 42 )
            local slotBoxX = queueX + vox.hud.ScaleWide( 8 )
            local directionText = rowData.offset < 0 and 'PREV' or 'NEXT'
            draw.RoundedBox( vox.hud.ScaleTall( 3 ), slotBoxX, rowY + vox.hud.ScaleTall( 5 ), labelW, rowH - vox.hud.ScaleTall( 10 ), ColorAlpha( colorPrimary, 148 ) )
            draw.SimpleText( directionText, vox.hud.fonts.ExtraTinyBold, slotBoxX + labelW * .5, rowY + rowH * .5, active and colorAccent or colorSecondaryText, 1, 1 )

            local nameX = slotBoxX + labelW + vox.hud.ScaleWide( 9 )
            local rightW = vox.hud.ScaleWide( active and 88 or 68 )
            drawClippedText( getWeaponName( wep ), active and vox.hud.fonts.TinyBold or vox.hud.fonts.ExtraTinyBold, nameX, rowY + rowH * .5, active and colorPrimaryText or colorSecondaryText, 0, 1, nameX, rowY, queueW - ( nameX - queueX ) - rightW, rowH )

            draw.SimpleText( 'S' .. weaponData.slot, vox.hud.fonts.ExtraTinyBold, queueX + queueW - vox.hud.ScaleWide( active and 54 or 12 ), rowY + rowH * .5, active and colorAccent or colorTertiaryText, 2, 1 )

            if ( active ) then
                draw.RoundedBox( 2, queueX + queueW - vox.hud.ScaleWide( 30 ), rowY + rowH * .5 - vox.hud.ScaleTall( 3 ), vox.hud.ScaleWide( 6 ), vox.hud.ScaleTall( 6 ), colorAccent )
            end
        end
    end

    local chipGap = vox.hud.ScaleWide( 5 )
    local chipW = ( queueW - chipGap ) * .5
    local selectLabel = selectedActive and 'EQUIPPED' or ( quickSwitchEnabled and 'AUTO' or 'SELECT' )
    draw.RoundedBox( vox.hud.ScaleTall( 4 ), queueX, controlY, chipW, controlH, ColorAlpha( colorPrimary, 150 ) )
    draw.SimpleText( 'SCROLL', vox.hud.fonts.ExtraTinyBold, queueX + chipW * .5, controlY + controlH * .5, colorSecondaryText, 1, 1 )

    draw.RoundedBox( vox.hud.ScaleTall( 4 ), queueX + chipW + chipGap, controlY, chipW, controlH, ColorAlpha( selectedActive and colorAccent or colorSecondary, selectedActive and 54 or 155 ) )
    draw.SimpleText( selectLabel, vox.hud.fonts.ExtraTinyBold, queueX + chipW + chipGap + chipW * .5, controlY + controlH * .5, selectedActive and colorAccent or colorPrimaryText, 1, 1 )

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
