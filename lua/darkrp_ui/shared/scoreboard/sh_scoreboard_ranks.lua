DarkRPUI=DarkRPUI or {}; DarkRPUI.Scoreboard=DarkRPUI.Scoreboard or {}; DarkRPUI.Scoreboard.Ranks=DarkRPUI.Scoreboard.Ranks or {}
function DarkRPUI.Scoreboard.RegisterRank(id,data) if not id or not istable(data) then return end data.id=id; DarkRPUI.Scoreboard.Ranks[id]=data end
for _,r in ipairs({"user","vip","moderator","admin","superadmin"}) do DarkRPUI.Scoreboard.RegisterRank(r,{displayName=string.upper(r),effect="Solid Color",primary=Color(80,160,255),secondary=Color(140,90,255)}) end
