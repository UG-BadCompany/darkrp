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

-- Premium animation/helper aliases used across the full UI package.
function UI.AnimateIn(panel) return UI.AnimatePanelIn(panel) end
function UI.AnimateOut(panel, callback) return UI.AnimatePanelOut(panel, callback) end
function UI.LerpColor(frac, from, to) return DarkRPUI.LerpColor(frac, from, to) end
function UI.HoverLerp(panel, speed)
    panel.DarkRPUIHover = UI.LerpValue(panel.DarkRPUIHover or 0, panel:IsHovered() and 1 or 0, speed or 12)
    return panel.DarkRPUIHover
end
function UI.MakeCloseButton(parent, onClick) return UI.CloseButton(parent, onClick) end
function UI.MakeIconButton(parent, text, onClick)
    local b=vgui.Create("DButton",parent); b:SetText(text or "•"); b:SetFont("DarkRPUI.Body"); b:SetTextColor(DarkRPUI.Color("text")); b.Hover=0; b.Active=0
    b.Paint=function(s,w,h)
        s.Hover=UI.HoverLerp(s,14); s.Active=UI.LerpValue(s.Active,(s.ActiveFunc and s.ActiveFunc()) and 1 or 0,14)
        local f=math.max(s.Hover,s.Active); UI.OutlinedBox(11,0,0,w,h,DarkRPUI.LerpColor(f,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(f,DarkRPUI.Color("border"),DarkRPUI.Color("accent")))
        if s.Active > 0.02 then surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("accent"),220*s.Active)); surface.DrawRect(0,8,3,h-16) end
    end
    b.DoClick=onClick or function() end
    return b
end
function UI.MakeAnimatedCard(parent, title, body)
    local c=vgui.Create("DButton",parent); c:SetText(""); c.Title=title or ""; c.Body=body or ""; c.Hover=0; c.Press=0
    c.Paint=function(s,w,h)
        s.Hover=UI.HoverLerp(s,10); local lift=-math.floor(5*s.Hover)
        UI.OutlinedBox(15,0,lift,w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"),DarkRPUI.Color("accent")))
        surface.SetDrawColor(DarkRPUI.WithAlpha(color_black,70*s.Hover)); surface.DrawRect(6,h-3,w-12,3)
        if s.Title ~= "" then UI.Text(s.Title,"DarkRPUI.Subtitle",16,16+lift) end
        if s.Body ~= "" then draw.DrawText(s.Body,"DarkRPUI.Small",16,48+lift,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT) end
    end
    return c
end
local function safeSetModel(panel, mdl)
    if not IsValid(panel) then return end
    mdl = (isstring(mdl) and mdl ~= "") and mdl or "models/player/kleiner.mdl"
    panel:SetModel(mdl)
    if not IsValid(panel.Entity) then panel:SetModel("models/player/kleiner.mdl") end
end
function UI.MakeModelPreview(parent, models, large)
    local p=vgui.Create("DModelPanel",parent); p.Models=istable(models) and models or { tostring(models or "models/player/kleiner.mdl") }; p.ModelIndex=1; p.HoverRot=0
    safeSetModel(p,p.Models[1]); p:SetFOV(large and 34 or 42); p:SetCamPos(Vector(48,0,58)); p:SetLookAt(Vector(0,0,42))
    p.LayoutEntity=function(s,ent) if not IsValid(ent) then return end; if s:IsHovered() then ent:SetAngles(Angle(0,CurTime()*35%360,0)) else ent:SetAngles(Angle(0,25,0)) end end
    p.PaintOver=function(s,w,h)
        if #s.Models > 1 then
            surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),210)); surface.DrawRect(0,h-24,w,24)
            for i=1,#s.Models do DarkRPUI.UI.RoundedBox(4,w/2-(#s.Models*8)/2+i*8-6,h-15,5,5,i==s.ModelIndex and DarkRPUI.Color("accent") or DarkRPUI.Color("muted")) end
        end
    end
    p.OnMousePressed=function(s,code) if #s.Models <= 1 then return end; if code==MOUSE_LEFT then s.ModelIndex=s.ModelIndex%#s.Models+1 else s.ModelIndex=s.ModelIndex-1; if s.ModelIndex<1 then s.ModelIndex=#s.Models end end; safeSetModel(s,s.Models[s.ModelIndex]) end
    return p
end
