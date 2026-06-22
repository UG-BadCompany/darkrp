--[[

Author: tochnonement
Email: tochnonement@gmail.com

19/08/2024

--]]

local hud = vox.hud

local L = function( ... ) return vox.lang:Get( ... ) end
local WIMG_ICON = vox.wimg.Create( 'hud_connection_lost', 'smooth mips' )
local COLOR_GRAY = Color( 200, 200, 200 )

-- It is mandatory to run this command as soon as possible
RunConsoleCommand( 'cl_timeout', '300' )

local function startFadeAnimation( panel, target, callback )
    panel.animAlpha = panel:GetAlpha() / 255

    vox.anim.Create( panel, 1, {
        index = 1,
        target = { animAlpha = target },
        easing = 'inOutSine',
        think = function( _, panel )
            panel:SetAlpha( panel.animAlpha * 255 )
        end,
        onFinished = function( _, panel )
            if ( callback ) then
                callback( panel )
            end
        end
    } )
end

local function createPanel()
    local scrW, scrH = ScrW(), ScrH()
    local x0, y0 = scrW * .5, scrH * .5
    local theme = hud:GetCurrentTheme()
    local colors = theme.colors
    local space = hud.ScaleTall( 30 )

    local btnWide, btnTall = hud.ScaleWide( 200 ), hud.ScaleTall( 30 )
    local btnY = scrH * .75 - btnTall * .5

    local textTitle = L( 'timeout_title' )
    local textInfo = L( 'timeout_info' )
    local textStatus = L( 'timeout_status' )
    local fontInfo = hud.fonts.Medium

    surface.SetFont( fontInfo )
    local textInfoW, textInfoH = surface.GetTextSize( textInfo )
    local textStatusW, textStatusH = surface.GetTextSize( textStatus )

    local frame = vgui.Create( 'Panel' )
    vox.hud.TimeoutPanel = frame

    frame:SetSize( ScrW(), ScrH() )
    frame:SetDrawOnTop( true )
    frame:SetAlpha( 0 )
    frame.statusFraction = 0
    frame.reconnectTime = 0
    frame.Paint = function( panel, w, h )
        if ( panel.reconnectTime > 0 and panel.reconnectTime <= SysTime() ) then
            RunConsoleCommand( 'retry' )
        end

        local alpha = panel:GetAlpha() / 255
        local iconSize = hud.ScaleTall( 128 )

        if ( alpha > 0) then
            vox.DrawBlurExpensive( panel, 6 * alpha )
        end

        surface.SetDrawColor( ColorAlpha( colors.primary, theme.isDark and 230 or 150 ) )
        surface.DrawRect( 0, 0, w, h )

        draw.SimpleText( textTitle, hud.fonts.BigBold, x0, y0, colors.textPrimary, 1, 4 )

        WIMG_ICON:DrawRotated( x0, h * .4, iconSize, iconSize, 0, colors.textPrimary )
    end
    frame.OnRemove = function()
        timer.Remove( 'vox.hud.TimeoutShowDetails' )
    end
    frame.Close = function( panel )
        if ( not panel.closed ) then
            panel.closed = true
            startFadeAnimation( panel, 0, function( this )
                this:Remove()
            end )
        end
    end

    local lblDesc = frame:Add( 'Panel' )
    lblDesc:SetTall( math.max( textInfoH, textStatusH ) )
    lblDesc:SetWide( scrW )
    lblDesc:SetPos( 0, y0 )
    lblDesc.Paint = function( panel, w, h )
        local statusFraction = frame.statusFraction
        local infoFraction = 1 - statusFraction
        local timeLeft = math.Round( math.max( 0, frame.reconnectTime - SysTime() ) )
        local prevAlpha = surface.GetAlphaMultiplier()

        surface.SetAlphaMultiplier( math.min( infoFraction, prevAlpha ) )
            vox.hud.DrawCheapText( textInfo, fontInfo, w * .5 - textInfoW * .5, h * statusFraction, colors.textSecondary )
        surface.SetAlphaMultiplier( math.min( statusFraction, prevAlpha ) )
            draw.SimpleText( textStatus:format( timeLeft ), fontInfo, w * .5, -h * infoFraction, colors.negative, 1, 0 )
        surface.SetAlphaMultiplier( prevAlpha )
    end

    local btnReconnect = frame:Add( 'vox.Button' )
    btnReconnect:SetText( L( 'reconnect_u' ) )
    btnReconnect:SetFont( hud.fonts.Tiny )
    btnReconnect:SetTextColor( colors.textPrimary )
    btnReconnect:SetColorIdle( colors.secondary )
    btnReconnect:SetColorHover( colors.tertiary )
    btnReconnect:SetSize( btnWide, btnTall )
    btnReconnect:SetPos( x0 - btnWide - space / 2, btnY )
    btnReconnect:Hide()
    btnReconnect.DoClick = function() RunConsoleCommand( 'retry' ) end

    local btnDisconnect = frame:Add( 'vox.Button' )
    btnDisconnect:SetText( L( 'disconnect_u' ) )
    btnDisconnect:SetFont( hud.fonts.Tiny )
    btnDisconnect:SetTextColor( colors.textPrimary )
    btnDisconnect:SetColorIdle( colors.secondary )
    btnDisconnect:SetColorHover( colors.tertiary )
    btnDisconnect:SetSize( btnWide, btnTall )
    btnDisconnect:SetPos( x0 + space / 2, btnY )
    btnDisconnect:Hide()
    btnDisconnect.DoClick = function() RunConsoleCommand( 'disconnect' ) end

    startFadeAnimation( frame, 1 )

    timer.Create( 'vox.hud.TimeoutShowDetails', 3, 1, function()
        if ( IsValid( frame ) ) then
            frame.reconnectTime = SysTime() + hud:GetOptionValue( 'timeout' )
            frame:MakePopup()

            vox.anim.Create( frame, 1, {
                index = 2,
                target = { statusFraction = 1 },
                easing = 'outQuad',
                think = function( _, panel )
                    if ( IsValid( btnDisconnect ) and IsValid( btnReconnect ) ) then
                        local alpha = panel.statusFraction * 255

                        btnReconnect:SetVisible( true )
                        btnReconnect:SetAlpha( alpha )

                        btnDisconnect:SetVisible( true )
                        btnDisconnect:SetAlpha( alpha )
                    end
                end
            } )
        end
    end )
end

timer.Create( 'vox.hud.TimeoutController', 1, 0, function()
    local isTimingOut, lastPing = GetTimeoutInfo()
    local panel = vox.hud.TimeoutPanel
    local isValid = IsValid( panel )

    if ( isTimingOut ) then
        if ( isValid ) then
        else
            createPanel()
        end
    elseif ( isValid ) then
        panel:Close()
    end
end )

concommand.Add( 'vox_hud_test_timeout', function( ply, _, args )
    if ( ply:IsSuperAdmin() ) then
        local freezeDuration = tonumber( args[ 1 ] ) or 10
        local resetTime = SysTime() + freezeDuration
        local hookName = 'vox.hud.TimeoutTest'

        ply:ConCommand( 'net_fakeloss 100' )

        hook.Add( 'DrawOverlay', hookName, function()
            if ( resetTime <= SysTime() ) then
                hook.Remove( 'DrawOverlay', hookName )
                ply:ConCommand( 'net_fakeloss 0' )
            end
        end )
    end
end )
