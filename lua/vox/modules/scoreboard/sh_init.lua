vox:Addon('scoreboard', {
    color = Color(65, 162, 211),
    author = 'Vox UI',
    version = '1.0.5',
    licensee = 'vox-ui'
})

----------------------------------------------------------------

vox.Include('sv_sql.lua')
vox.IncludeFolder('vox/modules/scoreboard/languages/')
vox.IncludeFolder('vox/modules/scoreboard/core/', true)
vox.IncludeFolder('vox/modules/scoreboard/cfg/', true)
vox.IncludeFolder('vox/modules/scoreboard/ui/')

vox.scoreboard:Print('Finished loading.')
