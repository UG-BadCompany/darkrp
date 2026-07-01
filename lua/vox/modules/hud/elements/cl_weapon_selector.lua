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
    local pad = vox.hud.ScaleWide( 10 )
    local panelW = math.min( vox.hud.ScaleWide( 340 ), scrW - screenPadding * 2 )
    local headerH = vox.hud.ScaleTall( 24 )
    local rowH = vox.hud.ScaleTall( 36 )
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

    local rows = {}
    local selectedData = nil

    if ( #weapons > 0 and IsValid( selectedWeapon ) ) then
        selectedData = getWrappedWeaponData( weapons, selectedIndex )

        if ( #weapons > 2 ) then
            rows[ #rows + 1 ] = {
                label = 'PREV',
                data = getWrappedWeaponData( weapons, selectedIndex - 1 )
            }
        end

        rows[ #rows + 1 ] = {
            label = 'NOW',
            data = selectedData,
            current = true
        }

        if ( #weapons > 1 ) then
            rows[ #rows + 1 ] = {
                label = #weapons == 2 and 'OTHER' or 'NEXT',
                data = getWrappedWeaponData( weapons, selectedIndex + 1 )
            }
        end
    end

    local rowCount = math.max( #rows, 1 )
    local panelH = headerH + pad + rowCount * rowH + math.max( rowCount - 1, 0 ) * gap + pad
    local x = scrW - panelW - screenPadding
    local y = math.Clamp( scrH * .38 - panelH * .5, screenPadding, scrH - screenPadding - panelH )

    draw.RoundedBox( vox.hud.ScaleTall( 6 ), x, y, panelW, panelH, ColorAlpha( colorPrimary, 232 ) )
    vox.DrawMatGradient( x, y, panelW, panelH, RIGHT, ColorAlpha( colorSecondary, 46 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 95 ) )
    surface.DrawOutlinedRect( x, y, panelW, panelH, 1 )
    surface.SetDrawColor( ColorAlpha( colorAccent, 210 ) )
    surface.DrawRect( x, y + headerH, 2, panelH - headerH - pad )

    draw.SimpleText( 'SELECTOR', vox.hud.fonts.ExtraTinyBold, x + pad, y + headerH * .5, colorSecondaryText, 0, 1 )
    draw.SimpleText( #weapons > 0 and ( selectedIndex .. ' / ' .. #weapons ) or '', vox.hud.fonts.ExtraTinyBold, x + panelW - pad, y + headerH * .5, colorSecondaryText, 2, 1 )

    if ( #weapons <= 0 or not IsValid( selectedWeapon ) ) then
        local emptyY = y + headerH + pad
        draw.RoundedBox( vox.hud.ScaleTall( 4 ), x + pad, emptyY, panelW - pad * 2, rowH, ColorAlpha( colorSecondary, 130 ) )
        draw.SimpleText( 'NO WEAPONS', vox.hud.fonts.SmallBold, x + panelW * .5, emptyY + rowH * .5, colorSecondaryText, 1, 1 )
        surface.SetAlphaMultiplier( prevAlpha )
        return
    end

    local rowX = x + pad
    local rowW = panelW - pad * 2
    local rowY = y + headerH + pad
    local labelW = vox.hud.ScaleWide( 50 )
    local rightW = vox.hud.ScaleWide( 72 )

    local function drawSelectorRow( rowData, index )
        local weaponData = rowData.data
        if ( not weaponData or not IsValid( weaponData.weapon ) ) then return end

        local rowCurrent = rowData.current
        local weapon = weaponData.weapon
        local rowColor = rowCurrent and ColorAlpha( colorAccent, 54 ) or ColorAlpha( colorSecondary, 118 )
        local rowBorder = rowCurrent and ColorAlpha( colorAccent, 205 ) or ColorAlpha( colorSecondaryText, 35 )
        local currentY = rowY + ( index - 1 ) * ( rowH + gap )

        draw.RoundedBox( vox.hud.ScaleTall( 4 ), rowX, currentY, rowW, rowH, rowColor )
        surface.SetDrawColor( rowBorder )
        surface.DrawOutlinedRect( rowX, currentY, rowW, rowH, 1 )

        if ( rowCurrent ) then
            draw.RoundedBox( 2, rowX, currentY, vox.hud.ScaleWide( 4 ), rowH, colorAccent )
        end

        local labelX = rowX + vox.hud.ScaleWide( 8 )
        draw.RoundedBox( vox.hud.ScaleTall( 3 ), labelX, currentY + vox.hud.ScaleTall( 7 ), labelW, rowH - vox.hud.ScaleTall( 14 ), ColorAlpha( colorPrimary, rowCurrent and 190 or 150 ) )
        draw.SimpleText( rowCurrent and ( 'S' .. weaponData.slot ) or rowData.label, vox.hud.fonts.ExtraTinyBold, labelX + labelW * .5, currentY + rowH * .5, rowCurrent and colorPrimaryText or colorSecondaryText, 1, 1 )

        local nameX = labelX + labelW + vox.hud.ScaleWide( 10 )
        local nameW = rowW - ( nameX - rowX ) - rightW - vox.hud.ScaleWide( 10 )
        drawClippedText( getWeaponName( weapon ), rowCurrent and vox.hud.fonts.TinyBold or vox.hud.fonts.ExtraTinyBold, nameX, currentY + rowH * .5 - vox.hud.ScaleTall( rowCurrent and 5 or 0 ), rowCurrent and colorPrimaryText or colorSecondaryText, 0, 1, nameX, currentY, nameW, rowH )

        if ( rowCurrent ) then
            local statusText = selectorData.activeWeapon == weapon and getWeaponAmmoText( client, weapon ) or ( quickSwitchEnabled and 'AUTO' or 'READY' )
            draw.SimpleText( selectedData and ( 'POS ' .. selectedData.pos ) or getWeaponMetaText( weapon ), vox.hud.fonts.ExtraTinyBold, nameX, currentY + rowH - vox.hud.ScaleTall( 8 ), colorSecondaryText, 0, 1 )
            draw.SimpleText( statusText, vox.hud.fonts.ExtraTinyBold, rowX + rowW - vox.hud.ScaleWide( 10 ), currentY + rowH * .5, colorAccent, 2, 1 )
        else
            draw.SimpleText( 'S' .. weaponData.slot, vox.hud.fonts.ExtraTinyBold, rowX + rowW - vox.hud.ScaleWide( 10 ), currentY + rowH * .5, colorTertiaryText, 2, 1 )
        end
    end

    for index, rowData in ipairs( rows ) do
        drawSelectorRow( rowData, index )
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
