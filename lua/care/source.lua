---@type care.internal_source
---@diagnostic disable-next-line: missing-fields
local Source = {}

function Source.new(completion_source)
    ---@type care.internal_source
    local self = setmetatable({}, { __index = Source })
    self.source = completion_source
    self.entries = {}
    self.config = require("care.config").options.sources[completion_source.name] or {}
    return self
end

function Source:get_keyword_pattern()
    local keyword_pattern = require("care.config").options.keyword_pattern or ""
    if self.source.keyword_pattern then
        ---@type string
        keyword_pattern = self.source.keyword_pattern
    end
    if self.source.get_keyword_pattern then
        keyword_pattern = self.source:get_keyword_pattern()
    end
    return keyword_pattern
end

function Source:get_offset(context)
    if not context then
        return context.cursor.col
    end
    local source_offset, _ = vim.regex(self:get_keyword_pattern() .. "\\m$"):match_str(context.line_before_cursor)

    if source_offset then
        return source_offset
    end

    return context.cursor.col
end

function Source:get_trigger_characters()
    local trigger_characters = {}
    if self.source.get_trigger_characters then
        return self.source.get_trigger_characters()
    end
    return trigger_characters
end

function Source:is_enabled()
    if self.config.enabled == nil then
        return true
    end
    if type(self.config.enabled) == "boolean" then
        ---@type boolean
        return self.config.enabled
    elseif type(self.config.enabled) == "function" then
        return self.config.enabled()
    end
    return true
end

function Source:execute(entry)
    if self.source.execute then
        self.source:execute(entry)
    end
end

return Source
