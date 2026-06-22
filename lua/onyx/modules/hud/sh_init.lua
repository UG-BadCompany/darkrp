--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

--[[

Author: tochnonement
Email: tochnonement@gmail.com

30/07/2024

--]]

onyx:Addon( 'hud', {
    color = Color( 99, 65, 211 ),
    author = 'tochnonement',
    version = '1.0.10',
    licensee = '76561198157781160'
} )

----------------------------------------------------------------

onyx.Include( 'sv_sql.lua' )
onyx.IncludeFolder( 'onyx/modules/hud/languages/' )
onyx.IncludeFolder( 'onyx/modules/hud/core/', true )
onyx.IncludeFolder( 'onyx/modules/hud/cfg/', true )
onyx.IncludeFolder( 'onyx/modules/hud/elements/' )
onyx.IncludeFolder( 'onyx/modules/hud/ui/' )

onyx.hud:Print( 'Finished loading.' )

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
