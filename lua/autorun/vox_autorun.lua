--[[
    Vox UI Bootstrap
    Mounts the Vox framework and active DarkRP interface modules.
    Keep this file minimal: shared loading order lives in lua/vox/init.lua.
]]

vox = vox or {}
vox.cfg = vox.cfg or {}

AddCSLuaFile('vox/util.lua')
include('vox/util.lua')

AddCSLuaFile('vox/init.lua')
include('vox/init.lua')
