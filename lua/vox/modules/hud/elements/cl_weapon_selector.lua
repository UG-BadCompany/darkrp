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

    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local colorPrimary = colors.primary
    local colorSecondary = colors.secondary
    local colorTertiary = colors.tertiary
    local colorAccent = colors.accent
    local colorPrimaryText = colors.textPrimary
    local colorSecondaryText = colors.textSecondary
    local colorTertiaryText = colors.textTertiary

    local prevAlpha = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier( toggleFraction )

    local screenPadding = vox.hud.GetScreenPadding()
    local slotW = vox.hud.ScaleWide( 126 )
    local slotH = vox.hud.ScaleTall( 96 )
    local titleH = vox.hud.ScaleTall( 22 )
    local totalW = slotW * MAX_SLOTS
    local x = scrW * .5 - totalW * .5
    local y = screenPadding + vox.hud.ScaleTall( 10 )

    draw.SimpleText( 'WEAPON SELECTOR', vox.hud.fonts.SmallBold, x, y - vox.hud.ScaleTall( 7 ), colorPrimaryText, 0, 1 )
    vox.DrawVoxPanel( x, y + titleH, totalW, slotH, { primary = ColorAlpha( colorPrimary, 238 ), secondary = colorSecondary, tertiary = colorTertiary, accent = colorAccent }, vox.hud.ScaleTall( 5 ) )

    for slotIndex = 1, MAX_SLOTS do
        local slotWeapons = slotsCache[ slotIndex ] or {}
        local wep = slotWeapons[ math.Clamp( selectorData.selectedPos or 1, 1, math.max( #slotWeapons, 1 ) ) ] or slotWeapons[ 1 ]
        local sx = x + ( slotIndex - 1 ) * slotW
        local selected = selectorData.selectedSlot == slotIndex and IsValid( wep )
        local active = IsValid( wep ) and selectorData.activeWeapon == wep

        if ( selected ) then
            draw.RoundedBox( vox.hud.ScaleTall( 5 ), sx + 2, y + titleH + 2, slotW - 4, slotH - 4, ColorAlpha( colorAccent, 72 ) )
            surface.SetDrawColor( ColorAlpha( colorAccent, 190 ) )
            surface.DrawOutlinedRect( sx + 2, y + titleH + 2, slotW - 4, slotH - 4, 1 )
            draw.RoundedBox( 2, sx + 2, y + titleH + 2, slotW - 4, 3, colorAccent )
        elseif ( active ) then
            draw.RoundedBox( vox.hud.ScaleTall( 5 ), sx + 4, y + titleH + 4, slotW - 8, slotH - 8, ColorAlpha( colorAccent, 28 ) )
        end

        draw.SimpleText( slotIndex, vox.hud.fonts.TinyBold, sx + vox.hud.ScaleWide( 12 ), y + titleH + vox.hud.ScaleTall( 14 ), IsValid( wep ) and colorPrimaryText or colorTertiaryText, 0, 1 )

        if ( IsValid( wep ) ) then
            drawWeaponIcon( wep, sx + vox.hud.ScaleWide( 26 ), y + titleH + vox.hud.ScaleTall( 14 ), slotW - vox.hud.ScaleWide( 52 ), vox.hud.ScaleTall( 38 ), 255 )
            draw.SimpleText( getWeaponName( wep ), vox.hud.fonts.TinyBold, sx + slotW * .5, y + titleH + vox.hud.ScaleTall( 70 ), selected and colorPrimaryText or colorSecondaryText, 1, 1 )
            draw.SimpleText( getWeaponAmmoText( client, wep ), vox.hud.fonts.ExtraTinyBold, sx + slotW * .5, y + titleH + vox.hud.ScaleTall( 84 ), selected and colorPrimaryText or colorSecondaryText, 1, 1 )
        end

        if ( slotIndex < MAX_SLOTS ) then
            surface.SetDrawColor( ColorAlpha( colorSecondaryText, 35 ) )
            surface.DrawLine( sx + slotW, y + titleH + vox.hud.ScaleTall( 10 ), sx + slotW, y + titleH + slotH - vox.hud.ScaleTall( 10 ) )
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
        elseif ( bind == '+attack' and not quickSwitchEnabled ) then
            if ( toggleState ) then
                selectWeapon()
                return true
            end
        elseif ( not ply:KeyDown( IN_ATTACK ) ) then
            if ( bind == 'invprev' ) then
                scrollWeapons( -1 )
            elseif ( bind == 'invnext' ) then
                scrollWeapons( 1 )
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
