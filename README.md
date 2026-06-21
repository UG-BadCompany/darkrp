# DarkRP Premium UI Suite

A modular, premium-quality Garry's Mod DarkRP UI addon built around the existing `lua/darkrp_ui` structure and the goals in `Doc/DARKRP_UI_MASTER_PLAN.md`.

## Install

1. Copy this folder into `garrysmod/addons/darkrp` on your server.
2. Restart the server or change map so `lua/autorun/darkrp_ui_loader.lua` runs on both realms.
3. Join the server and press **F4** for the command center, **Tab** for the scoreboard, and `darkrpui_settings` for quick settings access.

## Feature List

- Premium F4 command center with Dashboard, Jobs, Entities, Weapons, Shipments, Vehicles, Ammo, Food, Inventory, Skills, Store, Rules, Settings, and staff-only Admin tabs.
- DarkRP data-driven shop cards with search, prices, purchase command support, and clean placeholders for addon-backed systems.
- Replacement HUD for health, armor, hunger, money, salary, job, level/XP placeholders, wanted, lockdown, agenda/laws, ammo, and voice state.
- Modern scoreboard with avatars, name, job, rank, ping, SteamID copy, Steam profile shortcut, Staff/VIP badges, search/filter, and admin right-click actions.
- Notification queue with success/error/warning/info styles, animation, progress bars, position settings, sound toggle, and GMod/DarkRP notice replacement.
- Client settings saved to `DATA/darkrp_ui/settings.txt`: theme, HUD scale, blur, notification position, sounds, compact mode, and toggles.
- Central theme, font, material, drawing helper, module, utility, networking, server settings, and admin foundations.

## Configuration

Edit `lua/darkrp_ui/shared/sh_config.lua` to configure:

- Feature toggles and default DarkRP HUD hiding.
- Admin and VIP groups.
- Server links for Discord, rules, and store.
- Server rules text.
- Theme options and accent presets.
- HUD defaults such as laws/agenda/ammo visibility.
- F4 tab order, labels, icons, and staff-only visibility.
- Integration placeholder messages.

## Integration Notes

- DarkRP missing fallback is supported; the UI will run in preview mode without hard errors.
- ULX and SAM are not directly required. Server admin actions fire hooks:
  - `DarkRPUI.AdminAction(admin, action, target)`
  - `DarkRPUI.ULibAction(admin, action, target)` when ULib exists
  - `DarkRPUI.SAMAction(admin, action, target)` when SAM exists
- Add themes with `DarkRPUI.RegisterTheme(id, data)`.
- Add modules with `DarkRPUI.RegisterModule(id, module)`.
- Override level/XP with `DarkRPUI.GetLevelData(ply)`.
- Build custom inventory/skills/store panels by handling `DarkRPUI.BuildInventoryPanel`, `DarkRPUI.BuildSkillsPanel`, or `DarkRPUI.BuildStorePanel`.

## Known Placeholders

These tabs are intentionally clean integration points because they depend on server-specific addons:

- Inventory: connect your inventory addon or hook `DarkRPUI.BuildInventoryPanel`.
- Skills: connect an XP/perks backend or define `DarkRPUI.GetLevelData`.
- Store: connect your donation/store addon or server URL.

## Testing Checklist

- Start a local DarkRP server and confirm no client/server Lua errors on join.
- Press F4 and verify each tab opens, searches, and gracefully handles empty data.
- Buy a job/item on a DarkRP server and confirm the generated chat command matches your config.
- Toggle settings, reconnect, and verify saved settings reload from `DATA/darkrp_ui/settings.txt`.
- Press Tab and test search, SteamID copy, Steam profile, and staff right-click actions.
- Trigger `notification.AddLegacy`, `GAMEMODE:AddNotify`, and `DarkRPUI.Notify` to verify queue styling.
- Test as user, VIP, and staff groups to confirm tab/badge visibility.

## UI Close Behavior and Animation System

- **F4 command center:** F4 now toggles the menu open and closed. The top-right premium **×** button and **ESC** both close through `DarkRPUI.F4.Close()`, which plays a fade-out animation, removes the frame once complete, and releases cursor/input state so reopening never duplicates panels.
- **TAB scoreboard:** `ScoreboardShow` opens the custom roster and returns `false`; `ScoreboardHide` closes it immediately with the shared fade-out animation. A lightweight fail-safe also closes the scoreboard if TAB is no longer held, preventing stuck panels or trapped cursor state.
- **Admin/settings/future panels:** Shared UI helpers provide `DarkRPUI.UI.CloseButton(parent, callback)`, `DarkRPUI.UI.SafeRemoveAnimated(panel, duration)`, `DarkRPUI.UI.AnimatePanelIn(panel)`, and `DarkRPUI.UI.AnimatePanelOut(panel, callback)` so new inventory, store, skills, and settings panels can use one clean close path.
- **Premium motion:** Buttons, cards, F4 tabs, scoreboard rows, and notifications now use lerped hover/active states, card lift, tab indicators, soft blur where enabled, and slide/fade notification expiry without heavy per-panel Think hooks.

## Notification Load-Order Fix

The notification bridge no longer indexes `GAMEMODE` at file load time. `notification.AddLegacy` is safely replaced when available, while the DarkRP `GAMEMODE.AddNotify` override is installed only after `GAMEMODE` exists via `Initialize`, `InitPostEntity`, and a bounded timer retry. The notification path guards `DarkRPUI.Config`, `DarkRPUI.Settings`, and `DarkRPUI.Util`, so clients do not Lua error when DarkRP or the UI config is still loading or unavailable.
