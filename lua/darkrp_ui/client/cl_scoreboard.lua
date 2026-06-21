DarkRPUI = DarkRPUI or {}; DarkRPUI.Scoreboard = DarkRPUI.Scoreboard or {}
local function badgeText(ply) if DarkRPUI.Util.IsAdmin(ply) then return "STAFF", DarkRPUI.Color("warning") end if DarkRPUI.Util.IsVIP(ply) then return "VIP", DarkRPUI.Color("accent") end end
function DarkRPUI.Scoreboard.Open()
    if IsValid(DarkRPUI.Scoreboard.Frame) then DarkRPUI.Scoreboard.Frame:Remove() end
    local f=vgui.Create("DFrame"); DarkRPUI.Scoreboard.Frame=f; f:SetSize(ScrW()*0.74,ScrH()*0.74); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:MakePopup(); f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,5); DarkRPUI.UI.RoundedBox(18,0,0,w,h,DarkRPUI.Color("background")); DarkRPUI.UI.Text("Server Roster","DarkRPUI.Title",24,20); DarkRPUI.UI.Text(#player.GetAll().." players online", "DarkRPUI.Small",26,60,DarkRPUI.Color("subtext")) end
    local search=vgui.Create("DTextEntry",f); search:SetPos(24,92); search:SetSize(f:GetWide()-48,38); search:SetPlaceholderText("Search by name, job, rank, SteamID..."); search:SetFont("DarkRPUI.Body")
    local list=vgui.Create("DScrollPanel",f); list:SetPos(24,142); list:SetSize(f:GetWide()-48,f:GetTall()-166)
    local function rebuild()
        list:Clear(); local q=string.lower(search:GetValue() or ""); local players=player.GetAll(); table.sort(players,function(a,b) return team.GetName(a:Team()) < team.GetName(b:Team()) end)
        for _,ply in ipairs(players) do local hay=string.lower(table.concat({ply:Nick(), team.GetName(ply:Team()) or "", DarkRPUI.Util.PlayerGroup(ply), ply:SteamID()}, " ")); if q=="" or string.find(hay,q,1,true) then
            local row=vgui.Create("DButton",list); row:Dock(TOP); row:DockMargin(0,0,0,8); row:SetTall(64); row:SetText("")
            local av=vgui.Create("AvatarImage",row); av:SetSize(40,40); av:SetPos(12,12); av:SetPlayer(ply,40)
            row.Paint=function(_,w,h) DarkRPUI.UI.OutlinedBox(10,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border")); DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Body",62,10); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Unknown","DarkRPUI.Small",62,34,team.GetColor(ply:Team())); DarkRPUI.UI.Text(DarkRPUI.Util.PlayerGroup(ply),"DarkRPUI.Small",w-270,22,DarkRPUI.Color("subtext"),TEXT_ALIGN_RIGHT); local bt,bc=badgeText(ply); if bt then DarkRPUI.UI.Badge(w-210,22,bt,bc) end; DarkRPUI.UI.Text(ply:Ping().."ms","DarkRPUI.Small",w-18,22,DarkRPUI.Color("subtext"),TEXT_ALIGN_RIGHT) end
            row.DoClick=function() SetClipboardText(ply:SteamID()); DarkRPUI.Notify("success","SteamID copied",ply:SteamID()) end
            row.DoRightClick=function() local m=DermaMenu(); m:AddOption("Copy SteamID", function() SetClipboardText(ply:SteamID()) end); m:AddOption("Open Steam Profile", function() gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64()) end); if DarkRPUI.Util.IsAdmin(LocalPlayer()) then m:AddSpacer(); m:AddOption("Admin Actions", function() DarkRPUI.Admin.Open(ply) end); for _,a in ipairs({"bring","goto","freeze","kick"}) do m:AddOption(string.upper(a), function() DarkRPUI.Admin.Send(a,ply) end) end end; m:Open() end
        end end
    end
    search.OnChange=rebuild; rebuild()
end
hook.Add("ScoreboardShow","DarkRPUI.Scoreboard.Show",function() if DarkRPUI.Config.EnableScoreboard then DarkRPUI.Scoreboard.Open(); return false end end)
hook.Add("ScoreboardHide","DarkRPUI.Scoreboard.Hide",function() if IsValid(DarkRPUI.Scoreboard.Frame) then DarkRPUI.Scoreboard.Frame:Remove() end end)
