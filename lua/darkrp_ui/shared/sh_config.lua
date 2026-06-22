DarkRPUI = DarkRPUI or {}
DarkRPUI.Config = DarkRPUI.Config or {}

local C = DarkRPUI.Config
C.CommandPrefix = "darkrpui"
C.DefaultTheme = "obsidian_blue"
C.Features = { f4 = true, hud = true, scoreboard = true, notifications = true, admin = true, blur = true, sounds = true, compact = false }
C.EnableF4Menu, C.EnableHUD, C.EnableScoreboard, C.EnableNotifications, C.EnableAdminTools = true, true, true, true, true
C.HideDefaultDarkRPHUD, C.HideDefaultDarkRPAgenda, C.HideDefaultDarkRPLockdown, C.HideDefaultDarkRPArrested = true, false, false, true
C.AnimationSpeed = 0.16
C.Spacing = 14
C.Radius = 16
C.ShadowAlpha = 110
C.BlurEnabled = true
C.SoundEnabled = true
C.NotificationSound = "buttons/button15.wav"
C.ClickSound = "ui/buttonclickrelease.wav"
C.HoverSound = "ui/buttonrollover.wav"
C.NotificationPosition = "top-right"
C.ConfirmPurchases = false
C.Tooltips = true
C.LowResolutionScale = true
C.CurrencySymbol = "$"
C.AdminRanks = { superadmin = true, admin = true, moderator = true, mod = true, trialmod = true, operator = true }
C.VIPGroups = { vip = true, premium = true, donator = true, supporter = true, owner = true }
C.ServerLinks = {
    { name = "Discord", url = "https://discord.gg/yourserver" },
    { name = "Rules", url = "https://example.com/rules" },
    { name = "Store", url = "https://example.com/store" }
}
C.Rules = {
    "Respect all players and staff decisions.",
    "Do not RDM, RDA, prop abuse, scam, exploit, or evade roleplay.",
    "Advertise raids/mugs/warns according to your server rules.",
    "Use common sense; staff may intervene in edge cases."
}
C.RulesText = table.concat(C.Rules, "\n\n")
C.HUD = { scale = 1, showAgenda = true, showLaws = true, showAmmo = true, showVoice = true, maxLaws = 6, showMoney = true, showSalary = true, showHunger = true, showLevel = true }
C.ThemeOptions = { accentPresets = { blue = Color(79,140,255), purple = Color(155,105,255), emerald = Color(60,210,130), orange = Color(255,160,70) } }
C.F4Tabs = {
    { id = "dashboard", name = "Dashboard", icon = "◈", group = "Character" }, { id = "jobs", name = "Jobs", icon = "●", group = "Character" },
    { id = "entities", name = "Entities", icon = "▣", group = "Market" }, { id = "weapons", name = "Weapons", icon = "⌁", group = "Market" },
    { id = "shipments", name = "Shipments", icon = "▤", group = "Market" },
    { id = "ammo", name = "Ammo", icon = "▪", group = "Market" }, { id = "food", name = "Food", icon = "◍", group = "Market" },
    { id = "inventory", name = "Inventory", icon = "▧" }, { id = "player_upgrades", name = "Player Upgrades", icon = "✦", group = "Progression" },
    { id = "store", name = "Store", icon = "★", group = "Server" }, { id = "rules", name = "Rules", icon = "!", group = "Server" },
    { id = "settings", name = "Settings", icon = "⚙", group = "Server" }, { id = "admin", name = "Admin", icon = "⚑", group = "Staff", staffOnly = true }
}
C.Placeholders = {
    inventory = "Inventory integration point: override hook DarkRPUI.BuildInventoryPanel or register a module.",
    player_upgrades = "Player Upgrades/XP integration point: provide DarkRPUI.GetLevelData(ply) or use DarkRP vars level/xp.",
    store = "Store integration point: set ServerLinks.Store or hook DarkRPUI.OpenStore."
}


-- Premium shipment access controls. Keys may match shipment.name, entity, class, or weaponClass.
C.ShipmentJobWhitelist = C.ShipmentJobWhitelist or {
    -- ["AK-47 Shipment"] = { TEAM_GUNDEALER = true, TEAM_BLACKMARKET = true },
    -- ["Pistol Shipment"] = { TEAM_GUNDEALER = true }
}
C.ShipmentWhitelistDefaultAllow = false
C.ShowLockedShipments = true

-- Server-authoritative admin permissions and rank protection.
C.AdminPermissions = C.AdminPermissions or {
    superadmin = { bring=true, goto=true, returnply=true, freeze=true, unfreeze=true, spectate=true, unspectate=true, stripweapons=true, respawn=true, slay=true, kick=true, ban=true, warn=true, setjob=true, setmoney=true, jail=true, unjail=true, cloak=true, noclip=true, god=true },
    admin = { bring=true, goto=true, returnply=true, freeze=true, unfreeze=true, spectate=true, unspectate=true, stripweapons=true, respawn=true, slay=true, kick=true, warn=true, jail=true, unjail=true, cloak=true, noclip=true, god=true },
    moderator = { bring=true, goto=true, freeze=true, unfreeze=true, spectate=true, unspectate=true, warn=true, noclip=true }
}
C.AdminPreventSameOrHigherRank = true
C.AdminRankPower = C.AdminRankPower or { user=0, vip=0, moderator=20, mod=20, admin=50, superadmin=100, owner=999 }

C.AdminActionCooldown = C.AdminActionCooldown or 1.5
C.AdminBroadcastToStaff = C.AdminBroadcastToStaff ~= false
