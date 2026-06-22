# DarkRP Premium UI Suite

A complete modern UI overhaul for DarkRP servers: HUD, F4, scoreboard, notifications, settings, admin tools, popups, cards, filters, model previews, and shared premium components now use one cohesive glass-dashboard design.

## Visual overhaul

- Premium dark-glass panels, rounded cards, accent borders, soft shadows, animated hover states, premium buttons, search boxes, dropdowns, modals, empty states, locked states, and scrollbars.
- Responsive sizing and safe padding for 720p, 1080p, 1440p, and 4K.
- HUD money is inside the main HUD card; health, armor, hunger, salary, wanted, lockdown, ammo, agenda, laws, voice, and level placeholders share the active theme.
- The F4 sidebar no longer shows Vehicles. Vehicle source support remains in code for later reuse.
- Skills has been renamed to **Player Upgrades** across config, placeholders, and UI.

## Theme system

Included presets:

- Obsidian Blue
- Midnight Purple
- Carbon Red
- Emerald City
- Gold Luxury
- Clean Light
- Custom Accent

Every theme defines premium tokens for background, panel, card, card hover, border, text, muted/subtext, accent, success, warning, error, shadow, glass, disabled, locked, and highlight. UI systems consume these tokens instead of ad-hoc Derma colors.

## HUD configuration

Client-side settings include HUD position, HUD scale, HUD style, compact/full mode, module visibility for money/salary/hunger/level/ammo/agenda/laws, blur, theme preset, accent color, animation speed, font scale, notification position/sounds, reduce motion, and reset defaults. The Settings tab includes live HUD, notification, button, and card previews.

## F4 menu

Visible tabs:

Dashboard, Jobs, Entities, Weapons, Shipments, Ammo, Food, Inventory, Player Upgrades, Store, Rules, Settings, and Admin for staff.

Jobs use `DModelPanel`, support string/table models, fallback safely to Kleiner, auto-frame the model, rotate on hover, and allow local favorite jobs. Shop cards show name, price, description, category/preview where available, animated hover, and purchase buttons.

## Shipment job whitelist

Add whitelist rules in `lua/darkrp_ui/shared/sh_config.lua`:

```lua
DarkRPUI.Config.ShipmentJobWhitelist = {
    -- ["AK-47 Shipment"] = { TEAM_GUNDEALER = true, TEAM_BLACKMARKET = true },
    -- ["Pistol Shipment"] = { TEAM_GUNDEALER = true }
}
DarkRPUI.Config.ShipmentWhitelistDefaultAllow = false
DarkRPUI.Config.ShowLockedShipments = true
```

Shipment matching checks `shipment.name`, `shipment.entity`, `shipment.class`, and `shipment.weaponClass`. If a shipment is unavailable and locked shipments are enabled, the F4 shows a premium locked card and the info panel displays “Restricted to specific jobs.”

## TAB scoreboard behavior

- Holding TAB opens the scoreboard.
- Releasing TAB closes the scoreboard and always disables the screen clicker.
- While holding TAB, right-click unlocks the cursor for clickable rows/actions.
- Player rows support SteamID copy, Steam profile opening, and staff action menus.
- A fail-safe closes the scoreboard when TAB is no longer held, preventing stuck cursors.

## Admin backend

The admin UI now requests server-side actions through these net messages:

- `DarkRPUI.Admin.Action`
- `DarkRPUI.Admin.Notify`
- `DarkRPUI.Admin.RequestPlayerInfo`
- `DarkRPUI.Admin.PlayerInfo`

The server validates requester rank, action permission, target validity, and same/higher-rank protection before running anything. Supported working actions include bring, goto, return, freeze, unfreeze, spectate, unspectate, strip weapons, respawn, slay, and kick. Ban, warn, jail, unjail, set job, and set money expose clean integration hooks and polished placeholder responses when no supported admin mod integration is present.

Configuration:

```lua
DarkRPUI.Config.AdminPreventSameOrHigherRank = true
DarkRPUI.Config.AdminRankPower = { user = 0, vip = 0, moderator = 20, admin = 50, superadmin = 100, owner = 999 }
DarkRPUI.Config.AdminPermissions = { -- see sh_config.lua for defaults }
```

Hooks:

```lua
hook.Run("DarkRPUI.CanAdminAction", admin, target, action, data)
hook.Run("DarkRPUI.AdminAction", admin, target, action, data)
```

## Known integrations/placeholders

- Inventory, Player Upgrades/XP, and Store are integration-ready placeholders.
- Ban/warn/jail/unjail/setjob/setmoney should be wired to your chosen admin/economy stack through the provided hooks when ULX/SAM behavior differs by server version.

## Testing checklist

- F4 opens/closes.
- ESC closes F4.
- Vehicles tab is not visible.
- Player Upgrades tab is visible.
- Jobs show models.
- Job model fallback works.
- Shipments respect whitelist.
- Locked shipments display correctly.
- Money is inside main HUD.
- HUD does not clip at screen edge.
- HUD settings save.
- TAB opens scoreboard.
- Releasing TAB closes scoreboard.
- Right-click while holding TAB enables cursor.
- Scoreboard row actions are clickable.
- Cursor disables on TAB release.
- Admin actions run server-side.
- Non-admin users cannot run admin actions.
- Lower ranks cannot target equal/higher ranks when enabled.
- Notifications work before/after DarkRP loads.
- No Lua errors.
- No cursor stuck.
- No console spam.


## 1.2 premium systems update

This release deepens the Onyx-inspired-but-original direction with a stricter safe-area layout layer, a callable theme engine with `DarkRPUI.Theme.Default`, global animation constants, premium overlay systems, and more integration hooks.

### Safe-area debugging

Run this client convar to draw the protected layout rectangle and confirm HUD/menu elements are not touching screen corners:

```text
darkrpui_debug_safearea 1
```

The shared helpers now include `DarkRPUI.Layout.GetSafeRect()`, `DarkRPUI.Layout.ClampToScreen(x, y, w, h)`, `DarkRPUI.Layout.ClampRect(...)`, and `DarkRPUI.Layout.ClampPanel(...)`. F4, scoreboard, notifications, HUD cards, ammo HUD, agenda/law cards, door UI, radial menu, weapon selector, context menus, and modals use this safe-area clamp path.

### Premium overlays

- Modern top-center weapon selector with slot columns 1-6, active highlight, fade timing, and theme-aware cards.
- Door/property HUD card for owned/for-sale doors with safe-area clamp.
- Optional radial action API via `DarkRPUI.Radial.Open(items, x, y, callback)` for doors, player interactions, emotes, or staff quick actions.
- Admin log networking via `DarkRPUI.Admin.RequestLogs` and `DarkRPUI.Admin.Logs`.

### Expanded testing checklist

- No clipping at screen corners.
- Safe-area outline appears with `darkrpui_debug_safearea 1`.
- F4 centers within safe area at 65-72% width and clamps at lower resolutions.
- Player Upgrades hook `DarkRPUI.BuildPlayerUpgrades` can replace the stock upgrade cards.
- Player Upgrades includes Stamina, Strength, Business, Crafting, Driving, Security, Intelligence, Luck, Endurance, and Charisma.
- Weapon selector opens at top center for slots 1-6 and stays inside safe area.
- Door/property text appears as a modern centered card and stays inside safe area.
- Radial menus clamp around the crosshair and close on ESC/release integrations.
- Admin logs request/response networking is available only to staff.
