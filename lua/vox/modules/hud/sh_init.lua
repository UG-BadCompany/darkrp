vox:Addon( 'hud', {
    color = Color( 99, 65, 211 ),
    author = 'Vox UI',
    version = '1.0.10',
    licensee = 'vox-ui'
} )

----------------------------------------------------------------

vox.Include( 'sv_sql.lua' )
vox.IncludeFolder( 'vox/modules/hud/languages/' )
vox.IncludeFolder( 'vox/modules/hud/core/', true )
vox.IncludeFolder( 'vox/modules/hud/cfg/', true )
vox.IncludeFolder( 'vox/modules/hud/elements/' )
vox.IncludeFolder( 'vox/modules/hud/ui/' )

vox.hud:Print( 'Finished loading.' )
