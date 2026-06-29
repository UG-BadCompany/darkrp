local PANEL = {}

AccessorFunc(PANEL, 'm_colIdle', 'ColorIdle')
AccessorFunc(PANEL, 'm_colHover', 'ColorHover')
AccessorFunc(PANEL, 'm_colPressed', 'ColorPressed')

local ANIM_DURATION = .1

function PANEL:Init()
    self:Import('click')
    self:SetColorIdle(Color(235, 235, 235))
    self:SetColorHover(color_white)
    self:SetColorPressed(color_white)
    self:InstallScaleAnim()
    self:SetImageScale(1)
end

function PANEL:SetColorIdle(color)
    self.m_colIdle = color
    self.m_colColor = vox.CopyColor(color)
end

function PANEL:SetImageScale(scale)
    self.m_iImageScale = scale - .2
    self.m_iImageScaleInitial = scale
end

do
    local function animColor(panel, targetkey, duration)
        vox.anim.Create(panel, duration or ANIM_DURATION, {
            index = vox.anim.ANIM_HOVER,
            target = {
                m_colColor = panel[targetkey]
            }
        })
    end

    local function animScale(panel, target)
        vox.anim.Create(panel, duration or ANIM_DURATION, {
            index = vox.anim.ANIM_SCALE,
            target = {
                m_iImageScale = target
            }
        })
    end

    function PANEL:InstallHoverAnim()
        vox.gui.InjectEventHandler(self, 'OnCursorEntered')
        vox.gui.InjectEventHandler(self, 'OnCursorExited')

        self:On('OnCursorEntered', function(panel)
            if panel:GetDisabled() then return end
            animColor(panel, 'm_colHover')
        end)

        self:On('OnCursorExited', function(panel)
            if panel:GetDisabled() then return end
            animColor(panel, 'm_colIdle')
        end)

        self:On('OnPress', function(panel)
            if panel:GetDisabled() then return end
            animColor(panel, 'm_colPressed')
        end)

        self:On('OnRelease', function(panel)
            if panel:IsHovered() then
                panel:Call('OnCursorEntered')
            end
        end)
    end

    function PANEL:InstallScaleAnim()
        vox.gui.InjectEventHandler(self, 'OnCursorEntered')
        vox.gui.InjectEventHandler(self, 'OnCursorExited')

        self:On('OnCursorEntered', function(panel)
            if panel:GetDisabled() then return end
            animScale(panel, panel.m_iImageScaleInitial - .1)
        end)

        self:On('OnCursorExited', function(panel)
            if panel:GetDisabled() then return end
            animScale(panel, panel.m_iImageScaleInitial - .2)
        end)

        self:On('OnPress', function(panel)
            if panel:GetDisabled() then return end
            animScale(panel, panel.m_iImageScaleInitial)
        end)

        self:On('OnRelease', function(panel)
            if panel:IsHovered() then
                panel:Call('OnCursorEntered')
            end
        end)
    end

    local function animAngle(panel, target, onFinished)
        vox.anim.Create(panel, ANIM_DURATION * 2, {
            index = 1,
            target = {
                m_iImageAngle = target
            },
            onFinished = onFinished
        })
    end

    function PANEL:InstallRotationAnim()
        self:On('OnPress', function(panel)
            if panel:GetDisabled() then return end

            animAngle(panel, 15, function(_, panel)
                animAngle(panel, -15, function(_, panel)
                    animAngle(panel, 0)
                end)
            end)
        end)
    end
end

vox.gui.Register('vox.ImageButton', PANEL, 'vox.Image')
