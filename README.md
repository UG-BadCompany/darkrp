# DarkRP UI

A premium, client-focused DarkRP interface suite for Garry's Mod. It replaces the default rough Derma feel with a consistent modern theme, animated panels, safe DarkRP integration points, and client-side preferences.

## Current Features

- **F4 command center** with a command-center dashboard, animated tab transitions, premium job/shop cards, searchable/sortable job browsing, category filters, larger selected-item preview, rich job details, polished salary/player/slot displays, click sounds, and client-side favorites.
- **Premium job browser** reads `RPExtraTeams` directly, supports `job.model` as a string or table, validates model paths when possible, falls back to `models/player/kleiner.mdl`, caches model lists, avoids broken-model errors, auto-frames DModelPanel cameras, and lets users click multi-model previews to cycle appearances.
- **Job status indicators** include favorite, locked, VIP, staff, and vote badges, plus clearer requirements and loadout text in the selected job panel.
- **HUD** includes animated health, armor, hunger, money, salary, ammo, voice, wanted, lockdown, agenda, and laws displays with compact mode and scaling support.
- **Scoreboard** opens only while TAB is held, uses premium rows, avatars, job color stripes, staff/VIP badges, colored ping, SteamID copy, and admin action integration placeholders.
- **Notifications** safely wrap legacy and DarkRP notifications after `GAMEMODE` is available, with stacked animated toast cards, type icons, progress bars, slide animations, and sound settings.
- **Reusable UI components** include premium buttons, cards, search boxes, combo boxes, close buttons, model previews, empty states, confirmation modals, shared animation helpers, consistent radius, hover behavior, spacing, fonts, and accent colors.
- **Themes/settings** provide consistent radius, spacing, font usage, accent colors, blur, sounds, notification placement, HUD scale, compact mode, tooltip and low-resolution behavior, confirmation flow defaults, and saved favorites.

## Controls

- Press **F4** to open the DarkRP command menu.
- Press **F4 again**, **ESC**, or the premium close button to close the F4 menu.
- Press and hold **TAB** to show the scoreboard.
- Release **TAB** to close the scoreboard and restore normal mouse behavior.
- Click a job card to inspect it in the large right-side preview.
- Click the star on a job card to favorite/unfavorite it; favorites are saved client-side.
- Click a multi-model preview to cycle available models.
- Click a scoreboard row to copy that player’s SteamID.

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
- Custom restriction messaging: integrate server-specific VIP/staff/custom-check failure copy where desired.

## Testing Checklist

- Open F4 repeatedly and confirm no duplicate frames or stuck screen clicker.
- Close F4 with F4, ESC, and the close button and confirm all paths animate out cleanly.
- Search, sort, filter jobs, favorite jobs, reconnect, and confirm favorites persist.
- Verify every `RPExtraTeams` job displays a model and multi-model jobs can cycle models.
- Confirm invalid/missing job models fall back to `models/player/kleiner.mdl` without Lua errors.
- Select locked/VIP/staff/vote jobs and confirm indicators/actions are clear.
- Change money, salary, health, armor, hunger, wanted, lockdown, voice, ammo, laws, and agenda values and confirm HUD animations.
- Toggle compact mode and HUD scale and confirm the HUD remains readable at common resolutions.
- Hold and release TAB to confirm scoreboard appears only while held and mouse control is restored.
- Trigger legacy and DarkRP notifications before/after gamemode initialization and confirm there are no Lua errors.
- Toggle blur, sounds, compact mode, notification position, and HUD scale in settings.
- Right-click scoreboard rows and confirm the DermaMenu matches the premium panel/card styling.
- Open settings and admin panels from F4 and confirm every button, combo box, slider card, popup, scrollbar, empty state, tooltip, and notification follows the same spacing, radius, shadow, accent, and font language.
- Test at 1280x720 and ultrawide resolutions to confirm HUD scale, F4 clamping, scoreboard sizing, and notification stacks remain readable without clipping.
- Trigger confirmation popups and locked-state flows for jobs/purchases/admin actions and confirm they animate, close, and play click sounds without trapping input.
