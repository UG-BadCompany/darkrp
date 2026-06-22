--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

vox:Addon( 'hud', {
    color = Color( 99, 65, 211 ),
    author = 'tochnonement',
    version = '1.0.10',
    licensee = '76561198157781160'
} )

----------------------------------------------------------------

vox.Include( 'sv_sql.lua' )
vox.IncludeFolder( 'vox/modules/hud/languages/' )
vox.IncludeFolder( 'vox/modules/hud/core/', true )
vox.IncludeFolder( 'vox/modules/hud/cfg/', true )
vox.IncludeFolder( 'vox/modules/hud/elements/' )
vox.IncludeFolder( 'vox/modules/hud/ui/' )

vox.hud:Print( 'Finished loading.' )
