---@type care.entry
---@diagnostic disable-next-line: missing-fields
local Entry = {}

function Entry.new(completion_item, source, context)
    ---@type care.entry
    local self = setmetatable({}, { __index = Entry })
    self.completion_item = completion_item
    -- to avoid recursion because source.entries has entries which store source again
    self.source = {
        config = source.config,
        execute = source.execute,
        get_keyword_pattern = source.get_keyword_pattern,
        get_offset = source.get_offset,
        get_trigger_characters = source.get_trigger_characters,
        incomplete = source.incomplete,
        is_enabled = source.is_enabled,
        new = source.new,
        source = source.source,
        entries = {},
    }
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

function Entry:_get_default_range()
    return {
        start = {
            character = self:get_offset(),
            line = self.context.cursor.row - 1,
        },
        ["end"] = {
            character = self.context.cursor.col,
            line = self.context.cursor.row - 1,
        },
    }
end

function Entry:get_insert_range()
    if self.completion_item.textEdit then
        if self.completion_item.textEdit.insert then
            return self.completion_item.textEdit.insert
        else
            return self.completion_item.textEdit.range
        end
    else
        return self:_get_default_range()
    end
end

function Entry:get_replace_range()
    if self.completion_item.textEdit then
        if self.completion_item.textEdit.replace then
            return self.completion_item.textEdit.replace
        else
            return self.completion_item.textEdit.range
        end
    else
        return self:_get_default_range()
    end
end

return Entry
