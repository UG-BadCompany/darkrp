local COLOR_PRIMARY = vox:Config( 'colors.primary' )
local COLOR_SECONDARY = vox:Config( 'colors.secondary' )
local COLOR_TERTIARY = vox:Config( 'colors.tertiary' )
local COLOR_ACCENT = vox:Config( 'colors.accent' )
local COLOR_GRAY = Color( 150, 150, 150)
local COLOR_BUTTON_HOVER = vox.LerpColor( .5, COLOR_TERTIARY, COLOR_ACCENT )
local FONT_NAME = vox.Font( 'Comfortaa Bold@16' )
local FONT_DESC = vox.Font( 'Comfortaa@14' )
local FONT_BUTTON = vox.Font( 'Comfortaa Bold@32' )

local PANEL = {}

local function getUIColors()
    local theme = vox.hud and vox.hud.GetCurrentTheme and vox.hud:GetCurrentTheme()
    local colors = theme and theme.colors
    if not colors then
        return COLOR_PRIMARY, COLOR_SECONDARY, COLOR_TERTIARY, COLOR_ACCENT, COLOR_BUTTON_HOVER
    end

    local primary = colors.primary or COLOR_PRIMARY
    local secondary = colors.secondary or COLOR_SECONDARY
    local tertiary = colors.tertiary or COLOR_TERTIARY
    local accent = colors.accent or COLOR_ACCENT
    return primary, secondary, tertiary, accent, vox.LerpColor( .5, tertiary, accent )
end

function PANEL:Init()
    self.list = self:Add( 'vox.ScrollPanel' )
    self.list:Dock( FILL )

    self.grid = self.list:Add( 'vox.Grid' )
    self.grid:Dock( FILL )
    self.grid:SetColumnCount( 2 )
    self.grid:SetSpace( vox.ScaleTall( 5 ) )

    self:LoadOptions()
end

