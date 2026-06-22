DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
DarkRPUI.Admin.Logs = DarkRPUI.Admin.Logs or {}
DarkRPUI.Admin.Actions = DarkRPUI.Admin.Actions or {}

local savedPos, spectating, cooldowns = {}, {}, {}
local aliases = { ["return"]="returnply", strip="stripweapons" }
local function group(p) return DarkRPUI.Util.PlayerGroup(p) end
local function power(p) return (DarkRPUI.Config.AdminRankPower or {})[group(p)] or 0 end
local function sid(p) return IsValid(p) and p:SteamID() or "CONSOLE" end
local function cleanReason(v) v=tostring(v or ""):Trim(); return v ~= "" and string.sub(v,1,180) or nil end
local function duration(v) v=tonumber(v) or 0; return math.Clamp(math.floor(v),0,60*60*24*365) end
local function notify(p, ok, title, msg) net.Start("DarkRPUI.Admin.Notify"); net.WriteBool(ok); net.WriteString(title or (ok and "Success" or "Denied")); net.WriteString(msg or ""); net.Send(p) end
local function staffBroadcast(admin, action, target, data)
    if DarkRPUI.Config.AdminBroadcastToStaff == false then return end
    for _,p in ipairs(player.GetAll()) do if p ~= admin and DarkRPUI.Util.IsAdmin(p) then notify(p,true,"Staff action",admin:Nick().." used "..action..(IsValid(target) and (" on "..target:Nick()) or "")) end end
end
local function logAction(admin,target,action,data,result)
    local row={time=os.time(), adminName=IsValid(admin) and admin:Nick() or "Console", adminSteamID=sid(admin), targetName=IsValid(target) and target:Nick() or "None", targetSteamID=sid(target), action=action, reason=cleanReason(data and data.reason) or "", duration=duration(data and data.duration), result=result or "ok"}
    table.insert(DarkRPUI.Admin.Logs,1,row); if #DarkRPUI.Admin.Logs>200 then table.remove(DarkRPUI.Admin.Logs) end
    hook.Run("DarkRPUI.AdminLoggedAction", row)
end
local function register(id, def) def.id=id; DarkRPUI.Admin.Actions[id]=def end
local function integration(action, admin, target, data)
    if hook.Run("DarkRPUI.AdminActionOverride", action, admin, target, data or {}) == true then return true end
    if ulx and action=="ban" then RunConsoleCommand("ulx","banid",target:SteamID(),tostring(duration(data.duration)/60),cleanReason(data.reason) or "DarkRPUI ban"); return true end
    if ulx and action=="jail" then RunConsoleCommand("ulx","jail",target:Nick(),tostring(duration(data.duration))); return true end
    if sam and sam.player then return false,"SAM detected: bind this in DarkRPUI.AdminActionOverride for your SAM version." end
    return false,"Integration placeholder: handle with DarkRPUI.AdminActionOverride."
end

register("bring",{label="Bring",category="Movement",requiresTarget=true,run=function(a,t) savedPos[t]=t:GetPos(); t:SetPos(a:GetPos()+a:GetForward()*64+Vector(0,0,8)) end})
register("goto",{label="Goto",category="Movement",requiresTarget=true,run=function(a,t) savedPos[a]=a:GetPos(); a:SetPos(t:GetPos()+t:GetForward()*64+Vector(0,0,8)) end})
register("returnply",{label="Return",category="Movement",requiresTarget=true,run=function(_,t) if not savedPos[t] then return false,"No saved return position." end; t:SetPos(savedPos[t]); savedPos[t]=nil end})
register("freeze",{label="Freeze",category="Moderation",requiresTarget=true,run=function(_,t) t:Freeze(true) end})
register("unfreeze",{label="Unfreeze",category="Moderation",requiresTarget=true,run=function(_,t) t:Freeze(false) end})
register("spectate",{label="Spectate",category="Moderation",requiresTarget=true,run=function(a,t) savedPos[a]=a:GetPos(); spectating[a]={target=t,pos=a:GetPos()}; a:Spectate(OBS_MODE_IN_EYE); a:SpectateEntity(t) end})
register("unspectate",{label="Unspectate",category="Moderation",requiresTarget=false,run=function(a) a:UnSpectate(); if spectating[a] and spectating[a].pos then a:SetPos(spectating[a].pos) end; spectating[a]=nil end})
register("stripweapons",{label="Strip Weapons",category="Punishments",requiresTarget=true,destructive=true,run=function(_,t) t:StripWeapons() end})
register("respawn",{label="Respawn",category="Quick Actions",requiresTarget=true,run=function(_,t) t:Spawn() end})
register("slay",{label="Slay",category="Punishments",requiresTarget=true,destructive=true,run=function(_,t) t:Kill() end})
register("kick",{label="Kick",category="Punishments",requiresTarget=true,destructive=true,needsReason=true,run=function(_,t,d) t:Kick(cleanReason(d.reason) or "Kicked by staff.") end})
register("warn",{label="Warn",category="Punishments",requiresTarget=true,needsReason=true,run=function(_,t,d) notify(t,false,"Staff warning",cleanReason(d.reason) or "You have been warned.") end})
for _,id in ipairs({"ban","jail","unjail","setjob","setmoney","cloak"}) do register(id,{label=id,category="Server Tools",requiresTarget=true,destructive=(id=="ban" or id=="jail"),needsReason=(id=="ban" or id=="jail"),needsDuration=(id=="ban" or id=="jail"),run=function(a,t,d) return integration(id,a,t,d) end}) end
register("noclip",{label="Noclip",category="Movement",requiresTarget=true,run=function(_,t) if not t.SetMoveType then return false,"Unsupported." end; t:SetMoveType(t:GetMoveType()==MOVETYPE_NOCLIP and MOVETYPE_WALK or MOVETYPE_NOCLIP) end})
register("god",{label="God Mode",category="Moderation",requiresTarget=true,run=function(_,t) if t:HasGodMode() then t:GodDisable() else t:GodEnable() end end})

