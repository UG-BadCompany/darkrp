DarkRPUI = DarkRPUI or {}
DarkRPUI.Util = DarkRPUI.Util or {}
local U = DarkRPUI.Util
function U.Clamp(v, mn, mx) return math.max(mn, math.min(mx, tonumber(v) or 0)) end
function U.Scale(v) local base = math.min(ScrW and ScrW() or 1920, (ScrH and ScrH() or 1080) * 16 / 9) / 1920 return math.max(1, math.Round((v or 0) * base)) end
function U.FormatMoney(amount) if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(amount or 0) end return (DarkRPUI.Config.CurrencySymbol or "$") .. string.Comma(math.floor(tonumber(amount) or 0)) end
function U.PlayerGroup(ply) return IsValid(ply) and ply.GetUserGroup and string.lower(ply:GetUserGroup() or "user") or "user" end
function U.IsVIP(ply) return DarkRPUI.Config.VIPGroups[U.PlayerGroup(ply)] == true end
function U.IsAdmin(ply) return IsValid(ply) and (ply:IsAdmin() or DarkRPUI.Config.AdminRanks[U.PlayerGroup(ply)] == true) end
function U.DarkRPVar(ply, key, fallback) if IsValid(ply) and ply.getDarkRPVar then local v = ply:getDarkRPVar(key) if v ~= nil then return v end end return fallback end
function U.SafeCall(fn, ...) if not isfunction(fn) then return nil end local ok, a, b, c = pcall(fn, ...) if ok then return a, b, c end return nil end
function U.CanAfford(ply, price) if not price or price <= 0 then return true end local money = U.DarkRPVar(ply, "money", 0) return money >= price end
function U.OpenURL(url) if url and url ~= "" then gui.OpenURL(url) end end
