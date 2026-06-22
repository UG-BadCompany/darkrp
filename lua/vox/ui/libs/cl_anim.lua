--[[

Author: tochnonement
Email: tochnonement@gmail.com

16/04/2022

--]]

vox.anim = {}
vox.anim.list = {}

-- Reservation
vox.anim.ANIM_HOVER = 0x100
vox.anim.ANIM_X = 0x101
vox.anim.ANIM_Y = 0x102
vox.anim.ANIM_SCALE = 0x103

local anim = vox.anim
local tween = vox.tween
local cv = CreateClientConVar('cl_vox_smooth', '1', true, false, 'Enable smooth animations')

function anim.Create(panel, duration, data)
    if not panel.voxAnims then
        anim.list[#anim.list + 1] = panel
        panel.voxAnims = {}
    end

    local index = data.index
    local subject = data.subject or panel
    local target = data.target
    local easing = data.easing or 'linear'
    local think = data.think
    local onFinished = data.onFinished

    local instance = tween.new(duration, subject, target, easing)

    instance.index = index
    instance.think = think
    instance.onFinished = onFinished

    if (cv:GetBool() and not data.skipAnimation) then
        instance:set(0)
    else
        instance:set(duration)
    end

    panel.voxAnims[index] = instance
end

function anim.Simple(panel, duration, target, index, think, onFinished, easing)
    anim.Create(panel, duration, {
        index = index,
        target = target,
        think = think,
        onFinished = onFinished,
        easing = easing
    })
end

function anim.Remove(panel, index)
    if panel.voxAnims and panel.voxAnims[index] then
        panel.voxAnims[index] = nil
    end
end

do
    local table_remove = table.remove
    local RealFrameTime = RealFrameTime
    local pairs = pairs
    local IsValid = IsValid

    local function handle(index, instance, panel, time)
        local isFinished = instance:update(time)
        local onFinished = instance.onFinished
        local think = instance.think

        if think then
            think(instance, panel)
        end

        if isFinished then
            panel.voxAnims[index] = nil

            if onFinished then
                onFinished(instance, panel)
            end

            return true
        end

        return false
    end

    hook.Add('Think', 'vox.anim.Controller', function()
        local time = FrameTime() -- lol, `RealFrameTime` in some rare cases it might return 0 all the time (how is it even possible???)
        local index = 0

        while (true) do
            index = index + 1
            local panel = anim.list[index]
            if panel == nil then
                break
            end
            if IsValid(panel) then
                for animIndex, instance in pairs(panel.voxAnims) do
                    handle(animIndex, instance, panel, time)
                end
            else
                table_remove(anim.list, index)
            end
        end
        -- for i = 1, anim.index do
        --     local panel = anim.list[i]
        --     if IsValid(panel) then
        --         for index, instance in pairs(panel.voxAnims) do
        --             handle(index, instance, panel, time)
        --         end
        --     else
        --         anim.index = anim.index - 1
        --         table_remove(anim.list, i)
        --     end
        -- end
    end)
end
