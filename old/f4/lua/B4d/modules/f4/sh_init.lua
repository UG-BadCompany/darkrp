--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher

--[[

Author: tochnonement
Email: tochnonement@gmail.com

25/12/2023

--]]

onyx:Addon('f4', {
    color = Color(0,17,71),
    author = 'tochnonement',
    version = '1.1.6',
    licensee = '76561199575218969'
})

----------------------------------------------------------------

onyx.Include('sv_sql.lua')
onyx.IncludeFolder('onyx/modules/f4/languages/')
onyx.IncludeFolder('onyx/modules/f4/core/', true)
onyx.IncludeFolder('onyx/modules/f4/cfg/', true)
onyx.IncludeFolder('onyx/modules/f4/ui/')

onyx.f4:Print('Finished loading.')

--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher
