# DarkRP Premium UI Suite

A modular, premium-quality Garry's Mod DarkRP UI foundation based on `Doc/DARKRP_UI_MASTER_PLAN.md`.

## Install

1. Copy this repository folder into your server's `garrysmod/addons/` directory.
2. Restart the server or change map.
3. Press **F4** in-game to open the command center.

## Included Systems

- F4 menu replacement with dashboard, DarkRP data-driven categories, rules, settings, and extension placeholders.
- HUD replacement for health, armor, hunger, money, salary, job, wanted, lockdown, voice/ammo foundations.
- Scoreboard replacement with search, group badges, ping, and SteamID copy support.
- Notification queue with animated cards, progress bars, colors, and sound support.
- Settings save/load using client `DATA/darkrp_ui/settings.txt` and server sync hook.
- Admin action networking foundation for ULX/SAM/server integrations.
- Reusable theme, font, material, component, module, and config systems.

## Configuration

Edit `lua/darkrp_ui/shared/sh_config.lua` for feature toggles, tabs, rules, VIP/admin groups, sounds, and default theme.

## Extension Hooks

- `DarkRPUI.AdminAction(admin, action, target)` server hook fires for every admin action.
- `DarkRPUI.ThemeChanged(themeId)` client hook fires when the active theme changes.
- Add new themes with `DarkRPUI.RegisterTheme(id, data)`.
- Add modules with `DarkRPUI.RegisterModule(id, module)`.

## Notes

This addon intentionally avoids default Derma painting in primary surfaces. DarkRP, ULX/SAM, inventory, XP, and store integrations should be connected through the provided config, hooks, and networking foundation.
