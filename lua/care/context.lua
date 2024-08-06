---@type care.context
---@diagnostic disable-next-line: missing-fields
local Context = {}

---@type lsp.CompletionContext

function Context.new(previous)
    ---@type care.context
    local self = setmetatable({}, { __index = Context })
    previous = previous or {}
    -- reset so table doesn't get too big
    previous.previous = nil
    self.previous = previous and vim.deepcopy(previous)
    self.bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_get_current_line()
    self.line = line
    local cursor = vim.api.nvim_win_get_cursor(0)
    self.cursor = { row = cursor[1], col = cursor[2] }
    self.line_before_cursor = line:sub(1, self.cursor.col)
    return self
end

function Context:changed()
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
    if self.line ~= self.previous.line then
        return true
    end
    if self.line_before_cursor ~= self.previous.line_before_cursor then
        return true
    end
    return false
end

return Context
