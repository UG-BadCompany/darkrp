--[[

Author: tochnonement
Email: tochnonement@gmail.com

02/03/2024

--]]

onyx.utf8 = {}

local CASEMAP_LOWER = {} -- lower to upper
local CASEMAP_UPPER = {} -- upper to lower

do
    -- gmod doesn't like big lua files, so let's split them
    for index = 1, 4 do
        local data = include('data/utf8_chunk_' .. index .. '.lua')
        assert(data, 'missing UTF-8 casemap data (' .. index .. ')')
        for lowerCharCode, upperCharCode in next, data do
            CASEMAP_LOWER[lowerCharCode] = upperCharCode
            CASEMAP_UPPER[upperCharCode] = lowerCharCode
        end
    end
end

local function replace(text, mapping)
    assert(isstring(text), string.format('bad argument #1 `replace` (expected string, got %s)', type(text)))

    local newString = ''

    for _, code in utf8.codes(text) do
        newString = newString .. utf8.char(mapping[code] or code)
    end

    return newString
end

function onyx.utf8.upper(text)
    return replace(text, CASEMAP_LOWER)
end

function onyx.utf8.lower(text)
    return replace(text, CASEMAP_UPPER)
end