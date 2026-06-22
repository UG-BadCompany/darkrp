--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

--[[

Author: tochnonement
Email: tochnonement@gmail.com

21/08/2024

--]]

onyx.hud.RegisterLevelSystem( 'vrodankis', {
    getLevel = function( ply )
        return ( ply:getDarkRPVar( 'level' ) or 1 )
    end,
    getXP = function( ply )
        return ( ply:getDarkRPVar( 'xp' ) or 0 )
    end,
    getMaxXP = function( ply )
        -- omg...
        -- this is from Vrondakis, there is no util func
        local level = ( ply:getDarkRPVar( 'level' ) or 1 )
        local maxXP = ( ( ( 10 + ( ( level * ( level + 1 ) * 90 ) ) ) ) * LevelSystemConfiguration.XPMult )
        return maxXP
    end,
    customCheck = function()
        return ( LevelSystemConfiguration ~= nil )
    end,
    onDetected = function()
        hook.Remove( 'HUDPaint', 'manolis:MVLevels:HUDPaintA' )
    end
} )

onyx.hud.RegisterLevelSystem( 'glorified', {
    getLevel = function( ply )
        return GlorifiedLeveling.GetPlayerLevel( ply )
    end,
    getXP = function( ply )
        return GlorifiedLeveling.GetPlayerXP( ply )
    end,
    getMaxXP = function( ply )
        return GlorifiedLeveling.GetPlayerMaxXP( ply )
    end,
    customCheck = function()
        return ( GlorifiedLeveling ~= nil )
    end,
    onDetected = function()
        hook.Remove( 'HUDPaint', 'GlorifiedLeveling.HUD.HUDPaint' )
    end
} )

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
