# B4D UI

B4D UI is a clean-room premium DarkRP interface addon built under the `B4DUI` namespace. It replaces the standard DarkRP HUD, F4 menu, scoreboard, notifications, door UI, weapon selector, and staff tooling with a consistent modern dark-glass design.

## Install

1. Place this addon folder in `garrysmod/addons/b4d_ui`.
2. Restart the server or change map.
3. Configure `lua/b4d_ui/shared/sh_config.lua` and `lua/b4d_ui/shared/sh_theme.lua`.
4. Staff can open the admin menu with `b4d_admin`.

## File Structure

```text
lua/autorun/b4d_ui_loader.lua
lua/b4d_ui/shared/      Shared config, themes, fonts, utilities, permissions, admin registry
lua/b4d_ui/server/      Networking, settings, admin validation, action handlers, logs
lua/b4d_ui/client/core/ Client safe-area, theme, fonts, materials, storage, networking, animation
lua/b4d_ui/client/ui/   Shared Derma component library
lua/b4d_ui/client/f4/   B4D F4 modules
lua/b4d_ui/client/hud/  B4D HUD modules
lua/b4d_ui/client/scoreboard/ B4D Scoreboard modules
lua/b4d_ui/client/admin/ B4D Admin frontend
materials/b4d_ui/       Optional icons, logos, backgrounds
sound/b4d_ui/           Optional UI sounds
```

## Features

- B4D HUD with player card, money, salary, health, armor, hunger, ammo, notifications, and module registration.
- B4D F4 menu with Dashboard, Jobs, Shop, Inventory, Player Upgrades, Donate, Discord, Forum, Rules, Settings, and staff-only Admin tab.
- B4D Scoreboard with TAB hold behavior, right-click cursor activation, player rows, job and ping columns.
- B4D Admin with server-side action validation, rank hierarchy checks, cooldowns, logs, staff broadcasts, and ULX/SAM-style fallback hooks where possible.
- B4D Settings foundation with client JSON persistence and server sync hooks.
- Safe-area system with `b4d_ui_debug_safearea` debug convar.
- Theme tokens for Obsidian Blue, Midnight Purple, Carbon Red, Emerald City, Gold Luxury, Cream Light, Burgundy, and Custom Accent.

## Config Guide

Edit `lua/b4d_ui/shared/sh_config.lua`:

- `B4DUI.Config.Theme` sets the default theme.
- `B4DUI.Config.Links` controls Donate, Discord, Forum, and Rules links.
- `B4DUI.Config.HUD` toggles HUD modules.
- `B4DUI.Config.F4.Tabs` controls visible F4 pages.
- `B4DUI.Config.Scoreboard.Columns` controls default scoreboard columns.

## Admin Permissions Guide

Edit `lua/b4d_ui/shared/sh_permissions.lua`:

- `B4DUI.RankWeights` defines rank hierarchy.
- `B4DUI.Permissions` maps actions to minimum rank weight.
- `B4DUI.CanTarget` prevents lower staff from targeting equal/higher ranks.

## Shipment Whitelist Guide

Use the Shop modules under `lua/b4d_ui/client/f4/` as the frontend location for DarkRP shipments. Add allowed entities/shipments to your server config and render them as item cards through the B4D F4 shop module.

## Theme Guide

All UI should use `B4DUI.Color(token)` and values from `lua/b4d_ui/shared/sh_theme.lua`. Avoid random hardcoded colors in feature modules so every panel follows the selected theme.

## HUD Settings Guide

HUD modules are registered through `B4DUI.HUD.Register(id, paintFunction)`. Toggle modules in `B4DUI.Config.HUD` or client settings.

## Scoreboard Settings Guide

Scoreboard columns and rank groups are configured in `B4DUI.Config.Scoreboard`. Column editor and rank editor modules are scaffolded for in-game management.

## Testing Checklist

- Confirm loader prints no Lua errors on server start.
- Confirm HUD replaces default DarkRP HUD elements.
- Press F4 to open and close B4D F4.
- Hold TAB to open B4D Scoreboard and release TAB to close it.
- Right-click while TAB is held to enable cursor interaction.
- Run `b4d_admin` as staff and test each action against permission and hierarchy rules.
- Toggle `b4d_ui_debug_safearea 1` and verify panels stay inside the safe area.
