DarkRPUI = DarkRPUI or {}
DarkRPUI.Config = DarkRPUI.Config or {}

local C = DarkRPUI.Config
C.CommandPrefix = "darkrpui"
C.DefaultTheme = "dark_professional"
C.Features = { f4 = true, hud = true, scoreboard = true, notifications = true, admin = true, blur = true, sounds = true, compact = false }
C.EnableF4Menu, C.EnableHUD, C.EnableScoreboard, C.EnableNotifications, C.EnableAdminTools = true, true, true, true, true
C.HideDefaultDarkRPHUD, C.HideDefaultDarkRPAgenda, C.HideDefaultDarkRPLockdown, C.HideDefaultDarkRPArrested = true, false, false, true
C.AnimationSpeed = 0.16
C.BlurEnabled = true
C.SoundEnabled = true
C.NotificationSound = "buttons/button15.wav"
C.ClickSound = "ui/buttonclickrelease.wav"
C.NotificationPosition = "top-right"
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
C.HUD = { scale = 1, showAgenda = true, showLaws = true, showAmmo = true, showVoice = true, maxLaws = 6 }
C.ThemeOptions = { accentPresets = { blue = Color(79,140,255), purple = Color(155,105,255), emerald = Color(60,210,130), orange = Color(255,160,70) } }
C.F4Tabs = {
    { id = "dashboard", name = "Dashboard", icon = "◈" }, { id = "jobs", name = "Jobs", icon = "●" },
    { id = "entities", name = "Entities", icon = "▣" }, { id = "weapons", name = "Weapons", icon = "⌁" },
    { id = "shipments", name = "Shipments", icon = "▤" }, { id = "vehicles", name = "Vehicles", icon = "◆" },
    { id = "ammo", name = "Ammo", icon = "▪" }, { id = "food", name = "Food", icon = "◍" },
    { id = "inventory", name = "Inventory", icon = "▧" }, { id = "skills", name = "Skills", icon = "✦" },
    { id = "store", name = "Store", icon = "★" }, { id = "rules", name = "Rules", icon = "!" },
    { id = "settings", name = "Settings", icon = "⚙" }, { id = "admin", name = "Admin", icon = "⚑", staffOnly = true }
}
C.Placeholders = {
    inventory = "Inventory integration point: override hook DarkRPUI.BuildInventoryPanel or register a module.",
    skills = "Skills/XP integration point: provide DarkRPUI.GetLevelData(ply) or use DarkRP vars level/xp.",
    store = "Store integration point: set ServerLinks.Store or hook DarkRPUI.OpenStore."
}
