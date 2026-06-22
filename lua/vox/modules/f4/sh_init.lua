--[[

Author: tochnonement
Email: tochnonement@gmail.com

25/12/2023

--]]

vox:Addon('f4', {
    color = Color(0,17,71),
    author = 'tochnonement',
    version = '1.1.6',
    licensee = '76561199575218969'
})

----------------------------------------------------------------

vox.Include('sv_sql.lua')
vox.IncludeFolder('vox/modules/f4/languages/')
vox.IncludeFolder('vox/modules/f4/core/', true)
vox.IncludeFolder('vox/modules/f4/cfg/', true)
vox.IncludeFolder('vox/modules/f4/ui/')

vox.f4:Print('Finished loading.')
