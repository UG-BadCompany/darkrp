DarkRPUI=DarkRPUI or {}; DarkRPUI.Scoreboard=DarkRPUI.Scoreboard or {}; DarkRPUI.Scoreboard.ColumnSettings=DarkRPUI.Scoreboard.ColumnSettings or {"job","rank","money","level","kills","deaths","ping","voice"}
util.AddNetworkString("DarkRPUI.Scoreboard.SaveColumns")
net.Receive("DarkRPUI.Scoreboard.SaveColumns",function(_,ply) if not DarkRPUI.Util.IsAdmin(ply) then return end local cols=net.ReadTable() or {}; DarkRPUI.Scoreboard.ColumnSettings=cols; hook.Run("DarkRPUI.ScoreboardColumnsSaved",ply,cols) end)
