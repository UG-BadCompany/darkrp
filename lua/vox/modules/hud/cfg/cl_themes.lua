-- Vox UI command-center theme presets. All HUD elements should consume these tokens.
local function voxTheme(primary, secondary, tertiary, accent, extras)
    extras = extras or {}
    local colors = {
            primary = primary,
            secondary = secondary,
            tertiary = tertiary,
            quaternary = Color(8, 11, 16),
            accent = accent,
            border = Color(46, 62, 88),
            glow = ColorAlpha and ColorAlpha(accent, 70) or accent,
            textPrimary = Color(246, 248, 255),
            textSecondary = Color(166, 178, 204),
            textTertiary = Color(96, 110, 138),
            positive = Color(52, 211, 153),
            money = Color(52, 211, 153),
            negative = Color(255, 80, 105),
            armor = Color(88, 166, 255),
            hunger = Color(245, 197, 66),
            xp = Color(245, 197, 66),
            lockdown = Color(255, 80, 105)
        }
    for key, value in pairs( extras ) do
        colors[ key ] = value
    end
    return { colors = colors }
end

vox.hud:CreateTheme( 'default', voxTheme(
    Color(10, 13, 20), Color(16, 22, 34), Color(24, 32, 48), Color(0, 174, 255)
) )

vox.hud:CreateTheme( 'vox_obsidian', voxTheme(
    Color(9, 11, 16), Color(14, 19, 29), Color(23, 31, 45), Color(0, 174, 255)
) )

vox.hud:CreateTheme( 'vox_midnight', voxTheme(
    Color(8, 14, 28), Color(13, 24, 42), Color(20, 38, 62), Color(72, 149, 255)
) )

vox.hud:CreateTheme( 'vox_royal_purple', voxTheme(
    Color(16, 12, 28), Color(26, 18, 45), Color(42, 28, 68), Color(177, 94, 255)
) )

vox.hud:CreateTheme( 'vox_carbon_red', voxTheme(
    Color(16, 14, 16), Color(27, 21, 23), Color(46, 30, 34), Color(255, 66, 92)
) )

vox.hud:CreateTheme( 'vox_emerald', voxTheme(
    Color(8, 18, 16), Color(12, 31, 27), Color(18, 50, 42), Color(52, 211, 153)
) )

vox.hud:CreateTheme( 'vox_gold', voxTheme(
    Color(18, 15, 10), Color(33, 27, 16), Color(56, 44, 22), Color(245, 197, 66)
) )

vox.hud:CreateTheme( 'vox_light', voxTheme(
    Color(230, 235, 245), Color(244, 247, 252), Color(255, 255, 255), Color(0, 124, 255), {
        quaternary = Color(216, 224, 238),
        textPrimary = Color(20, 27, 39),
        textSecondary = Color(74, 86, 108),
        textTertiary = Color(120, 132, 154)
    }
) )

vox.hud:CreateTheme( 'custom_accent', voxTheme(
    Color(10, 13, 20), Color(16, 22, 34), Color(24, 32, 48), vox:Config( 'colors.accent' )
) )

-- Legacy names retained so existing saves do not break.
vox.hud.themes.vox = vox.hud.themes.default
vox.hud.themes.gray = vox.hud.themes.vox_light
vox.hud.themes.golden_dawn = vox.hud.themes.vox_gold
vox.hud.themes.sky_blue = vox.hud.themes.vox_midnight
vox.hud.themes.mint_light = vox.hud.themes.vox_emerald
vox.hud.themes.lavender = vox.hud.themes.vox_royal_purple
vox.hud.themes.green_apple = vox.hud.themes.vox_emerald
vox.hud.themes.elegance = vox.hud.themes.vox_obsidian
vox.hud.themes.ocean_wave = vox.hud.themes.vox_midnight
vox.hud.themes.violet_night = vox.hud.themes.vox_royal_purple
vox.hud.themes.forest = vox.hud.themes.vox_emerald
vox.hud.themes.rose_garden = vox.hud.themes.vox_carbon_red
vox.hud.themes.rustic_ember = vox.hud.themes.vox_carbon_red
