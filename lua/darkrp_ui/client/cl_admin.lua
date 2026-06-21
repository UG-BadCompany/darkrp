DarkRPUI = DarkRPUI or {}; DarkRPUI.Admin = DarkRPUI.Admin or {}
local actions={"bring","goto","freeze","jail","warn","kick","ban","spectate","reports"}
function DarkRPUI.Admin.Open(target)
    if not DarkRPUI.Util.IsAdmin(LocalPlayer()) then return end
    local f=vgui.Create("DFrame"); f:SetSize(360,420); f:Center(); f:SetTitle(""); f:MakePopup(); f.Paint=function(s,w,h) DarkRPUI.UI.RoundedBox(14,0,0,w,h,DarkRPUI.Color("background")); DarkRPUI.UI.Text("Admin Tools","DarkRPUI.Title",18,16); DarkRPUI.UI.Text(IsValid(target) and target:Nick() or "Select player from scoreboard", "DarkRPUI.Small",20,54,DarkRPUI.Color("subtext")) end
    local y=86; for _,a in ipairs(actions) do local b=vgui.Create("DButton",f); b:SetPos(18,y); b:SetSize(324,34); b:SetText(string.upper(a)); DarkRPUI.UI.StyleButton(b); b.DoClick=function() if IsValid(target) then net.Start("DarkRPUI.AdminAction"); net.WriteString(a); net.WriteUInt(target:EntIndex(),16); net.SendToServer() end end; y=y+40 end
end
concommand.Add("darkrpui_admin", function() DarkRPUI.Admin.Open() end)
