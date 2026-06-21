DarkRPUI = DarkRPUI or {}
DarkRPUI.Config = DarkRPUI.Config or {}

local C = DarkRPUI.Config
C.CommandPrefix = "darkrpui"
C.DefaultTheme = "dark_professional"
C.EnableF4Menu = true
C.EnableHUD = true
C.EnableScoreboard = true
C.EnableNotifications = true
C.EnableAdminTools = true
C.HideDefaultDarkRPHUD = true
C.HideDefaultDarkRPAgenda = true
C.HideDefaultDarkRPLockdown = true
C.HideDefaultDarkRPArrested = true
C.AnimationSpeed = 0.16
C.BlurEnabled = true
C.SoundEnabled = true
C.NotificationSound = "buttons/button15.wav"
C.AdminRanks = { superadmin = true, admin = true, moderator = true, mod = true }
C.VIPGroups = { vip = true, premium = true, donator = true, supporter = true }
C.CurrencySymbol = "$"
C.RulesText = [[Respect other players, obey staff instructions, do not RDM/RDA, and follow the server's roleplay rules. Edit this text in sh_config.lua.]]
C.F4Tabs = {
    { id = "dashboard", name = "Dashboard", icon = "◈" }, { id = "jobs", name = "Jobs", icon = "●" },
    { id = "entities", name = "Entities", icon = "▣" }, { id = "weapons", name = "Weapons", icon = "⌁" },
    { id = "shipments", name = "Shipments", icon = "▤" }, { id = "vehicles", name = "Vehicles", icon = "◆" },
    { id = "ammo", name = "Ammo", icon = "▪" }, { id = "food", name = "Food", icon = "◍" },
    { id = "inventory", name = "Inventory", icon = "▧" }, { id = "skills", name = "Skills & Perks", icon = "✦" },
    { id = "donator", name = "Donator Store", icon = "★" }, { id = "rules", name = "Rules", icon = "!" },
    { id = "settings", name = "Settings", icon = "⚙" }
}
C.Placeholders = { inventory = "Connect your inventory addon here.", skills = "Connect your XP/perks backend here.", donator = "Connect your store integration here." }
