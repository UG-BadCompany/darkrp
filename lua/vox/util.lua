local zeroFn = function() end

vox.ZeroFn = zeroFn
vox.IncludeClient = CLIENT and include or AddCSLuaFile
vox.IncludeServer = SERVER and include or zeroFn
vox.IncludeShared = function(path)
    AddCSLuaFile(path)
    return include(path)
end

do
    local Explode = string.Explode
    local Left = string.Left
    vox.Include = function(path)
        local parts = Explode('/', path)
        local prefix = Left(parts[#parts], 2)

        if prefix then
            if prefix == 'sv' then
                return vox.IncludeServer(path)
            elseif prefix == 'cl' then
                return vox.IncludeClient(path)
            elseif prefix == 'sh' then
                return vox.IncludeShared(path)
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
                vox.Include(path .. name)
            end
        end

        if recursive then
            for _, name in ipairs(folders) do
                IncludeFolder(path .. name .. '/', recursive)
            end
        end
    end
    vox.IncludeFolder = IncludeFolder
end

function vox:Config(key)
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
            white, '(', accent, 'VOX', white, ') ',
            white, '(', color, prefix, white, ') ',
            format(text, ...),
            '\n'
        )
    end

    function vox:Print(text, ...)
        MsgC(
            white, '(', accent, 'VOX', white, ') ',
            format(text, ...),
            '\n'
        )
    end

    function vox:PrintError(text, ...)
        printWPrefix(red, 'ERROR', text, ...)
    end

    function vox:PrintWarning(text, ...)
        printWPrefix(orange, 'WARNING', text, ...)
    end

    function vox:PrintSuccess(text, ...)
        printWPrefix(green, 'SUCCESS', text, ...)
    end

    do

        local cvDebug = CreateConVar('sh_vox_debug', '0', FCVAR_REPLICATED)

        function vox:PrintDebug(text, ...)
            if (cvDebug:GetBool()) then
                printWPrefix(blue, 'DEBUG', text, ...)
            end
        end
    end
end
