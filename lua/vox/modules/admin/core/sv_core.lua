util.AddNetworkString('VoxUI.Admin.Notify')
util.AddNetworkString('VoxUI.Admin.Logs')

vox.admin.Actions = vox.admin.Actions or {}
vox.admin.Logs = vox.admin.Logs or {}
vox.admin.Cooldowns = vox.admin.Cooldowns or {}

local HIERARCHY = { user = 0, vip = 5, moderator = 20, admin = 50, superadmin = 100 }
local COOLDOWN = 0.75

local function rankWeight(ply)
    if not IsValid(ply) then return 0 end
    local group = ply.GetUserGroup and ply:GetUserGroup() or 'user'
    return HIERARCHY[group] or (ply:IsSuperAdmin() and 100) or (ply:IsAdmin() and 50) or 0
end

local function notify(ply, ok, msg)
    if not IsValid(ply) then return end
    net.Start('VoxUI.Admin.Notify')
        net.WriteBool(ok)
        net.WriteString(msg or '')
    net.Send(ply)
end

function vox.admin:Log(admin, action, target, reason)
    local row = {
        time = os.time(),
        admin = IsValid(admin) and (admin:Nick() .. ' [' .. admin:SteamID() .. ']') or 'Console',
        action = action,
        target = IsValid(target) and (target:Nick() .. ' [' .. target:SteamID() .. ']') or 'none',
        reason = reason or ''
    }
    table.insert(self.Logs, 1, row)
    if #self.Logs > 200 then table.remove(self.Logs) end
    self:Print('# -> # (#)', row.admin, action, row.target)
    file.CreateDir('vox_admin')
    file.Append('vox_admin/audit.log', util.TableToJSON(row) .. '\n')
end

function vox.admin:RegisterAction(id, data)
    data.id = id
    self.Actions[id] = data
    if CAMI and CAMI.RegisterPrivilege then
        CAMI.RegisterPrivilege({ Name = 'vox_admin_' .. id, MinAccess = data.minAccess or 'admin', Description = 'Vox Admin: ' .. id })
    end
end

function vox.admin:CanRun(admin, id, target)
    local action = self.Actions[id]
    if not action then return false, 'Unknown Vox Admin action.' end
    if not IsValid(admin) or not admin:IsPlayer() then return false, 'Invalid admin.' end
    if self.Cooldowns[admin] and self.Cooldowns[admin] > CurTime() then return false, 'Action cooldown active.' end
    if action.target and not IsValid(target) then return false, 'Invalid target.' end
    local ok = admin:IsSuperAdmin()
    if CAMI and CAMI.PlayerHasAccess then
        local success, camiOk = pcall(CAMI.PlayerHasAccess, admin, 'vox_admin_' .. id, nil, target, { Fallback = action.minAccess or 'admin' })
        if success and camiOk ~= nil then ok = camiOk end
    end
    if not ok then ok = admin:IsAdmin() and (action.minAccess or 'admin') == 'admin' end
    if not ok then return false, 'You do not have permission.' end
    if action.target and target ~= admin and rankWeight(admin) <= rankWeight(target) then return false, 'Rank hierarchy blocks this action.' end
    return true
end

function vox.admin:Run(admin, id, target, reason, duration)
    local ok, err = self:CanRun(admin, id, target)
    if not ok then notify(admin, false, err) return false end
    self.Cooldowns[admin] = CurTime() + COOLDOWN
    reason = tostring(reason or 'No reason provided'):sub(1, 160)
    duration = math.Clamp(tonumber(duration) or 0, 0, 525600)
    local success, result = pcall(self.Actions[id].run, admin, target, reason, duration)
    if not success or result == false then notify(admin, false, isstring(result) and result or 'Action failed gracefully.') return false end
    if isstring(result) then notify(admin, false, result) return false end
    self:Log(admin, id, target, reason)
    notify(admin, true, 'Vox Admin action completed: ' .. id)
    for _, ply in ipairs(player.GetHumans()) do if ply ~= admin and ply:IsAdmin() then notify(ply, true, admin:Nick() .. ' used ' .. id) end end
    return true
end

