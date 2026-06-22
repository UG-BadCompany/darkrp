--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

--[[

Author: tochnonement
Email: tochnonement@gmail.com

20/08/2024

--]]

local COLOR_GREEN, COLOR_RED = Color( 96, 230, 39), Color( 252, 30, 30 )
local COLOR_SHADOW = Color( 0, 0, 0, 100 )
local COLOR_FUEL = Color( 196, 88, 0)
local CONVAR_BLUR = CreateClientConVar( 'cl_onyx_hud_speedometer_blur', '1', true, false, '', 0, 1 )

local STATUS_ICONS = {
    [ 'simfphys' ] = {
        {
            id = 'parking-brake',
            icons = {
                [ 1 ] = { 
                    url = 'https://i.imgur.com/DhZNMqx.png',
                    color = Color( 255, 0, 0 )
                }
            },
            getState = function( vehicle )
                return ( vehicle:GetHandBrakeEnabled() and 1 or 0 )
            end
        },
        {
            id = 'cruise-control',
            icons = {
                [ 1 ] = { 
                    url = 'https://i.imgur.com/rSkZck6.png',
                    color = Color( 166, 255, 0)
                }
            },
            getState = function( vehicle )
                return ( vehicle:GetIsCruiseModeOn() and 1 or 0 )
            end
        },
        {
            id = 'fog-light',
            icons = {
                [ 1 ] = { 
                    url = 'https://i.imgur.com/DgPmV27.png',
                    color = Color( 255, 204, 0)
                }
            },
            getState = function( vehicle )
                return ( vehicle:GetFogLightsEnabled() and 1 or 0 )
            end
        },
        {
            id = 'low-beam',
            icons = {
                [ 1 ] = { 
                    url = 'https://i.imgur.com/ckEQdme.png',
                    color = Color( 51, 255, 0)
                },
                [ 2 ] = { 
                    url = 'https://i.imgur.com/DKVPVJd.png',
                    color = Color( 0, 38, 255)
                },
            },
            getState = function( vehicle )
                if ( vehicle:GetLightsEnabled() ) then
                    if ( vehicle:GetLampsEnabled() ) then
                        return 2
                    else
                        return 1
                    end
                else
                    return 0
                end
            end
        },
    }
}

local hud = onyx.hud
local lerpSpeed

local function drawLine( x1, y1, x2, y2, wide, color )
	local diffX, diffY = x1 - x2, y1 - y2
    local rad = math.atan2( diffX, diffY )
	local rotation = math.deg( rad )
    local height = Vector( x1, y1 ):Distance( Vector( x2, y2 ) )
	
	x1 = x1 - math.floor( diffX * .5 )
	y1 = y1 - math.floor( diffY * .5 )
	
	draw.NoTexture()
    surface.SetDrawColor( color )
	surface.DrawTexturedRectRotated( x1, y1, wide, height, rotation )
end

local function convertToMPH( kmh )
    return kmh * 0.621371
end

local function getMaxSpeed( vehicle, useMPH )
    local maxSpeed = vehicle.GetMaxSpeed and vehicle:GetMaxSpeed() or hud:GetOptionValue( 'speedometer_max_speed' )
    if ( ( maxSpeed / 10 ) % 2 ~= 0 ) then maxSpeed = maxSpeed + 10 end

    local clampedSpeed = math.min( maxSpeed, 300 )

    if ( useMPH ) then
        return math.floor( convertToMPH( clampedSpeed ) / 10 ) * 10
    else
        return clampedSpeed
    end
end

