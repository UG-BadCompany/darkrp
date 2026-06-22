do
    for thickness = 1, 6 do
        vox.spoly.Generate('vox_circle_outline_' .. thickness, function(w, h)
            local scaledThickness = thickness * 32

            local x = w * .5
            local y = h * .5
            local r = h * .5
            local vertices = 64

            local circleInner = vox.CalculateCircle(x, y, r - scaledThickness, vertices)
            local circleOuter = vox.CalculateCircle(x, y, r, vertices)

            vox.InverseMaskFn(function()
                surface.DrawPoly(circleInner)
            end, function()
                surface.DrawPoly(circleOuter)
            end)
        end)
    end
end

do
    vox.spoly.Generate('vox_circle', function(w, h)
        local x0, y0 = w * .5, h * .5
        local r = h * .5
        local vertexs = 64
        local circle = vox.CalculateCircle(x0, y0, r, vertexs)

        surface.DrawPoly(circle)
    end)
end

--[[------------------------------
Draws a smooth outline for a circle
Available thickness: [1; 6]
--------------------------------]]
function vox.DrawOutlinedCircle(x0, y0, r, thickness, color)
    local id = 'vox_circle_outline_' .. thickness
    local d = r * 2

    vox.spoly.DrawRotated(id, x0, y0, d, d, 0, color)
end

--[[------------------------------
Draws a smooth circle
--------------------------------]]
function vox.DrawCircle(x0, y0, r, color)
    local x = x0 - r
    local y = y0 - r
    local d = r * 2

    if (color) then
        surface.SetDrawColor(color)
    end
    vox.spoly.Draw('vox_circle', x, y, d, d)
end

function vox.DrawAngledRect( x, y, w, h, cut, color )
    cut = math.min( cut or 10, w * .45, h * .45 )
    surface.SetDrawColor( color )
    draw.NoTexture()
    surface.DrawPoly( {
        { x = x + cut, y = y },
        { x = x + w, y = y },
        { x = x + w - cut, y = y + h },
        { x = x, y = y + h }
    } )
end

function vox.DrawVoxBlade( x, y, w, h, color, glowColor )
    glowColor = glowColor or color
    vox.DrawAngledRect( x - 2, y, w + 4, h, math.min( w * .5, 12 ), ColorAlpha( glowColor, 28 ) )
    vox.DrawAngledRect( x, y, w, h, math.min( w * .45, 10 ), color )
end

function vox.DrawVoxPanel( x, y, w, h, colors, radius )
    colors = colors or ( vox.hud and vox.hud:GetCurrentTheme().colors ) or {}
    radius = radius or 8
    local primary = colors.primary or Color( 10, 13, 20 )
    local secondary = colors.secondary or Color( 16, 22, 34 )
    local tertiary = colors.tertiary or Color( 24, 32, 48 )
    local accent = colors.accent or Color( 0, 174, 255 )

    draw.RoundedBox( radius, x, y, w, h, ColorAlpha( primary, 238 ) )
    vox.DrawMatGradient( x, y, w, h, RIGHT, ColorAlpha( accent, 20 ) )
    vox.DrawMatGradient( x, y, w, h, BOTTOM, ColorAlpha( tertiary, 70 ) )

    surface.SetDrawColor( ColorAlpha( secondary, 210 ) )
    surface.DrawOutlinedRect( x + 1, y + 1, w - 2, h - 2, 1 )
    surface.SetDrawColor( ColorAlpha( accent, 90 ) )
    surface.DrawLine( x + 10, y + 1, x + math.min( w - 10, 82 ), y + 1 )
    surface.DrawLine( x + w - math.min( w - 10, 82 ), y + h - 2, x + w - 10, y + h - 2 )
end

function vox.DrawVoxCornerTicks( x, y, w, h, color, size )
    size = size or 14
    surface.SetDrawColor( color )
    surface.DrawLine( x, y, x + size, y )
    surface.DrawLine( x, y, x, y + size )
    surface.DrawLine( x + w, y + h, x + w - size, y + h )
    surface.DrawLine( x + w, y + h, x + w, y + h - size )
end

function vox.DrawVoxScanlines( x, y, w, h, color, step )
    step = step or 6
    surface.SetDrawColor( color )
    for lineY = y, y + h, step do
        surface.DrawLine( x, lineY, x + w, lineY )
    end
end
