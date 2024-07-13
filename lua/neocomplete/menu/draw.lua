local format_utils = require("neocomplete.utils.format")
local utils = require("neocomplete.utils")

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

---@param self neocomplete.menu
return function(self)
    local alignment = self.config.ui.menu.alignment
    local width, entry_texts = format_utils.get_width(self.entries)
    local aligned_table = format_utils.get_align_tables(self.entries)
    local column = 0
    vim.api.nvim_buf_clear_namespace(self.menu_window.buf, self.ns, 0, -1)
    local spaces = {}
    for _ = 1, #self.entries do
        table.insert(spaces, (" "):rep(width))
    end
    vim.api.nvim_buf_set_lines(self.menu_window.buf, 0, -1, false, spaces)
    if self.index and self.index > 0 then
        for i = 0, #self.entries do
            if i == self.index then
                vim.api.nvim_buf_set_extmark(self.menu_window.buf, self.ns, i - 1, 0, {
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
                vim.api.nvim_buf_set_extmark(self.menu_window.buf, self.ns, line - 1, column, {
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
            end, self.menu_window.buf, self.ns, column)
            column = column + length
        elseif alignment[i] == "center" then
            local texts = get_texts(aligned_sec)
            local length = utils.longest(texts)
            add_extmarks(aligned_sec, function(chunk)
                return { string.rep(" ", math.floor((length - #chunk[1]) / 2)) .. chunk[1], chunk[2] }
            end, self.menu_window.buf, self.ns, column)
            column = column + length
        end
    end
    for line, entry in ipairs(self.entries) do
        for _, idx in ipairs(entry.matches or {}) do
            vim.api.nvim_buf_add_highlight(self.menu_window.buf, self.ns, "@neocomplete.match", line - 1, idx - 1, idx)
        end
    end

    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_col = cursor[2]
    local line_to_cursor = line:sub(1, cursor_col)
    local entry = self:get_active_entry()
    if not entry then
        return
    end
    local word_boundary = vim.fn.match(line_to_cursor, entry.source:get_keyword_pattern() .. "$")

    local prefix
    if word_boundary == -1 then
        prefix = ""
    else
        prefix = line:sub(word_boundary + 1, cursor_col)
    end

    if entry and self.config.ui.ghost_text then
        require("neocomplete.ghost_text").show(entry, #prefix)
    end
end
