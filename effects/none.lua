-- none.lua - no effect
local AddonName = ...
local Addon = _G[AddonName]
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local None = Addon.FX:Create("none", L.None)

function None:Run() end
