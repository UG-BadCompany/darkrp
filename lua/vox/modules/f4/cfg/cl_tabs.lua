vox.f4.tabs = {}

vox.f4:RegisterTab('dashboard', {
    order = 1,
    name = 'f4_dashboard_u',
    desc = 'f4_dashboard_desc',
    icon = 'https://i.imgur.com/L6Dbwjm.png',
    class = 'vox.f4.Dashboard'
})

vox.f4:RegisterTab('jobs', {
    order = 2,
    name = 'f4_jobs_u',
    desc = 'f4_jobs_desc',
    icon = 'https://i.imgur.com/B5jmfXa.png',
    class = 'vox.f4.Jobs'
})

vox.f4:RegisterTab('shop', {
    order = 3,
    name = 'f4_shop_u',
    desc = 'f4_shop_desc',
    icon = 'https://i.imgur.com/duyBVAS.png',
    class = 'vox.f4.Shop'
})


vox.f4:RegisterTab('inventory', {
    order = 4,
    name = 'INVENTORY',
    desc = 'Storage, identity, and roleplay items',
    icon = 'https://i.imgur.com/ECLKU9s.png',
    class = 'vox.f4.Inventory'
})

vox.f4:RegisterTab('upgrades', {
    order = 5,
    name = 'UPGRADES',
    desc = 'Progression and premium perks',
    icon = 'https://i.imgur.com/l4M12dO.png',
    class = 'vox.f4.Upgrades'
})

vox.f4:RegisterTab('settings', {
    order = 6,
    name = 'SETTINGS',
    desc = 'Theme, scale, previews, accessibility',
    icon = 'https://i.imgur.com/41kCW0x.png',
    class = 'vox.f4.Settings'
})
