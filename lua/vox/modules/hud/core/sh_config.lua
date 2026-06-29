local function createDisplayOption( id, default )
    if ( default == nil ) then default = true end

    vox.hud:RegisterOption( 'display_' .. id, {
        title = 'hud.' .. id .. '.name',
        desc = 'hud_should_draw',
        category = 'display',
        cami = 'vox_hud_edit',
        type = 'bool',
        default = default
    } )
end

CAMI.RegisterPrivilege({
    Name = 'vox_hud_edit',
    MinAccess = 'superadmin',
    Description = 'Allows to configure Vox HUD'
})

vox.hud:RegisterOption( 'timeout', {
    title = 'hud.timeout.name',
    desc = 'hud.timeout.desc',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 45,
    min = 15,
    max = 180
} )

vox.hud:RegisterOption( 'alert_queue', {
    title = 'hud.alert_queue.name',
    desc = 'hud.alert_queue.desc',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = false
} )

vox.hud:RegisterOption( 'props_counter', {
    title = 'hud.props_counter.name',
    desc = 'hud.props_counter.desc',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = false
} )

vox.hud:RegisterOption( 'restrict_themes', {
    title = 'hud.restrict_themes.name',
    desc = 'hud.restrict_themes.desc',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = false
} )

vox.hud:RegisterOption( 'main_avatar_mode', {
    title = 'hud.main_avatar_mode.name',
    desc = 'hud.main_avatar_mode.desc',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 0,
    min = 0,
    max = 1,
    combo = {
        { 'Avatar', 0 },
        { 'Model', 1 }
    }
} )

vox.hud:RegisterOption( 'voice_avatar_mode', {
    title = 'hud.voice_avatar_mode.name',
    desc = 'hud.voice_avatar_mode.desc',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 0,
    min = 0,
    max = 1,
    combo = {
        { 'Avatar', 0 },
        { 'Model', 1 }
    }
} )

-- Speedometer

vox.hud:RegisterOption( 'speedometer_mph', {
    title = 'hud.speedometer_mph.name',
    desc = 'hud.speedometer_mph.desc',
    category = 'speedometer',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = false
} )

vox.hud:RegisterOption( 'speedometer_max_speed', {
    title = 'hud.speedometer_max_speed.name',
    desc = 'hud.speedometer_max_speed.desc',
    category = 'speedometer',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 260,
    min = 180,
    max = 300
} )

-- Display

createDisplayOption( 'main' )
createDisplayOption( 'ammo' )
createDisplayOption( 'agenda' )
createDisplayOption( 'pickup_history' )
createDisplayOption( 'voice' )
createDisplayOption( 'alerts' )
createDisplayOption( 'vehicle' )
createDisplayOption( 'money' )
createDisplayOption( 'salary' )
createDisplayOption( 'job' )
createDisplayOption( 'health' )
createDisplayOption( 'armor' )
createDisplayOption( 'hunger' )
createDisplayOption( 'xp' )

vox.hud:RegisterOption( 'hud_style', {
    title = 'HUD Layout Preset',
    desc = 'Choose the Vox HUD layout preset',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 0,
    min = 0,
    max = 3,
    combo = vox.hud.GetHUDPresetComboOptions and vox.hud:GetHUDPresetComboOptions() or {
        { 'Compact Card', 0 },
        { 'Horizontal Bar', 1 },
        { 'Minimal Corner', 2 },
        { 'Roleplay Profile', 3 }
    }
} )

vox.hud:RegisterOption( 'animation_speed', {
    title = 'Animation Speed',
    desc = 'Controls HUD value smoothing speed',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 16,
    min = 1,
    max = 32
} )


vox.hud:RegisterOption( 'hud_scale', {
    title = 'HUD Scale',
    desc = 'Controls the client HUD preview and visual scale preference',
    category = 'appearance',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 100,
    min = 80,
    max = 125
} )

vox.hud:RegisterOption( 'font_size', {
    title = 'Font Size',
    desc = 'Adjusts premium UI readability preference',
    category = 'appearance',
    cami = 'vox_hud_edit',
    type = 'int',
    default = 100,
    min = 85,
    max = 120
} )

vox.hud:RegisterOption( 'compact_mode', {
    title = 'Compact Mode',
    desc = 'Tightens HUD and dashboard preview spacing',
    category = 'appearance',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = false
} )

vox.hud:RegisterOption( 'blur_enabled', {
    title = 'Blur On/Off',
    desc = 'Enables glass blur on premium Vox panels where supported',
    category = 'appearance',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = true
} )

vox.hud:RegisterOption( 'reduce_motion', {
    title = 'Reduce Motion',
    desc = 'Minimizes animated Vox UI effects',
    category = 'general',
    cami = 'vox_hud_edit',
    type = 'bool',
    default = false
} )
createDisplayOption( 'level' )
createDisplayOption( 'overhead_health', false )
createDisplayOption( 'overhead_armor', false )
