--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

AddCSLuaFile('onyx/framework/libs/thirdparty/data/utf8_chunk_1.lua')
AddCSLuaFile('onyx/framework/libs/thirdparty/data/utf8_chunk_2.lua')
AddCSLuaFile('onyx/framework/libs/thirdparty/data/utf8_chunk_3.lua')
AddCSLuaFile('onyx/framework/libs/thirdparty/data/utf8_chunk_4.lua')

onyx.IncludeFolder('onyx/framework/libs/thirdparty/')
onyx.IncludeFolder('onyx/framework/libs/')
onyx.IncludeFolder('onyx/framework/core/')

if (SERVER) then
    onyx.lang = {Get = function(phraseID)
        return phraseID
    end}
    onyx.lang.GetWFallback = onyx.lang.Get
end