function PANEL:LoadOptions()
    if ( not vox.hud:GetOptionValue( 'restrict_themes' )) then
        local themeOptions = {}

        for id, theme in pairs( vox.hud.themes ) do
            table.insert( themeOptions, {
                name = vox.lang:Get( string.format( 'hud.theme.%s.name', id ) ),
                key = id
            } )
        end

        self:AddOption( 'combo', 'theme', 'cl_vox_hud_theme_id', {
            options = themeOptions
        } )
    end

    local presetOptions = {}
    for _, opt in ipairs( vox.hud:GetHUDPresetComboOptions() ) do
        presetOptions[ #presetOptions + 1 ] = { name = opt[ 1 ], key = tostring( opt[ 2 ] ) }
    end
    self:AddOption( 'combo', 'hud_style', 'cl_vox_hud_hud_style', { options = presetOptions, serverOptionID = 'hud_hud_style' } )

    self:AddOption( 'int', 'scale', 'cl_vox_hud_scale' )
    self:AddOption( 'int', 'roundness', 'cl_vox_hud_roundness', { step = 4 } )
    self:AddOption( 'int', 'margin', 'cl_vox_hud_screen_padding', { step = 5 } )
    self:AddOption( 'int', '3d2d_max_details', 'cl_vox_hud_3d2d_max_details', { step = 1 } )

    self:AddOption( 'bool', 'compact', 'cl_vox_hud_compact' )
    self:AddOption( 'bool', 'speedometer_blur', 'cl_vox_hud_speedometer_blur' )

    if ( vox.hud:GetOptionValue( 'main_avatar_mode' ) == 1 ) then
        self:AddOption( 'bool', 'icons_3d', 'cl_vox_hud_3d_models' )
    end
end

function PANEL:AddOption( optionType, id, convarName, data )
    local text = vox.lang:Get( 'hud.' .. id .. '.name' )
    local desc = vox.lang:Get( 'hud.' .. id .. '.desc' )
    local convarObject = GetConVar( convarName )
    local data = data or {}
    local field = self:CreateField( text, desc )
    local height = field:GetTall() - field.padding * 2

    if ( optionType == 'bool' ) then
        field.centerChild = false

        field.togglerContainer = field:Add('Panel')
        field.togglerContainer:SetWide( vox.ScaleWide( 50 ) )
        field.togglerContainer:Dock( RIGHT )
        field.togglerContainer.PerformLayout = function( panel, w, h )
            local child = panel:GetChild( 0 )
            if ( IsValid( child ) ) then
                child:SetTall( child:GetWide() * .5 )
                child:Center()
            end
        end

        field.toggler = field.togglerContainer:Add('vox.Toggler')
        field.toggler:SetBackgroundColor( COLOR_TERTIARY )
        field.toggler:SetChecked( convarObject:GetBool(), true )
        field.toggler.OnChange = function( panel, newBool )
            convarObject:SetBool( newBool )
        end
    elseif ( optionType == 'combo' ) then
        local value = convarObject and convarObject:GetString() or tostring( vox.inconfig:Get( data.serverOptionID or '' ) or '' )

        local combo = field:Add( 'vox.ComboBox' )
        combo.serverOptionID = data.serverOptionID
        combo:SetWide( vox.ScaleWide( 175 ) )
        combo:Dock( RIGHT )
        combo.OnSelect = function( panel, index, text, data )
            if convarObject then
                convarObject:SetString( data )
            elseif data ~= nil then
                net.Start( 'vox.inconfig:Set' )
                    net.WriteString( panel.serverOptionID or '' )
                    net.WriteString( vox.TypeToString( tonumber( data ) or data ) )
                net.SendToServer()
            end
        end

        for i, opt in ipairs( data.options or {} ) do
            local key = opt.key

            combo:AddOption( opt.name, key )

            if ( key == value ) then
                combo:ChooseOptionID( i )
            end
        end
    elseif ( optionType == 'int' ) then
        local lblValue
        local min = convarObject:GetMin()
        local max = convarObject:GetMax()
        local step = data.step or 5

        local btnAdd = field:Add( 'DButton' )
        btnAdd:SetText( '' )
        btnAdd:SetWide( height )
        btnAdd:Dock( RIGHT )
        btnAdd.Paint = function( panel, w, h )
            local _, _, tertiary, _, hover = getUIColors()
            draw.RoundedBoxEx( 8, 0, 0, w, h, panel:IsHovered() and hover or tertiary, false, true, false, true )
            draw.SimpleText( '+', FONT_BUTTON, w * .5, h * .5, color_white, 1, 1 )
        end
        btnAdd.DoClick = function( panel )
            local newValue = math.floor( math.Clamp( convarObject:GetInt() + step, min, max ) / step ) * step

            surface.PlaySound('vox/ui/on_click/footfall_click.wav')
            convarObject:SetInt( newValue )

            lblValue:SetText( newValue )
        end

        lblValue = field:Add( 'vox.Label' )
        lblValue:SetWide( vox.ScaleWide( 50 ) )
        lblValue:SetContentAlignment( 5 )
        lblValue:SetText( convarObject:GetInt() )
        lblValue:Dock( RIGHT )
        lblValue:Font( 'Comfortaa SemiBold@20' )
        lblValue.Paint = function( panel, w, h )
            local primary = getUIColors()
            draw.RoundedBox( 0, 0, 0, w, h, primary )
        end

        local btnDecrease = field:Add( 'DButton' )
        btnDecrease:SetText( '' )
        btnDecrease:SetWide( height )
        btnDecrease:Dock( RIGHT )
        btnDecrease.Paint = function( panel, w, h )
            local _, _, tertiary, _, hover = getUIColors()
            draw.RoundedBoxEx( 8, 0, 0, w, h, panel:IsHovered() and hover or tertiary, true, false, true )
            draw.SimpleText( '-', FONT_BUTTON, w * .5, h * .5, color_white, 1, 1 )
        end
        btnDecrease.DoClick = function( panel )
            local newValue = math.floor( math.Clamp( convarObject:GetInt() - step, min, max ) / step ) * step

            surface.PlaySound('vox/ui/on_click/footfall_click.wav')
            convarObject:SetInt( newValue )

            lblValue:SetText( newValue )
        end
    end
end

function PANEL:CreateField( text, desc )
    local padding = vox.ScaleTall(7.5)

    local field = self.grid:Add( 'DPanel' )
    field:SetTall( vox.ScaleTall(45) )
    field:DockPadding( padding, padding, padding, padding )
    field.centerChild = true
    field.padding = padding
    field.Paint = function( p, w, h )
        local _, secondary, _, accent = getUIColors()
        if vox.DrawVoxRow then
            vox.DrawVoxRow( 0, 0, w, h, { secondary = secondary, accent = accent }, { hovered = p:IsHovered(), accent = accent, alpha = 225 } )
        else
            draw.RoundedBox( 8, 0, 0, w, h, secondary )
        end
        draw.SimpleText( text, FONT_NAME, padding, h * .5, accent, 0, 4 )
        draw.SimpleText( desc, FONT_DESC, padding, h * .5, COLOR_GRAY, 0, 0 )
    end
    field.PerformLayout = function( panel, w, h )
        local child = panel:GetChild( 0 )
        if ( IsValid( child ) and panel.centerChild ) then

        end
    end

    return field
end

vox.gui.Register( 'vox.hud.ClientSettings', PANEL )
