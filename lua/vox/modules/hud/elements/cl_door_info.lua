local RANGE = 400
local FONT_NAME = vox.hud.CreateFont3D2D( 'DoorName', 'Comfortaa SemiBold', 60 )
local FONT_SMALL_NAME = vox.hud.CreateFont3D2D( 'DoorSmallName', 'Comfortaa SemiBold', 40 )
local FONT_HELP = vox.hud.CreateFont3D2D( 'DoorHelp', 'Comfortaa', 32 )
local COLOR_GRAY = Color( 200, 200, 200 )
local COLOR_GREEN = Color( 147, 255, 108)
local COLOR_RED = Color( 255, 87, 87)
local COLOR_PANEL = Color( 4, 16, 32, 224 )
local COLOR_PANEL_INNER = Color( 8, 34, 58, 206 )
local COLOR_PANEL_LINE = Color( 28, 230, 115, 190 )
local COLOR_BLUE_LINE = Color( 20, 154, 255, 170 )
local COLOR_TEXT_MUTED = Color( 159, 177, 199 )
local MAT_DOOR = Material( 'vox_hud/door_title.png', 'smooth mips' )
local MAT_LOCK = Material( 'vox_hud/door_own.png', 'smooth mips' )
local L = function( ... ) return vox.lang:Get( ... ) end

local nearest = {}
local traceOut = {}
local traceIn = { output = traceOut, mask = MASK_SHOT }

local bindKey = ''

local function getThemeColors()
    local colors = ( vox.GetUIThemeColors and vox.GetUIThemeColors() ) or {}

    return {
        panel = ColorAlpha( colors.primary or COLOR_PANEL, 224 ),
        inner = ColorAlpha( colors.secondary or COLOR_PANEL_INNER, 206 ),
        card = ColorAlpha( colors.tertiary or colors.secondary or COLOR_PANEL_INNER, 238 ),
        accent = colors.accent or COLOR_PANEL_LINE,
        positive = colors.money or colors.positive or COLOR_GREEN,
        negative = colors.negative or COLOR_RED,
        text = colors.textPrimary or color_white,
        muted = colors.textSecondary or COLOR_TEXT_MUTED
    }
end

-- To get a nice string containing players' name from DarkRP
local function getPlayersStr( players, maxNames )
    local maxNames = maxNames or 2
    local result = {}
    local added = 0
    local limitExceeded = false

    for playerIndex in pairs( players ) do
        local ply = Player( playerIndex )
        if ( IsValid( ply ) ) then
            added = added + 1
            if ( added > maxNames ) then
                limitExceeded = true
                break
            end

            result[ added ] = ply:Name()
        end
    end

    local finalStr = table.concat( result, ', ' )

    if ( limitExceeded ) then
        finalStr = finalStr .. ', ...'
    end

    return finalStr
end

local function isHorizontalDoor( ent, hitNormal )
    if ( hitNormal and math.abs( hitNormal.z ) > .45 ) then return true end
    if ( not IsValid( ent ) ) then return false end

    local ang = ent:GetAngles()
    return math.abs( math.AngleDifference( ang.p, 0 ) ) > 35 or math.abs( math.AngleDifference( ang.r, 0 ) ) > 35
end

local function getUpright3D2DAngle( yaw )
    return Angle( 0, yaw, 90 )
end

local function getFacingYaw( fromPos, toPos )
    return ( toPos - fromPos ):Angle().y
end

local function getReadable3D2DAngle( hitNormal, renderPos, client, horizontalDoor )
    if ( not IsValid( client ) ) then
        return Angle( 0, 0, 90 )
    end

    if ( horizontalDoor ) then
        -- Horizontal/sloped doors need a vertical sign, so face the player by
        -- yaw only. Keeping pitch/roll stripped prevents sideways or skewed UI.
        return getUpright3D2DAngle( getFacingYaw( renderPos, client:EyePos() ) - 90 )
    end

    -- Upright doors should stay aligned with the traced door face. Do not use
    -- entity up-vectors here: normal doors also point upward and were being
    -- misclassified as horizontal/sloped panels.
    local faceYaw = hitNormal:Angle().y
    return getUpright3D2DAngle( faceYaw + 90 )
