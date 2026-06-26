local hud = vox.hud
local helpers = hud.presetHelpers

local function drawMinimalEdge( self, client, scrW, scrH )
    local _, colors, teamColor = helpers.GetThemeData( client )
    local space = hud.GetScreenPadding()
    local health = math.Clamp( client:Health() / math.max( client:GetMaxHealth(), 1 ), 0, 1 )
    local railW = hud.ScaleWide( 8 )

    helpers.DrawPresetBackdrop( space + hud.ScaleWide( 18 ), scrH - space - hud.ScaleTall( 42 ), hud.ScaleWide( 320 ), hud.ScaleTall( 42 ), colors, teamColor, 8 )
    vox.DrawVoxAngledAccentBlade( space, space, railW, scrH - space * 2, colors.accent )
    vox.DrawVoxAngledAccentBlade( scrW - space - railW, space, railW, scrH - space * 2, teamColor )
    vox.DrawVoxRow( space + hud.ScaleWide( 18 ), scrH - space - hud.ScaleTall( 42 ), hud.ScaleWide( 320 ), hud.ScaleTall( 42 ), colors, { accent = teamColor, selected = true } )
    draw.SimpleText( string.upper( client:Name() ), hud.fonts.TinyBold, space + hud.ScaleWide( 34 ), scrH - space - hud.ScaleTall( 31 ), colors.textPrimary, 0, 1 )
    draw.SimpleText( string.upper( helpers.GetPlayerJob( client ) ), hud.fonts.ExtraTinyBold, space + hud.ScaleWide( 34 ), scrH - space - hud.ScaleTall( 14 ), teamColor, 0, 1 )
    helpers.DrawBar( space + hud.ScaleWide( 170 ), scrH - space - hud.ScaleTall( 27 ), hud.ScaleWide( 150 ), hud.ScaleTall( 8 ), health, colors.negative, colors )
    vox.DrawVoxBadge( scrW - space - hud.ScaleWide( 230 ), scrH - space - hud.ScaleTall( 34 ), hud.ScaleWide( 210 ), hud.ScaleTall( 24 ), helpers.FormatMoney( client:getDarkRPVar( 'money' ) ), colors, { accent = colors.money or colors.positive } )
end

hud:RegisterHUDPreset( 'minimal_edge', { name = 'Minimal Corner', style = 2, drawFn = drawMinimalEdge } )
hud.DrawVoxMinimalEdge = drawMinimalEdge
