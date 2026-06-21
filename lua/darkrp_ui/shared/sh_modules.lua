DarkRPUI = DarkRPUI or {}; DarkRPUI.Modules = DarkRPUI.Modules or {}
function DarkRPUI.RegisterModule(id, module) module.id = id DarkRPUI.Modules[id] = module end
function DarkRPUI.GetModule(id) return DarkRPUI.Modules[id] end
