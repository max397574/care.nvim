---@type care.entry
---@diagnostic disable-next-line: missing-fields
local Entry = {}

function Entry.new(completion_item, source, context)
    ---@type care.entry
    local self = setmetatable({
        completion_item = completion_item,
        -- to avoid recursion because source.entries has entries which store source again
        source = {
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
        },
        context = context,
        matches = {},
    }, { __index = Entry })
    return self
end
local function is_white(str)
    return string.match(str, "^%s*$") ~= nil
end

local function is_start_of_new_token(text, index)
    if index <= 1 then
        return true
    end

    local prev = string.char(string.byte(text, index - 1))
    local curr = string.char(string.byte(text, index))

    -- Is a new word in CamelCase
    if not string.match(prev, "%l") and string.match(curr, "%u") then
        return true
    end
    -- Is a special char or whitespace
    if not (string.match(curr, "%w") or string.match(curr, "%s")) or is_white(curr) then
        return true
    end
    -- Is start of a new group of alphanumeric chars
    if not string.match(prev, "%w") and string.match(curr, "%w") then
        return true
    end
    -- Is start of a new group of digits
    if not string.match(prev, "%d") and string.match(curr, "%d") then
        return true
    end
    return false
end

function Entry:get_offset()
    local offset = self.source:get_offset(self.context)
    if offset == -1 then
        offset = #self.context.line_before_cursor
    end
    if self.completion_item.textEdit then
        local range = self.completion_item.textEdit.insert or self.completion_item.textEdit.range
        if range then
            local c = range.start.character
            for idx = c, self.source:get_offset(self.context) + 1 do
                if not is_white(string.byte(self.context.line, idx) or "") then
                    offset = idx
                    break
                end
            end
        end
    else
        -- Search beginning of token before cursor
        -- Adapted from hrsh7th/nvim-cmp
        local word = self:get_insert_word()
        for idx = self.source:get_offset(self.context), self.source:get_offset(self.context) - #word + 1, -1 do
            if is_start_of_new_token(self.context.line, idx) then
                local c = string.byte(self.context.line, idx)
                if not c or string.match(c, "%s") then
                    break
                end
                local match = true
                for i = 1, self.source:get_offset(self.context) - idx + 1 do
                    local c1 = string.byte(word, i)
                    local c2 = string.byte(self.context.line, idx + i - 1)
                    if not c1 or not c2 or c1 ~= c2 then
                        match = false
                        break
                    end
                end
                if match then
                    offset = math.min(offset, idx - 1)
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
