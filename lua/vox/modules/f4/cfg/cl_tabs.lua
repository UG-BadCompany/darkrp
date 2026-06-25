vox.f4.tabs = {}

vox.f4:RegisterTab('dashboard', {
    order = 1,
    name = 'f4_dashboard_u',
    desc = 'f4_dashboard_desc',
    mat = Material('vox_f4menu/dashboard.png', 'smooth mips'),
    class = 'vox.f4.Dashboard'
})

vox.f4:RegisterTab('jobs', {
    order = 2,
    name = 'f4_jobs_u',
    desc = 'f4_jobs_desc',
    mat = Material('vox_f4menu/jobs.png', 'smooth mips'),
    class = 'vox.f4.Jobs'
})

vox.f4:RegisterTab('shop', {
    order = 3,
    name = 'f4_shop_u',
    desc = 'f4_shop_desc',
    mat = Material('vox_f4menu/shop.png', 'smooth mips'),
    class = 'vox.f4.Shop'
})


vox.f4:RegisterTab('inventory', {
    order = 4,
    name = 'INVENTORY',
    desc = 'Storage, identity, and roleplay items',
    mat = Material('vox_f4menu/entities.png', 'smooth mips'),
    class = 'vox.f4.Inventory'
})

vox.f4:RegisterTab('upgrades', {
    order = 5,
    name = 'UPGRADES',
    desc = 'Progression and command perks',
    mat = Material('vox_f4menu/stats.png', 'smooth mips'),
    class = 'vox.f4.Upgrades'
})

vox.f4:RegisterTab('settings', {
    order = 6,
    name = 'SETTINGS',
    desc = 'Theme, scale, previews, accessibility',
    mat = Material('vox_f4menu/settings.png', 'smooth mips'),
    class = 'vox.f4.Settings'
})
