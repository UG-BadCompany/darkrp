local hud = vox.hud
local helpers = hud.presetHelpers

local function drawCommandStrip( self, client, scrW, scrH )
    local _, colors, teamColor = helpers.GetThemeData( client )
    local space = hud.GetScreenPadding()
    local w, h = scrW - space * 2, hud.ScaleTall( 56 )
    local x, y = space, scrH - space - h
    local health = math.Clamp( client:Health() / math.max( client:GetMaxHealth(), 1 ), 0, 1 )
    local armor = math.Clamp( client:Armor() / math.max( client:GetMaxArmor() or 100, 1 ), 0, 1 )

    vox.DrawVoxPanel( x, y, w, h, colors, hud.GetRoundness() )
    vox.DrawVoxAngledAccentBlade( x + 10, y + 8, 8, h - 16, colors.accent )
    vox.DrawVoxAngledAccentBlade( x + w - 18, y + 8, 8, h - 16, teamColor )
    draw.SimpleText( string.upper( client:Name() ), hud.fonts.SmallBold, x + hud.ScaleWide( 34 ), y + hud.ScaleTall( 15 ), colors.textPrimary, 0, 1 )
    draw.SimpleText( string.upper( helpers.GetPlayerJob( client ) ), hud.fonts.ExtraTinyBold, x + hud.ScaleWide( 34 ), y + hud.ScaleTall( 36 ), teamColor, 0, 1 )
    helpers.DrawBar( x + hud.ScaleWide( 300 ), y + hud.ScaleTall( 18 ), hud.ScaleWide( 260 ), hud.ScaleTall( 10 ), health, colors.negative, colors, 'HP' )
    helpers.DrawBar( x + hud.ScaleWide( 590 ), y + hud.ScaleTall( 18 ), hud.ScaleWide( 220 ), hud.ScaleTall( 10 ), armor, colors.armor or Color( 88, 166, 255 ), colors, 'AR' )
    vox.DrawVoxStatModule( x + w - hud.ScaleWide( 310 ), y + hud.ScaleTall( 8 ), hud.ScaleWide( 132 ), h - hud.ScaleTall( 16 ), 'Balance', helpers.FormatMoney( client:getDarkRPVar( 'money' ) ), colors, { accent = colors.money or colors.positive, radius = 4 } )
    vox.DrawVoxStatModule( x + w - hud.ScaleWide( 166 ), y + hud.ScaleTall( 8 ), hud.ScaleWide( 138 ), h - hud.ScaleTall( 16 ), 'Salary', helpers.FormatSalary( client:getDarkRPVar( 'salary' ) ), colors, { accent = colors.money or colors.positive, radius = 4 } )
end

hud:RegisterHUDPreset( 'command_strip', { name = 'Vox Command Strip', style = 1, drawFn = drawCommandStrip } )
hud.DrawVoxCommandStrip = drawCommandStrip
