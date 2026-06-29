vox.hud.PresetRegistry = vox.hud.PresetRegistry or {}
vox.hud.PresetOrder = vox.hud.PresetOrder or {}

local CONVAR_HUD_STYLE = CreateClientConVar( 'cl_vox_hud_hud_style', '0', true, false, 'Client-side Vox HUD layout preset', 0, 10 )

local function getAdminOverrideValue( id )
    local optionID = 'hud_' .. id
    local option = vox.inconfig and vox.inconfig.options and vox.inconfig.options[ optionID ]
    if not option then return end

    local value = vox.hud:GetOptionValue( id )
    if value ~= nil and value ~= option.default then
        return value
    end
end

function vox.hud:RegisterHUDPreset( id, data )
    assert( isstring( id ) and id ~= '', 'Vox HUD preset id must be a non-empty string' )
    data = data or {}

    local preset = self.PresetRegistry[ id ] or {}
    table.Merge( preset, data )

    preset.id = id
    preset.name = preset.name or id
    preset.style = tonumber( preset.style ) or ( #self.PresetOrder )
    self.PresetRegistry[ id ] = preset

    if not table.HasValue( self.PresetOrder, id ) then
        table.insert( self.PresetOrder, id )
    end

    table.sort( self.PresetOrder, function( a, b )
        return ( self.PresetRegistry[ a ].style or 0 ) < ( self.PresetRegistry[ b ].style or 0 )
    end )

    return preset
end

function vox.hud:GetHUDPreset( idOrStyle )
    if isnumber( idOrStyle ) then
        for _, id in ipairs( self.PresetOrder ) do
            local preset = self.PresetRegistry[ id ]
            if preset and preset.style == idOrStyle then return preset end
        end
    end

    return self.PresetRegistry[ idOrStyle ]
end

function vox.hud:GetCurrentHUDPreset()
    local style = getAdminOverrideValue( 'hud_style' )
    if style == nil then
        style = CONVAR_HUD_STYLE:GetInt()
    end

    return self:GetHUDPreset( style or 0 ) or self:GetHUDPreset( 'tactical_card' )
end

function vox.hud:GetHUDPresetComboOptions()
    local options = {}
    for _, id in ipairs( self.PresetOrder ) do
        local preset = self.PresetRegistry[ id ]
        options[ #options + 1 ] = { preset.name, preset.style }
    end
    return options
end

-- README-named HUD preset registry entries. Preset implementation files attach draw functions.
vox.hud:RegisterHUDPreset( 'tactical_card', { name = 'Compact Card', style = 0 } )
vox.hud:RegisterHUDPreset( 'command_strip', { name = 'Horizontal Bar', style = 1 } )
vox.hud:RegisterHUDPreset( 'minimal_edge', { name = 'Minimal Corner', style = 2 } )
vox.hud:RegisterHUDPreset( 'roleplay_profile', { name = 'Roleplay Profile', style = 3 } )
