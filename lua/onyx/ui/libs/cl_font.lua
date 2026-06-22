--[[

Author: tochnonement
Email: tochnonement@gmail.com

15/04/2022

--]]

onyx.fonts = {}

local string_Explode = string.Explode
local math_ceil = math.ceil
local surface_CreateFont = surface.CreateFont
local tonumber = tonumber

local function createFont(font, size, parameters, initialSize)
    local name = 'onyx.' .. font .. size .. util.CRC(parameters or '')

    if onyx.fonts[name] then
        return name
    end

    local data = {
        font = font,
        size = size,
        extended = true,
        initialSize = initialSize
    }

    if parameters then
        local tblParameters = string_Explode(';', parameters)
        for _, str in ipairs(tblParameters) do
            local parts = string_Explode(':', str)
            local key, val = parts[1], parts[2]
            if tonumber(val) then
                data[key] = tonumber(val)
            else
                if val == 'true' then
                    data[key] = true
                else
                    data[key] = false
                end
            end
        end
    end

    onyx.fonts[name] = data

    surface_CreateFont(name, data)

    return name
end

local fetchFont do
    local aliases = {}

    function fetchFont(family)
        local overridedFont = hook.Call('onyx.ui.OverrideFont', nil, family)
        return (overridedFont or aliases[family] or family)
    end

    local function createAlias(alias, real)
        aliases[alias] = real
    end

    createAlias('Averta', 'AvertaStd-Regular')
    createAlias('Averta Bold', 'AvertaStd-Bold')
    createAlias('Averta Black', 'AvertaStd-Black')
end

function onyx.Font(pattern, parameters)
    local parts = string_Explode('@', pattern)
    local family, size = fetchFont(parts[1]), tonumber(parts[2])
    local scaledSize = math_ceil(size / 900 * ScrH())

    return createFont(family, scaledSize, parameters, size)
end

function onyx.FontNoScale(pattern, size, parameters)
    local family

    if size then
        family = fetchFont(pattern)
    else
        local parts = string_Explode('@', pattern)

        family, size = fetchFont(parts[1]), parts[2]
    end

    return createFont(family, size, parameters)
end

hook.Add('OnScreenSizeChanged', 'onyx.font.Recreate', function()
    for name, data in pairs(onyx.fonts) do
        if data.initialSize then
            data.size = math_ceil(data.initialSize / 900 * ScrH())
            surface_CreateFont(name, data)
        end
    end
end)