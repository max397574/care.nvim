---@type care.entry
---@diagnostic disable-next-line: missing-fields
local Entry = {}

function Entry.new(completion_item, source, context)
    ---@type care.entry
    local self = setmetatable({}, { __index = Entry })
    self.completion_item = completion_item
    self.source = source
    self.context = context
    self.matches = {}
    return self
end
local function is_white(str)
    return string.match(str, "^%s*$") ~= nil
end

function Entry:get_offset()
    local offset, _ = vim.regex(self.source:get_keyword_pattern() .. "\\m$"):match_str(self.context.line_before_cursor)
    offset = offset or #self.context.line_before_cursor
    if self.completion_item.textEdit then
        local range = self.completion_item.textEdit.insert or self.completion_item.textEdit.range
        if range then
            local c = range.start.character
            for idx = c, self.context.cursor.col do
                if not is_white(string.byte(self.context.line, idx) or "") then
                    offset = idx
                    break
                end
            end
        end
    end
    return offset
end

function Entry:get_insert_text()
    local completion_item = self.completion_item
    local text
    if completion_item.textEdit then
        text = completion_item.textEdit.newText
    elseif completion_item.insertText then
        text = completion_item.insertText
    else
        text = completion_item.label
    end
    ---@type string
    return text
end

function Entry:get_insert_word()
    local completion_item = self.completion_item
    local text
    if completion_item.textEdit and completion_item.textEdit.newText then
        text = completion_item.textEdit.newText
    elseif completion_item.insertText then
        text = completion_item.insertText
    else
        text = completion_item.label
    end
    -- Snippet
    if completion_item.insertTextFormat == 2 then
        text = vim.fn.matchstrpos(text, [[^\w\+]])[1]
    end
    ---@type string
    return text
end

return Entry
