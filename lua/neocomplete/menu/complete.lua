---@param entry lsp.CompletionItem
---@return lsp.CompletionItem
local function normalize_entry(entry)
    entry.insertTextFormat = entry.insertTextFormat or 1
    -- TODO: make this earlier because the sorting won't happen here
    -- TODO: perhaps remove? are these fields even relevant to complete?
    entry.filterText = entry.filterText or entry.label
    entry.sortText = entry.sortText or entry.label
    entry.insertText = entry.insertText or entry.label
    return entry
end

---@param self neocomplete.menu
---@param completion_item lsp.CompletionItem
return function(self, completion_item)
    vim.print(completion_item)
    completion_item = normalize_entry(completion_item)
    local current_buf = vim.api.nvim_get_current_buf()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0)) --- @type integer, integer
    -- get cursor uses 1 based lines, rest of api 0 based
    cursor_row = cursor_row - 1
    local line = vim.api.nvim_get_current_line()
    local line_to_cursor = line:sub(1, cursor_col)
    -- Can add $ to keyword pattern because we just match on line to cursor
    -- TODO: don't use config keyword pattern here, could be source specific
    local word_boundary = vim.fn.match(line_to_cursor, self.config.keyword_pattern .. "$")

    local prefix
    if word_boundary == -1 then
        prefix = ""
    else
        prefix = line:sub(word_boundary + 1, cursor_col)
    end

    -- TODO: entry.insertTextMode
    local is_snippet = completion_item.insertTextFormat == 2

    if completion_item.textEdit and not is_snippet then
        -- An edit which is applied to a document when selecting this completion.
        -- When an edit is provided the value of `insertText` is ignored.

        if completion_item.textEdit.range then
            vim.lsp.util.apply_text_edits({ completion_item.textEdit }, current_buf, "utf-8")
        else
            -- TODO: config option to determine whether to pick insert or replace
            local textEdit = { range = completion_item.textEdit.insert, newText = completion_item.textEdit.newText }
            vim.lsp.util.apply_text_edits({ textEdit }, current_buf, "utf-8")
        end
    elseif completion_item.textEdit and is_snippet then
        local textEdit
        if completion_item.textEdit.range then
            textEdit = { range = completion_item.textEdit.range, newText = "" }
        else
            -- TODO: config option to determine whether to pick insert or replace
            textEdit = { range = completion_item.textEdit.insert, newText = "" }
        end
        vim.lsp.util.apply_text_edits({ textEdit }, current_buf, "utf-8")
        vim.api.nvim_win_set_cursor(0, { textEdit.range.start.line + 1, textEdit.range.start.character })
        self.config.snippet_expansion(completion_item.textEdit.newText)
    else
        -- TODO: confirm this is correct
        -- remove prefix which was used for sorting, text edit should remove it
        ---@see lsp.CompletionItem.insertText
        local start_char = cursor_col - #prefix
        vim.api.nvim_buf_set_text(0, cursor_row, start_char, cursor_row, start_char + #prefix, { "" })
        if is_snippet then
            self.config.snippet_expansion(completion_item.insertText)
        else
            -- TODO: check if should be `start_char - 1`
            vim.api.nvim_buf_set_text(0, cursor_row, start_char, cursor_row, start_char, { completion_item.insertText })
        end
    end

    if completion_item.additionalTextEdits and #completion_item.additionalTextEdits > 0 then
        vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, current_buf, "utf-8")
    end

    if completion_item.command then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.lsp.buf.execute_command(completion_item.command)
    end
end
