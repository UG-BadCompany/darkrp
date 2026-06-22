DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
-- Extension point for premium admin integrations. Core actions are registered in sv_admin.lua.
hook.Add("PlayerDisconnected","DarkRPUI.AdminCleanup",function(ply)
    if DarkRPUI.Admin and DarkRPUI.Admin.TempStates then DarkRPUI.Admin.TempStates[ply]=nil end
end)
