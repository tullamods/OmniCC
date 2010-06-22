--[[
	Classy.lua
		Utility methods for constructing a Bagnon object class
--]]

local Classy = {}
OmniCC.Classy = Classy

function Classy:New(frameType, parentClass)
	local class = CreateFrame(frameType)
	class.mt = {__index = class}

	if parentClass then
		class = setmetatable(class, {__index = parentClass})
		class.super = function(self, method, ...)
			parentClass[method](self, ...)
		end
	end

	class.Bind = function(self, obj)
		return setmetatable(obj, self.mt)
	end

	return class
end