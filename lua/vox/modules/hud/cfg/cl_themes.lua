-- Vox UI premium theme presets. All HUD elements should consume these tokens.
local function voxTheme(primary, secondary, tertiary, accent, extras)
    extras = extras or {}
    local colors = {
            primary = primary,
            secondary = secondary,
            tertiary = tertiary,
            quaternary = extras.quaternary or Color(8, 11, 16),
            accent = accent,
            secondaryAccent = extras.secondaryAccent or Color(142, 84, 255),
            border = extras.border or Color(46, 62, 88),
            glow = ColorAlpha and ColorAlpha(accent, extras.glowAlpha or 70) or accent,
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
        if ( key ~= 'selectable' and key ~= 'sortOrder' and key ~= 'glowAlpha' ) then
            colors[ key ] = value
        end
    end
    return { colors = colors, selectable = extras.selectable ~= false, sortOrder = extras.sortOrder or 100 }
end

vox.hud:CreateTheme( 'default', voxTheme(
    Color(7, 10, 18), Color(12, 18, 31), Color(20, 29, 46), Color(0, 204, 255), {
        secondaryAccent = Color(124, 92, 255),
        border = Color(34, 56, 86),
        glowAlpha = 92,
        sortOrder = 0
    }
) )

vox.hud:CreateTheme( 'vox_midnight', voxTheme(
    Color(6, 13, 29), Color(10, 24, 45), Color(17, 42, 72), Color(73, 166, 255), {
        secondaryAccent = Color(88, 101, 242),
        border = Color(31, 66, 105),
        sortOrder = 1
    }
) )

vox.hud:CreateTheme( 'vox_royal_purple', voxTheme(
    Color(18, 10, 33), Color(31, 18, 55), Color(52, 31, 86), Color(190, 100, 255), {
        secondaryAccent = Color(255, 93, 180),
        border = Color(74, 49, 111),
        sortOrder = 2
    }
) )

vox.hud:CreateTheme( 'vox_emerald', voxTheme(
    Color(4, 20, 18), Color(8, 35, 31), Color(14, 58, 48), Color(45, 226, 160), {
        secondaryAccent = Color(75, 190, 255),
        border = Color(24, 82, 68),
        sortOrder = 3
    }
) )

vox.hud:CreateTheme( 'vox_carbon_red', voxTheme(
    Color(18, 12, 15), Color(32, 20, 24), Color(54, 31, 37), Color(255, 72, 104), {
        secondaryAccent = Color(255, 157, 77),
        border = Color(90, 44, 54),
        sortOrder = 4
    }
) )

vox.hud:CreateTheme( 'vox_gold', voxTheme(
    Color(20, 15, 7), Color(36, 27, 13), Color(62, 46, 20), Color(255, 205, 72), {
        secondaryAccent = Color(255, 132, 60),
        border = Color(92, 68, 31),
        sortOrder = 5
    }
) )

vox.hud:CreateTheme( 'vox_light', voxTheme(
    Color(228, 235, 246), Color(243, 247, 253), Color(255, 255, 255), Color(0, 126, 255), {
        quaternary = Color(212, 223, 240),
        secondaryAccent = Color(111, 76, 255),
        border = Color(178, 192, 214),
        textPrimary = Color(18, 25, 38),
        textSecondary = Color(72, 84, 106),
        textTertiary = Color(116, 130, 154),
        sortOrder = 6
    }
) )

vox.hud:CreateTheme( 'custom_accent', voxTheme(
    Color(7, 10, 18), Color(12, 18, 31), Color(20, 29, 46), vox:Config( 'colors.accent' ), {
        sortOrder = 7
    }
) )

-- Legacy names retained so existing saves do not break, but hidden from the picker
-- to avoid multiple nearly identical theme presets.
local function legacyThemeAlias( id, targetID )
    local target = vox.hud.themes[ targetID ] or vox.hud.themes.default
    local alias = table.Copy( target )
    alias.selectable = false
    alias.aliasOf = targetID
    vox.hud.themes[ id ] = alias
end

legacyThemeAlias( 'vox', 'default' )
legacyThemeAlias( 'vox_obsidian', 'default' )
legacyThemeAlias( 'gray', 'vox_light' )
legacyThemeAlias( 'golden_dawn', 'vox_gold' )
legacyThemeAlias( 'sky_blue', 'vox_midnight' )
legacyThemeAlias( 'mint_light', 'vox_emerald' )
legacyThemeAlias( 'lavender', 'vox_royal_purple' )
legacyThemeAlias( 'green_apple', 'vox_emerald' )
legacyThemeAlias( 'elegance', 'default' )
legacyThemeAlias( 'ocean_wave', 'vox_midnight' )
legacyThemeAlias( 'violet_night', 'vox_royal_purple' )
legacyThemeAlias( 'forest', 'vox_emerald' )
legacyThemeAlias( 'rose_garden', 'vox_carbon_red' )
legacyThemeAlias( 'rustic_ember', 'vox_carbon_red' )
