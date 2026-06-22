--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/08/2024

--]]

local TYPE_AMMO = 0
local TYPE_WEAPON = 1
local TYPE_ITEM = 2
local HOLD_DURATION = 3

local hud = vox.hud
local history = {}

-- Colors inspired by the original UI, so it would be easy to adapt for players
local TYPES = {
    [ TYPE_AMMO ] = Color( 107, 136, 255 ),
    [ TYPE_ITEM ] = Color( 107, 255, 166 ),
    [ TYPE_WEAPON ] = Color( 255, 198, 107),
}

local MAX_RECORDS = 10

local function addRecord( name, type, amount )
    table.insert( history, 1, {
        name = name,
        amount = amount,
        endtime = CurTime() + HOLD_DURATION,
        duration = HOLD_DURATION,
        type = type,
        color = TYPES[ type ],
        fraction = 0
    } )

    if ( #history > MAX_RECORDS ) then
        table.remove( history, ( MAX_RECORDS + 1 ) )
    end
end

hook.Add( 'vox.inconfig.Updated', 'vox.hud.ClearPickupHistory', function( id, old, new )
    if ( id and id == 'hud_display_pickup_history' ) then
        history = {}
    end
end )

hook.Add( 'HUDAmmoPickedUp', 'vox.hud.InsertPickupHistory', function( ammoID, amount )
    if ( vox.hud:GetOptionValue( 'display_pickup_history' ) ) then
        local niceName = language.GetPhrase( string.format( '#%s_ammo', ammoID ) )

        for _, record in ipairs( history ) do
            if ( record.name == niceName ) then
                record.endtime = CurTime() + HOLD_DURATION
                record.fraction = 0
                record.amount = record.amount + amount
                return true
            end
        end

        addRecord( niceName, TYPE_AMMO, amount )
    end

    return true
end )

hook.Add( 'HUDWeaponPickedUp', 'vox.hud.InsertPickupHistory', function( weapon )
    -- lol I have encountered a really weird bug when physgun_beam is passed here
    if ( IsValid( weapon ) and weapon:IsWeapon() and vox.hud:GetOptionValue( 'display_pickup_history' ) ) then
        addRecord( language.GetPhrase( weapon:GetPrintName() ), TYPE_WEAPON, 1 )
    end
    return true
end )

hook.Add( 'HUDItemPickedUp', 'vox.hud.InsertPickupHistory', function( itemName )
    if ( vox.hud:GetOptionValue( 'display_pickup_history' ) ) then
        addRecord( language.GetPhrase( itemName ), TYPE_ITEM, 1 )
    end

    return true
end )

hook.Add( 'HUDDrawPickupHistory', 'vox.hud.DrawPickupHistory', function()
    if ( #history == 0 ) then return true end
    if ( not vox.hud:GetOptionValue( 'display_pickup_history' ) ) then return true end

    local scrW = ScrW()
    local scrH = ScrH()

    local screenPadding = vox.hud.GetScreenPadding() * 0.5
    local baseY = scrH * .5
    local baseX = scrW - screenPadding

    local colorPrimary = vox.hud:GetColor( 'primary' )
    local colorPrimaryText = vox.hud:GetColor( 'textPrimary' )

    local recordW = hud.ScaleWide( 140 )
    local recordH = hud.ScaleTall( 22 )
    local recordSpace = hud.ScaleTall( 5 )
    local lineW = hud.ScaleWide( 5 )
    local padding = hud.ScaleTall( 5 )
    local posY = baseY

    for index, record in ipairs( history ) do
        local isExpired = record.endtime <= CurTime()
        local targetFraction = isExpired and 0 or 1
        local amount = record.amount

        record.fraction = math.Approach( record.fraction, targetFraction, FrameTime() * 8 )

        local posX = baseX - recordW

        record.x = Lerp( record.fraction, ScrW(), posX )
        record.y = Lerp( FrameTime() * 16, record.y or posY, posY )
        local x, y = record.x, record.y

        local prevAlpha = surface.GetAlphaMultiplier()

        surface.SetAlphaMultiplier( record.fraction )

            hud.DrawRoundedBox( x, y, recordW, recordH, colorPrimary )

            render.SetScissorRect( x, y, x + lineW, y + recordH, true )
                hud.DrawRoundedBox( x, y, recordW, recordH, record.color )
            render.SetScissorRect( 0, 0, 0, 0, false )

            draw.SimpleText( record.name, vox.hud.fonts.TinyBold, x + padding + lineW, y + recordH * .5, colorPrimaryText, 0, 1 )

            if ( amount > 1 ) then
                draw.SimpleText( amount, vox.hud.fonts.TinyBold, x + recordW - padding, y + recordH * .5, colorPrimaryText, 2, 1 )
            end

        surface.SetAlphaMultiplier( prevAlpha )

        posY = posY - recordH - recordSpace

        if ( isExpired and record.fraction == 0 ) then
            table.remove( history, index )
        end
    end

    return true
end )