end

local function drawInfo( ent, client )
    if ( not IsValid( client ) ) then return end

    local screenPos = ent:LocalToWorld( ent:OBBCenter() ) + Vector( 0, 0, 16 )

    -- I wish I could put this in a timer, but it would look bad when the door is moving
    traceIn.start = client:GetShootPos()
    traceIn.endpos = screenPos
    traceIn.filter = client
    util.TraceLine( traceIn )

    if ( traceOut.Entity ~= ent ) then return end

    local hitPos = traceOut.HitPos
    local hitNormal = traceOut.HitNormal
    local length = ( hitPos - screenPos ):Length2D()
    local isBrushDoor = ent:GetClass() == 'func_door_rotating' or ent:GetClass() == 'func_door'

    if ( not isBrushDoor and length > 6 ) then return end

    local horizontalDoor = isHorizontalDoor( ent, hitNormal )
    local renderPos = horizontalDoor and ( hitPos + Vector( 0, 0, 24 ) ) or ( hitPos + hitNormal * 2 + Vector( 0, 0, 4 ) )
    local renderAng = getReadable3D2DAngle( hitNormal, renderPos, client, horizontalDoor )

    local doorTeams = ent:getKeysDoorTeams()
    local doorGroup = ent:getKeysDoorGroup()
    local doorCoowners = ent:getKeysCoOwners() or {}
    local doorPrice = GAMEMODE.Config.doorcost ~= 0 and GAMEMODE.Config.doorcost or 30
    local playerOwned = ent:isKeysOwned() or table.GetFirstValue( doorCoowners ) ~= nil
    local isOwned = playerOwned or doorGroup or doorTeams
    local allowedCoOwn = ent:getKeysAllowedToOwn()

    local title = ''
    local subtitle = ''
    local theme = getThemeColors()
    local color = theme.text
    local titleFont = FONT_NAME

    if ( isOwned ) then
        local doorOwner = ent:getDoorOwner()
        local ownedByClient = playerOwned and ( doorOwner == client or doorCoowners[ client:UserID() ] )

        title = ent:getKeysTitle()

        if ( not title ) then
            if ( playerOwned ) then
                title = L( 'door_owned' )
                color = ownedByClient and theme.positive or theme.negative
            else
                if ( doorGroup ) then
                    title = doorGroup
                    titleFont = FONT_SMALL_NAME
                else
                    title = L( 'door_owned' )
                end

                if ( doorTeams ) then
                    for teamIndex in pairs( doorTeams ) do
                        subtitle = subtitle .. team.GetName( teamIndex ) .. '\n'
                    end
                end
            end
        elseif ( not playerOwned ) then
            if ( doorGroup ) then
                subtitle = doorGroup
            elseif ( doorTeams ) then
                for teamIndex in pairs( doorTeams ) do
                    subtitle = subtitle .. team.GetName( teamIndex ) .. '\n'
                end
            end
        end

        if ( playerOwned ) then
            subtitle = L( 'hud_door_owner', { name = IsValid( doorOwner ) and doorOwner:Name() or '' } )

            if ( not table.IsEmpty( doorCoowners ) ) then
                subtitle = subtitle .. Format( '\n%s: %s', L( 'hud_door_coowners' ), getPlayersStr( doorCoowners ) )
            end

            if ( allowedCoOwn and not table.IsEmpty( allowedCoOwn ) ) then
                subtitle = subtitle .. Format( '\n%s: %s', L( 'hud_door_allowed' ), getPlayersStr( allowedCoOwn ) )
            end
        end
    else
        title = L( 'door_unowned' )
        subtitle = L( 'hud_door_help', { bind = bindKey, price = DarkRP.formatMoney( doorPrice ) } )
    end

    local accentColor = isOwned and color or theme.accent
    local subtitleLine = string.Explode( '\n', subtitle or '' )[ 1 ] or ''
    local promptText = L( 'hud_door_help', { bind = string.upper( bindKey ~= '' and bindKey or 'E' ), price = DarkRP.formatMoney( doorPrice ) } )
    promptText = isOwned and 'Press E to interact' or promptText

    cam.Start3D2D( renderPos, renderAng, .085 )

        local w, h = 560, 230
        local x, y = -w * .5, -h * .5

        draw.RoundedBox( 14, x, y, w, h, theme.panel )
        draw.RoundedBox( 14, x + 2, y + 2, w - 4, h - 4, theme.inner )
        surface.SetDrawColor( accentColor.r, accentColor.g, accentColor.b, 210 )
        surface.DrawOutlinedRect( x, y, w, h, 2 )
        surface.SetDrawColor( theme.accent.r, theme.accent.g, theme.accent.b, 140 )
        surface.DrawLine( x + 18, y, x + w - 18, y )

        draw.RoundedBox( 4, x + 34, y + 42, 82, 116, ColorAlpha( theme.card, 238 ) )
        surface.SetDrawColor( 255, 255, 255, 225 )
        surface.SetMaterial( MAT_DOOR )
        surface.DrawTexturedRect( x + 42, y + 50, 66, 100 )

        draw.RoundedBox( 46, x + w - 106, y - 18, 92, 92, ColorAlpha( theme.card, 238 ) )
        surface.SetDrawColor( accentColor.r, accentColor.g, accentColor.b, 225 )
        surface.DrawOutlinedRect( x + w - 106, y - 18, 92, 92, 2 )
        surface.SetDrawColor( accentColor.r, accentColor.g, accentColor.b, 230 )
        surface.SetMaterial( MAT_LOCK )
        surface.DrawTexturedRect( x + w - 73, y + 11, 28, 28 )

        draw.DrawText( title, titleFont == FONT_NAME and FONT_SMALL_NAME or titleFont, x + 142, y + 48, theme.text, TEXT_ALIGN_LEFT )
        draw.DrawText( subtitleLine, FONT_HELP, x + 142, y + 93, theme.muted, TEXT_ALIGN_LEFT )

        draw.RoundedBox( 5, x + 142, y + 145, 34, 34, ColorAlpha( theme.accent, 210 ) )
        draw.DrawText( string.upper( bindKey ~= '' and bindKey or 'E' ), FONT_HELP, x + 159, y + 146, theme.text, TEXT_ALIGN_CENTER )
        draw.DrawText( promptText, FONT_HELP, x + 186, y + 148, theme.muted, TEXT_ALIGN_LEFT )

    cam.End3D2D()
