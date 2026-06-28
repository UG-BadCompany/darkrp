util.AddNetworkString('VoxUI.Admin.Notify')
util.AddNetworkString('VoxUI.Admin.Logs')

vox.admin.Actions = vox.admin.Actions or {}
vox.admin.Logs = vox.admin.Logs or {}
vox.admin.Cooldowns = vox.admin.Cooldowns or {}

local MAX_REASON_LENGTH = 160
local MAX_DURATION_MINUTES = 525600
local LOG_LIMIT = 200

local function normalizeGroup(group)
    return string.lower(tostring(group or 'user'))
end

local function rankWeight(ply)
    if not IsValid(ply) then return 1000 end
    local group = normalizeGroup(ply.GetUserGroup and ply:GetUserGroup() or 'user')
    return (vox.admin.Hierarchy and vox.admin.Hierarchy[group]) or (ply:IsSuperAdmin() and 100) or (ply:IsAdmin() and 50) or 0
end

local function notify(ply, ok, msg)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    net.Start('VoxUI.Admin.Notify')
        net.WriteBool(ok)
        net.WriteString(msg or '')
    net.Send(ply)
end

function vox.admin:NotifyStaff(admin, actionID, target)
    local adminName = IsValid(admin) and admin:Nick() or 'Console'
    local targetName = IsValid(target) and target:Nick() or 'server'
    local msg = adminName .. ' used ' .. actionID .. ' on ' .. targetName

    for _, ply in ipairs(player.GetHumans()) do
        if ply ~= admin and ply:IsAdmin() then
            notify(ply, true, msg)
        end
    end
end

local function hasULXAccess(ply, actionID)
    if not ULib or not ULib.ucl or not ULib.ucl.query then return nil end
    local ok = ULib.ucl.query(ply, 'ulx ' .. actionID)
    if ok == nil and actionID == 'returnply' then ok = ULib.ucl.query(ply, 'ulx return') end
    return ok == true
end

local function hasSAMAccess(ply, actionID)
    if not sam or not sam.player or not sam.player.has_permission then return nil end
    local permission = actionID == 'returnply' and 'return' or actionID
    return sam.player.has_permission(ply, permission) == true
end

local function fallbackAccess(admin, action)
    if not IsValid(admin) then return false end
    local minAccess = normalizeGroup(action.minAccess or 'admin')
    if minAccess == 'superadmin' then return admin:IsSuperAdmin() end
    if minAccess == 'admin' then return admin:IsAdmin() end

    local adminWeight = rankWeight(admin)
    local requiredWeight = (vox.admin.Hierarchy and vox.admin.Hierarchy[minAccess]) or 0
    return adminWeight >= requiredWeight
end

local function checkPrivilege(admin, action, target)
    if admin:IsSuperAdmin() then return true end

    if CAMI and CAMI.PlayerHasAccess then
        local ok, allowed = pcall(CAMI.PlayerHasAccess, admin, 'vox_admin_' .. action.id, nil, target)
        if ok and allowed ~= nil then return allowed == true end
    end

    local ulxAllowed = hasULXAccess(admin, action.id)
    if ulxAllowed ~= nil then return ulxAllowed end

    local samAllowed = hasSAMAccess(admin, action.id)
    if samAllowed ~= nil then return samAllowed end

    return fallbackAccess(admin, action)
end

local function findPlayer(identifier)
    identifier = tostring(identifier or '')
    if identifier == '' then return nil end

    for _, ply in ipairs(player.GetAll()) do
        if ply:SteamID() == identifier or ply:SteamID64() == identifier or tostring(ply:UserID()) == identifier then
            return ply
        end
    end
end