function DarkRPUI.Admin.Can(ply, target, action, data)
    if not DarkRPUI.Util.IsAdmin(ply) then return false,"You are not staff." end
    action=aliases[action] or action; local def=DarkRPUI.Admin.Actions[action]; if not def then return false,"Unknown action." end
    local perms=(DarkRPUI.Config.AdminPermissions or {})[group(ply)] or {}; if not perms[action] then return false,"Your rank cannot use this action." end
    if def.requiresTarget and (not IsValid(target) or not target:IsPlayer()) then return false,"Invalid target player." end
    if IsValid(target) and target ~= ply and DarkRPUI.Config.AdminPreventSameOrHigherRank ~= false and power(ply) <= power(target) then return false,"You cannot target equal or higher ranked players." end
    if (def.needsReason or def.destructive) and not cleanReason(data and data.reason) then return false,"A reason is required." end
    if def.needsDuration and duration(data and data.duration) <= 0 then return false,"A duration is required." end
    cooldowns[ply]=cooldowns[ply] or {}; if (cooldowns[ply][action] or 0) > CurTime() then return false,"Please slow down." end; cooldowns[ply][action]=CurTime()+(DarkRPUI.Config.AdminActionCooldown or 1.5)
    local hr,why=hook.Run("DarkRPUI.CanAdminAction", ply, target, action, data or {}, def); if hr==false then return false,why or "Blocked by server hook." end
    return true
end

net.Receive("DarkRPUI.Admin.Action", function(_, ply)
    local action=string.lower(net.ReadString() or ""); action=aliases[action] or action
    local target=Entity(net.ReadUInt(16)); local data=net.ReadTable() or {}; data.reason=cleanReason(data.reason); data.duration=duration(data.duration)
    local def=DarkRPUI.Admin.Actions[action]; if not def then notify(ply,false,"Unknown action","Action does not exist."); return end
    local ok, reason=DarkRPUI.Admin.Can(ply,target,action,data); if not ok then logAction(ply,target,action,data,reason); notify(ply,false,"Action denied",reason); return end
    local ran,msg=def.run(ply,target,data); if ran==false then logAction(ply,target,action,data,msg); notify(ply,false,"Not completed",msg); return end
    logAction(ply,target,action,data,"ok"); hook.Run("DarkRPUI.AdminAction", ply, target, action, data, def); staffBroadcast(ply,action,target,data); notify(ply,true,"Admin action complete",def.label..(IsValid(target) and (" → "..target:Nick()) or ""))
end)

net.Receive("DarkRPUI.Admin.RequestPlayerInfo", function(_, ply)
    if not DarkRPUI.Util.IsAdmin(ply) then return end
    local t=Entity(net.ReadUInt(16)); if not IsValid(t) or not t:IsPlayer() then return end
    net.Start("DarkRPUI.Admin.PlayerInfo"); net.WriteEntity(t); net.WriteTable({steamid=t:SteamID(), steamid64=t:SteamID64(), usergroup=group(t), job=team.GetName(t:Team()) or "Unknown", health=t:Health(), armor=t:Armor(), money=DarkRPUI.Util.DarkRPVar(t,"money",0), ping=t:Ping(), pos=t:GetPos(), wanted=DarkRPUI.Util.DarkRPVar(t,"wanted",false), frozen=t:IsFlagSet(FL_FROZEN), alive=t:Alive(), playtime="Integration placeholder", notes="Integration placeholder"}); net.Send(ply)
end)


net.Receive("DarkRPUI.Admin.RequestLogs", function(_, ply)
    if not DarkRPUI.Util.IsAdmin(ply) then return end
    net.Start("DarkRPUI.Admin.Logs")
    net.WriteTable(DarkRPUI.Admin.Logs or {})
    net.Send(ply)
end)
