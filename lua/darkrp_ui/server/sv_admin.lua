DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
local savedPos, spectating = {}, {}
local targetRequired = { bring=true, goto=true, returnply=true, freeze=true, unfreeze=true, spectate=true, jail=true, unjail=true, stripweapons=true, respawn=true, slay=true, kick=true, ban=true, warn=true, setjob=true, setmoney=true }
local aliases = { ["return"]="returnply", strip="stripweapons" }
local function group(p) return DarkRPUI.Util.PlayerGroup(p) end
local function power(p) return (DarkRPUI.Config.AdminRankPower or {})[group(p)] or 0 end
function DarkRPUI.Admin.Can(ply, target, action, data)
    if not DarkRPUI.Util.IsAdmin(ply) then return false, "You are not staff." end
    action = aliases[action] or action
    local perms = (DarkRPUI.Config.AdminPermissions or {})[group(ply)] or {}
    if not perms[action] then return false, "Your rank cannot use this action." end
    if targetRequired[action] and (not IsValid(target) or not target:IsPlayer()) then return false, "Invalid target player." end
    if IsValid(target) and target ~= ply and DarkRPUI.Config.AdminPreventSameOrHigherRank ~= false and power(ply) <= power(target) then return false, "You cannot target equal or higher ranked players." end
    local hookResult, hookReason = hook.Run("DarkRPUI.CanAdminAction", ply, target, action, data or {})
    if hookResult == false then return false, hookReason or "Blocked by server hook." end
    return true
end
local function notify(p, ok, title, msg) net.Start("DarkRPUI.Admin.Notify"); net.WriteBool(ok); net.WriteString(title or (ok and "Success" or "Denied")); net.WriteString(msg or ""); net.Send(p) end
local actions = {}
actions.bring=function(a,t) savedPos[t]=t:GetPos(); t:SetPos(a:GetPos()+a:GetForward()*64+Vector(0,0,8)) end
actions.goto=function(a,t) savedPos[a]=a:GetPos(); a:SetPos(t:GetPos()+t:GetForward()*64+Vector(0,0,8)) end
actions.returnply=function(a,t) if savedPos[t] then t:SetPos(savedPos[t]); savedPos[t]=nil else return false,"No saved return position." end end
actions.freeze=function(_,t) t:Freeze(true) end; actions.unfreeze=function(_,t) t:Freeze(false) end
actions.stripweapons=function(_,t) t:StripWeapons() end; actions.respawn=function(_,t) t:Spawn() end; actions.slay=function(_,t) t:Kill() end
actions.kick=function(_,t,d) t:Kick((d and d.reason ~= "" and d.reason) or "Kicked by staff.") end
actions.spectate=function(a,t) savedPos[a]=a:GetPos(); spectating[a]={target=t,pos=a:GetPos()}; a:Spectate(OBS_MODE_IN_EYE); a:SpectateEntity(t) end
actions.unspectate=function(a) a:UnSpectate(); if spectating[a] and spectating[a].pos then a:SetPos(spectating[a].pos) end; spectating[a]=nil end
local function integration(action, admin, target, data)
    if hook.Run("DarkRPUI.AdminAction", admin, target, action, data or {}) == true then return true end
    if ulx and action=="ban" then RunConsoleCommand("ulx","banid",target:SteamID(),tostring(data.duration or 0),data.reason or "DarkRPUI ban"); return true end
    if ulx and action=="jail" then RunConsoleCommand("ulx","jail",target:Nick(),tostring(data.duration or 60)); return true end
    if SAM and sam and sam.player then return false,"SAM detected: bind this action in DarkRPUI.AdminAction hook for your SAM version." end
    return false,"Integration placeholder: handled by DarkRPUI.AdminAction hook or admin mod."
end
for _,id in ipairs({"ban","warn","jail","unjail","setjob","setmoney"}) do actions[id]=function(a,t,d) return integration(id,a,t,d) end end
net.Receive("DarkRPUI.Admin.Action", function(_, ply)
    local action=string.lower(net.ReadString() or ""); action=aliases[action] or action
    local target=Entity(net.ReadUInt(16)); local data=net.ReadTable() or {}
    local fn=actions[action]; if not fn then notify(ply,false,"Unknown action","Action does not exist."); return end
    local ok, reason=DarkRPUI.Admin.Can(ply,target,action,data); if not ok then notify(ply,false,"Action denied",reason); return end
    local ran, msg = fn(ply,target,data); if ran==false then notify(ply,false,"Not completed",msg); return end
    hook.Run("DarkRPUI.AdminAction", ply, target, action, data)
    notify(ply,true,"Admin action complete",action..(IsValid(target) and (" → "..target:Nick()) or ""))
end)
net.Receive("DarkRPUI.Admin.RequestPlayerInfo", function(_, ply)
    if not DarkRPUI.Util.IsAdmin(ply) then return end
    local t=Entity(net.ReadUInt(16)); if not IsValid(t) or not t:IsPlayer() then return end
    net.Start("DarkRPUI.Admin.PlayerInfo"); net.WriteEntity(t); net.WriteTable({steamid=t:SteamID(), usergroup=group(t), job=team.GetName(t:Team()) or "Unknown", health=t:Health(), armor=t:Armor(), money=DarkRPUI.Util.DarkRPVar(t,"money",0), ping=t:Ping(), pos=t:GetPos()}); net.Send(ply)
end)
