local hud = vox.hud
local cache = {}

local COLOR_BAR = Color( 0, 0, 0, 200 ) -- Only for light themes
local FONT_TEXT = 'vox.hud.Small'
local NOTIFICATION_TYPES = {
    [ NOTIFY_GENERIC ] = {
        colorKey = 'hunger',
        wimg = vox.wimg.Simple( 'https://i.imgur.com/2muiD5k.png', 'smooth mips' )
    },
    [ NOTIFY_ERROR ] = {
        colorKey = 'negative',
        wimg = vox.wimg.Simple( 'https://i.imgur.com/vNzFBlK.png', 'smooth mips' )
    },
    [ NOTIFY_UNDO ] = {
        colorKey = 'positive',
        wimg = vox.wimg.Simple( 'https://i.imgur.com/sgLeDjb.png', 'smooth mips' )
    },
    [ NOTIFY_HINT ] = {
        colorKey = 'accent',
        wimg = vox.wimg.Simple( 'https://i.imgur.com/vAjbKzK.png', 'smooth mips' )
    },
    [ NOTIFY_CLEANUP ] = {
        colorKey = 'secondaryAccent',
        wimg = vox.wimg.Simple( 'https://i.imgur.com/V3TyKJ9.png', 'smooth mips' )
    },
}

local function addNotification( text, type, length )
    table.insert( cache, 1, {
        text = text,
        type = type,
        endtime = CurTime() + length,
        duration = length
    } )
end

local function overrideNotifications()
    hud.original_AddLegacy = hud.original_AddLegacy or notification.AddLegacy

    function notification.AddLegacy( text, type, length )
        local text = tostring( text )
        local type = type or NOTIFY_GENERIC
        local length = length or 3
        local isEnabled = vox.hud.IsElementEnabled( 'notifications' )

        if ( isEnabled ) then
            addNotification( text:Trim():gsub('\n', ' '), type, length )
        else
            hud.original_AddLegacy( text, type, length )
        end
    end
end
vox.hud.OverrideGamemode( 'vox.hud.OverrideNotifications', overrideNotifications )

local function drawNotifications( self, client, scrW, scrH )
    local theme = hud:GetCurrentTheme()
    local colorPrimary = theme.colors.primary
    local colorSecondary = theme.colors.secondary
    local colorTertiary = theme.colors.tertiary
    local colorText = theme.colors.textPrimary
    local isDark = theme.dark

    local space = vox.hud.GetScreenPadding()
    local horPadding = vox.hud.ScaleTall( 10 )
    local notifH = vox.hud.ScaleTall( 46 )
    local hudRoundness = vox.hud.GetRoundness()
    local notifSpace = vox.hud.ScaleTall( 5 )
    local iconSpace = vox.hud.ScaleTall( 10 )
    local iconSize = vox.hud.ScaleTall( 18 )
    local lineH = vox.hud.ScaleTall( 2 )

    local amount = #cache
    local posY = scrH * .75
    local speed = FrameTime() * 8

    -- to avoid overlapping
    if ( #vox.hud.VoicePanels > 0 ) then
        for _, data in ipairs( vox.hud.VoicePanels ) do
            local panel = data.panel
            if ( IsValid( panel ) and panel:IsVisible() ) then
                posY = math.min( posY, select( 2, panel:GetPos() ) )
            end
        end
        posY = posY - notifSpace
    end

    posY = posY - notifH

    for index = 1, amount do
        local data = cache[ index ]
        if ( not data ) then continue end

        local notifText = data.text
        local notifType = data.type or 0
        local notifTypeData = NOTIFICATION_TYPES[ notifType ] or NOTIFICATION_TYPES[ NOTIFY_GENERIC ]
        local notifColor = colors[ notifTypeData.colorKey or 'accent' ] or colors.accent
        local timeLeft = math.max( 0, data.endtime - CurTime() )
        local lifeFraction = timeLeft / data.duration
        local expired = lifeFraction == 0
        local targetFraction = expired and 0 or 1
        local wimgObject = notifTypeData.wimg

        -- Get size
        surface.SetFont( FONT_TEXT )
        local textW, textH = surface.GetTextSize( notifText )
        local notifW = math.Clamp( textW + horPadding * 2 + iconSize + iconSpace + vox.hud.ScaleWide( 18 ), vox.hud.ScaleWide( 260 ), vox.hud.ScaleWide( 420 ) )

        -- Calculate pos
        local posX = expired and scrW or ( scrW - notifW - space )

        data.x = Lerp( speed, data.x or scrW, posX )
        data.y = Lerp( speed, data.y or posY, posY )
        data.fraction = math.Approach( data.fraction or 0, targetFraction, speed )

        local x = data.x
        local y = math.ceil( data.y )

        -- Draw
        local prevAlpha = surface.GetAlphaMultiplier()
        local lineColor = isDark and ColorAlpha( notifColor, 20 ) or COLOR_BAR

        surface.SetAlphaMultiplier( data.fraction )

            if vox.DrawVoxCard then
                vox.DrawVoxCard( x, y, notifW, notifH, colors, { accent = notifColor, radius = hudRoundness, bladeWidth = vox.hud.ScaleWide( 6 ) } )
            elseif vox.DrawVoxPanel then
                vox.DrawVoxPanel( x, y, notifW, notifH, colors, hudRoundness )
            else
                vox.hud.DrawRoundedBox( x, y, notifW, notifH, colorPrimary )
            end

            wimgObject:Draw( x + horPadding + vox.hud.ScaleWide( 6 ), y + notifH * .5 - iconSize * .5, iconSize, iconSize, notifColor )

            render.SetScissorRect( x, y + notifH - lineH, x + notifW, y + notifH, true )
                vox.hud.DrawRoundedBox( x, y, notifW, notifH, lineColor )
            render.SetScissorRect( x, y + notifH - lineH, x + notifW * lifeFraction, y + notifH, true )
                vox.hud.DrawRoundedBox( x, y, notifW, notifH, notifColor )
            render.SetScissorRect( 0, 0, 0, 0, false )

            vox.hud.DrawCheapText( 'VOX UI', FONT_TEXT, x + horPadding + iconSize + iconSpace + vox.hud.ScaleWide( 6 ), y + vox.hud.ScaleTall( 7 ), ColorAlpha( notifColor, 220 ) )
            vox.hud.DrawCheapText( notifText, FONT_TEXT, x + horPadding + iconSize + iconSpace + vox.hud.ScaleWide( 6 ), y + notifH - vox.hud.ScaleTall( 8 ) - textH, colorText )

        surface.SetAlphaMultiplier( prevAlpha )

        posY = posY - notifH - notifSpace

        if ( expired and data.fraction == 0 ) then
            table.remove( cache, index )
        end
    end
end

vox.hud:RegisterElement( 'notifications', {
    priority = 90,
    drawFn = drawNotifications,
    hideElements = {}
} )

concommand.Add( 'vox_hud_test_notifications', function( ply )
    if ( ply:IsAdmin() ) then
        local index = 0
        for type in pairs( NOTIFICATION_TYPES ) do
            index = index + 1
            notification.AddLegacy( 'Vox HUD Notification', type, 10 - index )
        end
    end
end )
