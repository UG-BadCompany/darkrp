--[[------------------------------
Vox visual helper aliases matching the public README naming.
These wrappers keep older call sites working while exposing the documented
angled accent blade, Vox card, Vox row, Vox badge, and Vox stat module names.
--------------------------------]]
function vox.DrawVoxAngledAccentBlade( x, y, w, h, color, glowColor )
    return vox.DrawVoxBlade( x, y, w, h, color, glowColor )
end

function vox.DrawVoxRow( x, y, w, h, colors, state )
    colors = colors or ( vox.GetThemeColors and vox.GetThemeColors() ) or {}
    state = state or {}
    local accent = state.accent or colors.accent or Color( 0, 174, 255 )
    local bg = state.background or colors.secondary or Color( 16, 22, 34 )

    vox.DrawAngledRect( x, y, w, h, state.cut or 10, ColorAlpha( bg, state.alpha or 210 ) )
    if state.hovered or state.selected then
        vox.DrawVoxRowHover( x, y, w, h, accent, state.selected and 1 or 0.65 )
    end
end

function vox.DrawVoxBadge( x, y, w, h, label, colors, state )
    colors = colors or ( vox.GetThemeColors and vox.GetThemeColors() ) or {}
    state = state or {}
    local accent = state.accent or colors.accent or Color( 0, 174, 255 )
    local textColor = state.textColor or colors.textPrimary or Color( 255, 255, 255 )
    local font = state.font or ( vox.hud and vox.hud.fonts and vox.hud.fonts.ExtraTinyBold ) or 'DermaDefaultBold'

    vox.DrawAngledRect( x, y, w, h, state.cut or 7, ColorAlpha( accent, state.alpha or 42 ) )
    surface.SetDrawColor( ColorAlpha( accent, 155 ) )
    surface.DrawOutlinedRect( x, y, w, h, 1 )
    draw.SimpleText( string.upper( tostring( label or '' ) ), font, x + w * .5, y + h * .5, textColor, 1, 1 )
end

function vox.DrawVoxStatModule( x, y, w, h, label, value, colors, state )
    colors = colors or ( vox.GetThemeColors and vox.GetThemeColors() ) or {}
    state = state or {}
    local accent = state.accent or colors.accent or Color( 0, 174, 255 )
    local labelFont = state.labelFont or ( vox.hud and vox.hud.fonts and vox.hud.fonts.ExtraTinyBold ) or 'DermaDefaultBold'
    local valueFont = state.valueFont or ( vox.hud and vox.hud.fonts and vox.hud.fonts.TinyBold ) or 'DermaDefaultBold'

    vox.DrawVoxCard( x, y, w, h, colors, { accent = accent, hovered = state.hovered, radius = state.radius or 6, bladeWidth = state.bladeWidth or 5 } )
    draw.SimpleText( string.upper( tostring( label or '' ) ), labelFont, x + ( state.textInset or 16 ), y + h * .35, colors.textSecondary or Color( 180, 190, 205 ), 0, 1 )
    draw.SimpleText( tostring( value or '' ), valueFont, x + w - ( state.textInset or 12 ), y + h * .68, state.valueColor or colors.textPrimary or Color( 255, 255, 255 ), 2, 1 )
end

-- Public Vox UI helper aliases used by HUD/F4/Scoreboard/Admin integrations.
vox.ui = vox.ui or {}

function vox.ui.DrawGlassPanel( x, y, w, h, colors, state )
    colors = vox.SafeColors and vox.SafeColors( colors ) or ( colors or {} )
    state = state or {}
    if vox.DrawVoxGlass then
        return vox.DrawVoxGlass( x, y, w, h, { radius = state.radius or 18, alpha = state.alpha or 232, accent = state.accent or colors.accent, base = state.base or colors.primary } )
    end
    return vox.DrawVoxPanel( x, y, w, h, colors, state.radius )
end

function vox.ui.DrawCard( x, y, w, h, colors, state )
    colors = vox.SafeColors and vox.SafeColors( colors ) or ( colors or {} )
    return vox.DrawVoxCard( x, y, w, h, colors, state or {} )
end

function vox.ui.DrawButton( x, y, w, h, label, colors, state )
    colors = vox.SafeColors and vox.SafeColors( colors ) or ( colors or {} )
    state = state or {}
    vox.ui.DrawCard( x, y, w, h, colors, { accent = state.accent or colors.accent, hovered = state.hovered, radius = state.radius or 10 } )
    draw.SimpleText( vox.SafeText and vox.SafeText( label ) or tostring( label or '' ), state.font or 'DermaDefaultBold', x + w * .5, y + h * .5, state.textColor or colors.textPrimary or color_white, 1, 1 )
end

function vox.ui.DrawSearchBox( x, y, w, h, colors, state )
    colors = vox.SafeColors and vox.SafeColors( colors ) or ( colors or {} )
    vox.ui.DrawGlassPanel( x, y, w, h, colors, { radius = ( state and state.radius ) or 12, alpha = 218 } )
end

function vox.ui.DrawBadge( x, y, w, h, label, colors, state )
    return vox.DrawVoxBadge( x, y, w, h, label, vox.SafeColors and vox.SafeColors( colors ) or colors, state or {} )
end

function vox.ui.DrawProgressBar( x, y, w, h, fraction, color, colors )
    colors = vox.SafeColors and vox.SafeColors( colors ) or ( colors or {} )
    fraction = math.Clamp( tonumber( fraction ) or 0, 0, 1 )
    draw.RoundedBox( h * .5, x, y, w, h, ColorAlpha( colors.textPrimary or color_white, 20 ) )
    draw.RoundedBox( h * .5, x, y, w * fraction, h, color or colors.accent or Color( 0, 188, 255 ) )
end

function vox.ui.DrawAvatar( x, y, size, color )
    vox.DrawOutlinedCircle( x + size * .5, y + size * .5, size * .5, 3, color or Color( 0, 188, 255 ) )
end

function vox.ui.DrawNotification( x, y, w, h, text, colors, state )
    vox.ui.DrawCard( x, y, w, h, colors, state or {} )
    draw.SimpleText( vox.SafeText and vox.SafeText( text ) or tostring( text or '' ), ( state and state.font ) or 'DermaDefault', x + 14, y + h * .5, ( colors and colors.textPrimary ) or color_white, 0, 1 )
end

function vox.ui.DrawModal( x, y, w, h, colors, state )
    return vox.ui.DrawGlassPanel( x, y, w, h, colors, state or { radius = 22, alpha = 244 } )
end

function vox.ui.DrawContextMenu( x, y, w, h, colors, state )
    return vox.ui.DrawGlassPanel( x, y, w, h, colors, state or { radius = 14, alpha = 238 } )
end
