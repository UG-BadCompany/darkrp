# Vox UI

Vox UI is a premium DarkRP interface suite for Garry's Mod. It ships as a complete HUD, F4 menu, scoreboard, settings center, notification stack, and admin control layer under the `vox` framework namespace.

## Visual Identity

Vox uses a distinct gaming UI language: charcoal glass panels, deep blue-gray surfaces, electric blue accent blades, subtle purple secondary highlights, slim cards, sharper rounded corners, neon strokes, hover glow, and diagonal/angled details. All active UI should consume Vox theme tokens rather than one-off hardcoded colors.

Included themes:

- Vox Obsidian
- Vox Midnight
- Vox Royal Purple
- Vox Carbon Red
- Vox Emerald
- Vox Gold
- Vox Light
- Custom Accent

## Installation

1. Place the addon folder in your server's `garrysmod/addons/` directory.
2. Keep the `lua/vox/` and `lua/autorun/vox_autorun.lua` paths intact.
3. Restart the server or run a clean map change.
4. Configure settings in-game through Vox Settings, Vox HUD settings, Vox Scoreboard settings, or the relevant console commands.

## Important Paths

- `lua/autorun/vox_autorun.lua` - bootstrap loader.
- `lua/vox/init.lua` - framework/module initializer.
- `lua/vox/modules/hud/` - Vox HUD, notifications, overhead UI, doors, radial/gesture UI, weapon selector, vehicle HUD, and settings.
- `lua/vox/modules/f4/` - Vox Menu tabs, jobs, shop, dashboard, upgrades, settings, and admin panels.
- `lua/vox/modules/scoreboard/` - Vox Scoreboard, columns, ranks, player inspector, and actions.
- `lua/vox/modules/admin/` - Vox Admin frontend/backend action registry.
- `lua/vox/ui/` - shared Vox UI components, drawing helpers, fonts, and traits.

## Console Commands

- `vox_reload` - requests a client-side Vox reload.
- `vox_reset_settings` - resets common client Vox settings to defaults.
- `vox_debug_safearea` - shows safe-area debugging for HUD alignment.
- `vox_test_notification` - previews Vox notification styles.
- `vox_open_admin` - opens Vox Admin.
- `vox_open_hud_settings` - opens Vox HUD settings.
- `vox_admin` - opens the admin control center.
- `vox_admin_action <action> <steamid> [reason] [duration]` - trusted UI/backend action bridge.

## HUD Presets

The HUD exposes four Vox-owned presets:

1. **Vox Tactical Card** - default compact card with angled accent blade, avatar/model frame, integrated money/salary, stacked health/armor/hunger bars, wanted/voice/license states, and animated values.
2. **Vox Command Strip** - command-style data strip for players who prefer a wider tactical HUD.
3. **Vox Minimal Edge** - reduced footprint edge layout.
4. **Vox Roleplay Profile** - richer profile-focused layout for immersive DarkRP servers.

HUD modules include main status, ammo, weapon selector, agenda, laws/alerts, wanted/lockdown alerts, voice indicator, pickup history, door info/menu, vehicle/speedometer, overhead UI, radial/gesture UI, and notifications. Modules use safe-area padding and support reduced motion where applicable.

## Vox Menu (F4)

Vox Menu keeps the expected DarkRP tabs without adding a Vehicles tab:

- Dashboard
- Jobs
- Shop
- Inventory
- Player Upgrades
- Donate
- Discord
- Forum
- Rules
- Settings
- Admin

The dashboard focuses on a custom command layout with profile/economy/job/server cards, players/staff counts, distribution summaries, announcements, mayor/laws, wanted players, and quick actions. Jobs use Vox job cards with an angled color strip, model badge, salary, slot meter, lock/vote/VIP badges, favorites, and a detailed model-stage overlay. Shop pages retain entities, weapons, shipments, ammo, and food with compact Vox item cards, whitelist/lock states, confirmation, and favorites.

## Vox Scoreboard

Vox Scoreboard preserves TAB behavior:

- Hold TAB to open.
- Release TAB to close.
- Right-click while holding TAB to enable cursor.
- Cursor is disabled on close.

Scoreboard features include grouped player sections, slim player rows, job-colored accent blades, rank badge pills, ping bars, voice/staff/VIP indicators, expandable player inspector, right-click context actions, column editor, rank editor, theme settings, preview rows, save, and reset controls.

## Vox Admin

Vox Admin provides a server-validated admin action registry with CAMI permission support, rank hierarchy protection, cooldowns, target validation, reason/duration sanitization, audit logs, staff notifications, and graceful fallback behavior.

Admin sections:

- Dashboard
- Players
- Player Inspector
- Logs
- Reports
- Movement Tools
- Punishments
- Server Tools
- Economy
- Settings

Registered actions:

- bring, goto, returnply
- freeze, unfreeze
- spectate, unspectate
- stripweapons, respawn, slay
- kick, warn
- ban, jail, unjail integration hooks
- setjob and setmoney integration hooks
- noclip, god, cloak

Ban/jail integrations attempt common ULX/SAM command fallbacks where available and otherwise fail with a clear integration-ready message.

## Shipment Whitelist

Vox Menu keeps DarkRP shipment/weapon/entity/ammo/food handling and displays whitelist or lock states directly on compact Vox shop cards. Keep DarkRP shipment definitions authoritative; Vox UI should present availability without bypassing server-side purchase validation.

## Settings and Accessibility

Vox Settings is organized as a control center:

- General
- Theme
- HUD
- F4
- Scoreboard
- Notifications
- Performance
- Accessibility
- Admin

Controls include toggles, sliders, dropdowns, number steppers, color pickers, reset buttons, and live previews for HUD cards, notifications, scoreboard rows, buttons/cards, and themes.

## Troubleshooting

- If the HUD does not appear, verify `lua/autorun/vox_autorun.lua` is present and the server performed a clean restart.
- If admin actions fail, check CAMI permissions and rank hierarchy. Equal/higher-ranked targets are protected.
- If notifications look default, ensure Vox HUD notifications are enabled and no other addon overwrote `notification.AddLegacy` after Vox loaded.
- If DarkRP data is missing, Vox uses safe fallbacks until DarkRP variables become available.
- Use `vox_debug_safearea` when elements are too close to screen edges.

## Testing Checklist

- Join as user and admin.
- Verify HUD values animate and stay inside safe-area.
- Verify money and salary are inside the HUD card.
- Open F4 and test each tab.
- Browse jobs, favorites, and job detail overlays.
- Browse shop categories and locked/whitelisted items.
- Hold TAB, release TAB, and test right-click cursor behavior.
- Expand a scoreboard row and test context actions.
- Open Vox Admin and test permitted/denied actions.
- Test notification types with `vox_test_notification`.
- Switch every Vox theme and confirm all UI uses theme tokens.
