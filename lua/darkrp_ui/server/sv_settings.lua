net.Receive("DarkRPUI.SettingsSync", function(_, ply)
    local incoming = net.ReadTable() or {}
    if not istable(incoming) then return end
    ply.DarkRPUISettings = incoming
end)
