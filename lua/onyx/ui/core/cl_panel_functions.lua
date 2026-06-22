--[[

Author: tochnonement
Email: tochnonement@gmail.com

15/04/2022

--]]

local ABSTRACT = {}

--[[------------------------------
Functions
--------------------------------]]
function ABSTRACT:GetX()
    local x = self:GetPos()
    return x
end

function ABSTRACT:GetY()
    local _, y = self:GetPos()
    return y
end

function ABSTRACT:SetX(x)
    self:SetPos(x, self:GetY())
end

function ABSTRACT:SetY(y)
    self:SetPos(self:GetX(), y)
end

-- Traits

function ABSTRACT:Import(name)
    onyx.trait.Import(self, name)
end

-- Events

function ABSTRACT:On(name, fn)
    return onyx.gui.AddEvent(self, name, fn)
end

function ABSTRACT:Call(name, ignoreRaw, ...)
    onyx.gui.CallEvent(self, name, ignoreRaw, ...)
end

function ABSTRACT:InjectEventHandler(name)
    onyx.gui.InjectEventHandler(self, name)
end

-- Misc

function ABSTRACT:Combine(pnl2, fnName)
    self[fnName] = function(_, ...)
        return pnl2[fnName](pnl2, ...)
    end
end

function ABSTRACT:CombineMutator(pnl2, mutatorName)
    self:Combine(pnl2, 'Set' .. mutatorName)
    self:Combine(pnl2, 'Get' .. mutatorName)
end

function ABSTRACT:MakeDispatchFn(pnl2, fnName)
    pnl2[fnName] = function(_, ...)
        return self:Call(fnName, nil, ...)
    end
end

function ABSTRACT:SquareInContainer(class, width, height, size, dock)
    self._Container = self:Add('Panel')
    self._Container:Dock(dock)
    self._Container:SetSize(width, height)

    self._Container.Child = self._Container:Add(class)

    self._Container.PerformLayout = function(panel, w, h)
        local size = size < 1 and math.ceil(math.min(w * size, h * size)) or size

        panel.Child:SetWide(size)
        panel.Child:SetTall(size)
        panel.Child:Center()
    end

    return self._Container.Child
end

function ABSTRACT:Padding(padding)
    self:DockPadding(padding, padding, padding, padding)
end

onyx.abstract = ABSTRACT

--[[------------------------------
Register
--------------------------------]]
for name, fn in pairs(ABSTRACT) do
    onyx.gui.RegisterFunc(name, fn)
end