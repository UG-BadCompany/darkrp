local hud = vox.hud
local helpers = hud.presetHelpers

local function drawRoleplayProfile( self, client, scrW, scrH )
    local _, colors, teamColor = helpers.GetThemeData( client )
    local space = hud.GetScreenPadding()
    local w, h = hud.ScaleWide( 370 ), hud.ScaleTall( 132 )
    local x, y = space, scrH - space - h
    local health = math.Clamp( client:Health() / math.max( client:GetMaxHealth(), 1 ), 0, 1 )
    local armor = math.Clamp( client:Armor() / math.max( client:GetMaxArmor() or 100, 1 ), 0, 1 )

    vox.DrawVoxCard( x, y, w, h, colors, { accent = teamColor, radius = hud.GetRoundness(), bladeWidth = hud.ScaleWide( 9 ) } )
    vox.DrawVoxBadge( x + hud.ScaleWide( 24 ), y + hud.ScaleTall( 16 ), hud.ScaleWide( 128 ), hud.ScaleTall( 18 ), 'Roleplay Profile', colors, { accent = teamColor } )
    helpers.DrawIdentity( client, x + hud.ScaleWide( 24 ), y + hud.ScaleTall( 44 ), colors, teamColor, hud.fonts.SmallBold, hud.fonts.TinyBold )
    vox.DrawVoxStatModule( x + w - hud.ScaleWide( 150 ), y + hud.ScaleTall( 16 ), hud.ScaleWide( 126 ), hud.ScaleTall( 44 ), 'Wallet', helpers.FormatMoney( client:getDarkRPVar( 'money' ) ), colors, { accent = colors.money or colors.positive } )
    vox.DrawVoxStatModule( x + w - hud.ScaleWide( 150 ), y + hud.ScaleTall( 70 ), hud.ScaleWide( 126 ), hud.ScaleTall( 42 ), 'Salary', helpers.FormatSalary( client:getDarkRPVar( 'salary' ) ), colors, { accent = colors.money or colors.positive } )
    helpers.DrawBar( x + hud.ScaleWide( 24 ), y + hud.ScaleTall( 92 ), hud.ScaleWide( 190 ), hud.ScaleTall( 10 ), health, colors.negative, colors, 'HEALTH' )
    helpers.DrawBar( x + hud.ScaleWide( 24 ), y + hud.ScaleTall( 112 ), hud.ScaleWide( 190 ), hud.ScaleTall( 8 ), armor, colors.armor or Color( 88, 166, 255 ), colors, 'ARMOR' )
end

hud:RegisterHUDPreset( 'roleplay_profile', { name = 'Vox Roleplay Profile', style = 3, drawFn = drawRoleplayProfile } )
hud.DrawVoxRoleplayProfile = drawRoleplayProfile
