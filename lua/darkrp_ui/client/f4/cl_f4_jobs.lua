DarkRPUI=DarkRPUI or {}; DarkRPUI.F4=DarkRPUI.F4 or {}
function DarkRPUI.F4.BuildJobs(parent) parent:Clear(); local scroll=DarkRPUI.UI.CreateScroll(parent); scroll:Dock(FILL); for _,job in ipairs(RPExtraTeams or {}) do DarkRPUI.F4.CreateItemCard(scroll,job,function(j) DarkRPUI.F4.ShowJobDetail(j) end):Dock(TOP) end end
