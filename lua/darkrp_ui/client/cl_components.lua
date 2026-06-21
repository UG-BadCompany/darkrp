DarkRPUI = DarkRPUI or {}; DarkRPUI.UI = DarkRPUI.UI or {}
DarkRPUI.Config = DarkRPUI.Config or {}; DarkRPUI.Settings = DarkRPUI.Settings or {}; DarkRPUI.Util = DarkRPUI.Util or {}
local UI = DarkRPUI.UI
local blurMat
local transparent = Color(0,0,0,0)

local function cfg(k, fallback) return DarkRPUI.Config and DarkRPUI.Config[k] ~= nil and DarkRPUI.Config[k] or fallback end
local function animSpeed(mult) return (cfg("AnimationSpeed", 0.16) or 0.16) * (mult or 1) end
function UI.LerpValue(current, target, speed) return Lerp(math.Clamp(FrameTime() * (speed or 10), 0, 1), current or 0, target or 0) end
function UI.RoundedBox(r,x,y,w,h,c) draw.RoundedBox(r or (DarkRPUI.ThemeRadius and DarkRPUI.ThemeRadius() or 8),x,y,w,h,c or (DarkRPUI.Color and DarkRPUI.Color("panel") or color_black)) end
function UI.OutlinedBox(r,x,y,w,h,c,border) UI.RoundedBox(r,x,y,w,h,c); surface.SetDrawColor(border or (DarkRPUI.Color and DarkRPUI.Color("border") or color_white)); surface.DrawOutlinedRect(x,y,w,h,1) end
function UI.Text(t,f,x,y,c,ax,ay) draw.SimpleText(t or "", f or "DarkRPUI.Body", x,y,c or DarkRPUI.Color("text"), ax or TEXT_ALIGN_LEFT, ay or TEXT_ALIGN_TOP) end
function UI.DrawBlur(panel, amount) if not IsValid(panel) then return end if DarkRPUI.Settings and DarkRPUI.Settings.blur == false then return end if not cfg("BlurEnabled", true) then return end blurMat = blurMat or Material("pp/blurscreen") local x,y=panel:LocalToScreen(0,0); surface.SetDrawColor(255,255,255); surface.SetMaterial(blurMat); for i=1,3 do blurMat:SetFloat("$blur", (i/3)*(amount or 6)); blurMat:Recompute(); render.UpdateScreenEffectTexture(); surface.DrawTexturedRect(-x,-y,ScrW(),ScrH()) end end

function UI.AnimatePanelIn(panel)
    if not IsValid(panel) then return end
    panel.DarkRPUIClosing = false
    panel:SetAlpha(0); panel:AlphaTo(255, animSpeed(1.15), 0)
    panel.DarkRPUIAnimScale = 0.965
    panel:SizeTo(panel:GetWide(), panel:GetTall(), animSpeed(1.15), 0, -1)
end
function UI.AnimatePanelOut(panel, callback)
    if not IsValid(panel) or panel.DarkRPUIClosing then return end
    panel.DarkRPUIClosing = true
    panel:SetMouseInputEnabled(false); panel:SetKeyboardInputEnabled(false)
    panel:AlphaTo(0, animSpeed(1.05), 0, function(_, pnl) if callback then callback(pnl) end end)
end
function UI.SafeRemoveAnimated(panel, duration)
    if not IsValid(panel) then return end
    local old = cfg("AnimationSpeed", 0.16); if duration then DarkRPUI.Config.AnimationSpeed = duration end
    UI.AnimatePanelOut(panel, function(p) if IsValid(p) then p:Remove() end end)
    if duration then DarkRPUI.Config.AnimationSpeed = old end
end
DarkRPUI.SafeRemoveAnimated = UI.SafeRemoveAnimated

function UI.CloseButton(parent, onClick)
    local b=vgui.Create("DButton",parent); b:SetText("×"); b:SetFont("DarkRPUI.Title"); b:SetTextColor(DarkRPUI.Color("text")); b:SetSize(46,46); b.Hover=0
    b.Paint=function(s,w,h) s.Hover=UI.LerpValue(s.Hover, s:IsHovered() and 1 or 0, 14); local a=45+80*s.Hover; UI.RoundedBox(14,0,0,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("error"),a)); surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("error"),160*s.Hover)); surface.DrawOutlinedRect(0,0,w,h,1) end
    b.DoClick=onClick or function() if IsValid(parent) then UI.SafeRemoveAnimated(parent) end end
    return b
end
function UI.StyleButton(btn, accent)
    btn:SetTextColor(DarkRPUI.Color("text")); btn:SetFont("DarkRPUI.Body"); btn.DarkRPUIHover=0
    btn.Paint=function(s,w,h) s.DarkRPUIHover=UI.LerpValue(s.DarkRPUIHover, s:IsHovered() and 1 or 0, 12); local base=DarkRPUI.Color("card"); local hov=accent or DarkRPUI.Color("cardHover"); UI.OutlinedBox(10,0,0,w,h,DarkRPUI.LerpColor(s.DarkRPUIHover,base,hov),DarkRPUI.LerpColor(s.DarkRPUIHover,DarkRPUI.Color("border"),DarkRPUI.Color("accent"))) end
end
function UI.MakeHeader(parent, title, subtitle) local p=vgui.Create("DPanel",parent); p:SetTall(DarkRPUI.Util.Scale(72)); p.Paint=function(_,w,h) UI.Text(title,"DarkRPUI.Title",0,4); UI.Text(subtitle,"DarkRPUI.Small",2,42,DarkRPUI.Color("subtext")) end; return p end
function UI.EmptyState(parent, title, body) local p=vgui.Create("DPanel",parent); p:Dock(FILL); p.Paint=function(_,w,h) UI.RoundedBox(16,w*.5-190,h*.5-72,380,144,DarkRPUI.Color("card")); UI.Text(title or "Nothing here yet","DarkRPUI.Subtitle",w*.5,h*.5-42,DarkRPUI.Color("text"),TEXT_ALIGN_CENTER); draw.SimpleText(body or "This area is ready for server integration.","DarkRPUI.Small",w*.5,h*.5,DarkRPUI.Color("subtext"),TEXT_ALIGN_CENTER) end; return p end
function UI.MakeCard(parent, title, body, action, footer) local c=vgui.Create("DButton",parent); c:SetText(""); c.Title=title; c.Body=body; c.Footer=footer; c.Lift=0; c.DoClick=action or function() end; c.Paint=function(s,w,h) s.Lift=UI.LerpValue(s.Lift,s:IsHovered() and 1 or 0,10); local y=-math.floor(4*s.Lift); UI.OutlinedBox(12,0,y,w,h,DarkRPUI.LerpColor(s.Lift,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Lift,DarkRPUI.Color("border"),DarkRPUI.Color("accent"))); UI.Text(s.Title,"DarkRPUI.Subtitle",16,14+y); draw.DrawText(s.Body or "","DarkRPUI.Small",16,42+y,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT); if s.Footer then UI.Text(s.Footer,"DarkRPUI.Tiny",w-14,h-22+y,DarkRPUI.Color("accent"),TEXT_ALIGN_RIGHT) end end; return c end
function UI.Badge(x,y,text,color) surface.SetFont("DarkRPUI.Tiny"); local tw=surface.GetTextSize(text); UI.RoundedBox(6,x,y,tw+14,20,color or DarkRPUI.Color("accent")); UI.Text(text,"DarkRPUI.Tiny",x+7,y+4,color_white) return tw+14 end