function vox.admin:WriteAuditLog(admin, action, target, reason)
    local row = {
        time = os.time(),
        admin = IsValid(admin) and (admin:Nick() .. ' [' .. admin:SteamID() .. ']') or 'Console',
        action = action,
        target = IsValid(target) and (target:Nick() .. ' [' .. target:SteamID() .. ']') or 'server',
        reason = reason or ''
    }

    table.insert(self.Logs, 1, row)
    if #self.Logs > LOG_LIMIT then table.remove(self.Logs) end

    self:Print('# -> # (#)', row.admin, action, row.target)
    file.CreateDir('vox_admin')
    file.Append('vox_admin/audit.log', util.TableToJSON(row) .. '\n')
end

vox.admin.Log = vox.admin.WriteAuditLog

function vox.admin:GetCooldownKey( admin )
    if not IsValid( admin ) then return 'Console' end
    return admin:SteamID() or tostring( admin )
end

function vox.admin:EnforceCooldown(admin, action)
    local cooldownEnd = self.Cooldowns[ self:GetCooldownKey( admin ) ] or 0
    if cooldownEnd > CurTime() then
        return false, string.format('Action cooldown active (%.1fs).', cooldownEnd - CurTime())
    end

    return true
end

function vox.admin:ValidateTarget(action, target)
    if not action.target then return true end
    if not IsValid(target) or not target:IsPlayer() then return false, 'Invalid target.' end
    if target:IsBot() and action.blockBots then return false, 'This action cannot target bots.' end
    return true
end

function vox.admin:CheckHierarchy(admin, action, target)
    if action.target and target ~= admin and rankWeight(admin) <= rankWeight(target) then
        return false, 'Rank hierarchy blocks this action.'
    end

    return true
end

function vox.admin:CanRun(admin, id, target)
    local action = self.Actions[id]
    if not action then return false, 'Unknown Vox Admin action.' end
    if not isfunction(action.run) then return false, 'Vox Admin action has no server handler.' end
    if IsValid(admin) and not admin:IsPlayer() then return false, 'Invalid admin.' end

    local cooldownOK, cooldownErr = self:EnforceCooldown(admin, action)
    if not cooldownOK then return false, cooldownErr end

    local targetOK, targetErr = self:ValidateTarget(action, target)
    if not targetOK then return false, targetErr end

    if IsValid( admin ) and not checkPrivilege(admin, action, target) then return false, 'You do not have permission.' end

    local hierarchyOK, hierarchyErr = self:CheckHierarchy(admin, action, target)
    if not hierarchyOK then return false, hierarchyErr end

    return true
end

function vox.admin:ExecuteServerAction(admin, id, target, reason, duration)
    local ok, err = self:CanRun(admin, id, target)
    if not ok then notify(admin, false, err) return false end

    local action = self.Actions[id]
    self.Cooldowns[ self:GetCooldownKey( admin ) ] = CurTime() + (action.cooldown or self.CooldownSeconds or 0.75)

    reason = tostring(reason or 'No reason provided'):Trim():sub(1, MAX_REASON_LENGTH)
    if reason == '' then reason = 'No reason provided' end
    duration = math.Clamp(tonumber(duration) or 0, 0, MAX_DURATION_MINUTES)

    local success, result = pcall(action.run, admin, target, reason, duration)
    if not success then
        self:WriteAuditLog(admin, id .. '_error', target, result)
        notify(admin, false, 'Action errored; see server console/audit log.')
        ErrorNoHalt('[Vox Admin] ' .. id .. ' failed: ' .. tostring(result) .. '\n')
        return false
    end

    if result == false or isstring(result) then
        notify(admin, false, isstring(result) and result or 'Action failed gracefully.')
        return false
    end

    self:WriteAuditLog(admin, id, target, reason)
    notify(admin, true, 'Vox Admin action completed: ' .. id)
    self:NotifyStaff(admin, id, target)
    return true
end

vox.admin.Run = vox.admin.ExecuteServerAction
vox.admin.ExecuteAction = vox.admin.ExecuteServerAction
vox.admin.EnforceActionCooldown = vox.admin.EnforceCooldown
vox.admin.CheckRankHierarchy = vox.admin.CheckHierarchy
vox.admin.ValidateActionTarget = vox.admin.ValidateTarget
vox.admin.StoreAuditLog = vox.admin.WriteAuditLog
vox.admin.SendStaffNotification = vox.admin.NotifyStaff

