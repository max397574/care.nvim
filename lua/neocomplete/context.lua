---@type neocomplete.context
---@diagnostic disable-next-line: missing-fields
local context = {}

---@type lsp.CompletionContext

---@param previous neocomplete.context?
---@return neocomplete.context
function context.new(previous)
    ---@type neocomplete.context
    local self = setmetatable({}, { __index = context })
    previous = previous or {}
    -- reset so table doesn't get too big
    previous.previous = nil
    self.previous = previous and vim.deepcopy(previous)
    self.bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    self.cursor = { row = cursor[1], col = cursor[2] }
    return self
end

function context.changed(self)
    if not self.previous then
        return true
    end
    if self.bufnr ~= self.previous.bufnr then
        return true
    end
    if self.cursor.col ~= self.previous.cursor.col then
        return true
    end
    if self.cursor.row ~= self.previous.cursor.row then
        return true
    end
    return false
end

return context
