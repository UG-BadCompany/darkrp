DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
local actions={
    {id="bring", label="Bring", tone="accent"},{id="goto", label="Goto", tone="info"},{id="returnply", label="Return", tone="info"},{id="freeze", label="Freeze", tone="warning"},{id="unfreeze", label="Unfreeze", tone="success"},{id="spectate", label="Spectate", tone="accent"},{id="unspectate", label="Unspectate", tone="accent"},{id="stripweapons", label="Strip Weapons", tone="warning"},{id="respawn", label="Respawn", tone="success"},{id="slay", label="Slay", tone="error"},{id="kick", label="Kick", tone="error"},{id="ban", label="Ban", tone="error"},{id="warn", label="Warn", tone="warning"},{id="jail", label="Jail", tone="warning"},{id="unjail", label="Unjail", tone="success"},{id="setjob", label="Set Job", tone="info"},{id="setmoney", label="Set Money", tone="success"}
}
local selected
local searchText=""
local function canLocal(action) local perms=(DarkRPUI.Config.AdminPermissions or {})[DarkRPUI.Util.PlayerGroup(LocalPlayer())] or {}; return perms[action] == true end
function DarkRPUI.Admin.Send(action,target,data) if not IsValid(target) and action ~= "unspectate" then return end net.Start("DarkRPUI.Admin.Action"); net.WriteString(action); net.WriteUInt(IsValid(target) and target:EntIndex() or 0,16); net.WriteTable(data or {}); net.SendToServer(); DarkRPUI.Notify("info","Admin request",action..(IsValid(target) and (" -> "..target:Nick()) or "")) end
local function plyLine(ply) return (ply:SteamID() or "BOT").." • "..(team.GetName(ply:Team()) or "Unknown") end
local function drawPlayerCard(row, ply, active)
    row.Hover=DarkRPUI.UI.HoverLerp(row,12); local f=math.max(row.Hover,active and 1 or 0)
    DarkRPUI.UI.ShadowedBox(15,0,-3*row.Hover,row:GetWide(),row:GetTall(),DarkRPUI.UI.LerpColor(f,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.UI.LerpColor(f,DarkRPUI.Color("border"),DarkRPUI.Color("accent")),65+35*f)
    surface.SetDrawColor(team.GetColor(ply:Team())); surface.DrawRect(0,12,4,row:GetTall()-24)
    DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Body",16,10)
    DarkRPUI.UI.Text(plyLine(ply),"DarkRPUI.Small",16,32,DarkRPUI.Color("subtext"))
    DarkRPUI.UI.Badge(row:GetWide()-78,18,DarkRPUI.Util.IsAdmin(ply) and "STAFF" or "USER",DarkRPUI.Util.IsAdmin(ply) and DarkRPUI.Color("warning") or DarkRPUI.Color("accent"))
end
function DarkRPUI.Admin.Open(target)
    if not DarkRPUI.Util.IsAdmin(LocalPlayer()) then return end
    selected=IsValid(target) and target or selected
    if IsValid(DarkRPUI.Admin.Frame) then DarkRPUI.UI.SafeRemoveAnimated(DarkRPUI.Admin.Frame) end
    local f=vgui.Create("DFrame"); DarkRPUI.Admin.Frame=f; f:SetSize(760,540); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:MakePopup(); DarkRPUI.UI.AnimatePanelIn(f)
    f.OnKeyCodePressed=function(_,key) if key==KEY_ESCAPE then DarkRPUI.UI.SafeRemoveAnimated(f) end end
    f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,5); DarkRPUI.UI.ShadowedBox(20,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),242),DarkRPUI.Color("border"),125); DarkRPUI.UI.Text("Admin Command Center","DarkRPUI.Title",24,18); DarkRPUI.UI.Text("Search players, inspect details, and run moderated actions.","DarkRPUI.Small",26,56,DarkRPUI.Color("subtext")) end
    local close=DarkRPUI.UI.CloseButton(f, function() DarkRPUI.UI.SafeRemoveAnimated(f) end); close:SetPos(f:GetWide()-58,12)
    local left=vgui.Create("DPanel",f); left:SetPos(22,92); left:SetSize(350,426); left.Paint=function(_,w,h) DarkRPUI.UI.ShadowedBox(18,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border"),90) end
    local searchHolder, search = DarkRPUI.UI.PremiumSearch(left,"Search name, SteamID, job...",function(v) searchText=string.lower(v or ""); if IsValid(left.List) and left.Rebuild then left.Rebuild() end end); searchHolder:SetPos(14,14); searchHolder:SetSize(322,44)
    local list=vgui.Create("DScrollPanel",left); left.List=list; list:SetPos(14,70); list:SetSize(322,342); DarkRPUI.UI.StyleScrollbar(list)
    local detail=vgui.Create("DPanel",f); detail:SetPos(390,92); detail:SetSize(348,426); detail.Paint=function(_,w,h)
        DarkRPUI.UI.ShadowedBox(18,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border"),90)
        if not IsValid(selected) then DarkRPUI.UI.Text("Select a player","DarkRPUI.Subtitle",24,24); DarkRPUI.UI.Text("Player details and action buttons appear here.","DarkRPUI.Small",24,56,DarkRPUI.Color("subtext")); return end
        DarkRPUI.UI.Text(selected:Nick(),"DarkRPUI.Subtitle",24,22); DarkRPUI.UI.Text(plyLine(selected),"DarkRPUI.Small",24,52,DarkRPUI.Color("subtext")); DarkRPUI.UI.Badge(24,82,DarkRPUI.Util.IsAdmin(selected) and "STAFF" or "PLAYER",DarkRPUI.Util.IsAdmin(selected) and DarkRPUI.Color("warning") or DarkRPUI.Color("accent")); DarkRPUI.UI.Badge(92,82,"HP "..selected:Health(),DarkRPUI.Color("success")); DarkRPUI.UI.Badge(150,82,"PING "..selected:Ping(),DarkRPUI.Color("info"))
    end
    local grid=vgui.Create("DIconLayout",detail); grid:SetPos(22,126); grid:SetSize(304,278); grid:SetSpaceX(10); grid:SetSpaceY(10)
    local function rebuildActions()
        grid:Clear(); for _,a in ipairs(actions) do if canLocal(a.id) then local b=vgui.Create("DButton",grid); b:SetSize(147,42); b:SetText(a.label); DarkRPUI.UI.StyleButton(b,DarkRPUI.Color(a.tone)); DarkRPUI.UI.AttachTooltip(b,"Run "..a.label.." on the selected player."); b.DoClick=function() if not IsValid(selected) then DarkRPUI.Notify("warning","No player selected","Choose a player first."); return end; DarkRPUI.UI.Confirm("Confirm admin action","Run "..a.label.." on "..selected:Nick().."?","Run","Cancel",function(ok) if ok then DarkRPUI.Admin.Send(a.id,selected,{reason="Requested from DarkRPUI",duration=0}) end end) end end end
    end
    left.Rebuild=function()
        list:Clear(); for _,ply in ipairs(player.GetAll()) do local hay=string.lower(ply:Nick().." "..plyLine(ply)); if searchText=="" or string.find(hay,searchText,1,true) then local row=vgui.Create("DButton",list); row:Dock(TOP); row:DockMargin(0,0,0,10); row:SetTall(64); row:SetText(""); row.Paint=function(s) drawPlayerCard(s,ply,selected==ply) end; row.DoClick=function() DarkRPUI.UI.PlayClick(); selected=ply; detail:InvalidateLayout(true) end end end
    end
    rebuildActions(); left.Rebuild()
end
function DarkRPUI.Admin.OpenPanel(parent)
    if not IsValid(parent) then return end
    local p=vgui.Create("DPanel",parent); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function(_,w,h) DarkRPUI.UI.Text("Admin Tools","DarkRPUI.Title",0,0); DarkRPUI.UI.Text("Premium moderation workspace","DarkRPUI.Small",2,38,DarkRPUI.Color("subtext")) end
    local open=vgui.Create("DButton",p); open:SetSize(230,46); open:SetPos(0,74); open:SetText("Open Command Center"); DarkRPUI.UI.StyleButton(open,DarkRPUI.Color("accent")); open.DoClick=function() DarkRPUI.Admin.Open(selected) end
    local list=vgui.Create("DScrollPanel",p); list:SetPos(0,136); list:SetSize(620,360); DarkRPUI.UI.StyleScrollbar(list)
    for _,ply in ipairs(player.GetAll()) do local row=DarkRPUI.UI.MakeAnimatedCard(list,"",""); row:Dock(TOP); row:DockMargin(0,0,0,10); row:SetTall(68); row.PaintOver=function(s) drawPlayerCard(s,ply,false) end; row.DoClick=function() selected=ply; DarkRPUI.Admin.Open(ply) end end
end
concommand.Add("darkrpui_admin", function() DarkRPUI.Admin.Open() end)

net.Receive("DarkRPUI.Admin.Notify", function() local ok=net.ReadBool(); local title=net.ReadString(); local msg=net.ReadString(); DarkRPUI.Notify(ok and "success" or "error", title, msg) end)
