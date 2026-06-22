B4DUI = B4DUI or {}; B4DUI.F4=B4DUI.F4 or {}; function B4DUI.F4.Toggle() if IsValid(B4DUI.F4.Frame) then B4DUI.F4.Frame:Close(); return end; B4DUI.F4.Open() end
hook.Add("ShowSpare2","B4DUI.F4",function() B4DUI.F4.Toggle(); return true end)
