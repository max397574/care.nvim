---@type care.internal_source
---@diagnostic disable-next-line: missing-fields
local source = {}

function source.new(completion_source)
    ---@type care.internal_source
    local self = setmetatable({}, { __index = source })
    self.source = completion_source
    self.entries = {}
    return self
end

function source.get_keyword_pattern(self)
    local keyword_pattern = require("care.config").options.keyword_pattern
    if self.source.keyword_pattern then
        ---@type string
        keyword_pattern = self.source.keyword_pattern
    end
    if self.source.get_keyword_pattern then
        keyword_pattern = self.source:get_keyword_pattern()
    end
    return keyword_pattern
end

function source.get_offset(self, context)
    if not context then
        return context.cursor.col
    end
    local source_offset, _ = vim.regex(self:get_keyword_pattern() .. "\\m$"):match_str(context.line_before_cursor)

    if source_offset then
        return source_offset
    end

    return context.cursor.col

    -- -- Can add $ to keyword pattern because we just match on line to cursor
    -- local word_boundary = vim.fn.match(line_to_cursor, keyword_pattern .. "$")
    -- print(keyword_pattern)
    -- print("match", word_boundary)
    -- print("regex", vim.regex(keyword_pattern .. "\\m$"):match_str(line_to_cursor))
    -- if word_boundary == -1 then
    --     return 0
    -- end
    --
    -- return context.cursor.col - word_boundary
end

function source.get_trigger_characters(self)
    local trigger_characters = {}
    if self.source.get_trigger_characters then
        return self.source.get_trigger_characters()
    end
    return trigger_characters
end

return source
