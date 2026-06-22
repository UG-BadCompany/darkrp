--[[

Author: tochnonement
Email: tochnonement@gmail.com

12/08/2024

--]]

local PLAYER = FindMetaTable( 'Player' )

util.AddNetworkString( 'vox.hud::SendAlert' )

local function overridePrintMessage()
    vox.hud.original_PrintMessage = vox.hud.original_PrintMessage or PLAYER.PrintMessage                                                                                                                                                                                                                              -- b7fe7d19-18c9-42a0-823d-06e7663479ef

    PLAYER.PrintMessage = function( self, type, message )
        if ( type == HUD_PRINTCENTER ) then
            net.Start( 'vox.hud::SendAlert' )
                net.WriteString( message )
            net.Send( self )
        else
            vox.hud.original_PrintMessage( self, type, message )
        end
    end
end
vox.WaitForGamemode( 'vox.hud.OverridePrintMessage', overridePrintMessage )

hook.Add( 'PlayerSay', 'vox.hud.OpenSettings', function( ply, text )
    local text = string.lower( text )
    if ( text == '!hud' or text == '/hud' ) then
        ply:ConCommand( 'vox_hud' )
        return ''
    end
end )
