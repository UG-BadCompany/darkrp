--[[

Author: tochnonement
Email: tochnonement@gmail.com

03/05/2023

--]]

local ADDON = {}
ADDON.__index = ADDON

function ADDON:RegisterOption(id, data)
    data.addon = self.id

    if (SERVER) then
        data.onSet = function(value)
            self.db:Queue([[REPLACE INTO `vox_]] .. self.id .. [[_settings` VALUES(']] .. self.db:Escape(id) .. [[', ']] .. self.db:Escape(vox.TypeToString(value)) .. [[');]])
        end
    end

    vox.inconfig:Register(self.id .. '_' .. id, data)
end

function ADDON:GetOptionValue(id)
    return vox.inconfig:Get(self.id .. '_' .. id)
end

if (SERVER) then
    function ADDON:SetupDatabase(mysqlEnabled, credentials)
        local moduleName = 'sqlite'
        local data = {}

        if (mysqlEnabled) then
            moduleName = 'mysqloo'
            data = {
                hostname = credentials.Hostname,
                username = credentials.Username,
                password = credentials.Password,
                database = credentials.Schema,
                port = credentials.Port,
            }
        end

        if (self.db and self.db:IsConnected()) then
            self.db:Log('Connection recycled.')
        else
            self.db = vox.sql.Create(moduleName, self.id, data)
        end

        self:CreateSettingsTable()
        self:LoadSettings()

        hook.Run('vox.' .. self.id .. '.DatabaseInit')
    end

    function ADDON:CreateSettingsTable()
        local id = self.id

        local q = self.db:Create('vox_' .. id .. '_settings')
            q:Create('id', 'VARCHAR(64) NOT NULL')
            q:Create('value', 'VARCHAR(255) NOT NULL')
            q:PrimaryKey('id')
        q:Execute()
    end

    function ADDON:LoadSettings()
        local addonID = self.id
        vox.WaitForGamemode('vox.' .. addonID .. '.LoadSettings', function()
            local q = self.db:Select('vox_' .. addonID .. '_settings')
                q:Callback(function(result)

                    self:Print('Loaded settings.')
                    if (result and #result > 0) then
                        for _, row in ipairs(result) do
                            local optionID = addonID .. '_' .. row.id
                            local value = vox.StringToType(row.value)

                            vox.inconfig.values[optionID] = value
                        end
                    end

                end)
            q:Execute()
        end)
    end
end

do
    local accent = Color(174, 0, 255)
    local accent2 = Color(38, 185, 160)
    local white = color_white
    local red = Color(255, 73, 73)
    local green = Color(121, 255, 68)
    local orange = Color(255, 180, 68)

    local function format(text, ...)
        for _, arg in ipairs({...}) do
            if isentity(arg) and arg:IsPlayer() then
                arg = arg:Name() .. ' (' .. arg:SteamID() .. ')'
            else
                arg = tostring(arg)
            end

            text = string.gsub(text, '#', arg, 1)
        end

        return text
    end

    local function printWPrefix(id, color, prefix, text, ...)
        MsgC(
            white, '(', accent, 'VOX', white, ') ',
            white, '(', accent2, id, white, ') ',
            white, '(', color, prefix, white, ') ',
            format(text, ...),
            '\n'
        )
    end

    function ADDON:Print(text, ...)
        local id = string.upper(self.id)
        MsgC(
            white, '(', accent, 'VOX', white, ') ',
            white, '(', accent2, id, white, ') ',
            format(text, ...),
            '\n'
        )
    end

    function ADDON:PrintError(text, ...)
        local id = string.upper(self.id)
        printWPrefix(id, red, 'ERROR', text, ...)
    end

    function ADDON:PrintWarning(text, ...)
        local id = string.upper(self.id)
        printWPrefix(id, orange, 'WARNING', text, ...)
    end

    function ADDON:PrintSuccess(text, ...)
        local id = string.upper(self.id)
        printWPrefix(id, green, 'SUCCESS', text, ...)
    end

    function ADDON:PrintDebug(...)
        vox:PrintDebug(...)
    end
end

--[[------------------------------
Public function
--------------------------------]]

function vox:Addon(id, data)
    assert(isstring(id), Format('bad argument #1 (expected string, got %s)', type(id)))
    assert(istable(data), Format('bad argument #2 (expected table, got %s)', type(data)))

    if (self[id] == nil) then
        data.id = id

        self[id] = setmetatable(data, ADDON)
        self[id]:Print('Initialized.')
    else
        self[id]:Print('Refreshing.')
    end

    return self[id]
end
