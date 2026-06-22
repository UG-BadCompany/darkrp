DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
local actions={"bring","goto","freeze","jail","warn","kick","ban","spectate","reports"}
function DarkRPUI.Admin.Send(action,target) if not IsValid(target) then return end net.Start("DarkRPUI.AdminAction"); net.WriteString(action); net.WriteUInt(target:EntIndex(),16); net.SendToServer(); DarkRPUI.Notify("info","Admin action",action.." -> "..target:Nick()) end
function DarkRPUI.Admin.Open(target)
    if not DarkRPUI.Util.IsAdmin(LocalPlayer()) then return end
    if IsValid(DarkRPUI.Admin.Frame) then DarkRPUI.UI.SafeRemoveAnimated(DarkRPUI.Admin.Frame) end
    local f=vgui.Create("DFrame"); DarkRPUI.Admin.Frame=f; f:SetSize(400,452); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:MakePopup(); DarkRPUI.UI.AnimatePanelIn(f); f.OnKeyCodePressed=function(_,key) if key==KEY_ESCAPE then DarkRPUI.UI.SafeRemoveAnimated(f) end end; f.Paint=function(s,w,h) DarkRPUI.UI.DrawBlur(s,5); DarkRPUI.UI.ShadowedBox(18,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("background"),240),DarkRPUI.Color("border"),120); DarkRPUI.UI.Text("Admin Tools","DarkRPUI.Title",22,18); DarkRPUI.UI.Text(IsValid(target) and target:Nick() or "Select player from scoreboard", "DarkRPUI.Small",24,58,DarkRPUI.Color("subtext")) end
    local close=DarkRPUI.UI.CloseButton(f, function() DarkRPUI.UI.SafeRemoveAnimated(f) end); close:SetPos(f:GetWide()-58,12)
    local y=92; for _,a in ipairs(actions) do local b=vgui.Create("DButton",f); b:SetPos(22,y); b:SetSize(356,38); b:SetText(string.upper(a)); DarkRPUI.UI.StyleButton(b); DarkRPUI.UI.AttachTooltip(b,"Run "..a.." for the selected player."); b.DoClick=function() DarkRPUI.UI.Confirm("Confirm admin action","Run "..a.." on "..(IsValid(target) and target:Nick() or "this player").."?", "Run", "Cancel", function(ok) if ok then DarkRPUI.Admin.Send(a,target) end end) end; y=y+44 end
end
function DarkRPUI.Admin.OpenPanel(parent)
    if not IsValid(parent) then return end
    local p=vgui.Create("DPanel",parent); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function() end
    local list=vgui.Create("DScrollPanel",p); list:Dock(FILL); DarkRPUI.UI.StyleScrollbar(list)
    for _,ply in ipairs(player.GetAll()) do local row=DarkRPUI.UI.MakeAnimatedCard(list,"",""); row:Dock(TOP); row:DockMargin(0,0,0,10); row:SetTall(58); row.PaintOver=function(_,w,h) DarkRPUI.UI.Text(ply:Nick(),"DarkRPUI.Body",16,10); DarkRPUI.UI.Text(ply:SteamID().." • "..(team.GetName(ply:Team()) or "Unknown"),"DarkRPUI.Small",16,32,DarkRPUI.Color("subtext")); DarkRPUI.UI.Badge(w-72,19,DarkRPUI.Util.IsAdmin(ply) and "STAFF" or "USER",DarkRPUI.Util.IsAdmin(ply) and DarkRPUI.Color("warning") or DarkRPUI.Color("accent")) end; DarkRPUI.UI.AttachTooltip(row,"Open premium moderation actions."); row.DoClick=function() DarkRPUI.Admin.Open(ply) end end
end
concommand.Add("darkrpui_admin", function() DarkRPUI.Admin.Open() end)
