DarkRPUI=DarkRPUI or {}; DarkRPUI.Scoreboard=DarkRPUI.Scoreboard or {}
util.AddNetworkString("DarkRPUI.Scoreboard.SaveRank")
net.Receive("DarkRPUI.Scoreboard.SaveRank",function(_,ply) if not DarkRPUI.Util.IsAdmin(ply) then return end local id=string.lower(net.ReadString() or ""); local data=net.ReadTable() or {}; if id=="" then return end DarkRPUI.Scoreboard.RegisterRank(id,data); hook.Run("DarkRPUI.ScoreboardRankSaved",ply,id,data) end)
