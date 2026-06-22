--[[

Author: tochnonement
Email: tochnonement@gmail.com

21/08/2024

--]]

vox.hud.levelling = vox.hud.levelling or {}

local function validateDataValue( data, key )
    assert( data[ key ], Format( '`vox.hud.RegisterLevelSystem` bad data (missing value for \'%s\')', key ) )
    assert( isfunction( data[ key ] ), Format( '`vox.hud.RegisterLevelSystem` bad data (the value should be function \'%s\')', type( data ), key ) )
end

function vox.hud.RegisterLevelSystem( id, data )
    assert( isstring( id ), Format( '`vox.hud.RegisterLevelSystem` bad argument #1 (expected string, got %s)', type( id ) ) )
    assert( istable( data ), Format( '`vox.hud.RegisterLevelSystem` bad argument #2 (expected table, got %s)', type( data ) ) )
    validateDataValue( data, 'getLevel' )
    validateDataValue( data, 'getMaxXP' )
    validateDataValue( data, 'getXP' )
    validateDataValue( data, 'customCheck' )

    data.id = id
    vox.hud.levelling[ id ] = data
end

function vox.hud.IsLevellingEnabled()
    return ( vox.hud.levelSystem ~= nil )
end

function vox.hud.GetLevelData( client )
    local sysTable = vox.hud.levelSystem
    if ( sysTable ) then
        local level = math.Round( sysTable.getLevel( client ) )
        local maxXP = math.Round( sysTable.getMaxXP( client ) )
        local xp = math.Round( sysTable.getXP( client ) )

        return level, xp, maxXP
    end
end

vox.WaitForGamemode( 'vox.hud.CheckLevelSystem', function()
    for sysID, sysTable in pairs( vox.hud.levelling ) do
        if ( sysTable.customCheck() ) then
            if ( not sysTable.detected and sysTable.onDetected ) then
                sysTable.detected = true
                sysTable.onDetected()
            end

            vox.hud.levelSystem = sysTable
        end
    end
end )
