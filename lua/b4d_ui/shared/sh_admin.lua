B4DUI = B4DUI or {}; B4DUI.Admin=B4DUI.Admin or {}; B4DUI.Admin.Actions=B4DUI.Admin.Actions or {}
function B4DUI.Admin.RegisterAction(id,data) data=data or {}; data.id=id; B4DUI.Admin.Actions[id]=data end
function B4DUI.Admin.GetAction(id) return B4DUI.Admin.Actions[id] end
for _,id in ipairs({"bring","goto","returnply","freeze","unfreeze","spectate","unspectate","stripweapons","respawn","slay","kick","warn","ban","jail","unjail","setjob","setmoney","noclip","god","cloak"}) do B4DUI.Admin.RegisterAction(id,{name=string.upper(string.sub(id,1,1))..string.sub(id,2),permission=id,needsTarget=true}) end
