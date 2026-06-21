DarkRPUI = DarkRPUI or {}; DarkRPUI.UI = DarkRPUI.UI or {}
DarkRPUI.Config = DarkRPUI.Config or {}; DarkRPUI.Settings = DarkRPUI.Settings or {}; DarkRPUI.Util = DarkRPUI.Util or {}
local UI = DarkRPUI.UI
local blurMat
local transparent = Color(0,0,0,0)

local function cfg(k, fallback) return DarkRPUI.Config and DarkRPUI.Config[k] ~= nil and DarkRPUI.Config[k] or fallback end
local function animSpeed(mult) return (cfg("AnimationSpeed", 0.16) or 0.16) * (mult or 1) end
function UI.LerpValue(current, target, speed) return Lerp(math.Clamp(FrameTime() * (speed or 12), 0, 1), current or 0, target or 0) end
function UI.AnimSpeed(mult) return animSpeed(mult) end
function UI.DrawShadow(x,y,w,h,alpha)
    alpha = alpha or 95
    surface.SetDrawColor(0,0,0,alpha*.28); surface.DrawRect(x+4,y+6,w-8,h)
    surface.SetDrawColor(0,0,0,alpha*.18); surface.DrawRect(x+8,y+10,w-16,h)
end
function UI.RoundedBox(r,x,y,w,h,c) draw.RoundedBox(r or (DarkRPUI.ThemeRadius and DarkRPUI.ThemeRadius() or 8),x,y,w,h,c or (DarkRPUI.Color and DarkRPUI.Color("panel") or color_black)) end
function UI.OutlinedBox(r,x,y,w,h,c,border) UI.RoundedBox(r,x,y,w,h,c); surface.SetDrawColor(border or (DarkRPUI.Color and DarkRPUI.Color("border") or color_white)); surface.DrawOutlinedRect(x,y,w,h,1) end
function UI.ShadowedBox(r,x,y,w,h,c,border,alpha) UI.DrawShadow(x,y,w,h,alpha); UI.OutlinedBox(r,x,y,w,h,c,border) end
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
    btn.Paint=function(s,w,h) s.DarkRPUIHover=UI.HoverLerp(s,12); local y=-math.floor(2*s.DarkRPUIHover); local base=DarkRPUI.Color("card"); local hov=accent or DarkRPUI.Color("cardHover"); UI.ShadowedBox(11,0,y,w,h,DarkRPUI.LerpColor(s.DarkRPUIHover,base,hov),DarkRPUI.LerpColor(s.DarkRPUIHover,DarkRPUI.Color("border"),DarkRPUI.Color("accent")),55+45*s.DarkRPUIHover) end
    local old=btn.DoClick; btn.DoClick=function(s,...) UI.PlayClick(); if old then return old(s,...) end end
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
        UI.ShadowedBox(15,0,lift,w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"),DarkRPUI.Color("accent")),70+45*s.Hover)
        surface.SetDrawColor(DarkRPUI.WithAlpha(color_black,70*s.Hover)); surface.DrawRect(6,h-3,w-12,3)
        if s.Title ~= "" then UI.Text(s.Title,"DarkRPUI.Subtitle",16,16+lift) end
        if s.Body ~= "" then draw.DrawText(s.Body,"DarkRPUI.Small",16,48+lift,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT) end
    end
    return c
end
local function safeSetModel(panel, mdl)
    if not IsValid(panel) then return end
    local fallback = "models/player/kleiner.mdl"
    mdl = (isstring(mdl) and mdl ~= "") and mdl or fallback
    if util and util.IsValidModel and not util.IsValidModel(mdl) then mdl = fallback end
    local ok = pcall(function() panel:SetModel(mdl) end)
    if not ok then pcall(function() panel:SetModel(fallback) end) end
    if not IsValid(panel.Entity) then pcall(function() panel:SetModel(fallback) end) end
end
function UI.MakeModelPreview(parent, models, large)
    local p=vgui.Create("DModelPanel",parent); p.Models=istable(models) and models or { tostring(models or "models/player/kleiner.mdl") }; p.ModelIndex=1; p.HoverRot=0
    safeSetModel(p,p.Models[1]); p:SetFOV(large and 28 or 36); p:SetCamPos(Vector(46,-10,58)); p:SetLookAt(Vector(0,0,40)); p.AmbientLight=Color(95,120,155); p.DirectionalLight=Color(255,255,255)
    function p:AutoFrameModel() if not IsValid(self.Entity) then return end; local mn,mx=self.Entity:GetRenderBounds(); local height=math.max(1, mx.z-mn.z); local width=math.max(math.abs(mn.x)+math.abs(mx.x), math.abs(mn.y)+math.abs(mx.y), 28); local dist=math.max(width*1.35, height*.78); self:SetCamPos(Vector(dist,-dist*.16,mn.z+height*.58)); self:SetLookAt(Vector(0,0,mn.z+height*.50)); self:SetFOV(large and 24 or 32) end
    p:AutoFrameModel()
    p.LayoutEntity=function(s,ent) if not IsValid(ent) then return end; local target=s:IsHovered() and ((CurTime()*34)%360) or 25; ent:SetAngles(Angle(0,target,0)); ent:SetModelScale(1+((s:IsHovered() and .025 or 0)),0); ent:SetColor(color_white) end
    p.PaintOver=function(s,w,h)
        if #s.Models > 1 then
            surface.SetDrawColor(DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),210)); surface.DrawRect(0,h-24,w,24)
            for i=1,#s.Models do DarkRPUI.UI.RoundedBox(4,w/2-(#s.Models*8)/2+i*8-6,h-15,5,5,i==s.ModelIndex and DarkRPUI.Color("accent") or DarkRPUI.Color("muted")) end
        end
    end
    p.OnMousePressed=function(s,code) if #s.Models <= 1 then return end; if code==MOUSE_LEFT then s.ModelIndex=s.ModelIndex%#s.Models+1 else s.ModelIndex=s.ModelIndex-1; if s.ModelIndex<1 then s.ModelIndex=#s.Models end end; safeSetModel(s,s.Models[s.ModelIndex]); if s.AutoFrameModel then s:AutoFrameModel() end; UI.PlayClick() end
    return p