local function reg(id, fn, target) vox.admin:RegisterAction(id, { target = target ~= false, run = fn }) end
reg('bring', function(a,t) t.VoxAdminReturnPos=t:GetPos(); t:SetPos(a:GetPos()+a:GetForward()*80); return true end)
reg('goto', function(a,t) a.VoxAdminReturnPos=a:GetPos(); a:SetPos(t:GetPos()+t:GetForward()*80); return true end)
reg('returnply', function(a,t) if not t.VoxAdminReturnPos then return 'No return position.' end t:SetPos(t.VoxAdminReturnPos); return true end)
reg('freeze', function(a,t) t:Freeze(true); return true end)
reg('unfreeze', function(a,t) t:Freeze(false); return true end)
reg('stripweapons', function(a,t) t:StripWeapons(); return true end)
reg('respawn', function(a,t) t:Spawn(); return true end)
reg('slay', function(a,t) t:Kill(); return true end)
reg('kick', function(a,t,r) t:Kick('Vox Admin: '..r); return true end)
reg('warn', function(a,t,r) notify(t,false,'Vox Admin warning: '..r); return true end)
reg('spectate', function(a,t) a:Spectate(OBS_MODE_IN_EYE); a:SpectateEntity(t); return true end)
reg('unspectate', function(a) a:UnSpectate(); a:Spawn(); return true end, false)
reg('noclip', function(a,t) t:SetMoveType(t:GetMoveType()==MOVETYPE_NOCLIP and MOVETYPE_WALK or MOVETYPE_NOCLIP); return true end)
reg('god', function(a,t) if t:HasGodMode() then t:GodDisable() else t:GodEnable() end return true end)
reg('ban', function(a,t,r,d) if ulx then RunConsoleCommand('ulx','ban',t:Nick(),tostring(d or 0),r); return true end if sam then RunConsoleCommand('sam','ban',t:SteamID(),tostring(d or 0),r); return true end return 'Ban is integration-ready; connect ULX/SAM/your ban system before enabling.' end)
reg('jail', function(a,t,r,d) if ulx then RunConsoleCommand('ulx','jail',t:Nick(),tostring(d or 0)); return true end if sam then RunConsoleCommand('sam','jail',t:SteamID(),tostring(d or 0)); return true end return 'Jail is integration-ready placeholder.' end)
reg('unjail', function(a,t) if ulx then RunConsoleCommand('ulx','unjail',t:Nick()); return true end if sam then RunConsoleCommand('sam','unjail',t:SteamID()); return true end return 'Unjail is integration-ready placeholder.' end)
reg('setjob', function(a,t,r,d) local name = tostring(r or '') if name == '' then return 'Provide a job/team name as the reason.' end for id, data in pairs(RPExtraTeams or {}) do if string.lower(data.name or '') == string.lower(name) or tostring(id) == name then t:changeTeam(id, true, true) return true end end return 'Unknown DarkRP job: ' .. name end)
reg('setmoney', function(a,t,r,d) local amount = tonumber(r) or tonumber(d) if not amount then return 'Provide a numeric money amount as the reason.' end local current = t.getDarkRPVar and (t:getDarkRPVar('money') or 0) or 0 if t.addMoney then t:addMoney(amount - current) elseif t.setDarkRPVar then t:setDarkRPVar('money', amount) else return 'DarkRP money API unavailable.' end return true end)
reg('cloak', function(a,t) t:SetNoDraw(not t:GetNoDraw()); t:DrawShadow(not t:GetNoDraw()); return true end)

concommand.Add('vox_admin_logs', function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    net.Start('VoxUI.Admin.Logs')
        net.WriteUInt(math.min(#vox.admin.Logs, 50), 8)
        for i = 1, math.min(#vox.admin.Logs, 50) do net.WriteString(util.TableToJSON(vox.admin.Logs[i]) or '{}') end
    net.Send(ply)
end)

concommand.Add('vox_admin_action', function(ply, _, args)
    if not IsValid(ply) then return end
    local id, steamid = args[1], args[2]
    local target
    for _, p in ipairs(player.GetAll()) do if p:SteamID() == steamid or p:SteamID64() == steamid then target = p break end end
    vox.admin:Run(ply, id, target, args[3] or '', tonumber(args[4]) or 0)
end)
