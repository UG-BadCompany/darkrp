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
    local targetSlotW = vox.hud.ScaleWide( 126 )
    local titleH = vox.hud.ScaleTall( 24 )
    local previewH = vox.hud.ScaleTall( 62 )
    local headerH = vox.hud.ScaleTall( 26 )
    local rowH = vox.hud.ScaleTall( 32 )
    local gap = vox.hud.ScaleTall( 3 )
    local totalW = math.min( targetSlotW * MAX_SLOTS, scrW - screenPadding * 2 )
    local slotW = math.floor( totalW / MAX_SLOTS )
    totalW = slotW * MAX_SLOTS
    local x = scrW * .5 - totalW * .5
    local y = screenPadding + vox.hud.ScaleTall( 10 )
    local selectedWeapon = getSelectedWeapon()

    local maxRows = 0
    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ] or {}
        maxRows = math.max( maxRows, #slotWeapons )
    end

    local columnH = headerH + math.max( maxRows, 1 ) * rowH + math.max( maxRows - 1, 0 ) * gap
    local panelY = y + titleH
    local panelH = previewH + gap + columnH

    draw.SimpleText( 'WEAPON SELECTOR', vox.hud.fonts.SmallBold, x, y - vox.hud.ScaleTall( 7 ), colorPrimaryText, 0, 1 )
    draw.SimpleText( quickSwitchEnabled and 'FAST SWITCH' or 'SCROLL TO SELECT', vox.hud.fonts.ExtraTinyBold, x + totalW, y - vox.hud.ScaleTall( 7 ), colorSecondaryText, 2, 1 )

    draw.RoundedBox( vox.hud.ScaleTall( 5 ), x, panelY, totalW, panelH, ColorAlpha( colorPrimary, 44 ) )
    vox.DrawMatGradient( x, panelY, totalW, panelH, RIGHT, ColorAlpha( colorAccent, 18 ) )
    vox.DrawMatGradient( x, panelY, totalW, panelH, BOTTOM, ColorAlpha( colorTertiary, 34 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 95 ) )
    surface.DrawOutlinedRect( x, panelY, totalW, panelH, 1 )

    local previewX = x + vox.hud.ScaleWide( 8 )
    local previewY = panelY + vox.hud.ScaleTall( 7 )
    local previewW = totalW - vox.hud.ScaleWide( 16 )
    local previewInnerH = previewH - vox.hud.ScaleTall( 12 )
    draw.RoundedBox( vox.hud.ScaleTall( 5 ), previewX, previewY, previewW, previewInnerH, ColorAlpha( colorSecondary, 142 ) )
    surface.SetDrawColor( ColorAlpha( colorAccent, 45 ) )
    surface.DrawOutlinedRect( previewX, previewY, previewW, previewInnerH, 1 )

    if ( IsValid( selectedWeapon ) ) then
        local iconSize = math.min( vox.hud.ScaleTall( 44 ), previewInnerH - vox.hud.ScaleTall( 8 ) )
        local iconX = previewX + vox.hud.ScaleWide( 12 )
        local iconY = previewY + previewInnerH * .5 - iconSize * .5
        draw.RoundedBox( vox.hud.ScaleTall( 4 ), iconX - vox.hud.ScaleWide( 4 ), iconY - vox.hud.ScaleTall( 4 ), iconSize + vox.hud.ScaleWide( 8 ), iconSize + vox.hud.ScaleTall( 8 ), ColorAlpha( colorAccent, 26 ) )
        drawWeaponIcon( selectedWeapon, iconX, iconY, iconSize, iconSize, 255 )

        local textX = iconX + iconSize + vox.hud.ScaleWide( 18 )
        local textW = previewW - ( textX - previewX ) - vox.hud.ScaleWide( 150 )
        draw.SimpleText( 'SELECTED', vox.hud.fonts.ExtraTinyBold, textX, previewY + vox.hud.ScaleTall( 10 ), colorSecondaryText, 0, 0 )
        drawClippedText( getWeaponName( selectedWeapon ), vox.hud.fonts.SmallBold, textX, previewY + vox.hud.ScaleTall( 29 ), colorPrimaryText, 0, 1, textX, previewY + vox.hud.ScaleTall( 22 ), math.max( textW, vox.hud.ScaleWide( 80 ) ), vox.hud.ScaleTall( 22 ) )
        draw.SimpleText( getWeaponMetaText( selectedWeapon ), vox.hud.fonts.ExtraTinyBold, textX, previewY + previewInnerH - vox.hud.ScaleTall( 9 ), colorSecondaryText, 0, 1 )

        local ammoText = getWeaponAmmoText( client, selectedWeapon )
        draw.SimpleText( ammoText, vox.hud.fonts.SmallBold, previewX + previewW - vox.hud.ScaleWide( 16 ), previewY + vox.hud.ScaleTall( 21 ), colorPrimaryText, 2, 1 )
        draw.SimpleText( selectedWeapon == selectorData.activeWeapon and 'EQUIPPED' or 'READY', vox.hud.fonts.ExtraTinyBold, previewX + previewW - vox.hud.ScaleWide( 16 ), previewY + previewInnerH - vox.hud.ScaleTall( 12 ), selectedWeapon == selectorData.activeWeapon and colorAccent or colorSecondaryText, 2, 1 )
    else
        draw.SimpleText( 'NO WEAPON SELECTED', vox.hud.fonts.SmallBold, previewX + previewW * .5, previewY + previewInnerH * .5, colorSecondaryText, 1, 1 )
    end

    local columnsY = panelY + previewH + gap
    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ] or {}
        local sx = x + ( slotIndex - 1 ) * slotW
        local slotY = columnsY

        draw.SimpleText( 'S' .. slotIndex, vox.hud.fonts.SmallBold, sx + vox.hud.ScaleWide( 10 ), slotY + headerH * .5, #slotWeapons > 0 and colorPrimaryText or colorTertiaryText, 0, 1 )
        draw.SimpleText( tostring( #slotWeapons ), vox.hud.fonts.ExtraTinyBold, sx + slotW - vox.hud.ScaleWide( 12 ), slotY + headerH * .5, #slotWeapons > 0 and colorSecondaryText or colorTertiaryText, 2, 1 )
        slotY = slotY + headerH

        for index, wep in ipairs( slotWeapons ) do
            if ( IsValid( wep ) ) then
                local selected = selectorData.selectedSlot == slotIndex and index == selectorData.selectedPos
                local active = selectorData.activeWeapon == wep
                local rowX = sx + vox.hud.ScaleWide( 3 )
                local rowW = slotW - vox.hud.ScaleWide( 6 )
                local rowColor = selected and ColorAlpha( colorAccent, 62 ) or ColorAlpha( active and colorAccent or colorSecondary, active and 32 or 112 )
                local rowBorder = selected and ColorAlpha( colorAccent, 180 ) or ColorAlpha( active and colorAccent or colorSecondaryText, active and 110 or 30 )

                draw.RoundedBox( vox.hud.ScaleTall( 4 ), rowX, slotY, rowW, rowH, rowColor )
                surface.SetDrawColor( rowBorder )
                surface.DrawOutlinedRect( rowX, slotY, rowW, rowH, 1 )

                if ( selected ) then
                    draw.RoundedBox( 2, rowX, slotY, vox.hud.ScaleWide( 4 ), rowH, colorAccent )
                end

                if ( active ) then
                    draw.RoundedBox( 2, rowX + rowW - vox.hud.ScaleWide( 8 ), slotY + rowH * .5 - vox.hud.ScaleTall( 3 ), vox.hud.ScaleWide( 6 ), vox.hud.ScaleTall( 6 ), colorAccent )
                end

                local textX = rowX + vox.hud.ScaleWide( selected and 11 or 7 )
                local textW = rowW - vox.hud.ScaleWide( active and 20 or 12 ) - ( textX - rowX )
                drawClippedText( getWeaponName( wep ), selected and vox.hud.fonts.TinyBold or vox.hud.fonts.ExtraTinyBold, textX, slotY + rowH * .5, selected and colorPrimaryText or ( active and colorPrimaryText or colorSecondaryText ), 0, 1, textX, slotY, textW, rowH )

                slotY = slotY + rowH + gap
            end
        end

        if ( slotIndex < MAX_SLOTS ) then
            surface.SetDrawColor( ColorAlpha( colorSecondaryText, 35 ) )
            surface.DrawLine( sx + slotW, columnsY + vox.hud.ScaleTall( 8 ), sx + slotW, columnsY + columnH - vox.hud.ScaleTall( 8 ) )
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
