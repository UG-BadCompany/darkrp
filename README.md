# DarkRP UI

A premium, client-focused DarkRP interface suite for Garry's Mod. It replaces the default rough Derma feel with a consistent modern theme, animated panels, safe DarkRP integration points, and client-side preferences.

## Current Features

- **F4 command center** with dashboard cards, animated tab transitions, premium job/shop cards, searchable/sortable job browsing, category filters, right-side selected item preview, model preview panels, and client-side job favorites.
- **Job support** reads `RPExtraTeams` directly, supports `job.model` as a string or table, falls back to `models/player/kleiner.mdl`, and avoids broken model errors.
- **HUD** includes animated health, armor, hunger, money, salary, ammo, voice, wanted, lockdown, agenda, and laws displays with compact mode and scaling support.
- **Scoreboard** opens only while TAB is held, uses premium rows, avatars, job color stripes, staff/VIP badges, colored ping, SteamID copy, and admin action integration placeholders.
- **Notifications** safely wrap legacy and DarkRP notifications after `GAMEMODE` is available, with stacked animated toast cards, icons, progress bars, and sound settings.
- **Reusable UI components** include premium buttons, cards, search boxes, combo boxes, close buttons, model previews, empty states, confirmation modals, and shared animation helpers.
- **Themes/settings** provide consistent radius, spacing, font usage, accent colors, blur, sounds, notification placement, HUD scale, compact mode, and saved favorites.

## Controls

- Press **F4** to open the DarkRP command menu.
- Press **ESC** or the premium close button to close the F4 menu.
- Press and hold **TAB** to show the scoreboard.
- Release **TAB** to close the scoreboard and restore normal mouse behavior.
- Click a job card to inspect it in the large right-side preview.
- Click the star on a job card to favorite/unfavorite it; favorites are saved client-side.
- Click a multi-model preview to cycle available models.

## F4 Close Behavior

The F4 frame is single-instance safe. If it is already open, pressing F4 again starts the animated close path instead of creating a duplicate frame. Close actions disable input, fade out the panel, remove it safely, and release the screen clicker.

## TAB Scoreboard Behavior

The scoreboard is intended to be visible only while TAB is held. `ScoreboardShow` opens it, `ScoreboardHide` closes it, and a lightweight fail-safe closes it if TAB is no longer down so mouse input is not trapped after release.

## Theme and Settings Info

Client settings are stored in `data/darkrp_ui/settings.txt` and include theme, HUD enabled state, HUD scale, blur, notifications, notification position, sounds, compact mode, and favorites. Server owners can edit shared defaults in `lua/darkrp_ui/shared/sh_config.lua` and theme colors/radius in `lua/darkrp_ui/shared/sh_theme.lua`.

## Known Integration Placeholders

- Inventory panel: override/register an inventory module for the `inventory` F4 tab.
- Skills/XP: provide `DarkRPUI.GetLevelData(ply)` or DarkRP vars `level`, `xp`, and `xpmax`.
- Store: wire the `store` tab to your donation/store provider.
- Admin actions: connect moderation commands in `DarkRPUI.Admin.Send` to your admin system permissions.
- Server links: update Discord, rules, and store URLs in config.

## Testing Checklist

- Open F4 repeatedly and confirm no duplicate frames or stuck screen clicker.
- Search, sort, filter jobs, favorite jobs, reconnect, and confirm favorites persist.
- Verify every `RPExtraTeams` job displays a model and multi-model jobs can cycle models.
- Select locked/VIP/staff/vote jobs and confirm indicators/actions are clear.
- Change money, salary, health, armor, hunger, wanted, lockdown, voice, ammo, laws, and agenda values and confirm HUD animations.
- Hold and release TAB to confirm scoreboard appears only while held and mouse control is restored.
- Trigger legacy and DarkRP notifications before/after gamemode initialization and confirm there are no Lua errors.
- Toggle blur, sounds, compact mode, notification position, and HUD scale in settings.
