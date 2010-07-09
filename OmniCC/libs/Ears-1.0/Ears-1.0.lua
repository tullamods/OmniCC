--[[
	Ears.lua
		A simple message passing object.
--]]

local Ears = LibStub:NewLibrary('Ears-1.0', 0)
if not Ears then return end

local ears_MT = {__index = Ears}

function Ears:New()
	local o = setmetatable({}, ears_MT)
	o.listeners = {}
	return o
end


function Ears:Inject(f)
	local ear = self:New()
	for k, v in pairs(self) do
		assert(not f[k], (f:GetName() or '<Unknown Frame>') .. string.format('%s already has a method named "%s"', (f:GetName() or '<Unknown Frame>'), k))
		f[k] = function(self, ...) ear[k](ear, ...) end
	end
	return f
end


--trigger a message, with the given args
function Ears:SendMessage(msg, ...)
	assert(msg, 'Usage: Ears:SendMessage(msg[, args])')
	assert(type(msg) == 'string', 'String expected for <msg>, got: \'' .. type(msg) .. '\'')

	local listeners = self.listeners[msg]
	if listeners then
		for obj, action in pairs(listeners) do
			action(obj, msg, ...)
		end
	end
end


--tells obj to do something when msg happens
function Ears:AddListener(obj, msg, method)
	assert(obj and msg, 'Usage: Ears:AddListener(obj, msg[, method])')
	assert(type(msg) == 'string', 'String expected for <msg>, got: \'' .. type(msg) .. '\'')

	local method = method or msg
	local action

	if type(method) == 'string' then
		assert(obj[method] and type(obj[method]) == 'function', 'Object does not have an instance of ' .. method)
		action = obj[method]
	else
		assert(type(method) == 'function', 'String or function expected for <method>, got: \'' .. type(method) .. '\'')
		action = method
	end

	local listeners = self.listeners[msg] or {}
	listeners[obj] = action
	self.listeners[msg] = listeners

--	assert(self.listeners[msg] and self.listeners[msg][obj], 'Ears: Failed to register ' .. msg)
end


--tells obj to do nothing when msg happens
function Ears:RemoveListener(obj, msg)
	assert(obj and msg, 'Usage: Ears:RemoveListener(obj, msg)')
	assert(type(msg) == 'string', 'String expected for <msg>, got: \'' .. type(msg) .. '\'')

	local listeners = self.listeners[msg]
	if listeners then
		listeners[obj] = nil
		if not next(listeners) then
			self.listeners[msg] = nil
		end
	end

--	assert(not(self.listeners[msg] and self.listeners[msg][obj]), 'Ears: Failed to ignore ' .. msg)
end


--ignore all messages for obj
function Ears:RemoveAllListeners(obj)
	assert(obj, 'Usage: Ears:RemoveAllListeners(obj)')

	for msg in pairs(self.listeners) do
		self:Ignore(obj, msg)
	end
end