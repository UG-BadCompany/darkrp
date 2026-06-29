local TRAIT = {}

AccessorFunc(TRAIT, 'm_bDepressed', 'Depressed', FORCE_BOOL)
AccessorFunc(TRAIT, 'm_bDisabled', 'Disabled', FORCE_BOOL)

--[[------------------------------
Makes possible to make any panel clickable
--------------------------------]]

function TRAIT:Init()
    self:SetDepressed(false)
    self:SetCursor('hand')
    self:SetMouseInputEnabled(true)

    --[[------------------------------
    Override default, not add
    Useful when is called for DLabel
    --------------------------------]]
    self.OnMousePressed = function(self, code)
        if not self:GetDisabled() then
            self:SetDepressed(true)
            self:Call('OnPress', nil, code)
        end
    end

    self.OnMouseReleased = function(self, code)
        if self:GetDisabled() then return end

        if (CurTime() - (vox.menuButtonPressTime or 0) > .2) then
            self:Call('OnRelease', nil, code)

            if code == MOUSE_LEFT then
                self:Call('DoClick')
            elseif code == MOUSE_RIGHT then
                self:Call('DoRightClick')
            else
                self:Call('DoMiddleClick')
            end
        end

        self:SetDepressed(false)
    end
end

function TRAIT:SetDisabled(bool)
    self.m_bDisabled = bool

    if bool then
        self:SetCursor('no')
        self:Call('OnDisabled', nil)
    else
        self:SetCursor('hand')
        self:Call('OnEnabled', nil)
    end
end

local colorCircle = Color(0, 0, 0, 100)
function TRAIT:AddHoverSound()
    self:On('OnCursorEntered', function(panel)
        -- surface.PlaySound('vox/ui/on_mouseover/mouse_over1.wav')
        -- surface.PlaySound('vox/ui/on_mouseover/mouse_over2.wav')
        -- surface.PlaySound('vox/ui/on_mouseover/mouse_over5.wav')
        surface.PlaySound('vox/ui/on_mouseover/pop_mouse_over.wav')
        -- surface.PlaySound('vox/ui/on_mouseover/sub_bass_mouseover.wav')
    end)

    self:On('OnRelease', function(panel)
        -- surface.PlaySound('vox/ui/on_click/round_pop_click.wav')
        -- surface.PlaySound('vox/ui/on_click/round_pop_click1.wav')
        -- surface.PlaySound('vox/ui/on_click/pop_click.wav')
        -- surface.PlaySound('vox/ui/on_click/melodic1_click.wav')
        surface.PlaySound('vox/ui/on_click/footfall_click.wav')
    end)
end

function TRAIT:AddClickEffect()
    self:On('OnRelease', function(panel)
        local x, y = panel:ScreenToLocal(input.GetCursorPos())

        panel.circleAnimFraction = 0
        panel.circleX = x
        panel.circleY = y
        vox.anim.Create(panel, .25, {
            index = 400,
            target = {
                circleAnimFraction = 1
            }
        })
    end)

    self.circleAnimFraction = 0
    self:InjectEventHandler('PaintOver')
    self:On('PaintOver', function(panel, w, h)
        if (panel.circleAnimFraction > 0 and panel.circleAnimFraction < 1) then
            local circle = vox.CalculateCircle(panel.circleX, panel.circleY, math.max(w, h) * panel.circleAnimFraction, 32)
            vox.DrawPoly(circle, ColorAlpha(colorCircle, colorCircle.a * (1 - panel.circleAnimFraction)))
        end
    end)
end

vox.trait.Register('click', TRAIT, 'Makes it easy to make any panel clickable')
