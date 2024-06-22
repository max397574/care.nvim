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
    if completion_item.textEdit then
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
