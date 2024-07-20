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

---@param entry neocomplete.entry
return function(entry)
    local config = require("neocomplete.config").options
    if _G.neocomplete_debug then
        vim.print(entry.completion_item)
        vim.print(entry.context)
    end

    local cur_ctx = require("neocomplete.context").new()
    local unblock = require("neocomplete").core:block()

    local completion_item = entry.completion_item
    completion_item = normalize_entry(completion_item)

    vim.api.nvim_buf_set_text(
        cur_ctx.bufnr,
        cur_ctx.cursor.row - 1,
        entry:get_offset(),
        cur_ctx.cursor.row - 1,
        cur_ctx.cursor.col,
        {
            string.sub(entry.context.line_before_cursor, entry:get_offset() + 1),
        }
    )
    vim.api.nvim_win_set_cursor(0, { entry.context.cursor.row, entry.context.cursor.col })

    cur_ctx = require("neocomplete.context").new()

    -- TODO: entry.insertTextMode
    local is_snippet = completion_item.insertTextFormat == 2
    local snippet_text

    if not completion_item.textEdit then
        ---@diagnostic disable-next-line: missing-fields
        completion_item.textEdit = {
            newText = completion_item.insertText,
        }
    else
        if not completion_item.textEdit.range then
            -- TODO: config option to determine whether to pick insert or replace
            ---@type lsp.TextEdit
            completion_item.textEdit =
                { range = completion_item.textEdit.insert, newText = completion_item.textEdit.newText }
        end
    end

    -- TODO: check out cmp insert and replace range
    completion_item.textEdit.range = {
        start = {
            character = entry:get_offset(),
            line = entry.context.cursor.row - 1,
        },
        ["end"] = {
            character = entry.context.cursor.col,
            line = entry.context.cursor.row - 1,
        },
    }

    local diff_before = math.max(0, entry.context.cursor.col - completion_item.textEdit.range.start.character)
    local diff_after = math.max(0, completion_item.textEdit.range["end"].character - entry.context.cursor.col)

    completion_item.textEdit.range.start.line = cur_ctx.cursor.row - 1
    completion_item.textEdit.range.start.character = cur_ctx.cursor.col - diff_before
    completion_item.textEdit.range["end"].line = cur_ctx.cursor.row - 1
    completion_item.textEdit.range["end"].character = cur_ctx.cursor.col + diff_after

    local new_text = ""
    if is_snippet then
        snippet_text = completion_item.textEdit.newText or completion_item.insertText
    else
        -- TODO: revert when https://github.com/neovim/neovim/issues/29811 if fixed
        new_text = completion_item.textEdit.newText or completion_item.insertText
    end
    completion_item.textEdit.newText = ""

    vim.lsp.util.apply_text_edits({ completion_item.textEdit }, cur_ctx.bufnr, "utf-16")

    local start = completion_item.textEdit.range.start
    vim.api.nvim_win_set_cursor(0, { start.line + 1, start.character })
    if is_snippet then
        config.snippet_expansion(snippet_text)
    else
        -- TODO: revert when https://github.com/neovim/neovim/issues/29811 if fixed
        cur_ctx = require("neocomplete.context").new()
        vim.api.nvim_buf_set_text(
            cur_ctx.bufnr,
            cur_ctx.cursor.row - 1,
            cur_ctx.cursor.col,
            cur_ctx.cursor.row - 1,
            cur_ctx.cursor.col,
            { new_text }
        )
        vim.api.nvim_win_set_cursor(0, { start.line + 1, start.character + #new_text })
    end

    if completion_item.additionalTextEdits and #completion_item.additionalTextEdits > 0 then
        vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, cur_ctx.bufnr, "utf-16")
    end

    unblock()

    if completion_item.command then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.lsp.buf.execute_command(completion_item.command)
    end
end
