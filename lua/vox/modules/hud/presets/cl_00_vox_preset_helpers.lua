local hud = vox.hud

vox.hud.presetHelpers = vox.hud.presetHelpers or {}
local helpers = vox.hud.presetHelpers

function helpers.FormatMoney( amount )
    amount = math.Round( tonumber( amount ) or 0 )
    return DarkRP and DarkRP.formatMoney and DarkRP.formatMoney( amount ) or tostring( amount )
end

function helpers.FormatSalary( salary )
    return '+ ' .. helpers.FormatMoney( salary or 0 )
end

function helpers.GetPlayerJob( client )
    return client:getDarkRPVar( 'job' ) or team.GetName( client:Team() )
end

function helpers.GetThemeData( client )
    local colors, theme = (vox.GetThemeColors and vox.GetThemeColors()) or {}, nil
    colors = colors or (vox.PremiumPalette and vox.PremiumPalette()) or {}
    colors.textPrimary = colors.textPrimary or colors.text or color_white
    colors.textSecondary = colors.textSecondary or colors.muted or Color( 145, 160, 184 )
    colors.accent = colors.accent or Color( 0, 188, 255 )
    colors.negative = colors.negative or Color( 255, 78, 104 )
    colors.positive = colors.positive or Color( 72, 221, 142 )
    colors.money = colors.money or colors.positive
    return theme, colors, team.GetColor( client:Team() )
end

function helpers.DrawBar( x, y, w, h, fraction, color, colors, label )
    fraction = math.Clamp( fraction or 0, 0, 1 )
    draw.RoundedBox( h * .5, x, y, w, h, ColorAlpha( colors.textPrimary or color_white, 20 ) )
    render.SetScissorRect( x, y, x + w * fraction, y + h, true )
        draw.RoundedBox( h * .5, x, y, w, h, color )
    render.SetScissorRect( 0, 0, 0, 0, false )
    if label then draw.SimpleText( label, hud.fonts.ExtraTinyBold, x + w, y + h * .5, colors.textSecondary, 2, 1 ) end
end

function helpers.DrawIdentity( client, x, y, colors, teamColor, nameFont, jobFont )
    draw.SimpleText( client:Name(), nameFont or hud.fonts.SmallBold, x, y, colors.textPrimary, 0, 0 )
    draw.SimpleText( helpers.GetPlayerJob( client ), jobFont or hud.fonts.TinyBold, x, y + hud.ScaleTall( 22 ), teamColor, 0, 0 )
end
