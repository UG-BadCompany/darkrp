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
