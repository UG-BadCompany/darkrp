-- by p1ng :D

onyx:Addon('scoreboard', {
    color = Color(65, 162, 211),
    author = 'tochnonement',
    version = '1.0.5',
    licensee = '76561198425391088'
})

----------------------------------------------------------------

onyx.Include('sv_sql.lua')
onyx.IncludeFolder('onyx/modules/scoreboard/languages/')
onyx.IncludeFolder('onyx/modules/scoreboard/core/', true)
onyx.IncludeFolder('onyx/modules/scoreboard/cfg/', true)
onyx.IncludeFolder('onyx/modules/scoreboard/ui/')

onyx.scoreboard:Print('Finished loading.')