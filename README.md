# DarkRP Premium UI Suite

A complete 2026 visual rebuild for DarkRP servers. The addon now uses an original Onyx-inspired dark gaming dashboard direction without copying Onyx branding, assets, logos, or layout one-to-one.

## Full visual rebuild

- Rebuilt visual language around charcoal/navy glass frames, slate cards, thin blue accent lines, compact spacing, modern tabs, clean icons, animated rows, soft blur/dim overlays, thin scrollbars, and professional modal frames.
- Shared premium component library powers frames, headers, sidebars, cards, rows, buttons, icon buttons, search boxes, dropdowns, toggles, sliders, model previews, progress bars, badges, modals, locked states, loading states, context menus, and scrollbars.
- HUD, F4, scoreboard, admin menu, settings, notifications, weapon selector, door/property display, modals, radial menus, and overlays use the same design tokens instead of one-off Derma styling.

## Theme system

Included presets:

- Obsidian Blue
- Midnight Purple
- Carbon Red
- Emerald City
- Gold Luxury
- Cream Light
- Burgundy
- Custom Accent

The 2026 token set includes background, frame, frame header, sidebar, dark/light panels, cards, hover cards, rows, selected rows, borders, primary/secondary text, muted text, accent/accent hover/accent soft, success, money, warning, error, armor, hunger, wanted, shadow, glass, disabled, and locked colors.

## Safe-area layout

Global helpers prevent corner clipping and keep panels inside the playable screen:

- `DarkRPUI.Layout.GetSafeRect()`
- `DarkRPUI.Layout.ClampToScreen(x, y, w, h)`
- `DarkRPUI.Layout.ClampRect(x, y, w, h, padding)`
- `DarkRPUI.Layout.ClampPanel(panel, useSafeRect)`
- `DarkRPUI.Layout.CenterFrame(w, h)`

Debug the safe rectangle with:

```text
darkrpui_debug_safearea 1
```

The safe-area path is used by HUD cards, ammo, notifications, agenda/laws/wanted/lockdown cards, F4, scoreboard, settings, admin, modals, context menus, door UI, radial menu, and weapon selector.

## Animation and typography

- Fonts: `DarkRPUI.Title`, `DarkRPUI.Section`, `DarkRPUI.Subtitle`, `DarkRPUI.Body`, `DarkRPUI.Small`, `DarkRPUI.Tiny`, `DarkRPUI.Number`, and `DarkRPUI.Icon`.
- Animation helpers: `DarkRPUI.Anim.Fast`, `DarkRPUI.Anim.Normal`, `DarkRPUI.Anim.Slow`, `DarkRPUI.Anim.Duration(...)`, and `DarkRPUI.Anim.Lerp(...)`.
- Reduce Motion keeps fades but removes aggressive motion when enabled.

## F4 features

Visible sidebar tabs:

Dashboard, Jobs, Shop, Inventory, Player Upgrades, Donate, Discord, Forum, Rules, Settings, and Admin for staff.

Vehicles are removed from visible navigation. Skills is renamed to **Player Upgrades** everywhere.

Highlights:

- Centered glass F4 frame with safe-area clamping, close button, ESC close, animated open/close, no duplicate frames, and cursor cleanup.
- Player profile card at the top of the sidebar with avatar, name, job, and job-color accent.
- Dashboard command center with profile, job, wallet, vitals, level/XP placeholder, staff online, announcements, and quick-action cards.
- Jobs use searchable premium cards, favorites, salary, slots, lock badges, vote/VIP/staff tags, hover animation, model previews, and a detail panel.
- Job model handling supports string/table models, invalid model fallback, and auto-framing.
- Shop is a single premium tab with internal top tabs for Entities, Weapons, Shipments, Ammo, and Food. Vehicles are not shown.
- Purchase confirmation support is available through `DarkRPUI.Config.ConfirmPurchases`.

## Shipment job whitelist

Configure in `lua/darkrp_ui/shared/sh_config.lua`:

```lua
DarkRPUI.Config.ShipmentJobWhitelist = {
    -- ["AK-47 Shipment"] = { TEAM_GUNDEALER = true, TEAM_BLACKMARKET = true },
    -- ["Pistol Shipment"] = { TEAM_GUNDEALER = true }
}
DarkRPUI.Config.ShipmentWhitelistDefaultAllow = false
DarkRPUI.Config.ShowLockedShipments = true
```

