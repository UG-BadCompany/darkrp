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
    colors = colors or ( vox.GetThemeColors and vox.GetThemeColors() ) or {}
    radius = radius or 16
    local primary = colors.primary or Color( 7, 10, 18 )
    local secondary = colors.secondary or Color( 18, 26, 43 )
    local tertiary = colors.tertiary or Color( 24, 35, 56 )
    local accent = colors.accent or Color( 0, 188, 255 )
    local violet = colors.violet or Color( 139, 92, 246 )

    draw.RoundedBox( radius, x, y, w, h, ColorAlpha( primary, 238 ) )
    vox.DrawMatGradient( x, y, w, h, RIGHT, ColorAlpha( accent, 24 ) )
    vox.DrawMatGradient( x, y, w, h, BOTTOM, ColorAlpha( violet, 16 ) )
    vox.DrawMatGradient( x, y, w, h, TOP, ColorAlpha( tertiary, 74 ) )

    surface.SetDrawColor( ColorAlpha( secondary, 230 ) )
    surface.DrawOutlinedRect( x + 1, y + 1, w - 2, h - 2, 1 )
    surface.SetDrawColor( ColorAlpha( color_white, 10 ) )
    surface.DrawLine( x + radius, y + 2, x + w - radius, y + 2 )
    surface.SetDrawColor( ColorAlpha( accent, 115 ) )
    surface.DrawLine( x + radius, y + 1, x + math.min( w - radius, 150 ), y + 1 )
    surface.DrawLine( x + w - math.min( w - radius, 150 ), y + h - 2, x + w - radius, y + h - 2 )
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

function vox.DrawVoxCard( x, y, w, h, colors, state )
    colors = colors or ( vox.GetThemeColors and vox.GetThemeColors() ) or {}
    state = state or {}
    local accent = state.accent or colors.accent or Color( 0, 174, 255 )
    local lift = state.hovered and 3 or 0

    vox.DrawVoxPanel( x, y - lift, w, h, colors, state.radius or 6 )
    vox.DrawVoxBlade( x, y + 8 - lift, state.bladeWidth or 7, h - 16, accent, accent )

    if state.hovered then
        vox.DrawAngledRect( x + w - 74, y - lift, 74, h, 16, ColorAlpha( accent, 34 ) )
        surface.SetDrawColor( ColorAlpha( accent, 120 ) )
        surface.DrawOutlinedRect( x + 1, y + 1 - lift, w - 2, h - 2, 1 )
    end
end

function vox.DrawVoxRowHover( x, y, w, h, accent, amount )
    amount = amount or 1
    if amount <= 0 then return end

    accent = accent or Color( 0, 174, 255 )
    vox.DrawAngledRect( x, y, w, h, 10, ColorAlpha( accent, 20 * amount ) )
    vox.DrawVoxBlade( x, y + 5, 5, h - 10, ColorAlpha( accent, 220 * amount ), accent )
end
