local hud = vox.hud
local helpers = hud.presetHelpers

local function drawTacticalCard( self, client, scrW, scrH )
    local _, colors, teamColor = helpers.GetThemeData( client )
    local space = hud.GetScreenPadding()
    local w, h = hud.ScaleWide( 340 ), hud.ScaleTall( 126 )
    local x, y = space, scrH - space - h
    local health = math.Clamp( client:Health() / math.max( client:GetMaxHealth(), 1 ), 0, 1 )
    local armor = math.Clamp( client:Armor() / math.max( client:GetMaxArmor() or 100, 1 ), 0, 1 )

    vox.DrawVoxCard( x, y, w, h, colors, { accent = teamColor, radius = hud.GetRoundness(), bladeWidth = hud.ScaleWide( 10 ) } )
    vox.DrawVoxCornerTicks( x + 8, y + 8, w - 16, h - 16, ColorAlpha( colors.accent, 95 ), 18 )
    helpers.DrawIdentity( client, x + hud.ScaleWide( 28 ), y + hud.ScaleTall( 16 ), colors, teamColor, hud.fonts.SmallBold, hud.fonts.Tiny )
    vox.DrawVoxStatModule( x + w - hud.ScaleWide( 144 ), y + hud.ScaleTall( 14 ), hud.ScaleWide( 124 ), hud.ScaleTall( 42 ), 'Balance', helpers.FormatMoney( client:getDarkRPVar( 'money' ) ), colors, { accent = colors.money or colors.positive } )
    draw.SimpleText( 'STIPEND ' .. helpers.FormatSalary( client:getDarkRPVar( 'salary' ) ), hud.fonts.ExtraTinyBold, x + w - hud.ScaleWide( 20 ), y + hud.ScaleTall( 64 ), colors.textSecondary, 2, 0 )
    helpers.DrawBar( x + hud.ScaleWide( 28 ), y + hud.ScaleTall( 78 ), w - hud.ScaleWide( 56 ), hud.ScaleTall( 10 ), health, colors.negative, colors, math.Round( health * 100 ) .. '%' )
    helpers.DrawBar( x + hud.ScaleWide( 28 ), y + hud.ScaleTall( 98 ), w - hud.ScaleWide( 56 ), hud.ScaleTall( 8 ), armor, colors.armor or Color( 88, 166, 255 ), colors )
    vox.DrawVoxBadge( x + hud.ScaleWide( 28 ), y + h - hud.ScaleTall( 20 ), hud.ScaleWide( 70 ), hud.ScaleTall( 16 ), client:getDarkRPVar( 'wanted' ) and 'WANTED' or 'CLEAR', colors, { accent = client:getDarkRPVar( 'wanted' ) and colors.negative or colors.positive } )
end

hud:RegisterHUDPreset( 'tactical_card', { name = 'Vox Tactical Card', style = 0, drawFn = drawTacticalCard } )
hud.DrawVoxTacticalCard = drawTacticalCard
