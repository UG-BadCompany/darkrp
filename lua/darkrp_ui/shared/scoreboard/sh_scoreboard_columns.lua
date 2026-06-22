DarkRPUI=DarkRPUI or {}; DarkRPUI.Scoreboard=DarkRPUI.Scoreboard or {}; DarkRPUI.Scoreboard.Columns=DarkRPUI.Scoreboard.Columns or {}
function DarkRPUI.Scoreboard.RegisterColumn(id,data) if not id or not istable(data) then return end data.id=id; DarkRPUI.Scoreboard.Columns[id]=data end
local function dv(p,k,f) return DarkRPUI.Util and DarkRPUI.Util.DarkRPVar(p,k,f) or f end
DarkRPUI.Scoreboard.RegisterColumn("job",{name="Job",width=150,alignment=TEXT_ALIGN_LEFT,value=function(p) return team.GetName(p:Team()) or "Unknown" end,color=function(p) return team.GetColor(p:Team()) end})
DarkRPUI.Scoreboard.RegisterColumn("rank",{name="Rank",width=100,alignment=TEXT_ALIGN_LEFT,value=function(p) return DarkRPUI.Util.PlayerGroup(p) end})
DarkRPUI.Scoreboard.RegisterColumn("money",{name="Money",width=110,alignment=TEXT_ALIGN_RIGHT,value=function(p) return DarkRPUI.Util.FormatMoney(dv(p,"money",0)) end})
DarkRPUI.Scoreboard.RegisterColumn("playtime",{name="Playtime",width=100,alignment=TEXT_ALIGN_RIGHT,value=function(p) return hook.Run("DarkRPUI.ScoreboardPlaytime",p) or "—" end})
DarkRPUI.Scoreboard.RegisterColumn("level",{name="Level",width=70,alignment=TEXT_ALIGN_RIGHT,value=function(p) return hook.Run("DarkRPUI.ScoreboardLevel",p) or dv(p,"level",1) end})
DarkRPUI.Scoreboard.RegisterColumn("health",{name="HP",width=60,alignment=TEXT_ALIGN_RIGHT,value=function(p) return p:Health() end})
DarkRPUI.Scoreboard.RegisterColumn("karma",{name="Karma",width=70,alignment=TEXT_ALIGN_RIGHT,value=function(p) return hook.Run("DarkRPUI.ScoreboardKarma",p) or "—" end})
DarkRPUI.Scoreboard.RegisterColumn("kills",{name="Kills",width=60,alignment=TEXT_ALIGN_RIGHT,value=function(p) return p:Frags() end})
DarkRPUI.Scoreboard.RegisterColumn("deaths",{name="Deaths",width=70,alignment=TEXT_ALIGN_RIGHT,value=function(p) return p:Deaths() end})
DarkRPUI.Scoreboard.RegisterColumn("ping",{name="Ping",width=60,alignment=TEXT_ALIGN_RIGHT,value=function(p) return p:Ping().."ms" end})
DarkRPUI.Scoreboard.RegisterColumn("voice",{name="Voice",width=60,alignment=TEXT_ALIGN_CENTER,value=function(p) return p:IsSpeaking() and "●" or "" end})
DarkRPUI.Scoreboard.RegisterColumn("custom",{name="Custom",width=110,alignment=TEXT_ALIGN_LEFT,value=function(p) return hook.Run("DarkRPUI.ScoreboardCustomColumn",p) or "" end})
