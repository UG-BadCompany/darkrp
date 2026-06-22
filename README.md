# Vox UI

Vox UI is a premium DarkRP interface suite for Garry's Mod. It keeps the existing feature foundation while presenting a distinct Vox identity: charcoal glass panels, sharper cards, angled electric accent bars, polished hover states, smooth value animation, and safer admin/backend fallbacks.

## Installation

1. Place this addon in your server `garrysmod/addons/` folder.
2. Keep the folder structure intact (`lua/vox`, `materials/vox_*`, `resource/fonts`).
3. Restart or change map so Garry's Mod loads `lua/autorun/vox_autorun.lua`.
4. Configure in-game with `vox_hud`, `vox_admin`, the F4 settings page, and scoreboard admin settings.

## Feature List

- **Vox HUD**: compact player card, avatar/model circle, name, job, money, salary, health, armor, hunger, level/XP, ammo, voice, agenda, laws/alerts, pickup history, weapon selector, door info, and vehicle HUD.
- **Vox Menu**: dashboard, jobs, shop, inventory, Player Upgrades, donate, Discord, forum, rules, settings, and staff-only admin entry points.
- **Vox Scoreboard**: TAB behavior, grouped teams, search-ready player list, rank/column editors, staff action integration, Steam profile actions, and a built-in Vox Admin fallback.
- **Vox Admin**: server-side action registry, CAMI privileges, rank hierarchy protection, cooldowns, logs, target validation, graceful placeholder integrations, and staff notifications.
- **Vox Settings**: theme, HUD, F4, scoreboard, notification, performance, accessibility, and admin configuration options.
- **Vox Notifications**: DarkRP-safe notification handling with Vox styling hooks and no `GAMEMODE` indexing at file load.

## Theme Guide

Vox UI uses theme tokens rather than random hardcoded colors. The included presets are:

- Vox Obsidian
- Vox Midnight
- Vox Royal Purple
- Vox Carbon Red
- Vox Emerald
- Vox Gold
- Vox Light
- Custom Accent

Core tokens include `primary`, `secondary`, `tertiary`, `quaternary`, `accent`, `textPrimary`, `textSecondary`, `textTertiary`, `positive/money`, `negative`, `armor`, `hunger`, and `xp`.

## HUD Settings

Open with `vox_hud`. Server owners can configure display modules and players can tune personal settings. Supported layout presets are Vox Compact Corner, Vox Tactical Bar, Vox Minimal, and Vox Roleplay Card. Toggles include money, salary, job, health, armor, hunger, level, XP, ammo, agenda, laws/alerts, pickup history, voice, vehicle HUD, compact mode, animation speed, and reduced motion.

## F4 Tabs

The Vox Menu keeps the current feature set and uses these user-facing tabs: Dashboard, Jobs, Shop, Inventory, Player Upgrades, Donate, Discord, Forum, Rules, Settings, and Admin for staff. Vehicles are intentionally not added.

## Scoreboard Columns And Ranks

The scoreboard configuration supports grouping and user-facing column/rank editing. Recommended columns are job/team, rank, money, playtime, level, health, karma, kills, deaths, ping, voice, and custom hook columns. Rank effects should be configured as none, solid, gradient, rainbow, or pulse.

## Admin Permissions

Each built-in action registers a CAMI privilege named `vox_admin_<action>`. Supported actions include bring, goto, returnply, freeze, unfreeze, spectate, unspectate, stripweapons, respawn, slay, kick, warn, ban placeholder, jail placeholder, unjail placeholder, setjob placeholder, setmoney placeholder, noclip, god, and cloak placeholder.

Vox Admin validates permissions and targets server-side, applies rank hierarchy protection, logs successful actions, and uses ULX/SAM/FAdmin scoreboard handlers when present with a clean built-in fallback when not present.

## Shipment Whitelist

The shop keeps the existing DarkRP shipment whitelist behavior. Restricted shipments should remain visible as clean locked cards with disabled purchase buttons and a reason/detail panel when available.

## Testing Checklist

- Join a DarkRP server without Lua errors.
- Run `vox_hud` and verify Vox HUD settings save/load.
- Open F4 and verify Vox Menu branding and Player Upgrades naming.
- Hold TAB, release TAB, and right-click while TAB is held to verify scoreboard cursor behavior.
- Run `vox_admin` as staff and test allowed actions against lower-ranked test players.
- Verify no stuck cursor, duplicate frames, clipping, or console spam.
