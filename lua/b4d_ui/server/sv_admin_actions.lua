B4DUI.ReturnPositions=B4DUI.ReturnPositions or {}; B4DUI.AdminCooldowns=B4DUI.AdminCooldowns or {}
local function runDarkRPCommand(ply, cmd) if ply and cmd then ply:ConCommand("darkrp "..cmd) end end
B4DUI.ActionHandlers={
 bring=function(a,t) B4DUI.ReturnPositions[t]=t:GetPos(); t:SetPos(a:GetPos()+a:GetForward()*60) end,
 goto=function(a,t) B4DUI.ReturnPositions[a]=a:GetPos(); a:SetPos(t:GetPos()+t:GetForward()*60) end,
 returnply=function(a,t) if B4DUI.ReturnPositions[t] then t:SetPos(B4DUI.ReturnPositions[t]); B4DUI.ReturnPositions[t]=nil end end,
 freeze=function(a,t) t:Freeze(true) end, unfreeze=function(a,t) t:Freeze(false) end,
 spectate=function(a,t) a:Spectate(OBS_MODE_IN_EYE); a:SpectateEntity(t) end, unspectate=function(a) a:UnSpectate(); a:Spawn() end,
 stripweapons=function(a,t) t:StripWeapons() end, respawn=function(a,t) t:Spawn() end, slay=function(a,t) t:Kill() end,
 kick=function(a,t,r) t:Kick(r ~= "" and r or "Kicked by staff") end, warn=function(a,t,r) B4DUI.Notify(t,"Warning: "..(r ~= "" and r or "No reason"),"warning") end,
 ban=function(a,t,r,d) if ULib and ULib.ban then ULib.ban(t, math.ceil((d or 0)/60), r, a) else t:Kick("Ban placeholder: "..(r or "No reason")) end end,
 jail=function(a,t,r,d) if sam and sam.player and sam.player.jail then sam.player.jail(t,d or 60) else t:Freeze(true); timer.Simple(d or 60,function() if IsValid(t) then t:Freeze(false) end end) end end,
 unjail=function(a,t) t:Freeze(false) end,
 setjob=function(a,t,r) if DarkRP and r and r ~= "" then t:changeTeam(tonumber(r) or t:Team(), true) end end,
 setmoney=function(a,t,r) if t.addMoney then t:addMoney((tonumber(r) or 0) - (t:getDarkRPVar("money") or 0)) end end,
 noclip=function(a,t) t:SetMoveType(t:GetMoveType()==MOVETYPE_NOCLIP and MOVETYPE_WALK or MOVETYPE_NOCLIP) end,
 god=function(a,t) if t:HasGodMode() then t:GodDisable() else t:GodEnable() end end,
 cloak=function(a,t) t:SetNoDraw(not t:GetNoDraw()) end
}
