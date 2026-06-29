vox.trait = vox.trait or {}
vox.trait.list = vox.trait.list or {}

local trait = vox.trait

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
        panel.voxTraits = panel.voxTraits or {}

        local data = trait.Get(id)

        -- Check if trait is valid
        if not data then return false end

        -- Check if already imported
        if panel.voxTraits[id] then return false end

        local initFunc = data.Init

        for k, v in pairs(data) do
            if k == 'Init' then
                goto skip
            end

            if hookList[k] then
                vox.gui.InjectEventHandler(panel, k)
                vox.gui.AddEvent(panel, k, v)
            else
                panel[k] = v
            end

            ::skip::
        end

        if initFunc then
            initFunc(panel)
        end

        panel.voxTraits[id] = true

        return true
    end
end