local function reg(id, fn, target)
    local action = vox.admin.Actions[id] or { target = target ~= false }
    action.target = target ~= false
    action.run = fn
    vox.admin:RegisterAction(id, action)
end

local function commandAvailable(command)
    if not concommand or not concommand.GetTable then return true end
    local commands = concommand.GetTable()
    return not commands or commands[command] ~= nil
end

local function runULX(command, target, duration, reason)
    if not ulx or not commandAvailable('ulx') then return false end
    if duration ~= nil then
        RunConsoleCommand('ulx', command, target:Nick(), tostring(duration), reason or '')
    else
        RunConsoleCommand('ulx', command, target:Nick())
    end
    return true
end

local function runSAM(command, target, duration, reason)
    if not sam or not commandAvailable('sam') then return false end
    if duration ~= nil then
        RunConsoleCommand('sam', command, target:SteamID(), tostring(duration), reason or '')
    else
        RunConsoleCommand('sam', command, target:SteamID())
    end
    return true
end

local DRC_REASON_MAP_DEFAULTS = {
    rdm = 'RDM',
    randomdeathmatch = 'RDM',
    ['random death match'] = 'RDM',
    failrp = 'FAILRP',
    fail = 'FAILRP',
    fearrp = 'FEARRP',
    fear = 'FEARRP',
    nlr = 'NLR',
    newlife = 'NLR',
    ['new life rule'] = 'NLR',
    meta = 'META',
    metagame = 'META',
    metagaming = 'META',
    prop = 'PROP',
    props = 'PROP',
    propspam = 'PROP',
    ['prop spam'] = 'PROP',
    propblock = 'PROP',
    ['prop block'] = 'PROP',
    proppush = 'PROP',
    ['prop push'] = 'PROP',
    mic = 'MIC',
    micspam = 'MIC',
    ['mic spam'] = 'MIC',
    chatspam = 'MIC',
    combatlog = 'COMBATLOG',
    ['combat logging'] = 'COMBATLOG',
    disconnect = 'COMBATLOG',
    build = 'BUILD',
    building = 'BUILD',
    job = 'JOB',
    jobabuse = 'JOB',
    abuse = 'JOB',
    general = 'GENERAL',
    other = 'GENERAL'
}

local DRC_ESTIMATED_DURATION_DEFAULTS = {
    INTRO = 9,
    RDM = 10,
    FAILRP = 10,
    FEARRP = 10,
    NLR = 10,
    META = 10,
    PROP = 10,
    MIC = 10,
    COMBATLOG = 10,
    BUILD = 10,
    JOB = 10,
    GENERAL = 9,
    FUNNY = 9,
    STORIES = 65,
    PAPERWORK = 18,
    HOLD = 14,
    RUMORS = 18,
    COFFEE = 18,
    RANDOM = 12,
    ADMIN = 16,
    IDLE = 10,
    OBSERVATIONS = 14,
    JUMP = 7,
    CROUCH = 7,
    DOOR = 7,
    SPAMJUMP = 9,
    SPAMDOOR = 9,
    PATIENT = 12,
    END = 10
}

