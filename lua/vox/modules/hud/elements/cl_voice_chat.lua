vox.hud.VoicePanels = vox.hud.VoicePanels or {}

local hud = vox.hud
local cache = hud.VoicePanels

local ANIM_DURATION = .2

local function findBestFont( text, maxWidth, ... )
    local bestFont = select( 1, ... )
    assert( bestFont, 'no fonts given' )

    local lastWidth = math.huge
    for _, font in ipairs( { ... } ) do
        local width = vox.GetTextSize( text, font )
        local isGood = width <= maxWidth

        if ( isGood or width < lastWidth ) then
            bestFont = font
            lastWidth = width

            if ( isGood ) then
                break
            end
        end
    end

    return bestFont
end

local function createPanel( ply )
    local padding = hud.ScaleTall( 5 )
    local bUseModelIcon = vox.hud:GetOptionValue( 'voice_avatar_mode' ) == 1

    local panel = vgui.Create( 'Panel' )
    panel:SetVisible( false )
    panel:SetPaintedManually( true )
    panel:SetWide( hud.ScaleWide( 200 ) )
    panel:SetTall( hud.ScaleTall( 40 ) )
    panel:DockPadding( padding, padding, padding, padding )

    panel.player = ply
    panel.name = ply:Name()
    panel.job = team.GetName( ply:Team())
    panel.color = team.GetColor( ply:Team() )
    panel.fraction = 0
    panel.font = vox.hud.fonts.SmallBold

    panel.OnRemove = function( this )
        for index, data in ipairs( cache ) do
            if ( data.panel == this ) then
                table.remove( cache, index )
                break
            end
        end
    end

    panel.Paint = function( this, w, h )
        local size = h - padding * 2
        local textX = h + padding
        local shouldShowJob = true
        local textColor = hud:GetColor( 'textPrimary' )
        local primaryColor = hud:GetColor( 'primary' )
        local isDark = hud:IsDark()
        local y0 = h * .5

        vox.hud.DrawRoundedBox( 0, 0, w, h, primaryColor )

        draw.SimpleText( this.name, this.font, textX, y0, textColor, 0, 1 )

        if ( this.mask and IsValid( this.avatar ) ) then
            vox.DrawWithPolyMask( this.mask, function()
                if ( this.avatar:GetClassName() ~= 'AvatarImage' ) then
                    surface.SetDrawColor( 0, 0, 0, 100 )
                    surface.DrawRect( 0, 0, w, h )

                    vox.DrawMatGradient( 0, 0, w, h, BOTTOM, ColorAlpha( this.color, isDark and 25 or 150 )  )
                end

                this.avatar:PaintManual()
            end )

            vox.DrawOutlinedCircle( padding + size * .5, y0, size * .5, 4, this.color )
        end
    end

    panel.PerformLayout = function( this, w, h )
        local size = h - padding * 2
        local maxWidth = w - size

        this.mask = vox.CalculateCircle( padding + size * .5, h * .5, math.floor( size * .5 ) - 1, 24 )
        this.font = findBestFont( this.name, maxWidth, vox.hud.fonts.SmallBold, vox.hud.fonts.TinyBold )
    end

    panel.avatar = panel:Add( bUseModelIcon and 'SpawnIcon' or 'AvatarImage' )
    panel.avatar:SetWide( panel:GetTall() - padding * 2 )
    panel.avatar:SetPaintedManually( true )
    panel.avatar:Dock( LEFT )

    if ( bUseModelIcon ) then
        -- I have to disable it, since gmod starts rebuilding the icon
        -- and if there would be many icons it would be a mess
        -- this function does synchronize bodygroups & skin as well :(
        -- vox.hud.UpdateModelIcon( panel.avatar, vox.hud.GetModelData( ply ) )

        panel.avatar:SetModel( ply:GetModel() )
    else
        panel.avatar:SetPlayer( ply, 64 )
    end

    return panel
end

local function findPanel( ply )
    for index, data in ipairs( cache ) do
        if ( data.ply == ply ) then
            return data.panel
        end
    end
end

local function startAnimation( panel, targetFraction, duration, onFinished )
    vox.anim.Create( panel, duration, {
        index = 1,
        target = { fraction = targetFraction },
        onFinished = onFinished,
        easing = 'inOutQuad',
        think = function( _, this )
            this:SetAlpha( this.fraction * 255 )
        end
    } )
end

local function toggleSpeaking( ply, state )
    local panel = findPanel( ply )
    if ( state ) then
        if ( IsValid( panel ) ) then
            startAnimation( panel, 1, ANIM_DURATION )
        else
            local data ={
                ply = ply,
                panel = createPanel( ply )
            }

            table.insert( cache, data )
            startAnimation( data.panel, 1, ANIM_DURATION )
        end
    else
        if ( IsValid( panel ) ) then
            startAnimation( panel, 0, .5, function( _, this )
                this:Remove()
            end )
        end
    end
end

local function sanitizeCache()
    for _ = 1, #cache do
        for index, data in ipairs( cache ) do
            if ( not IsValid( data.ply ) ) then
                data.panel:Remove()
                break
            end
        end
    end
end

local function drawVoiceChat( self, client, scrW, scrH )
    local screenPadding = hud.GetScreenPadding()
    local baseY = scrH * .75
    local posY = baseY
    local space = hud.ScaleTall( 5 )
    local speed = FrameTime() * 8

    for index, data in ipairs( cache ) do
        local ply = data.ply -- always valid here
        local panel = data.panel
        if ( IsValid( panel ) ) then
            local width, height = panel:GetSize()
            local posX = scrW - screenPadding - width

            posY = posY - height

            panel.animatedX = Lerp( speed, panel.animatedX or ScrW(), posX )
            panel.animatedY = Lerp( speed, panel.animatedY or posY, posY )

            panel:SetPos( panel.animatedX, panel.animatedY )
            panel:SetVisible( true ) -- this fixes micro glitch with popup being visible when created
            panel:PaintManual()

            posY = posY - space
        end
    end
end

hook.Add( 'PlayerStartVoice', 'vox.hud.PlayerStartVoice', function( ply )
    if ( IsValid( ply ) and ply ~= LocalPlayer() ) then
        toggleSpeaking( ply, true )
    end

    return true
end )

hook.Add( 'PlayerEndVoice', 'vox.hud.PlayerEndVoice', function( ply )
    if ( IsValid( ply ) ) then
        toggleSpeaking( ply, false )
    end

    return true
end )

vox.hud:RegisterElement( 'voice', {
    drawFn = function( self, client, scrW, scrH )
        sanitizeCache()
        drawVoiceChat( self, client, scrW, scrH )
    end
} )
