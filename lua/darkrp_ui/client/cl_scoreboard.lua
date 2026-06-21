DarkRPUI = DarkRPUI or {}; DarkRPUI.Scoreboard = DarkRPUI.Scoreboard or {}
local function badgeText(ply) if DarkRPUI.Util.IsAdmin(ply) then return "STAFF", DarkRPUI.Color("warning") end if DarkRPUI.Util.IsVIP(ply) then return "VIP", DarkRPUI.Color("accent") end end
local function pingColor(p) if p < 70 then return DarkRPUI.Color("success") elseif p < 140 then return DarkRPUI.Color("warning") end return DarkRPUI.Color("error") end
function DarkRPUI.Scoreboard.Close()
    local f = DarkRPUI.Scoreboard.Frame
    if not IsValid(f) then return end
    DarkRPUI.Scoreboard.Frame = nil
    gui.EnableScreenClicker(false)
    DarkRPUI.UI.AnimatePanelOut(f, function(p) if IsValid(p) then p:Remove() end end)
end
function DarkRPUI.Scoreboard.Open()
    if IsValid(DarkRPUI.Scoreboard.Frame) then DarkRPUI.Scoreboard.Close() end
    local f=vgui.Create("DFrame"); DarkRPUI.Scoreboard.Frame=f; f:SetSize(ScrW()*0.76,ScrH()*0.76); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:SetMouseInputEnabled(true); f:SetKeyboardInputEnabled(false); DarkRPUI.UI.AnimatePanelIn(f); f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,5); DarkRPUI.UI.OutlinedBox(20,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),240),DarkRPUI.Color("border")); DarkRPUI.UI.Text("Server Roster","DarkRPUI.Title",24,20); DarkRPUI.UI.Text(#player.GetAll().." players online  •  hold TAB to keep open", "DarkRPUI.Small",26,60,DarkRPUI.Color("subtext")) end
    local searchHolder,search=DarkRPUI.UI.PremiumSearch(f,"Search by name, job, rank, SteamID..."); searchHolder:SetPos(24,92); searchHolder:SetSize(f:GetWide()-48,42)
    local list=vgui.Create("DScrollPanel",f); list:SetPos(24,142); list:SetSize(f:GetWide()-48,f:GetTall()-166)
    local function rebuild()
        list:Clear(); local q=string.lower(search:GetValue() or ""); local players=player.GetAll(); table.sort(players,function(a,b) return team.GetName(a:Team()) < team.GetName(b:Team()) end)
        for _,ply in ipairs(players) do local hay=string.lower(table.concat({ply:Nick(), team.GetName(ply:Team()) or "", DarkRPUI.Util.PlayerGroup(ply), ply:SteamID()}, " ")); if q=="" or string.find(hay,q,1,true) then
            local row=vgui.Create("DButton",list); row:Dock(TOP); row:DockMargin(0,0,0,8); row:SetTall(64); row:SetText("")
            local av=vgui.Create("AvatarImage",row); av:SetSize(40,40); av:SetPos(12,12); av:SetPlayer(ply,40)
            row.Hover=0; row.Paint=function(s,w,h) s.Hover=DarkRPUI.UI.LerpValue(s.Hover,s:IsHovered() and 1 or 0,12); DarkRPUI.UI.OutlinedBox(12,0,0,w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("panel"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"),DarkRPUI.Color("accent"))); local tc=team.GetColor(ply:Team()); surface.SetDrawColor(tc.r,tc.g,tc.b,230); surface.DrawRect(0,0,5,h); surface.SetDrawColor(DarkRPUI.WithAlpha(color_black,120)); surface.DrawOutlinedRect(10,10,44,44); DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Body",66,9); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Unknown","DarkRPUI.Small",66,34,tc); DarkRPUI.UI.Text(DarkRPUI.Util.PlayerGroup(ply),"DarkRPUI.Small",w-300,22,DarkRPUI.Color("subtext"),TEXT_ALIGN_RIGHT); local bt,bc=badgeText(ply); if bt then DarkRPUI.UI.Badge(w-230,22,bt,bc) end; DarkRPUI.UI.Text(ply:Ping().."ms","DarkRPUI.Small",w-18,22,pingColor(ply:Ping()),TEXT_ALIGN_RIGHT) end
            row.DoClick=function() SetClipboardText(ply:SteamID()); DarkRPUI.Notify("success","SteamID copied",ply:SteamID()) end
            row.DoRightClick=function() local m=DermaMenu(); m:AddOption("Copy SteamID", function() SetClipboardText(ply:SteamID()) end); m:AddOption("Open Steam Profile", function() gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64()) end); if DarkRPUI.Util.IsAdmin(LocalPlayer()) then m:AddSpacer(); m:AddOption("Admin Actions", function() DarkRPUI.Admin.Open(ply) end); for _,a in ipairs({"bring","goto","freeze","kick"}) do m:AddOption(string.upper(a), function() DarkRPUI.Admin.Send(a,ply) end) end end; m:Open() end
        end end
    end
    search.OnChange=rebuild; rebuild()
end
hook.Add("ScoreboardShow","DarkRPUI.Scoreboard.Show",function() if DarkRPUI.Config.EnableScoreboard then DarkRPUI.Scoreboard.Open(); return false end end)
hook.Add("ScoreboardHide","DarkRPUI.Scoreboard.Hide",function() DarkRPUI.Scoreboard.Close() end)
hook.Add("Think","DarkRPUI.Scoreboard.FailSafe",function() if IsValid(DarkRPUI.Scoreboard.Frame) and not input.IsKeyDown(KEY_TAB) then DarkRPUI.Scoreboard.Close() end end)
