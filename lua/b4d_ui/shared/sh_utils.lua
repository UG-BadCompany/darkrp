B4DUI = B4DUI or {}
function B4DUI.Lerp(current,target,speed) return Lerp(FrameTime()*math.max(speed or 10,1), current or target, target or 0) end
function B4DUI.ClampText(text,font,w) surface.SetFont(font or "DermaDefault"); local s=tostring(text or ""); if surface.GetTextSize(s)<=w then return s end; while #s>0 and surface.GetTextSize(s.."...")>w do s=string.sub(s,1,#s-1) end; return s.."..." end
function B4DUI.Money(v) local cur=(B4DUI.Config and B4DUI.Config.Currency) or "$"; return cur..string.Comma(math.floor(tonumber(v) or 0)) end
function B4DUI.CanUseDarkRP() return istable(DarkRP) end
function B4DUI.TeamColor(ply) return team.GetColor(IsValid(ply) and ply:Team() or 1) or B4DUI.Color("accent") end
