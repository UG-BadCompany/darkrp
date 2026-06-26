CAMI.RegisterPrivilege({
    Name = 'vox_f4_edit',
    MinAccess = 'superadmin',
    Description = 'Allows to configure Vox Menu'
})

vox.f4:RegisterOption('title', {
    title = 'f4.title.name',
    desc = 'f4.title.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'string',
    default = 'Vox Menu'
})

vox.f4:RegisterOption('scale', {
    title = 'F4 Scale',
    desc = 'Controls the command center frame scale',
    category = 'Appearance',
    cami = 'vox_f4_edit',
    type = 'int',
    default = 100,
    min = 85,
    max = 120
})

vox.f4:RegisterOption('animations', {
    title = 'Animations',
    desc = 'Enables smooth command center transitions',
    category = 'Appearance',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = true
})

vox.f4:RegisterOption('compact_mode', {
    title = 'Compact Mode',
    desc = 'Uses tighter dashboard cards and rows',
    category = 'Appearance',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = false
})

vox.f4:RegisterOption('colored_items', {
    title = 'f4.colored_items.name',
    desc = 'f4.colored_items.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = true
})

vox.f4:RegisterOption('edit_job_colors', {
    title = 'f4.edit_job_colors.name',
    desc = 'f4.edit_job_colors.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = true
})

vox.f4:RegisterOption('hide_admins', {
    title = 'f4.hide_admins.name',
    desc = 'f4.hide_admins.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = false
})

vox.f4:RegisterOption('hide_donate_tab', {
    title = 'f4.hide_donate_tab.name',
    desc = 'f4.hide_donate_tab.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = false
})

vox.f4:RegisterOption('admin_on_duty', {
    title = 'f4.admin_on_duty.name',
    desc = 'f4.admin_on_duty.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = false
})

vox.f4:RegisterOption('admin_on_duty_job', {
    title = 'f4.admin_on_duty_job.name',
    desc = 'f4.admin_on_duty_job.desc',
    category = 'General',
    cami = 'vox_f4_edit',
    type = 'string',
    default = 'Admin on Duty'
})

vox.f4:RegisterOption('item_columns', {
    title = 'f4.item_columns.name',
    desc = 'f4.item_columns.desc',
    category = 'Items',
    cami = 'vox_f4_edit',
    type = 'int',
    min = 1,
    max = 3,
    default = 3
})

vox.f4:RegisterOption('item_show_unavailable', {
    title = 'f4.item_show_unavailable.name',
    desc = 'f4.item_show_unavailable.desc',
    category = 'Items',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = true
})

vox.f4:RegisterOption('job_columns', {
    title = 'f4.job_columns.name',
    desc = 'f4.job_columns.desc',
    category = 'Jobs',
    cami = 'vox_f4_edit',
    type = 'int',
    min = 1,
    max = 3,
    default = 2
})

vox.f4:RegisterOption('job_show_unavailable', {
    title = 'f4.job_show_unavailable.name',
    desc = 'f4.job_show_unavailable.desc',
    category = 'Jobs',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = true
})

vox.f4:RegisterOption('job_show_requirejob', {
    title = 'f4.job_show_requirejob.name',
    desc = 'f4.job_show_requirejob.desc',
    category = 'Jobs',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = false
})

vox.f4:RegisterOption('model_3d', {
    title = 'f4.model_3d.name',
    desc = 'f4.model_3d.desc',
    category = 'Performance',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = false
})

--[[------------------------------
URL
--------------------------------]]

vox.f4:RegisterOption('website_ingame', {
    title = 'f4.website_ingame.name',
    desc = 'f4.website_ingame.desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'bool',
    default = true
})

vox.f4:RegisterOption('discord_url', {
    title = 'f4.discord_url.name',
    desc = 'f4.option_url_desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})

vox.f4:RegisterOption('announcement_discord_server_id', {
    title = 'f4.announcement_discord_server_id.name',
    desc = 'f4.announcement_discord_server_id.desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})

vox.f4:RegisterOption('announcement_discord_channel_id', {
    title = 'f4.announcement_discord_channel_id.name',
    desc = 'f4.announcement_discord_channel_id.desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})

vox.f4:RegisterOption('forum_url', {
    title = 'f4.forum_url.name',
    desc = 'f4.option_url_desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})

vox.f4:RegisterOption('steam_url', {
    title = 'f4.steam_url.name',
    desc = 'f4.option_url_desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})

vox.f4:RegisterOption('rules_url', {
    title = 'f4.rules_url.name',
    desc = 'f4.option_url_desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})

vox.f4:RegisterOption('donate_url', {
    title = 'f4.donate_url.name',
    desc = 'f4.option_url_desc',
    category = 'Links',
    cami = 'vox_f4_edit',
    type = 'string',
    default = ''
})
