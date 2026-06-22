--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

--[[

Author: tochnonement
Email: tochnonement@gmail.com

12/08/2024

--]]

local PLAYER = FindMetaTable( 'Player' )

util.AddNetworkString( 'onyx.hud::SendAlert' )

local function overridePrintMessage()
    onyx.hud.original_PrintMessage = onyx.hud.original_PrintMessage or PLAYER.PrintMessage                                                                                                                                                                                                                              -- b7fe7d19-18c9-42a0-823d-06e7663479ef

    PLAYER.PrintMessage = function( self, type, message )
        if ( type == HUD_PRINTCENTER ) then
            net.Start( 'onyx.hud::SendAlert' )
                net.WriteString( message )
            net.Send( self )
        else
            onyx.hud.original_PrintMessage( self, type, message )
        end
    end
end
onyx.WaitForGamemode( 'onyx.hud.OverridePrintMessage', overridePrintMessage )

hook.Add( 'PlayerSay', 'onyx.hud.OpenSettings', function( ply, text )
    local text = string.lower( text )
    if ( text == '!hud' or text == '/hud' ) then
        ply:ConCommand( 'onyx_hud' )
        return ''
    end
end )

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