Shipment matching checks `shipment.name`, `shipment.entity`, `shipment.class`, and `shipment.weaponClass`. If a shipment is unavailable and locked shipments are enabled, the F4 shows a premium locked card and the info panel displays “Restricted to specific jobs.”

## Player Upgrades

The old Skills naming has been replaced by **Player Upgrades**. Stock upgrade cards include Stamina, Strength, Business, Crafting, Driving, Security, Intelligence, Luck, Endurance, and Charisma. Servers can replace the page with:

```lua
hook.Run("DarkRPUI.BuildPlayerUpgrades", parent)
```

Return `true` from the hook to use a custom upgrade backend.

## HUD configuration

The settings menu exposes theme, scale, roundness, margin, compact mode, 3D model/avatar preferences, main HUD visibility, ammo, agenda, pickup history, voice panels, alerts, blur, speedometer blur, notification queue, theme restriction, font scale, animation speed, reduce motion, and live preview-style cards.

The HUD places money inside the main HUD card and keeps health, hunger, armor, salary, level, ammo, wanted, lockdown, agenda, laws, voice, and notification elements safe-area clamped.

## Scoreboard behavior

- Holding TAB opens the scoreboard.
- Releasing TAB closes it and always disables the screen clicker.
- Right-click while holding TAB enables the cursor for clickable rows and staff actions.
- A fail-safe closes the scoreboard if TAB is no longer held.
- The rebuilt scoreboard includes a left rail, search, column labels, premium player rows, ping colors, staff/VIP badges, context actions, and internal Settings, Ranks, and Columns pages.

## Admin backend and frontend

Server-authoritative net messages:

- `DarkRPUI.Admin.Action`
- `DarkRPUI.Admin.Notify`
- `DarkRPUI.Admin.RequestPlayerInfo`
- `DarkRPUI.Admin.PlayerInfo`
- `DarkRPUI.Admin.RequestLogs`
- `DarkRPUI.Admin.Logs`

The backend validates staff rank, action existence, permissions, target validity, rank hierarchy, reason, duration, cooldown, hooks, and logs every action. Supported actions include bring, goto, return, freeze, unfreeze, spectate, unspectate, strip weapons, respawn, slay, kick, warn, ban placeholder/integration, jail placeholder/integration, unjail placeholder/integration, setjob placeholder/integration, setmoney placeholder/integration, noclip, god, and cloak placeholder.

Configure permissions and rank power in `lua/darkrp_ui/shared/sh_config.lua` with `DarkRPUI.Config.AdminPermissions`, `DarkRPUI.Config.AdminPreventSameOrHigherRank`, and `DarkRPUI.Config.AdminRankPower`.

Hooks:

```lua
hook.Run("DarkRPUI.CanAdminAction", admin, target, action, data)
hook.Run("DarkRPUI.AdminAction", admin, target, action, data)
hook.Run("DarkRPUI.AdminActionOverride", action, admin, target, data)
```

## Notifications, overlays, and property UI

- Notifications are right-side toast cards with icons, title/message, colored accent strip, progress bar, and slide/fade stack animation.
- Weapon selector is replaced by a top-center premium selector with slot boxes and active highlights.
- Door/property text is replaced with a small centered premium card for owned/for-sale/locked states.
- `DarkRPUI.Radial.Open(items, x, y, callback)` provides optional radial menus for doors, emotes, player interaction, and staff quick actions.
- Connection-lost style overlay hooks are supported through the premium overlay file.

## Testing checklist

- No clipping at any corner.
- Safe-area outline appears with `darkrpui_debug_safearea 1`.
- F4 opens/closes.
- ESC closes F4.
- Vehicles tab is not visible.
- Player Upgrades tab is visible.
- Jobs show models.
- Job details open.
- Favorites save.
- Shipments whitelist works.
- Locked shipments look correct.
- Money is inside HUD.
- HUD settings save.
- Scoreboard opens only while TAB is held.
- Right-click while holding TAB enables cursor.
- Cursor disables on release.
- Admin actions work server-side.
- Non-admins cannot use admin actions.
- Rank protection works.
- Notifications work safely.
- Weapon selector works.
- Door UI works.
- Settings save.
- No Lua errors.
- No console spam.
