B4DUI = B4DUI or {}; B4DUI.Scoreboard=B4DUI.Scoreboard or {}
hook.Add("ScoreboardShow","B4DUI.ScoreboardShow",function() B4DUI.Scoreboard.Open(); return false end)
hook.Add("ScoreboardHide","B4DUI.ScoreboardHide",function() if IsValid(B4DUI.Scoreboard.Frame) then B4DUI.Scoreboard.Frame:Close() end; gui.EnableScreenClicker(false); return false end)
hook.Add("Think","B4DUI.ScoreboardCursor",function() if IsValid(B4DUI.Scoreboard.Frame) and input.IsMouseDown(MOUSE_RIGHT) then gui.EnableScreenClicker(true) end end)