local function ensureDRCComplianceConfig()
    if not DRC then return end

    DRC.Config = DRC.Config or {}
    local config = DRC.Config

    config.DefaultHoldSeconds = tonumber(config.DefaultHoldSeconds) or 180
    config.MinHoldSeconds = tonumber(config.MinHoldSeconds) or 10
    config.MaxHoldSeconds = tonumber(config.MaxHoldSeconds) or 3600
    config.IntroStartDelay = tonumber(config.IntroStartDelay) or 3
    config.AfterIntroDelay = tonumber(config.AfterIntroDelay) or 9
    config.AfterReasonDelay = tonumber(config.AfterReasonDelay) or 10
    config.QueueGapSeconds = tonumber(config.QueueGapSeconds) or 1
    config.FillerMinDelay = tonumber(config.FillerMinDelay) or 10
    config.FillerMaxDelay = tonumber(config.FillerMaxDelay) or 24
    config.EndDelayAfterSpawn = tonumber(config.EndDelayAfterSpawn) or 1.25

    if type(config.ReasonMap) ~= 'table' then config.ReasonMap = {} end
    for key, value in pairs(DRC_REASON_MAP_DEFAULTS) do
        if config.ReasonMap[key] == nil then
            config.ReasonMap[key] = value
        end
    end

    if type(config.EstimatedDurations) ~= 'table' then config.EstimatedDurations = {} end
    for key, value in pairs(DRC_ESTIMATED_DURATION_DEFAULTS) do
        if config.EstimatedDurations[key] == nil then
            config.EstimatedDurations[key] = value
        end
    end

    if type(config.SequencePattern) ~= 'table' or #config.SequencePattern == 0 then
        config.SequencePattern = {'FUNNY', 'PAPERWORK', 'STORIES', 'HOLD', 'COFFEE', 'RUMORS', 'OBSERVATIONS', 'ADMIN'}
    end

    if type(config.ActionCooldown) ~= 'table' then config.ActionCooldown = {} end
    config.ActionCooldown.JUMP = tonumber(config.ActionCooldown.JUMP) or 8
    config.ActionCooldown.CROUCH = tonumber(config.ActionCooldown.CROUCH) or 10
    config.ActionCooldown.DOOR = tonumber(config.ActionCooldown.DOOR) or 8
    config.ActionCooldown.SPAMJUMP = tonumber(config.ActionCooldown.SPAMJUMP) or 16
    config.ActionCooldown.SPAMDOOR = tonumber(config.ActionCooldown.SPAMDOOR) or 16
    config.ActionCooldown.PATIENT = tonumber(config.ActionCooldown.PATIENT) or 50
end

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
reg('ban', function(a,t,r,d) if runULX('ban', t, d, r) then return true end if runSAM('ban', t, d, r) then return true end return 'No ULX/SAM ban command is available on this server.' end)
reg('jail', function(a,t,r,d) if runULX('jail', t, d, r) then return true end if runSAM('jail', t, d, r) then return true end return 'No ULX/SAM jail command is available on this server.' end)
reg('drc_compliance', function(a,t,r,d)
    if not DRC or not DRC.JailPlayer then return 'DRC Compliance addon is not loaded.' end
    ensureDRCComplianceConfig()
    if not DRC.JailPoint or not DRC.JailPoint.pos then return 'No DRC jail point set. Use /drc_setjail in the compliance room.' end

    local duration = tonumber(d) or (DRC.Config and DRC.Config.DefaultHoldSeconds) or 180
    local ok, err = pcall(DRC.JailPlayer, a, t, r, duration)
    if not ok then return 'DRC Compliance jail failed: ' .. tostring(err) end
    return true
end)
reg('unjail', function(a,t) if runULX('unjail', t) then return true end if runSAM('unjail', t) then return true end return 'No ULX/SAM unjail command is available on this server.' end)
reg('setjob', function(a,t,r,d) local name = tostring(r or '') if name == '' or name == 'No reason provided' then return 'Provide a job/team name as the reason.' end for id, data in pairs(RPExtraTeams or {}) do if string.lower(data.name or '') == string.lower(name) or tostring(id) == name then t:changeTeam(id, true, true) return true end end return 'Unknown DarkRP job: ' .. name end)
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
    if IsValid(ply) and not ply:IsPlayer() then return end
    local id, targetID = args[1], args[2]
    local action = vox.admin.Actions[id]
    local target = action and action.target and findPlayer(targetID) or nil
    vox.admin:Run(ply, id, target, args[3] or '', tonumber(args[4]) or 0)
end)
