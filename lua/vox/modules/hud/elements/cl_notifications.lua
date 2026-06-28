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

local function getTextSize( font, text )
    surface.SetFont( font )
    return surface.GetTextSize( tostring( text or '' ) )
end

local function getWrappedText( data, key, text, font, maxW )
    text = tostring( text or '' )
    maxW = math.floor( maxW or 0 )

    if ( data[ key ] ~= text or data[ key .. 'MaxW' ] ~= maxW ) then
        data[ key ] = text
        data[ key .. 'MaxW' ] = maxW
        data[ key .. 'Wrapped' ] = DarkRP and DarkRP.textWrap and DarkRP.textWrap( text, font, maxW ) or text
    end

    return data[ key .. 'Wrapped' ]
end

local function drawNotifications( self, client, scrW, scrH )
    local theme = hud:GetCurrentTheme()
    local colors = ( theme and theme.colors ) or {}
    local colorPrimary = colors.primary or Color( 3, 11, 24 )
    local colorSecondary = colors.secondary or Color( 8, 27, 52 )
    local colorText = colors.textPrimary or color_white
    local colorMuted = colors.textSecondary or Color( 145, 172, 200 )

    local space = vox.hud.GetScreenPadding()
    local availableW = math.max( vox.hud.ScaleWide( 220 ), scrW - space * 2 )
    local minNotifW = math.min( vox.hud.ScaleWide( 278 ), availableW )
    local maxNotifW = math.max( minNotifW, math.min( vox.hud.ScaleWide( 430 ), availableW ) )
    local minNotifH = vox.hud.ScaleTall( 58 )
    local notifSpace = vox.hud.ScaleTall( 8 )
    local iconSize = vox.hud.ScaleTall( 32 )
    local posY = scrH * .28
    local speed = FrameTime() * 8

    if ( #cache > 0 ) then
        draw.SimpleText( 'NOTIFICATIONS', vox.hud.fonts.ExtraTinyBold, scrW - minNotifW - space + vox.hud.ScaleWide( 6 ), posY - vox.hud.ScaleTall( 12 ), colorText, 0, 1 )
    end

    for index = 1, #cache do
        local data = cache[ index ]
        if ( not data ) then continue end

        local notifType = data.type or 0
        local notifTypeData = NOTIFICATION_TYPES[ notifType ] or NOTIFICATION_TYPES[ NOTIFY_GENERIC ]
        local notifColor = colors[ notifTypeData.colorKey or 'accent' ] or colors.accent or Color( 0, 174, 255 )
        local timeLeft = math.max( 0, data.endtime - CurTime() )
        local lifeFraction = timeLeft / math.max( data.duration or 0, .01 )
        local expired = lifeFraction == 0
        local targetFraction = expired and 0 or 1
        local title = NOTIF_TITLES[ notifType ] or 'Notification'
        local rawText = tostring( data.text or '' )
        local timeText = index == 1 and 'now' or ( math.ceil( ( ( data.duration or 0 ) - timeLeft ) / 60 ) .. 'm ago' )
        local contentX = vox.hud.ScaleWide( 54 )
        local rightPad = math.max( vox.hud.ScaleWide( 20 ), select( 1, getTextSize( vox.hud.fonts.ExtraTinyBold, timeText ) ) + vox.hud.ScaleWide( 18 ) )
        local contentMaxW = math.max( vox.hud.ScaleWide( 120 ), maxNotifW - contentX - rightPad )
        local contentMinW = math.max( vox.hud.ScaleWide( 120 ), minNotifW - contentX - rightPad )
        local titleW, titleH = getTextSize( vox.hud.fonts.ExtraTinyBold, title )
        local rawTextW = getTextSize( FONT_TEXT, rawText )
        local contentW = math.Clamp( math.max( titleW, rawTextW ), contentMinW, contentMaxW )
        local notifW = math.Clamp( contentX + contentW + rightPad, minNotifW, maxNotifW )
        local textW = math.max( vox.hud.ScaleWide( 80 ), notifW - contentX - rightPad )
        local wrappedText = getWrappedText( data, 'voxHudText', rawText, FONT_TEXT, textW )
        local _, lineH = getTextSize( FONT_TEXT, 'Ay' )
        local lineCount = math.max( 1, select( 2, wrappedText:gsub( '\n', '\n' ) ) + 1 )
        local bodyH = lineH * lineCount
        local topPad = vox.hud.ScaleTall( 10 )
        local bodyY = topPad + titleH + vox.hud.ScaleTall( 2 )
        local notifH = math.max( minNotifH, bodyY + bodyH + vox.hud.ScaleTall( 10 ) )
        local x = scrW - notifW - space

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
            draw.SimpleText( title, vox.hud.fonts.ExtraTinyBold, data.x + contentX, y + topPad, colorText, 0, 0 )
            render.SetScissorRect( data.x + contentX, y + bodyY, data.x + contentX + textW, y + notifH - vox.hud.ScaleTall( 8 ), true )
                draw.DrawText( wrappedText, FONT_TEXT, data.x + contentX, y + bodyY, colorMuted, 0 )
            render.SetScissorRect( 0, 0, 0, 0, false )
            draw.SimpleText( timeText, vox.hud.fonts.ExtraTinyBold, data.x + notifW - vox.hud.ScaleWide( 10 ), y + topPad + titleH * .5, colorMuted, 2, 1 )
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
