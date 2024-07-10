---@type neocomplete.docs_view
---@diagnostic disable-next-line: missing-fields
local Docs = {}

function Docs.new(entry, x_offset, position, config)
    ---@type neocomplete.docs_view
    local self = setmetatable({}, { __index = Docs })
    self.current_scroll = 1
    if not entry.completion_item.documentation then
        return nil
    end
    local documentation = entry.completion_item.documentation
    local format = "markdown"
    local contents
    if type(documentation) == "table" and documentation.kind == "plaintext" then
        format = "plaintext"
        contents = vim.split(documentation.value or "", "\n", { trimempty = true })
    else
        contents = vim.lsp.util.convert_input_to_markdown_lines(documentation --[[@as string]])
    end

    local TODO = 100000
    local width = math.min(vim.o.columns - x_offset, config.max_width)
    local height = math.min(TODO, config.max_height)
    self.bufnr = vim.api.nvim_create_buf(false, true)

    local do_stylize = format == "markdown" and vim.g.syntax_on ~= nil

    if do_stylize then
        contents = vim.lsp.util._normalize_markdown(contents, { width = width })
        vim.bo[self.bufnr].filetype = "markdown"
        vim.treesitter.start(self.bufnr)
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, contents)
    else
        -- Clean up input: trim empty lines
        contents = vim.split(table.concat(contents, "\n"), "\n", { trimempty = true })

        if format then
            vim.bo[self.bufnr].syntax = format
        end
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, true, contents)
    end

    self.winnr = vim.api.nvim_open_win(self.bufnr, false, {
        relative = "cursor",
        anchor = position == "below" and "NW" or "SW",
        border = config.border,
        style = "minimal",
        width = width,
        height = math.min(height, #contents),
        row = position == "below" and 1 or 0,
        col = x_offset,
    })

    vim.api.nvim_set_option_value("scrolloff", 0, { win = self.winnr })

    return self
end

function Docs:scroll(delta)
    self.current_scroll = self.current_scroll + delta
    local top_visible = vim.fn.line("w0", self.winnr)
    local bottom_visible = vim.fn.line("w$", self.winnr)
    local visible_amount = bottom_visible - top_visible + 1
    self.current_scroll =
        math.min(self.current_scroll, #vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false) - visible_amount - 1)
    self:set_scroll(self.current_scroll)
end

function Docs:set_scroll(line)
    vim.api.nvim_win_call(self.winnr, function()
        vim.cmd("normal! " .. line .. "zt")
    end)
end

return Docs
