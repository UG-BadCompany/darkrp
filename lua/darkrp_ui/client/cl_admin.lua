DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
local actions={"bring","goto","freeze","jail","warn","kick","ban","spectate","reports"}
function DarkRPUI.Admin.Send(action,target) if not IsValid(target) then return end net.Start("DarkRPUI.AdminAction"); net.WriteString(action); net.WriteUInt(target:EntIndex(),16); net.SendToServer(); DarkRPUI.Notify("info","Admin action",action.." -> "..target:Nick()) end
function DarkRPUI.Admin.Open(target)
    if not DarkRPUI.Util.IsAdmin(LocalPlayer()) then return end
    if IsValid(DarkRPUI.Admin.Frame) then DarkRPUI.UI.SafeRemoveAnimated(DarkRPUI.Admin.Frame) end
    local f=vgui.Create("DFrame"); DarkRPUI.Admin.Frame=f; f:SetSize(360,420); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:MakePopup(); DarkRPUI.UI.AnimatePanelIn(f); f.OnKeyCodePressed=function(_,key) if key==KEY_ESCAPE then DarkRPUI.UI.SafeRemoveAnimated(f) end end; f.Paint=function(_,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("background")); DarkRPUI.UI.Text("Admin Tools","DarkRPUI.Title",18,16); DarkRPUI.UI.Text(IsValid(target) and target:Nick() or "Select player from scoreboard", "DarkRPUI.Small",20,54,DarkRPUI.Color("subtext")) end
    local close=DarkRPUI.UI.CloseButton(f, function() DarkRPUI.UI.SafeRemoveAnimated(f) end); close:SetPos(f:GetWide()-58,12)
    local y=86; for _,a in ipairs(actions) do local b=vgui.Create("DButton",f); b:SetPos(18,y); b:SetSize(324,34); b:SetText(string.upper(a)); DarkRPUI.UI.StyleButton(b); b.DoClick=function() DarkRPUI.Admin.Send(a,target) end; y=y+40 end
end
function DarkRPUI.Admin.OpenPanel(parent)
    if not IsValid(parent) then return end
    local p=vgui.Create("DPanel",parent); p:Dock(FILL); p:DockMargin(20,0,20,20); p.Paint=function() end
    local list=vgui.Create("DScrollPanel",p); list:Dock(FILL)
    for _,ply in ipairs(player.GetAll()) do local row=vgui.Create("DButton",list); row:Dock(TOP); row:DockMargin(0,0,0,8); row:SetTall(44); row:SetText(ply:Nick().."  •  "..ply:SteamID()); DarkRPUI.UI.StyleButton(row); row.DoClick=function() DarkRPUI.Admin.Open(ply) end end
end
concommand.Add("darkrpui_admin", function() DarkRPUI.Admin.Open() end)
