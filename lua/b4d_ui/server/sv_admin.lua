local function validateAction(ply, id, target, reason, duration)
    if not B4DUI.HasPermission(ply, id) then return false,"No permission" end
    local cd=B4DUI.AdminCooldowns[ply] or 0; if cd>CurTime() then return false,"Action cooldown" end
    local data=B4DUI.Admin.GetAction(id); if not data then return false,"Unknown action" end
    if data.needsTarget and not IsValid(target) then return false,"Invalid target" end
    if IsValid(target) and not B4DUI.CanTarget(ply,target) then return false,"Target rank is protected" end
    if #tostring(reason or "") > B4DUI.Config.Admin.MaxReasonLength then return false,"Reason too long" end
    if tonumber(duration or 0) > B4DUI.Config.Admin.MaxDuration then return false,"Duration too long" end
    return true
end
net.Receive("B4DUI.AdminAction",function(_,ply)
    local id=net.ReadString(); local target=net.ReadEntity(); local reason=net.ReadString(); local duration=net.ReadUInt(32)
    local ok,err=validateAction(ply,id,target,reason,duration); if not ok then B4DUI.Notify(ply,err,"danger"); return end
    local fn=B4DUI.ActionHandlers[id]; if not fn then B4DUI.Notify(ply,"Action not implemented","danger"); return end
    B4DUI.AdminCooldowns[ply]=CurTime()+B4DUI.Config.Admin.DefaultCooldown
    fn(ply,target,reason,duration); B4DUI.LogAdmin(ply,id,target,reason); B4DUI.Notify(nil,ply:Nick().." used "..id.." on "..(IsValid(target) and target:Nick() or "none"),"info")
end)
concommand.Add("b4d_admin_logs",function(ply) if IsValid(ply) then B4DUI.SendAdminLogs(ply) end end)
