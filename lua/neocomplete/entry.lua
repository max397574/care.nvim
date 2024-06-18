---@type neocomplete.entry
---@diagnostic disable-next-line: missing-fields
local Entry = {}

function Entry.new(completion_item, source)
    ---@type neocomplete.entry
    local self = setmetatable({}, { __index = Entry })
    self.completion_item = completion_item
    self.source = source
    self.matches = {}
    return self
end

return Entry
