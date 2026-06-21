DarkRPUI = DarkRPUI or {}
DarkRPUI.Util = DarkRPUI.Util or {}
local U = DarkRPUI.Util
function U.Clamp(v, mn, mx) return math.max(mn, math.min(mx, v or 0)) end
function U.LerpColor(frac, a, b) frac = U.Clamp(frac, 0, 1) return Color(Lerp(frac,a.r,b.r), Lerp(frac,a.g,b.g), Lerp(frac,a.b,b.b), Lerp(frac,a.a or 255,b.a or 255)) end
function U.FormatMoney(amount) local sym = DarkRPUI.Config.CurrencySymbol or "$" if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(amount or 0) end return sym .. string.Comma(math.floor(tonumber(amount) or 0)) end
function U.PlayerGroup(ply) return IsValid(ply) and (ply.GetUserGroup and ply:GetUserGroup() or "user") or "user" end
function U.IsVIP(ply) return DarkRPUI.Config.VIPGroups[U.PlayerGroup(ply)] == true end
function U.IsAdmin(ply) return IsValid(ply) and (ply:IsAdmin() or DarkRPUI.Config.AdminRanks[U.PlayerGroup(ply)] == true) end
function U.SafeCall(fn, ...) if not isfunction(fn) then return nil end return fn(...) end
function U.Scale(v) return math.Round(v * math.min(ScrW() / 1920, ScrH() / 1080)) end
