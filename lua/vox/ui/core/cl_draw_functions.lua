--[[

Author: tochnonement
Email: tochnonement@gmail.com

18/11/2023

--]]

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
