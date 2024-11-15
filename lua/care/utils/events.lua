local event = {}

event.new = function()
	local self = setmetatable({}, { __index = event })
	self.events = {}
	return self
end

event.on = function(self, name, callback)
	if not self.events[name] then
		self.events[name] = {}
	end
	table.insert(self.events[name], callback)
	return function()
		self:off(name, callback)
	end
end

event.off = function(self, name, callback)
	for i, callback_ in ipairs(self.events[name] or {}) do
		if callback_ == callback then
			table.remove(self.events[name], i)
			break
		end
	end
end

event.clear = function(self)
	self.events = {}
end

event.emit = function(self, name, ...)
	for _, callback in ipairs(self.events[name] or {}) do
		callback(...)
	end
end

return event.new()
