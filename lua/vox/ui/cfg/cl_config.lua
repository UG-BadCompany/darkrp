--[[

Author: tochnonement
Email: tochnonement@gmail.com

05/06/2022

--]]

vox.cfg.fontFamily = 'Comfortaa' -- probably does nothing, but I keep it just in case I missed something

local function hexcolor(hex)
	local r, g, b = string.match(hex, '#(..)(..)(..)')
	local a = string.len(hex) > 7 and string.Right(hex, 2) or "FF"

	return Color(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), tonumber(a, 16))
end

vox.cfg.colors = {}
vox.cfg.colors.primary = hexcolor('#10131B')
vox.cfg.colors.secondary = hexcolor('#171B26')
vox.cfg.colors.tertiary = hexcolor('#202637')
vox.cfg.colors.quaternary = hexcolor('#0B0E14')
vox.cfg.colors.accent = Color(118, 92, 255)
vox.cfg.colors.lightgray = Color(235, 235, 235)
vox.cfg.colors.gray = Color(144, 144, 144)
vox.cfg.colors.positive = Color(39, 174, 96)
vox.cfg.colors.negative = Color(235, 77, 75)

hook.Call('vox.ui.LoadedConfig')
