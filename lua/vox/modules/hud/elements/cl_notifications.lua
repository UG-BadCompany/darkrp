local hud = vox.hud
local cache = {}
hud.notificationCache = cache

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
    local data = {
        text = text,
        type = type,
        endtime = CurTime() + length,
        duration = length
    }

    table.insert( cache, 1, data )
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

local NOTIF_TITLES = {
    [ NOTIFY_GENERIC ] = 'New Announcement',
    [ NOTIFY_ERROR ] = 'Wanted Level',
    [ NOTIFY_UNDO ] = 'Money Received',
    [ NOTIFY_HINT ] = 'New Announcement',
    [ NOTIFY_CLEANUP ] = 'Cleanup'
}

local function drawNotifications( self, client, scrW, scrH )
    local theme = hud:GetCurrentTheme()
    local colors = ( theme and theme.colors ) or {}
    local colorPrimary = colors.primary or Color( 3, 11, 24 )
    local colorSecondary = colors.secondary or Color( 8, 27, 52 )
    local colorText = colors.textPrimary or color_white
    local colorMuted = colors.textSecondary or Color( 145, 172, 200 )

    local space = vox.hud.GetScreenPadding()
    local notifW = vox.hud.ScaleWide( 278 )
    local notifH = vox.hud.ScaleTall( 58 )
    local notifSpace = vox.hud.ScaleTall( 8 )
    local iconSize = vox.hud.ScaleTall( 32 )
    local x = scrW - notifW - space
    local posY = scrH * .28
    local speed = FrameTime() * 8

    if ( #cache > 0 ) then
        draw.SimpleText( 'NOTIFICATIONS', vox.hud.fonts.ExtraTinyBold, x + vox.hud.ScaleWide( 6 ), posY - vox.hud.ScaleTall( 12 ), colorText, 0, 1 )
    end

    for index = 1, #cache do
        local data = cache[ index ]
        if ( not data ) then continue end

        local notifType = data.type or 0
        local notifTypeData = NOTIFICATION_TYPES[ notifType ] or NOTIFICATION_TYPES[ NOTIFY_GENERIC ]
        local notifColor = colors[ notifTypeData.colorKey or 'accent' ] or colors.accent or Color( 0, 174, 255 )
        local timeLeft = math.max( 0, data.endtime - CurTime() )
        local lifeFraction = timeLeft / data.duration
        local expired = lifeFraction == 0
        local targetFraction = expired and 0 or 1

        data.x = Lerp( speed, data.x or ( scrW + notifW ), expired and scrW or x )
        data.y = Lerp( speed, data.y or posY, posY )
        data.fraction = math.Approach( data.fraction or 0, targetFraction, speed )

        local y = math.ceil( data.y )
        local prevAlpha = surface.GetAlphaMultiplier()
        surface.SetAlphaMultiplier( data.fraction )
            draw.RoundedBox( vox.hud.ScaleTall( 8 ), data.x, y, notifW, notifH, ColorAlpha( colorPrimary, 235 ) )
            vox.DrawMatGradient( data.x, y, notifW, notifH, RIGHT, ColorAlpha( notifColor, 28 ) )
            surface.SetDrawColor( ColorAlpha( notifColor, 115 ) )
            surface.DrawOutlinedRect( data.x, y, notifW, notifH, 1 )
            draw.RoundedBox( vox.hud.ScaleTall( 6 ), data.x + vox.hud.ScaleWide( 10 ), y + notifH * .5 - iconSize * .5, iconSize, iconSize, ColorAlpha( notifColor, 38 ) )
            if notifTypeData.wimg and notifTypeData.wimg.Draw then
                notifTypeData.wimg:Draw( data.x + vox.hud.ScaleWide( 18 ), y + notifH * .5 - vox.hud.ScaleTall( 8 ), vox.hud.ScaleTall( 16 ), vox.hud.ScaleTall( 16 ), notifColor )
            end
            draw.SimpleText( NOTIF_TITLES[ notifType ] or 'Notification', vox.hud.fonts.ExtraTinyBold, data.x + vox.hud.ScaleWide( 54 ), y + vox.hud.ScaleTall( 18 ), colorText, 0, 1 )
            draw.SimpleText( data.text, FONT_TEXT, data.x + vox.hud.ScaleWide( 54 ), y + vox.hud.ScaleTall( 36 ), colorMuted, 0, 1 )
            draw.SimpleText( index == 1 and 'now' or ( math.ceil( ( data.duration - timeLeft ) / 60 ) .. 'm ago' ), vox.hud.fonts.ExtraTinyBold, data.x + notifW - vox.hud.ScaleWide( 10 ), y + vox.hud.ScaleTall( 17 ), colorMuted, 2, 1 )
            draw.RoundedBox( 2, data.x, y + notifH - 2, notifW * lifeFraction, 2, ColorAlpha( notifColor, 185 ) )
        surface.SetAlphaMultiplier( prevAlpha )

        posY = posY + notifH + notifSpace
        if ( expired and data.fraction == 0 ) then table.remove( cache, index ) end
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
