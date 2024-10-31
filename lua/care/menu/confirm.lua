---@param entry lsp.CompletionItem
---@return lsp.CompletionItem
local function normalize_entry(entry)
    entry.insertTextFormat = entry.insertTextFormat or 1
    entry.filterText = entry.filterText or entry.label
    entry.sortText = entry.sortText or entry.label
    entry.insertText = entry.insertText or entry.label
    return entry
end

local Log = require("care.utils.log")

---@param entry care.entry
return function(entry)
    local config = require("care.config").options
    Log.log("Confirming Entry")
    Log.log("Completion item", function()
        local item = vim.deepcopy(entry.completion_item)
        item.documentation = "<documentation>"
        return item
    end)
    Log.log("Entry context:", entry.context)

    local cur_ctx = require("care.context").new()
    local unblock = require("care").core:block()

    local completion_item = entry.completion_item
    completion_item = normalize_entry(completion_item)

    -- Restore context where entry was completed (remove filter)
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

    cur_ctx = require("care.context").new()

    local range = config.confirm_behavior == "insert" and entry:get_insert_range() or entry:get_replace_range()
    range["end"].character = cur_ctx.cursor.col + math.max(0, range["end"].character - entry.context.cursor.col)

    Log.log("Range (before adjustments), behavior: " .. config.confirm_behavior, range)

    -- TODO: entry.insertTextMode
    local is_snippet = completion_item.insertTextFormat == 2
    local snippet_text

    -- Integrates nvim-autopairs with care.nvim
    if config.integration.autopairs then
        local autopairs = require("nvim-autopairs")
        local rules = autopairs.get_rules("(")
        local handlers = require("nvim-autopairs.completion.handlers")
        local is_function, is_method = completion_item.kind == 3, completion_item.kind == 2
        local lisp_filetypes = { clojure = true, clojurescript = true, fennel = true, janet = true }
        local is_lisp = lisp_filetypes[vim.bo.ft] == true
        local is_python = vim.bo.ft == "python"
        local buf = vim.api.nvim_get_current_buf()

        if is_function or is_method then
            if is_lisp then
                handlers.lisp("(", completion_item, buf)
            elseif is_python then
                handlers.python("(", completion_item, buf, rules)
            else
                handlers["*"]("(", completion_item, buf, rules)
            end
        end
    end

    if not completion_item.textEdit then
        ---@diagnostic disable-next-line: missing-fields
        completion_item.textEdit = {
            newText = completion_item.insertText,
        }
    end
    completion_item.textEdit.newText = completion_item.textEdit.newText or completion_item.insertText

    completion_item.textEdit.range = range

    if is_snippet then
        snippet_text = completion_item.textEdit.newText or completion_item.insertText
        completion_item.textEdit.newText = ""
    end

    Log.log("Text Edit", completion_item.textEdit)
    Log.log("Snippet Text", snippet_text)

    vim.lsp.util.apply_text_edits({ completion_item.textEdit }, cur_ctx.bufnr, "utf-16")

    local start = completion_item.textEdit.range.start
    if is_snippet then
        vim.api.nvim_win_set_cursor(0, { start.line + 1, start.character })
        config.snippet_expansion(snippet_text)
    else
        local text_edit_lines = vim.split(completion_item.textEdit.newText, "\n")
        vim.api.nvim_win_set_cursor(0, {
            start.line + #text_edit_lines,
            #text_edit_lines == 1 and start.character + #completion_item.textEdit.newText
                or #text_edit_lines[#text_edit_lines],
        })
    end

    if completion_item.additionalTextEdits and #completion_item.additionalTextEdits > 0 then
        vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, cur_ctx.bufnr, "utf-16")
    end

    if entry.source.execute then
        entry.source:execute(entry)
    end
    unblock()
    vim.schedule(function()
        require("care").core.context = require("care.context").new(require("care").core.context)
        require("care").core:complete(3)
    end)
end