local function drawFuelHUD( element, client, vehicle, scrW, scrH, theme )
    local curFuel = vehicle:GetFuel()
    local maxFuel = vehicle:GetMaxFuel()
	local fuel = curFuel / maxFuel

    local w = hud.ScaleWide( 200 )
    local h = hud.ScaleTall( 40 )
    local x0 = scrW * .5
    local x = x0 - w * .5
    local y = scrH - h - hud.GetScreenPadding()
    local colors = theme.colors

    local horPadding = hud.ScaleTall( 10 )
    local verPadding = hud.ScaleTall( 7.5 )
    local lineW = w - horPadding * 2
    local lineH = hud.ScaleTall( 5 )
    local lineX = x + horPadding
    local lineY = y + h - lineH - verPadding
    local textY = y + verPadding * .5

    hud.DrawRoundedBox( x, y, w, h, colors.primary )
    hud.DrawRoundedBox( lineX, lineY, lineW, lineH, colors.textTertiary  )

    draw.SimpleText( onyx.lang:Get( 'fuel' ), hud.fonts.TinyBold, x + horPadding, textY, colors.textPrimary, 0, 0 )

    local textW = draw.SimpleText( ' / ' .. maxFuel, hud.fonts.Tiny, x + w - horPadding, textY, colors.textSecondary, 2, 0 )
    draw.SimpleText( math.Round( curFuel, 1 ), hud.fonts.TinyBold, x + w - horPadding - textW, textY, COLOR_FUEL, 2, 0 )

    render.SetScissorRect( lineX, lineY, lineX + lineW * fuel, lineY + lineH, true )
        hud.DrawRoundedBox( lineX, lineY, lineW, lineH, COLOR_FUEL  )
    render.SetScissorRect( 0, 0, 0, 0, false )
end

