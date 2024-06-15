---@type neocomplete.menu
---@diagnostic disable-next-line: missing-fields
local Menu = {}

local format_utils = require("neocomplete.utils.format")
local utils = require("neocomplete.utils")

function Menu.new()
    ---@type neocomplete.menu
    local self = setmetatable({}, { __index = Menu })
    self.entries = nil
    self.ns = vim.api.nvim_create_namespace("neocomplete")
    self.config = require("neocomplete.config").options
    self.buf = vim.api.nvim_create_buf(false, true)
    self.winnr = nil
    self.index = 0
    return self
end

local function get_texts(aligned_sec)
    local texts = {}
    for _, aligned_chunks in ipairs(aligned_sec) do
        local line_text = {}
        for _, chunk in ipairs(aligned_chunks) do
            table.insert(line_text, chunk[1])
        end
        table.insert(texts, table.concat(line_text, ""))
    end
    return texts
end

--- Realigns chunks and adds extmarks
---@param aligned_sec table
---@param realign function(chunk: {[1]: string, [2]: number}): {[1]: string, [2]: number}
---@param buf integer
---@param ns integer
---@param column integer
local function add_extmarks(aligned_sec, realign, buf, ns, column)
    for line, aligned_chunks in ipairs(aligned_sec) do
        local realigned_chunks = {}
        for _, chunk in ipairs(aligned_chunks) do
            table.insert(realigned_chunks, realign(chunk))
        end
        vim.api.nvim_buf_set_extmark(buf, ns, line - 1, column, {
            virt_text = realigned_chunks,
            virt_text_pos = "overlay",
            hl_mode = "combine",
        })
    end
end

