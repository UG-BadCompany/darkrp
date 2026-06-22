B4DUI = B4DUI or {}
B4DUI.RankWeights={user=0,trialmod=20,mod=30,admin=60,superadmin=90,owner=100}
B4DUI.Permissions={bring=30,goto=20,returnply=20,freeze=30,unfreeze=30,spectate=20,unspectate=20,stripweapons=60,respawn=30,slay=60,kick=60,warn=30,ban=90,jail=60,unjail=60,setjob=60,setmoney=90,noclip=60,god=60,cloak=60,admin_menu=20,settings_admin=90}
function B4DUI.GetRankWeight(rank) return B4DUI.RankWeights[string.lower(tostring(rank or "user"))] or 0 end
function B4DUI.GetPlayerRank(ply) if not IsValid(ply) then return "user" end; if ply.GetUserGroup then return string.lower(ply:GetUserGroup() or "user") end; return "user" end
function B4DUI.HasPermission(ply, perm) if not IsValid(ply) then return false end; if ply:IsSuperAdmin() then return true end; local need=B4DUI.Permissions[perm] or 999; return B4DUI.GetRankWeight(B4DUI.GetPlayerRank(ply))>=need end
function B4DUI.CanTarget(actor,target) if not IsValid(actor) or not IsValid(target) then return false end; if actor==target then return true end; if actor:IsSuperAdmin() then return true end; return B4DUI.GetRankWeight(B4DUI.GetPlayerRank(actor))>B4DUI.GetRankWeight(B4DUI.GetPlayerRank(target)) end