end

do
    local DOORS = {
        [ 'prop_door_rotating' ] = true,
        [ 'func_door_rotating' ] = true,
        [ 'func_door' ] = true,
    }

    local traceDoorOut = {}
    local traceDoorIn = { output = traceDoorOut, mask = MASK_SHOT }

    local function addNearestDoor( ent, seen )
        if ( not IsValid( ent ) or seen[ ent ] ) then return end
        if ( not ent:isDoor() ) then return end
        if ( ent.getKeysNonOwnable and ent:getKeysNonOwnable() ) then return end
        if ( not DOORS[ ent:GetClass() ] or ent:GetNoDraw() ) then return end

        seen[ ent ] = true
        table.insert( nearest, ent )
    end

    timer.Create( 'vox.hud.CatchNearestDoors', 1 / 5, 0, function()
        local client = LocalPlayer()
        if ( IsValid( client ) ) then
            local shootPos = client:GetShootPos()
            local aimVector = client:GetAimVector()
            local entities = ents.FindInCone( shootPos, aimVector, RANGE, math.cos( math.rad( 45 ) ) )
            local seen = {}

            nearest = {}
            bindKey = input.LookupBinding( 'gm_showteam' ) or ''

            for _, ent in ipairs( entities ) do
                addNearestDoor( ent, seen )
            end

            traceDoorIn.start = shootPos
            traceDoorIn.endpos = shootPos + aimVector * RANGE
            traceDoorIn.filter = client
            util.TraceLine( traceDoorIn )

            addNearestDoor( traceDoorOut.Entity, seen )
        end
    end )
end

hook.Add( 'PostDrawTranslucentRenderables', 'vox.hud.DrawDoors', function()
    local client = LocalPlayer()
    for _, ent in ipairs( nearest ) do
        if ( IsValid( ent ) ) then
            drawInfo( ent, client )
        end
    end
end )
