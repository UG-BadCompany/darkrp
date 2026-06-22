vox.hud.themes = vox.hud.themes or {}

local CONVAR_THEME = CreateClientConVar( 'cl_vox_hud_theme_id', 'default', true, false )

cvars.AddChangeCallback( 'cl_vox_hud_theme_id', function( _, _, new )
    hook.Run( 'vox.hud.OnChangedTheme', vox.hud:GetCurrentTheme() )
end, 'vox.hud.internal' )

-- predefined colors
local COLORS = {
    [ 'light' ] = {
        textPrimary = color_black,
        textSecondary = Color( 45, 45, 45 ),
        textTertiary = Color( 70, 70, 70),
        negative = Color( 210, 35, 35),
        lockdown = Color( 166, 44, 44)
    },
    [ 'dark' ] = {
        textPrimary = color_white,
        textSecondary = Color( 171, 171, 171),
        textTertiary = Color( 97, 97, 97),
        negative = Color( 255, 76, 76),
        lockdown = Color( 255, 76, 76)
    }
}

function vox.hud:GetColor( id )
    local themeTable = self:GetCurrentTheme() or {}
    local colorsTable = themeTable.colors or {}

    return colorsTable[ id ]
end

function vox.hud:GetCurrentTheme()
    local theme

    if ( self:GetOptionValue( 'restrict_themes' ) ) then
        theme = self.themes[ 'default' ]
    else
        local themeID = CONVAR_THEME:GetString()
        theme = self.themes[ themeID ] or self.themes[ 'default' ]
    end

    theme = theme or {}
    theme.colors = theme.colors or {}

    return theme
end

function vox.hud:IsDark()
    local theme = self:GetCurrentTheme() or {}
    return theme.dark or false
end

function vox.hud:CreateTheme( id, data )
    data.colors = data.colors or {}
    local colors = data.colors
    local _, _, lightness = ColorToHSL( colors.primary or Color( 20, 22, 28 ) )
    local isDark = lightness < .5
    local predefinedColors = COLORS[ isDark and 'dark' or 'light' ]

    data.id = id
    data.dark = isDark
    data.isDark = isDark

    table.Inherit( colors, predefinedColors )

    self.themes[ id ] = data
end
