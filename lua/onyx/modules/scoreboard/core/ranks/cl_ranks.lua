-- by p1ng :D

onyx.scoreboard.nameEffects = {}

function onyx.scoreboard:RegisterNameEffect(id, func)
    table.insert(onyx.scoreboard.nameEffects, {
        id = id,
        func = func,
        name = ('scoreboard_eff_' .. id)
    })
end

function onyx.scoreboard:FindNameEffect(id)
    for index, data in ipairs(self.nameEffects) do
        if (data.id == id) then
            return data, index
        end
    end
end

do
    local fontCommon = onyx.Font('Comfortaa SemiBold@16') -- the size got dynamically changed
    local fontGlow = onyx.Font('Comfortaa SemiBold@16', 'blursize:2') -- the size got dynamically changed

    local COLOR_SHADOW = Color(0, 0, 0, 100)
    local SHADOW_DISTANCE = 2

    local ColorAlpha = ColorAlpha
    local SimpleText = draw.SimpleText

    -- Common (colorized)
    onyx.scoreboard:RegisterNameEffect('default', function(text, x, y, color, ax, ay)
        SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)
        SimpleText(text, fontCommon, x, y, color, ax, ay)
    end)

    -- Glow (colorized)
    onyx.scoreboard:RegisterNameEffect('glow', function(text, x, y, color, ax, ay)
        SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)
        SimpleText(text, fontGlow, x, y, ColorAlpha(color, 80 + 80 * math.abs(math.sin(CurTime() * 2))), ax, ay)
        SimpleText(text, fontCommon, x, y, color, ax, ay)
    end)

    -- Rainbow
    onyx.scoreboard:RegisterNameEffect('rainbow', function(text, x, y, color, ax, ay)
        local lastX = x
        local counter = 0
        local speed = CurTime() * 50

        SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)

        for _, code in utf8.codes(text) do
            local offset = counter * 5
            local color = HSVToColor((speed + offset) % 360, 1, 1)

            counter = counter + 1
            lastX = lastX + select(1, SimpleText(utf8.char(code), fontCommon, lastX, y, color, ax, ay))
        end
    end)

    -- Wavy Dual
    onyx.scoreboard:RegisterNameEffect('wavy_dual', function(text, x, y, color, ax, ay)
        local lastX = x
        local counter = 0
        local speed = CurTime() * 5

        -- draw.SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)

        for _, code in utf8.codes(text) do
            local offset = math[counter % 2 == 0 and 'cos' or 'sin'](speed)
            local fraction = math.abs(offset)
            local color1 = color
            local h, s, v = ColorToHSV(color1)
            local color2 = onyx.ColorEditHSV(color1, (h + 90) % 360)
            local color = onyx.LerpColor(fraction, color1, color2)
            local char = utf8.char(code)

            counter = counter + 1

            SimpleText(char, fontCommon, lastX + SHADOW_DISTANCE, y + offset * .05 + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)
            lastX = lastX + select(1, SimpleText(char, fontCommon, lastX, y + offset * .05, color, ax, ay))
        end
    end)

    -- Gradient
    onyx.scoreboard:RegisterNameEffect('gradient_invert', function(text, x, y, color, ax, ay, realX, realY)
        local color1 = color
        local h, s, v = ColorToHSV(color1)
        local color2 = onyx.ColorEditHSV(color1, (h + 180) % 360)

        SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)
        local textW, textH = SimpleText(text, fontCommon, x, y, color, ax, ay)

        local realYStart = realY - textH * .5

        render.SetScissorRect(realX, realYStart + textH * .65, realX + textW, realYStart + textH, true)
            SimpleText(text, fontCommon, x, y, color2, ax, ay)
        render.SetScissorRect(0, 0, 0, 0, false)
    end)

    -- Scanning
    onyx.scoreboard:RegisterNameEffect('scanning_vertical', function(text, x, y, color, ax, ay, realX, realY)
        SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)
        SimpleText(text, fontGlow, x, y, ColorAlpha(color, 30), ax, ay)
        local textW, textH = SimpleText(text, fontCommon, x, y, color_black, ax, ay)

        local realYStart = realY - textH * .5
        local animYStart = realYStart + textH * ((CurTime() * .5) % 1.5)
        local scanLineHeight = textH
        local scanLineRadius = scanLineHeight * .15

        render.SetScissorRect(realX, animYStart, realX + textW, animYStart + scanLineRadius, true)
            SimpleText(text, fontCommon, x, y, color, ax, ay)
        render.SetScissorRect(0, 0, 0, 0, false)
    end)

    onyx.scoreboard:RegisterNameEffect('scanning_horizontal', function(text, x, y, color, ax, ay, realX, realY)
        SimpleText(text, fontCommon, x + SHADOW_DISTANCE, y + SHADOW_DISTANCE, COLOR_SHADOW, ax, ay)
        SimpleText(text, fontGlow, x, y, ColorAlpha(color, 30), ax, ay)
        local textW, textH = SimpleText(text, fontCommon, x, y, color_black, ax, ay)

        local realYStart = realY - textH * .5
        local animXStart = realX + textW * ((CurTime() * 1) % 1.5)
        local scanLineWidth = textW
        local scanLineRadius = scanLineWidth * .1

        render.SetScissorRect(animXStart, realYStart, animXStart + scanLineRadius, realYStart + textH, true)
            SimpleText(text, fontCommon, x, y, color, ax, ay)
        render.SetScissorRect(0, 0, 0, 0, false)
    end)
end

net.Receive('onyx.scoreboard:SyncRanks', function(length)
    local rawData = net.ReadData(length)
    local parsedData = pon.decode(rawData)

    onyx.scoreboard.ranks = parsedData
    onyx.scoreboard:Print('Synchronized ranks.')

    hook.Run('onyx.scoreboard.SyncedRanks')
end)