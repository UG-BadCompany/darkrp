--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

local zeroFn = function() end

onyx.ZeroFn = zeroFn
onyx.IncludeClient = CLIENT and include or AddCSLuaFile
onyx.IncludeServer = SERVER and include or zeroFn
onyx.IncludeShared = function(path)
    AddCSLuaFile(path)
    return include(path)
end

do
    local Explode = string.Explode
    local Left = string.Left
    onyx.Include = function(path)
        local parts = Explode('/', path)
        local prefix = Left(parts[#parts], 2)

        if prefix then
            if prefix == 'sv' then
                return onyx.IncludeServer(path)
            elseif prefix == 'cl' then
                return onyx.IncludeClient(path)
            elseif prefix == 'sh' then
                return onyx.IncludeShared(path)
            end
        end
    end
end

do
    local Find = file.Find
    local ipairs = ipairs
    local GetExtensionFromFilename = string.GetExtensionFromFilename

    local function IncludeFolder(path, recursive)
        local files, folders = Find(path .. '*', 'LUA')

        for _, name in ipairs(files) do
            if GetExtensionFromFilename(name) == 'lua' then
                onyx.Include(path .. name)
            end
        end

        if recursive then
            for _, name in ipairs(folders) do
                IncludeFolder(path .. name .. '/', recursive)
            end
        end
    end
    onyx.IncludeFolder = IncludeFolder
end

function onyx:Config(key)
    local tSequence = string.Explode('.', key)
    local iSequence = #tSequence
    local previousTbl = self.cfg

    for i = 1, iSequence do
        local keyPart = tSequence[i]
        if previousTbl[keyPart] then
            if i == iSequence then
                return previousTbl[keyPart]
            else
                previousTbl = previousTbl[keyPart]
            end
        end
    end

    return fallback
end

do
    local accent = Color(174, 0, 255)
    local white = color_white
    local red = Color(255, 73, 73)
    local green = Color(121, 255, 68)
    local orange = Color(255, 180, 68)
    local blue = Color(68, 149, 255)

    local function format(text, ...)
        for _, arg in ipairs({...}) do
            if isentity(arg) and arg:IsPlayer() then
                arg = arg:Name() .. " (" .. arg:SteamID() .. ")"
            else
                arg = tostring(arg)
            end
    
            text = string.gsub(text, "#", arg, 1)
        end
    
        return text
    end

    local function printWPrefix(color, prefix, text, ...)
        MsgC(
            white, '(', accent, 'ONYX', white, ') ',
            white, '(', color, prefix, white, ') ',
            format(text, ...),
            '\n'
        )
    end

    function onyx:Print(text, ...)
        MsgC(
            white, '(', accent, 'ONYX', white, ') ',
            format(text, ...),
            '\n'
        )
    end

    function onyx:PrintError(text, ...)
        printWPrefix(red, 'ERROR', text, ...)
    end

    function onyx:PrintWarning(text, ...)
        printWPrefix(orange, 'WARNING', text, ...)
    end

    function onyx:PrintSuccess(text, ...)
        printWPrefix(green, 'SUCCESS', text, ...)
    end
    
    do

        local cvDebug = CreateConVar('sh_onyx_debug', '0', FCVAR_REPLICATED)

        function onyx:PrintDebug(text, ...)
            if (cvDebug:GetBool()) then
                printWPrefix(blue, 'DEBUG', text, ...)
            end
        end
    end
end