local function drawVehicleHUD( element, client, scrW, scrH )
    local cache = element.cache
    local vehicle = client:GetVehicle()
    if ( not IsValid( vehicle ) ) then return end

    local parent = vehicle:GetParent()
    if ( IsValid( parent ) ) then
        vehicle = parent
    elseif ( vehicle:GetClass() == 'prop_vehicle_prisoner_pod' ) then
        return
    end

    if ( vehicle.GetDriver == nil ) then return end
    if ( vehicle:GetDriver() ~= client ) then return end

    local isAdvanced = simfphys and simfphys.IsCar( vehicle )
    if ( isAdvanced and cvars.Bool( 'cl_simfphys_hud' ) ) then RunConsoleCommand( 'cl_simfphys_hud', 0 ) end -- we cannot just turn block their hook, because there are things beside hud (for example turn signal controls :\)
    
    local size = hud.ScaleTall( 250 )
    local screenPadding = hud.GetScreenPadding()
    local x, y = scrW - size - screenPadding, scrH - size - screenPadding
    local x0, y0 = x + size * .5, y + size * .5

    local theme = hud:GetCurrentTheme()
    local colors = theme.colors

    local outerRadius = math.floor( size * .5 )
    local innerRadius = math.floor( outerRadius * .9 )
    local arcLength = 270

    cache.outerMask = cache.outerMask or onyx.CalculateCircle( x0, y0, outerRadius + 1, 24 )
    cache.innerMask = cache.innerMask or onyx.CalculateArc( x0, y0, 180 + 45, arcLength, outerRadius + 1, 24, true )

    local outerMask = cache.outerMask
    local innerMask = cache.innerMask

    local speed = vehicle:GetVelocity():Length()
    local useMPH = hud:GetOptionValue( 'speedometer_mph' )
    local maxSpeed = getMaxSpeed( vehicle, useMPH )

    local dividers = math.floor( maxSpeed / ( useMPH and 10 or 20 ) )

    local rawSpeed = speed * .09141 * .75
    if ( useMPH ) then rawSpeed = convertToMPH( rawSpeed ) end

	local converted = math.min( maxSpeed, rawSpeed )

    lerpSpeed = Lerp( FrameTime() * 8, lerpSpeed or converted, converted )

    local circFraction = lerpSpeed / maxSpeed
    local colorLine = onyx.LerpColor( circFraction, COLOR_GREEN, COLOR_RED )

    -- Draw blur
    if ( CONVAR_BLUR:GetBool() ) then
        onyx.DrawWithPolyMask( outerMask, function()
            onyx.DrawBlurExpensive( vgui.GetWorldPanel(), 6 )
        end )
    end

    -- Draw background
    onyx.DrawCircle( x0, y0, outerRadius, ColorAlpha( colors.primary, theme.dark and 200 or 100 ) )

    local _, textH = draw.SimpleText( math.Round( lerpSpeed ), hud.fonts.Speedometer, x0, y + size, colors.textPrimary, 1, 4 )
    draw.SimpleText( useMPH and 'mph' or 'km/h', hud.fonts.SmallBold, x0, y + size - textH * .8, colors.textSecondary, 1, 4 )

    -- Draw lines & numbers
    local angStep = 270 / ( dividers )
    local lineLength = hud.ScaleTall( 15 )
    local lineCircRadius = innerRadius - 1
    local lineWidth = hud.ScaleTall( 2 )

    for index = 0, dividers do
        local curAng = angStep * index + 90 + 45
        local rad = math.rad( curAng )
        local cos, sin = math.cos( rad ), math.sin( rad )
        local raw = index * math.Round( maxSpeed / dividers )
        local value = math.Round( raw )
        local textColor = ( math.floor( lerpSpeed ) > 0 and lerpSpeed >= value ) and colorLine or colors.textSecondary
    
        drawLine( x0 + cos * lineCircRadius, y0 + sin * lineCircRadius, x0 + cos * ( lineCircRadius - lineLength ), y0 + sin * ( lineCircRadius - lineLength ), lineWidth, textColor )

        draw.SimpleText( value, hud.fonts.SmallBold, x0 + cos * innerRadius * .75 + 1, y0 + sin * innerRadius * .75 + 1, COLOR_SHADOW, 1, 1 )
        draw.SimpleText( value, hud.fonts.SmallBold, x0 + cos * innerRadius * .75, y0 + sin * innerRadius * .75, textColor, 1, 1 )
    end

    -- Draw line background
    onyx.DrawWithPolyMask( innerMask, function()
        onyx.DrawOutlinedCircle( x0, y0, innerRadius, 1, colors.textSecondary )
    end )

    -- Draw line fill
    local innerMaskFill = onyx.CalculateArc( x0, y0, 180 + 45, arcLength * circFraction, innerRadius, 24, true )

    onyx.DrawWithPolyMask( innerMaskFill, function()
        onyx.DrawOutlinedCircle( x0, y0, innerRadius, 2, colorLine )
    end )

    -- Draw additional info ( simfphys )
    if ( isAdvanced ) then
        local statusTable = STATUS_ICONS[ 'simfphys' ]

        -- it is replicated
        if ( cvars.Bool( 'sv_simfphys_fuel' ) ) then
            drawFuelHUD( element, client, vehicle, scrW, scrH, theme )
        end

        if ( LVS and LVS.HudEditorsHide ) then
            LVS.HudEditorsHide[ 'VehicleHealth' ] = true
        end

        if ( statusTable ) then
            local iconSize = hud.ScaleTall( 20 )
            local iconSpace = hud.ScaleTall( 10 )
            local amount = #statusTable
            local totalW = iconSize * 2 + iconSpace
            local totalH = iconSize * 2 + iconSpace
            local row = 0
            local column = 0

            for index, status in ipairs( statusTable ) do
                local state = status.getState( vehicle )
                local icon = status.icons[ state ] or status.icons[ 1 ]
                local url = icon.url or status.icons[ 1 ].url
                local color = state == 0 and colors.textSecondary or icon.color

                column = column + 1

                icon.wimg = icon.wimg or onyx.wimg.Simple( url, 'smooth mips' )

                icon.wimg:Draw( x0 - totalW * .5 + ( column - 1 ) * ( iconSize + iconSpace ), y0 - totalW * .5 + row * ( iconSize + iconSpace ), iconSize, iconSize, color )

                if ( column >= 2 ) then
                    row = row + 1
                    column = 0
                end
            end

        end
    
    end
end

onyx.hud:RegisterElement( 'vehicle', { 
    drawFn = drawVehicleHUD, 
    priority = 40,
    initFunc = function( element )
        element.cache = {}
    end,
    onSizeChanged = function( element )
        element.cache = {}
    end
} )

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
