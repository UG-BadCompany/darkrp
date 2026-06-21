DarkRPUI = DarkRPUI or {}; DarkRPUI.Materials = DarkRPUI.Materials or {}
function DarkRPUI.GetMaterial(path) if not DarkRPUI.Materials[path] then DarkRPUI.Materials[path] = Material(path, "smooth mips") end return DarkRPUI.Materials[path] end
