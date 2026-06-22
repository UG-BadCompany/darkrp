AddCSLuaFile('vox/framework/libs/thirdparty/data/utf8_chunk_1.lua')
AddCSLuaFile('vox/framework/libs/thirdparty/data/utf8_chunk_2.lua')
AddCSLuaFile('vox/framework/libs/thirdparty/data/utf8_chunk_3.lua')
AddCSLuaFile('vox/framework/libs/thirdparty/data/utf8_chunk_4.lua')

vox.IncludeFolder('vox/framework/libs/thirdparty/')
vox.IncludeFolder('vox/framework/libs/')
vox.IncludeFolder('vox/framework/core/')

if (SERVER) then
    vox.lang = {Get = function(phraseID)
        return phraseID
    end}
    vox.lang.GetWFallback = vox.lang.Get
end
