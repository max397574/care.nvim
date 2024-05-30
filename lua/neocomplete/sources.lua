local neocomplete_sources = {}
neocomplete_sources.sources = {}

---@param source neocomplete.source
function neocomplete_sources.register_source(source)
    table.insert(neocomplete_sources.sources, source)
end

---@return neocomplete.source[]
function neocomplete_sources.get_sources()
    return vim.deepcopy(neocomplete_sources.sources)
end

---@param context neocomplete.context
---@param source neocomplete.source
---@param callback fun(items: neocomplete.entry[])
function neocomplete_sources.complete(context, source, callback)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local last_char = vim.api.nvim_get_current_line():sub(cursor[2], cursor[2])
    ---@type lsp.CompletionContext
    local completion_context
    if vim.tbl_contains(source.get_trigger_characters(), last_char) then
        completion_context = {
            triggerKind = 2,
            triggerCharacter = last_char,
        }
    else
        completion_context = {
            triggerKind = 1,
        }
    end
    source.complete({ completion_context = completion_context, context = context }, callback)
end

return neocomplete_sources
