-- by p1ng :D

vox:Addon('scoreboard', {
    color = Color(65, 162, 211),
    author = 'tochnonement',
    version = '1.0.5',
    licensee = '76561198425391088'
})

----------------------------------------------------------------

vox.Include('sv_sql.lua')
vox.IncludeFolder('vox/modules/scoreboard/languages/')
vox.IncludeFolder('vox/modules/scoreboard/core/', true)
vox.IncludeFolder('vox/modules/scoreboard/cfg/', true)
vox.IncludeFolder('vox/modules/scoreboard/ui/')

vox.scoreboard:Print('Finished loading.')