function Menu:draw()
    local alignment = self.config.ui.menu.alignment
    local width, entry_texts = format_utils.get_width(self.entries)
    local aligned_table = format_utils.get_align_tables(self.entries)
    local column = 0
    vim.api.nvim_buf_clear_namespace(self.buf, self.ns, 0, -1)
    local spaces = {}
    for _ = 1, #self.entries do
        table.insert(spaces, (" "):rep(width))
    end
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, spaces)
    if self.index and self.index > 0 then
        for i = 0, #self.entries do
            if i == self.index then
                vim.api.nvim_buf_set_extmark(self.buf, self.ns, i - 1, 0, {
                    virt_text = { { string.rep(" ", width), "@neocomplete.selected" } },
                    virt_text_pos = "overlay",
                })
            end
        end
    end
    for i, aligned_sec in ipairs(aligned_table) do
        if not alignment[i] or alignment[i] == "left" then
            local texts = {}
            for line, aligned_chunks in ipairs(aligned_sec) do
                local line_text = {}
                for _, chunk in ipairs(aligned_chunks) do
                    table.insert(line_text, chunk[1])
                end
                local cur_line_text = table.concat(line_text, "")
                table.insert(texts, cur_line_text)
                vim.api.nvim_buf_set_extmark(self.buf, self.ns, line - 1, column, {
                    virt_text = aligned_chunks,
                    virt_text_pos = "overlay",
                    hl_mode = "combine",
                })
            end
            column = column + utils.longest(texts)
        elseif alignment[i] == "right" then
            local texts = get_texts(aligned_sec)
            local length = utils.longest(texts)
            add_extmarks(aligned_sec, function(chunk)
                return { string.rep(" ", length - #chunk[1]) .. chunk[1], chunk[2] }
            end, self.buf, self.ns, column)
            column = column + length
        elseif alignment[i] == "center" then
            local texts = get_texts(aligned_sec)
            local length = utils.longest(texts)
            add_extmarks(aligned_sec, function(chunk)
                return { string.rep(" ", math.floor((length - #chunk[1]) / 2)) .. chunk[1], chunk[2] }
            end, self.buf, self.ns, column)
            column = column + length
        end
    end
    for line, entry in ipairs(self.entries) do
        for _, idx in ipairs(entry.matches or {}) do
            vim.api.nvim_buf_add_highlight(self.buf, self.ns, "@neocomplete.match", line - 1, idx - 1, idx)
        end
    end
end

function Menu:open_win(offset)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local screenpos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
    local space_below = vim.o.lines - screenpos.row - 3 - vim.o.cmdheight

    local width, _ = format_utils.get_width(self.entries)
    local space_above = vim.fn.line(".") - vim.fn.line("w0") - 1
    -- local space_below = vim.fn.line("w$") - vim.fn.line(".")
    local available_space = math.max(space_above, space_below)
    local wanted_space = math.min(#self.entries, self.config.ui.menu.max_height)
    local position = "below"
    local config_position = self.config.ui.menu.position
    local height
    if config_position == "auto" then
        if space_below < wanted_space then
            position = "above"
            if space_above < wanted_space then
                position = space_above > space_below and "above" or "below"
            end
        end
        height = math.min(wanted_space, available_space)
    elseif config_position == "bottom" then
        position = "below"
        height = math.min(wanted_space, space_below)
    elseif config_position == "top" then
        position = "above"
        height = math.min(wanted_space, space_above)
    end
    Menu.winnr = vim.api.nvim_open_win(self.buf, false, {
        relative = "cursor",
        height = height,
        width = width,
        style = "minimal",
        border = self.config.ui.menu.border,
        row = position == "below" and 1 or -(height + 2),
        col = -offset,
    })
    vim.wo[self.winnr][self.buf].scrolloff = 0
end

function Menu:close()
    -- TODO: reset more things?
    pcall(vim.api.nvim_win_close, self.winnr, true)
    Menu.winnr = nil
end

function Menu:select_next(count)
    self.index = self.index + count
    if self.index > #self.entries then
        self.index = self.index - #self.entries - 1
    end
    if self.index > (vim.fn.line("w$", self.winnr) - vim.fn.line("w0", self.winnr)) then
        vim.api.nvim_win_call(self.winnr, function()
            vim.cmd("normal! " .. self.index - (vim.fn.line("w$", self.winnr) - vim.fn.line("w0", self.winnr)) .. "zt")
        end)
    end
    self:draw()
end

function Menu:select_prev(count)
    self.index = self.index - count
    if self.index < 0 then
        self.index = #self.entries + self.index + 1
    end
    if self.index < (vim.fn.line("w0", self.winnr)) then
        vim.api.nvim_win_call(self.winnr, function()
            vim.cmd("normal! " .. self.index .. "zt")
        end)
    end
    self:draw()
end

function Menu:open(entries, offset)
    self.entries = entries
    if not entries or #entries < 1 then
        return
    end
    if self.winnr then
        self:close()
    end
    self.index = 0
    if not self.winnr then
        self:open_win(offset)
        self:draw()
    end
end

function Menu:get_active_entry()
    if not self.entries then
        return nil
    end
    -- TODO: make configurable (cmpts "autoselect")
    if self.index == 0 then
        return self.entries[1]
    end
    return self.entries[self.index]
end

---@param entry neocomplete.entry
---@return neocomplete.entry
local function normalize_entry(entry)
    entry.insertTextFormat = entry.insertTextFormat or 1
    -- TODO: make this earlier because the sorting won't happen here
    -- TODO: perhaps remove? are these fields even relevant to complete?
    entry.filterText = entry.filterText or entry.label
    entry.sortText = entry.sortText or entry.label
    entry.insertText = entry.insertText or entry.label
    return entry
end

---@param entry neocomplete.entry
function Menu:complete(entry)
    vim.print(entry)
    entry = normalize_entry(entry)
    local current_buf = vim.api.nvim_get_current_buf()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0)) --- @type integer, integer
    -- get cursor uses 1 based lines, rest of api 0 based
    cursor_row = cursor_row - 1
    local line = vim.api.nvim_get_current_line()
    local line_to_cursor = line:sub(1, cursor_col)
    -- Can add $ to keyword pattern because we just match on line to cursor
    -- TODO: don't use config keyword pattern here, could be source specific
    local word_boundary = vim.fn.match(line_to_cursor, self.config.keyword_pattern .. "$")

    local prefix = line:sub(word_boundary + 1, cursor_col)

    -- TODO: entry.insertTextMode
    local is_snippet = entry.insertTextFormat == 2

    if entry.textEdit and not is_snippet then
        -- An edit which is applied to a document when selecting this completion.
        -- When an edit is provided the value of `insertText` is ignored.

        if entry.textEdit.range then
            vim.lsp.util.apply_text_edits({ entry.textEdit }, current_buf, "utf-8")
        else
            -- TODO: config option to determine whether to pick insert or replace
            local textEdit = { range = entry.textEdit.insert, newText = entry.textEdit.newText }
            vim.lsp.util.apply_text_edits({ textEdit }, current_buf, "utf-8")
        end
    elseif entry.textEdit and is_snippet then
        local textEdit
        if entry.textEdit.range then
            textEdit = { range = entry.textEdit.range, newText = "" }
        else
            -- TODO: config option to determine whether to pick insert or replace
            textEdit = { range = entry.textEdit.insert, newText = "" }
        end
        vim.lsp.util.apply_text_edits({ textEdit }, current_buf, "utf-8")
        vim.api.nvim_win_set_cursor(0, { textEdit.range.start.line + 1, textEdit.range.start.character })
        self.config.snippet_expansion(entry.textEdit.newText)
    else
        -- TODO: confirm this is correct
        -- remove prefix which was used for sorting, text edit should remove it
        ---@see lsp.CompletionItem.insertText
        local start_char = cursor_col - #prefix
        vim.api.nvim_buf_set_text(0, cursor_row, start_char, cursor_row, start_char + #prefix, { "" })
        if is_snippet then
            self.config.snippet_expansion(entry.insertText)
        else
            -- TODO: check if should be `start_char - 1`
            vim.api.nvim_buf_set_text(0, cursor_row, start_char, cursor_row, start_char, { entry.insertText })
        end
    end

    if entry.additionalTextEdits and #entry.additionalTextEdits > 0 then
        vim.lsp.util.apply_text_edits(entry.additionalTextEdits, current_buf, "utf-8")
    end

    if entry.command then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.lsp.buf.execute_command(entry.command)
    end
end

function Menu:confirm()
    -- Set undo point
    vim.o.ul = vim.o.ul
    local entry = self:get_active_entry()
    if not entry then
        return
    end
    self:complete(entry)
    self:close()
end

function Menu:is_open()
    return self.winnr ~= nil
end

return Menu
