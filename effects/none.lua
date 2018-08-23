-- none.lua - no effect

local OmniCC = _G[...]

local L = _G.OMNICC_LOCALS

local noop = function()
end

OmniCC:RegisterEffect {
	name = L.None,
	id = "none",
	Run = noop,
	Setup = noop
}
