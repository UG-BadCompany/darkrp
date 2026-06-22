DarkRPUI = DarkRPUI or {}; DarkRPUI.Scoreboard = DarkRPUI.Scoreboard or {}
local cursor=false
local function badgeText(ply) if DarkRPUI.Util.IsAdmin(ply) then return "STAFF", DarkRPUI.Color("warning") end if DarkRPUI.Util.IsVIP(ply) then return "VIP", DarkRPUI.Color("accent") end end
local function pingColor(p) if p < 70 then return DarkRPUI.Color("success") elseif p < 140 then return DarkRPUI.Color("warning") end return DarkRPUI.Color("error") end
local adminActions={"bring","goto","freeze","unfreeze","spectate","stripweapons","respawn","slay","kick","ban","warn"}
local function setCursor(v) cursor=v and true or false; gui.EnableScreenClicker(cursor) end
function DarkRPUI.Scoreboard.Close()
    local f=DarkRPUI.Scoreboard.Frame; DarkRPUI.Scoreboard.Frame=nil; setCursor(false)
    if IsValid(f) then DarkRPUI.UI.AnimatePanelOut(f,function(p) if IsValid(p) then p:Remove() end end) end
end
local function rowMenu(ply)
    local m=DermaMenu(); m:AddOption("Copy SteamID",function() SetClipboardText(ply:SteamID()) end); m:AddOption("Open Steam Profile",function() gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64()) end)
    if DarkRPUI.Util.IsAdmin(LocalPlayer()) then m:AddSpacer(); for _,a in ipairs(adminActions) do m:AddOption(string.upper(a),function() DarkRPUI.Admin.Send(a,ply) end) end end
    DarkRPUI.UI.StyleDermaMenu(m); m:Open()
end
function DarkRPUI.Scoreboard.Open()
    if IsValid(DarkRPUI.Scoreboard.Frame) then return end
    setCursor(false)
    local f=vgui.Create("DFrame"); DarkRPUI.Scoreboard.Frame=f; local fw,fh=DarkRPUI.Layout.SizeForScreen(1120,760); f:SetSize(fw,fh); f:Center(); DarkRPUI.Layout.ClampPanel(f,true); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:SetMouseInputEnabled(true); f:SetKeyboardInputEnabled(false); DarkRPUI.UI.AnimatePanelIn(f)
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,5); DarkRPUI.UI.ShadowedBox(22,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),240),DarkRPUI.Color("border"),125); DarkRPUI.UI.Text("Server Roster","DarkRPUI.Title",24,20); DarkRPUI.UI.Text("Hold TAB to view • Right-click to use cursor/actions", "DarkRPUI.Small",26,60,DarkRPUI.Color("subtext")); DarkRPUI.UI.Badge(w-130,28,#player.GetAll().." ONLINE",DarkRPUI.Color("accent")) end
    local searchHolder,search=DarkRPUI.UI.PremiumSearch(f,"Search by name, job, rank, SteamID..."); searchHolder:SetPos(24,92); searchHolder:SetSize(f:GetWide()-48,42)
    local list=vgui.Create("DScrollPanel",f); list:SetPos(24,142); list:SetSize(f:GetWide()-48,f:GetTall()-166); DarkRPUI.UI.StyleScrollbar(list)
    local function rebuild()
        list:Clear(); local q=string.lower(search:GetValue() or ""); local players=player.GetAll(); table.sort(players,function(a,b) return (team.GetName(a:Team()) or "") < (team.GetName(b:Team()) or "") end)
        for _,ply in ipairs(players) do local hay=string.lower(table.concat({ply:Nick(), team.GetName(ply:Team()) or "", DarkRPUI.Util.PlayerGroup(ply), ply:SteamID()}," ")); if q=="" or string.find(hay,q,1,true) then
            local row=vgui.Create("DButton",list); row:Dock(TOP); row:DockMargin(0,0,0,8); row:SetTall(64); row:SetText(""); row:SetMouseInputEnabled(true)
            local av=vgui.Create("AvatarImage",row); av:SetSize(40,40); av:SetPos(12,12); av:SetPlayer(ply,40)
            row.Paint=function(s,w,h) s.Hover=DarkRPUI.UI.HoverLerp(s,12); local tc=team.GetColor(ply:Team()); DarkRPUI.UI.ShadowedBox(14,0,-math.floor(3*s.Hover),w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"),DarkRPUI.Color("accent")),65+35*s.Hover); surface.SetDrawColor(tc.r,tc.g,tc.b,230); surface.DrawRect(0,0,5,h); DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Body",66,9); DarkRPUI.UI.Text(team.GetName(ply:Team()) or "Unknown","DarkRPUI.Small",66,34,tc); DarkRPUI.UI.Text(DarkRPUI.Util.PlayerGroup(ply),"DarkRPUI.Small",w-300,22,DarkRPUI.Color("subtext"),TEXT_ALIGN_RIGHT); local bt,bc=badgeText(ply); if bt then DarkRPUI.UI.Badge(w-230,22,bt,bc) end; DarkRPUI.UI.Text(ply:Ping().."ms","DarkRPUI.Small",w-18,22,pingColor(ply:Ping()),TEXT_ALIGN_RIGHT) end
            row.DoClick=function() if cursor then SetClipboardText(ply:SteamID()); DarkRPUI.Notify("success","SteamID copied",ply:SteamID()) end end
            row.DoRightClick=function() if not cursor then setCursor(true) end; rowMenu(ply) end
        end end
    end
    search.OnChange=rebuild; rebuild()
end
hook.Add("ScoreboardShow","DarkRPUI.Scoreboard.Show",function() if DarkRPUI.Config.EnableScoreboard then DarkRPUI.Scoreboard.Open(); return false end end)
hook.Add("ScoreboardHide","DarkRPUI.Scoreboard.Hide",function() DarkRPUI.Scoreboard.Close() end)
hook.Add("Think","DarkRPUI.Scoreboard.CursorAndFailsafe",function() if IsValid(DarkRPUI.Scoreboard.Frame) then if not input.IsKeyDown(KEY_TAB) then DarkRPUI.Scoreboard.Close(); return end; if input.IsMouseDown(MOUSE_RIGHT) and not cursor then setCursor(true) end end end)
