net.Receive("DarkRPUI.AdminAction", function(_, ply)
    if not DarkRPUI.Util.IsAdmin(ply) then return end
    local action = string.lower(net.ReadString() or "")
    local target = Entity(net.ReadUInt(16))
    if not IsValid(target) or not target:IsPlayer() then return end
    hook.Run("DarkRPUI.AdminAction", ply, action, target)
    if ULib then hook.Run("DarkRPUI.ULibAction", ply, action, target) end
    if SAM then hook.Run("DarkRPUI.SAMAction", ply, action, target) end
end)
