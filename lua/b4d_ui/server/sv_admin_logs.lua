B4DUI.AdminLogs=B4DUI.AdminLogs or {}
function B4DUI.LogAdmin(actor,action,target,reason) local row={time=os.time(),actor=IsValid(actor) and actor:Nick() or "Console",action=action,target=IsValid(target) and target:Nick() or "None",reason=reason or ""}; table.insert(B4DUI.AdminLogs,1,row); if #B4DUI.AdminLogs>250 then table.remove(B4DUI.AdminLogs) end end
function B4DUI.SendAdminLogs(ply) if not B4DUI.HasPermission(ply,"admin_menu") then return end; net.Start("B4DUI.AdminLogs"); net.WriteTable(B4DUI.AdminLogs); net.Send(ply) end
