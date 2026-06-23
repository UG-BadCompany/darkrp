local zeroFn = function() end

vox.ZeroFn = zeroFn
vox.IncludeClient = CLIENT and include or AddCSLuaFile
vox.IncludeServer = SERVER and include or zeroFn
vox.IncludeShared = function(path)
    if not file.Exists(path, 'LUA') then
        vox:PrintWarning('Missing include: #', path)
        return
    end

    AddCSLuaFile(path)
    return include(path)
end

do
    local Explode = string.Explode
    local Left = string.Left
    local missingIncludes = {}

    vox.Include = function(path)
        if not file.Exists(path, 'LUA') then
            if not missingIncludes[path] then
                missingIncludes[path] = true
                vox:PrintWarning('Missing include: #', path)
            end
            return
        end

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
        if not file.Exists(path, 'LUA') then
            vox:PrintWarning('Missing include folder: #', path)
            return
        end

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



vox.FontFallbacks = vox.FontFallbacks or {
    [ 'Overpass SemiBold' ] = 'Montserrat',
    [ 'Overpass Bold' ] = 'Montserrat',
    [ 'Overpass' ] = 'Roboto',
    [ 'Montserrat' ] = 'Tahoma',
    [ 'Roboto' ] = 'Tahoma',
    [ 'Comfortaa' ] = 'Tahoma',
    [ 'Comfortaa Bold' ] = 'Tahoma',
    [ 'Comfortaa SemiBold' ] = 'Tahoma'
}

function vox.SafeColor( color, fallback )
    if IsColor and IsColor( color ) then
        return color
    end

    return fallback or color_white or Color( 255, 255, 255 )
end

function vox.SafeTheme()
    local theme = {}

    if vox.hud and vox.hud.GetCurrentTheme then
        theme = vox.hud:GetCurrentTheme() or {}
    end

    theme.colors = theme.colors or {}
    return theme
end

function vox.GetThemeColors()
    local theme = vox.SafeTheme()
    local colors = theme.colors or {}

    if table.IsEmpty( colors ) and vox.theme and vox.theme.tokens then
        local t = vox.theme.tokens
        colors = {
            primary = t.frame, secondary = t.panel, tertiary = t.panelAlt, quaternary = t.bg,
            accent = t.accent, secondaryAccent = t.secondaryAccent, border = t.border,
            textPrimary = t.text, textSecondary = t.textSoft, textTertiary = t.muted,
            positive = t.success, money = t.money, negative = t.danger, armor = t.armor,
            hunger = t.hunger, xp = t.warning, lockdown = t.danger
        }
    end

    return colors, theme
end

function vox.SafeFont( preferred, fallback )
    local font = preferred or fallback or 'Trebuchet24'
    local visited = {}

    while vox.FontFallbacks[ font ] and not visited[ font ] do
        visited[ font ] = true
        font = vox.FontFallbacks[ font ]
    end

    return font or fallback or 'Trebuchet24'
end

function vox.SafeMaterial( path, fallback, params )
    if CLIENT and path and file.Exists( path, 'GAME' ) then
        return Material( path, params )
    end

    if CLIENT and fallback then
        return Material( fallback, params )
    end
end

function vox.SafeIcon( path, fallback, params )
    return vox.SafeMaterial( path, fallback or 'icon16/information.png', params )
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
