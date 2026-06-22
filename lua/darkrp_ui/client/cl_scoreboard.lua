DarkRPUI = DarkRPUI or {}; DarkRPUI.Scoreboard = DarkRPUI.Scoreboard or {}
local cursor=false
local activePage="players"
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
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,5); DarkRPUI.UI.ShadowedBox(22,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),240),DarkRPUI.Color("border"),125); DarkRPUI.UI.Text("SERVER ROSTER","DarkRPUI.Title",w/2,20,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER); DarkRPUI.UI.Text("Hold TAB to view • Right-click to use cursor/actions", "DarkRPUI.Small",w/2,52,DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER); DarkRPUI.UI.Badge(w-130,28,#player.GetAll().." ONLINE",DarkRPUI.Color("accent")) end
    local rail=vgui.Create("DPanel",f); rail:SetPos(18,88); rail:SetSize(54,f:GetTall()-106); rail.Paint=function(_,w,h) DarkRPUI.UI.RoundedBox(16,0,0,w,h,DarkRPUI.Color("sidebarDark")) end
    local content=vgui.Create("DPanel",f); content:SetPos(86,88); content:SetSize(f:GetWide()-110,f:GetTall()-112); content.Paint=nil
    local function buildSettingsPage(kind) content:Clear(); local title=kind=="ranks" and "RANK EFFECTS" or kind=="columns" and "COLUMN CONFIGURATION" or "SCOREBOARD SETTINGS"; DarkRPUI.UI.MakeHeader(content,title,"Modern configurable scoreboard tooling."):Dock(TOP); local grid=vgui.Create("DIconLayout",content); grid:Dock(FILL); grid:SetSpaceX(12); grid:SetSpaceY(12); local rows=(kind=="columns") and {"Column #1","Column #2","Column #3","Column #4","Column #5"} or (kind=="ranks" and {"Rank Identifier","Display Name","Effect","Color","Preview","Save"} or {"Title input","Group Teams","Colorized Gradient","Blur Theme","Show Avatars","Show Mic Icons","Show Ping Bars","Show Staff Actions"}); for _,r in ipairs(rows) do local c=DarkRPUI.UI.MakeAnimatedCard(grid,r,"Configurable premium option"); c:SetSize(260,96) end end
    local function buildPlayersPage() content:Clear(); local searchHolder,search=DarkRPUI.UI.PremiumSearch(content,"Search… (Name/SteamID)"); searchHolder:Dock(TOP); searchHolder:SetTall(42); local header=vgui.Create("DPanel",content); header:Dock(TOP); header:SetTall(30); header.Paint=function(_,w,h) DarkRPUI.UI.Text("PLAYER","DarkRPUI.Tiny",12,8,DarkRPUI.Color("muted")); DarkRPUI.UI.Text("JOB", "DarkRPUI.Tiny", w-560,8,DarkRPUI.Color("muted")); DarkRPUI.UI.Text("RANK", "DarkRPUI.Tiny", w-430,8,DarkRPUI.Color("muted")); DarkRPUI.UI.Text("MONEY", "DarkRPUI.Tiny", w-310,8,DarkRPUI.Color("muted")); DarkRPUI.UI.Text("PING", "DarkRPUI.Tiny", w-70,8,DarkRPUI.Color("muted")) end; local list=vgui.Create("DScrollPanel",content); list:Dock(FILL); list:DockMargin(0,6,0,0); DarkRPUI.UI.StyleScrollbar(list)
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
    local pages={{"players","👥"},{"settings","⚙"},{"ranks","◆"},{"columns","▥"},{"return","↩"}}
    for _,pg in ipairs(pages) do local b=DarkRPUI.UI.MakeIconButton(rail,pg[2],function() if pg[1]=="return" then DarkRPUI.Scoreboard.Close(); return end; activePage=pg[1]; if activePage=="players" then buildPlayersPage() else buildSettingsPage(activePage) end end); b:Dock(TOP); b:DockMargin(8,8,8,0); b:SetTall(38); b.ActiveFunc=function() return activePage==pg[1] end end
    activePage="players"; buildPlayersPage()
end
hook.Add("ScoreboardShow","DarkRPUI.Scoreboard.Show",function() if DarkRPUI.Config.EnableScoreboard then DarkRPUI.Scoreboard.Open(); return false end end)
hook.Add("ScoreboardHide","DarkRPUI.Scoreboard.Hide",function() DarkRPUI.Scoreboard.Close() end)
hook.Add("Think","DarkRPUI.Scoreboard.CursorAndFailsafe",function() if IsValid(DarkRPUI.Scoreboard.Frame) then if not input.IsKeyDown(KEY_TAB) then DarkRPUI.Scoreboard.Close(); return end; if input.IsMouseDown(MOUSE_RIGHT) and not cursor then setCursor(true) end end end)
