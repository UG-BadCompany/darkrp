vox.hud.PresetRegistry = vox.hud.PresetRegistry or {}
vox.hud.PresetOrder = vox.hud.PresetOrder or {}

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
    return self:GetHUDPreset( self:GetOptionValue( 'hud_style' ) or 0 ) or self:GetHUDPreset( 'tactical_card' )
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
vox.hud:RegisterHUDPreset( 'tactical_card', { name = 'Vox Tactical Card', style = 0 } )
vox.hud:RegisterHUDPreset( 'command_strip', { name = 'Vox Command Strip', style = 1 } )
vox.hud:RegisterHUDPreset( 'minimal_edge', { name = 'Vox Minimal Edge', style = 2 } )
vox.hud:RegisterHUDPreset( 'roleplay_profile', { name = 'Vox Roleplay Profile', style = 3 } )

