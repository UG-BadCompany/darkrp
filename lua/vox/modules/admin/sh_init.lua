vox:Addon('admin', {
    color = Color(0, 174, 255),
    author = 'Vox UI',
    version = '2.1.0',
    licensee = 'vox-ui'
})

vox.admin.Actions = vox.admin.Actions or {}
vox.admin.ActionOrder = vox.admin.ActionOrder or {}
vox.admin.CooldownSeconds = 0.75
vox.admin.Hierarchy = { user = 0, vip = 5, moderator = 20, admin = 50, superadmin = 100 }

function vox.admin:RegisterAction(id, data)
    assert(isstring(id) and id ~= '', 'Vox admin action id must be a non-empty string')
    data = data or {}
    data.id = id
    data.name = data.name or string.upper(id)
    data.category = data.category or 'General'
    data.minAccess = data.minAccess or 'admin'
    data.target = data.target ~= false
    data.cooldown = tonumber(data.cooldown) or self.CooldownSeconds
    data.reason = data.reason ~= false

    if not self.Actions[id] then
        self.ActionOrder[#self.ActionOrder + 1] = id
    end

    self.Actions[id] = data

    if SERVER and CAMI and CAMI.RegisterPrivilege then
        CAMI.RegisterPrivilege({
            Name = 'vox_admin_' .. id,
            MinAccess = data.minAccess,
            Description = 'Vox Admin: ' .. (data.description or data.name or id)
        })
    end
end

function vox.admin:GetAction(id)
    return self.Actions[id]
end

function vox.admin:GetSortedActions()
    local out = {}
    for _, id in ipairs(self.ActionOrder or {}) do
        if self.Actions[id] then out[#out + 1] = self.Actions[id] end
    end
    return out
end

local function registerDefaultActions()
    local A = vox.admin
    A:RegisterAction('bring', { name = 'Bring', category = 'Movement', description = 'Bring a player to you.' })
    A:RegisterAction('goto', { name = 'Goto', category = 'Movement', description = 'Teleport to a player.' })
    A:RegisterAction('returnply', { name = 'Return', category = 'Movement', description = 'Return a player to their saved position.' })
    A:RegisterAction('freeze', { name = 'Freeze', category = 'Moderation', description = 'Freeze a player in place.' })
    A:RegisterAction('unfreeze', { name = 'Unfreeze', category = 'Moderation', description = 'Unfreeze a player.' })
    A:RegisterAction('stripweapons', { name = 'Strip Weapons', category = 'Moderation', description = 'Remove all weapons from a player.' })
    A:RegisterAction('respawn', { name = 'Respawn', category = 'Moderation', description = 'Respawn a player.' })
    A:RegisterAction('slay', { name = 'Slay', category = 'Punishments', description = 'Kill a player.' })
    A:RegisterAction('kick', { name = 'Kick', category = 'Punishments', description = 'Kick a player.', reason = true })
    A:RegisterAction('warn', { name = 'Warn', category = 'Punishments', description = 'Send a warning to a player.', reason = true })
    A:RegisterAction('spectate', { name = 'Spectate', category = 'Staff Tools', description = 'Spectate a player.' })
    A:RegisterAction('unspectate', { name = 'Unspectate', category = 'Staff Tools', target = false, description = 'Stop spectating.' })
    A:RegisterAction('noclip', { name = 'Noclip', category = 'Staff Tools', description = 'Toggle noclip on a player.', minAccess = 'superadmin' })
    A:RegisterAction('god', { name = 'God', category = 'Staff Tools', description = 'Toggle god mode on a player.', minAccess = 'superadmin' })
    A:RegisterAction('ban', { name = 'Ban', category = 'Punishments', description = 'Ban through ULX/SAM when available.', minAccess = 'superadmin', reason = true })
    A:RegisterAction('jail', { name = 'Jail', category = 'Punishments', description = 'Jail through ULX/SAM when available.', reason = true })
    A:RegisterAction('drc_compliance', { name = 'DRC Compliance', category = 'Punishments', description = 'Send a player to Department of Roleplay Compliance.', reason = true })
    A:RegisterAction('unjail', { name = 'Unjail', category = 'Punishments', description = 'Unjail through ULX/SAM when available.' })
    A:RegisterAction('setjob', { name = 'Set Job', category = 'DarkRP', description = 'Set DarkRP job by name/id.', minAccess = 'superadmin', reason = true })
    A:RegisterAction('setmoney', { name = 'Set Money', category = 'DarkRP', description = 'Set DarkRP wallet amount.', minAccess = 'superadmin', reason = true })
    A:RegisterAction('cloak', { name = 'Cloak', category = 'Staff Tools', description = 'Toggle player visibility.' })
end

registerDefaultActions()
vox.IncludeFolder('vox/modules/admin/core/', true)
vox.admin:Print('Finished loading Vox Admin action registry.')