end


-- 10/10 polish helpers -------------------------------------------------------
function UI.PlayClick()
    if DarkRPUI.Settings and DarkRPUI.Settings.sounds == false then return end
    if DarkRPUI.Config and DarkRPUI.Config.SoundEnabled == false then return end
    surface.PlaySound((DarkRPUI.Config and DarkRPUI.Config.ClickSound) or "ui/buttonclickrelease.wav")
end
function UI.StyleCombo(combo)
    combo:SetFont("DarkRPUI.Body"); combo:SetTextColor(DarkRPUI.Color("text")); combo.DarkRPUIHover=0
    combo.Paint=function(s,w,h) s.DarkRPUIHover=UI.HoverLerp(s,12); UI.ShadowedBox(12,0,0,w,h,DarkRPUI.LerpColor(s.DarkRPUIHover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.DarkRPUIHover,DarkRPUI.Color("border"),DarkRPUI.Color("accent")),45); UI.Text("⌄","DarkRPUI.Small",w-24,h/2-7,DarkRPUI.Color("muted")) end
    combo.OnMenuOpened=function(s,m) if IsValid(m) then m.Paint=function(_,w,h) UI.ShadowedBox(10,0,0,w,h,DarkRPUI.Color("panel"),DarkRPUI.Color("border"),80) end end end
end
function UI.StyleScrollbar(scroll)
    if not IsValid(scroll) or not IsValid(scroll:GetVBar()) then return end
    local v=scroll:GetVBar(); v:SetWide(8); v.Paint=function(_,w,h) UI.RoundedBox(4,2,0,w-4,h,DarkRPUI.WithAlpha(DarkRPUI.Color("border"),95)) end
    v.btnGrip.Paint=function(s,w,h) s.Hover=UI.HoverLerp(s,12); UI.RoundedBox(4,1,0,w-2,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("muted"),DarkRPUI.Color("accent"))) end
    v.btnUp.Paint=function() end; v.btnDown.Paint=function() end
end
function UI.PremiumSearch(parent, placeholder, onChange)
    local holder=vgui.Create("DPanel",parent); holder:SetTall(44); holder.Hover=0
    holder.Paint=function(s,w,h) s.Hover=UI.HoverLerp(s,12); UI.OutlinedBox(13,0,0,w,h,DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("card"),DarkRPUI.Color("cardHover")),DarkRPUI.LerpColor(s.Hover,DarkRPUI.Color("border"),DarkRPUI.Color("accent"))); UI.Text("⌕","DarkRPUI.Body",15,11,DarkRPUI.Color("muted")) end
    local e=vgui.Create("DTextEntry",holder); e:Dock(FILL); e:DockMargin(42,3,12,3); e:SetPaintBackground(false); e:SetFont("DarkRPUI.Body"); e:SetTextColor(DarkRPUI.Color("text")); e:SetPlaceholderText(placeholder or "Search..."); e.OnChange=function() if onChange then onChange(e:GetValue() or "") end end
    return holder,e
end
function UI.Confirm(title, body, yes, no, cb)
    local f=vgui.Create("DFrame"); f:SetSize(420,210); f:Center(); f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(false); f:MakePopup(); UI.AnimateIn(f)
    f.Paint=function(s,w,h) UI.DrawBlur(s,5); UI.ShadowedBox(18,0,0,w,h,DarkRPUI.Color("background"),DarkRPUI.Color("border"),110); UI.Text(title or "Confirm","DarkRPUI.Subtitle",24,22); draw.DrawText(body or "Are you sure?","DarkRPUI.Small",24,58,DarkRPUI.Color("subtext"),TEXT_ALIGN_LEFT) end
    local yb=vgui.Create("DButton",f); yb:SetText(yes or "Confirm"); yb:SetPos(24,142); yb:SetSize(178,42); UI.StyleButton(yb,DarkRPUI.Color("success")); yb.DoClick=function() UI.PlayClick(); if cb then cb(true) end; UI.SafeRemoveAnimated(f) end
    local nb=vgui.Create("DButton",f); nb:SetText(no or "Cancel"); nb:SetPos(218,142); nb:SetSize(178,42); UI.StyleButton(nb,DarkRPUI.Color("error")); nb.DoClick=function() UI.PlayClick(); if cb then cb(false) end; UI.SafeRemoveAnimated(f) end
end
