--[[

Author: tochnonement
Email: tochnonement@gmail.com

16/04/2022

--]]

onyx.trait = onyx.trait or {}
onyx.trait.list = onyx.trait.list or {}

local trait = onyx.trait

function trait.Register(id, data)
    trait.list[id] = data
end

function trait.Get(id)
    return trait.list[id]
end

do
    local hookList = {
        ['Think'] = true,
        ['OnMousePressed'] = true,
        ['OnMouseReleased'] = true,
        ['PerformLayout'] = true,
        ['OnCursorEntered'] = true,
        ['OnCursorExited'] = true,
    }

    function trait.Import(panel, id)
        panel.onyxTraits = panel.onyxTraits or {}

        local data = trait.Get(id)

        -- Check if trait is valid
        if not data then return false end

        -- Check if already imported
        if panel.onyxTraits[id] then return false end

        local initFunc = data.Init

        for k, v in pairs(data) do
            if k == 'Init' then
                goto skip
            end

            if hookList[k] then
                onyx.gui.InjectEventHandler(panel, k)
                onyx.gui.AddEvent(panel, k, v)
            else
                panel[k] = v
            end

            ::skip::
        end

        if initFunc then
            initFunc(panel)
        end

        panel.onyxTraits[id] = true

        return true
    end
end