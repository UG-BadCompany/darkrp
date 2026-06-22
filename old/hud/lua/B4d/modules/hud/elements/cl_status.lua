--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

--[[

Author: tochnonement
Email: tochnonement@gmail.com

18/08/2024

--]]

local hud = onyx.hud
local arrestEndTime

local L = function( ... ) return onyx.lang:Get( ... ) end
local WIMG_LOCKDOWN = onyx.wimg.Create( 'hud_lockdown', 'smooth mips' )
local WIMG_WANTED = onyx.wimg.Create( 'hud_wanted', 'smooth mips' )
local WIMG_ARRESTED = onyx.wimg.Create( 'hud_arrested', 'smooth mips' )

local function drawLabel( x, y, w, h, padding, wimg, title, desc, color )
    local x0, y0 = x + w * .5, y + h * .5
    local iconSize = h - padding * 2

    hud.DrawRoundedBox( x, y, w, h, hud:GetColor( 'primary' ) )

    wimg:Draw( x + padding, y + padding, iconSize, iconSize, ColorAlpha( color, 100 + 155 * math.abs( math.sin( CurTime() * 4 ) ) ) )

    draw.SimpleText( title, hud.fonts.TinyBold, x + padding * 2 + iconSize, y0, color, 0, 4 )
    draw.SimpleText( desc, hud.fonts.Tiny, x + padding * 2 + iconSize, y0, hud:GetColor( 'textSecondary' ), 0, 0 )
end

hud:RegisterElement( 'status', { 
    height = 120,
    priority = 60,
    drawFn = function( element, client, scrW, scrH )
        local parent = onyx.hud.elements[ 'agenda' ]
        local screenPadding = hud.GetScreenPadding()
        local padding = hud.ScaleTall( parent.padding )
        local w = hud.ScaleWide( parent.width )
        local h = hud.ScaleTall( 50 )
        local space = hud.ScaleTall( 7.5 )

        local x, y = scrW - w - screenPadding, screenPadding
        if ( parent.active ) then
            y = y + hud.ScaleTall( parent.height ) + space
        end

        if ( GetGlobalBool( 'DarkRP_LockDown' ) ) then
            drawLabel( x, y, w, h, padding, WIMG_LOCKDOWN, L( 'hud_lockdown' ), L( 'hud_lockdown_help' ), hud:GetColor( 'lockdown' ) )
            y = y + h + space
        end

        if ( client:getDarkRPVar( 'wanted' ) ) then
            drawLabel( x, y, w, h, padding, WIMG_WANTED, L( 'hud_wanted' ), L( 'hud_wanted_help', { reason = client:getDarkRPVar( 'wantedReason' ) or '' } ), hud.GetAnimColor( 0 ) )
            y = y + h + space
        end

        if ( client:getDarkRPVar( 'Arrested' ) ) then
            local timeLeft = arrestEndTime and math.Clamp( math.Round( arrestEndTime - CurTime() ), 0, 9999 ) or -1
            local timeFormatted
        
            if ( timeLeft >= 0 ) then
                if ( timeLeft > 300 ) then
                    timeFormatted = string.format( '%d %s', math.Round( timeLeft / 60 ) , L( 'minutes_l' ) )
                else
                    timeFormatted = string.format( '%d %s', timeLeft , L( 'seconds_l' ) )
                end
            else
                timeFormatted = L( 'unknown' )
            end

            local helpText = L( 'hud_arrested_help', { time = timeFormatted } )

            drawLabel( x, y, w, h, padding, WIMG_ARRESTED, L( 'hud_arrested' ), helpText, hud:GetColor( 'textPrimary' ) )
        else
            arrestEndTime = nil
        end
    end, 
} )

onyx.hud.OverrideGamemode( 'onyx.hud.OverrideArrest', function()
    usermessage.Hook( 'GotArrested', function( msg )
        arrestEndTime = CurTime() + msg:ReadFloat()
    end )
end )

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
