-- I made this to cache calculated values for UI scaling
-- It is working cheaper than using raw functions ;P

local CONVAR = CreateClientConVar( 'cl_vox_hud_scale', '100', true, false, 'Scale', 50, 150 )

local currentContextID
local cache = {
    [ 1 ] = {}, -- ScaleWide
    [ 2 ] = {} -- ScaleTall
}

local scale do
    local Round = math.Round
    function scale( int, method, storageIndex )
        local scaleFunc = vox[ method ]
        local scaleInt = vox.hud.GetScale() -- from outside

        if ( currentContextID ) then
            local cacheTable = cache[ storageIndex ]
            local cached = cacheTable[ int ]

            if ( cached ) then
                return cached
            else
                local result = Round( scaleFunc( int ) * scaleInt )

                cache[ storageIndex ][ int ] = result

                return result
            end
        else
            return Round( scaleFunc( int ) * scaleInt )
        end
    end
end

function vox.hud.GetScale()
    local serverScale = 100
    if ( vox.hud.GetOptionValue and vox.inconfig and vox.inconfig.options and vox.inconfig.options[ 'hud_hud_scale' ] ) then
        serverScale = vox.hud:GetOptionValue( 'hud_scale' ) or 100
    end

    return ( CONVAR:GetInt() / 100 ) * ( serverScale / 100 )
end

function vox.hud.StartScaling( contextID )
    currentContextID = contextID
end

function vox.hud.EndScaling()
    if ( currentContextID ) then
        currentContextID = nil
    end
end

function vox.hud.ScaleWide( int )
    return scale( int, 'ScaleWide', 1 )
end

function vox.hud.ScaleTall( int )
    return scale( int, 'ScaleTall', 2 )
end

function vox.hud.ResetScaleCache()
    local client = LocalPlayer()

    for index = 1, 2 do
        cache[ index ] = {}
    end

    for id, element in pairs( vox.hud.elements ) do
        if ( element.onSizeChanged ) then
            element:onSizeChanged( client )
        end
    end
end

cvars.AddChangeCallback( 'cl_vox_hud_scale', function( _, _, new )
    vox.hud.ResetScaleCache()
    vox.hud.BuildFonts()
end, 'vox.hud.Update' )

hook.Add( 'vox.inconfig.Updated', 'vox.hud.UpdateServerScale', function( id )
    if ( id == 'hud_hud_scale' or id == 'hud_font_size' ) then
        vox.hud.ResetScaleCache()
        vox.hud.BuildFonts()
    end
end )

hook.Add( 'OnScreenSizeChanged', 'vox.hud.ResetScaleCache', function()
    vox.hud.ResetScaleCache()
    vox.hud.BuildFonts()
end )
