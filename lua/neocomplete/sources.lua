local neocomplete_sources = {}

---@type neocomplete.internal_source[]
neocomplete_sources.sources = {}

---@param completion_source neocomplete.source
function neocomplete_sources.register_source(completion_source)
    local source = require("neocomplete.source").new(completion_source)
    table.insert(neocomplete_sources.sources, source)
end

---@return neocomplete.internal_source[]
function neocomplete_sources.get_sources()
    return vim.deepcopy(neocomplete_sources.sources)
end

---@param context neocomplete.context
---@param source neocomplete.internal_source
---@param callback fun(items: neocomplete.entry[], is_incomplete?: boolean)
function neocomplete_sources.complete(context, source, callback)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local last_char = vim.api.nvim_get_current_line():sub(cursor[2], cursor[2])
    ---@type lsp.CompletionContext
    local completion_context
    if context.reason == 1 then
        if
            vim.tbl_contains(source.source.get_trigger_characters(), last_char)
            or (not source.entries or #source.entries == 0)
        then
            -- if vim.tbl_contains(source.source.get_trigger_characters(), last_char) or true then
            completion_context = {
                triggerKind = 2,
                triggerCharacter = last_char,
            }
        elseif not source.incomplete then
            -- TODO: cleanup
            local line = vim.api.nvim_get_current_line()
            local line_to_cursor = line:sub(1, context.cursor.col)
            local keyword_pattern = require("neocomplete.config").options.keyword_pattern
            if source.source.keyword_pattern then
                keyword_pattern = source.source.keyword_pattern
            end
            if source.source.get_keyword_pattern then
                keyword_pattern = source.source:get_keyword_pattern()
            end
            -- Can add $ to keyword pattern because we just match on line to cursor
            local word_boundary = vim.fn.match(line_to_cursor, keyword_pattern .. "$")
            if word_boundary == -1 then
                return 0
            end

            local prefix = line:sub(word_boundary + 1, context.cursor.col)

            callback(require("neocomplete.sorter").sort(source.entries, prefix))
            return
        end
    else
        completion_context = {
            triggerKind = 1,
        }
    end
    if source.incomplete then
        completion_context = {
            triggerKind = 3,
        }
    end
    source.source.complete({ completion_context = completion_context, context = context }, callback)
end

return neocomplete_sources
