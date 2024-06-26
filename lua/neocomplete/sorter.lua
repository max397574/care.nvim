--- Used for filtering and sorting entries. This uses fzy-lua under the hood.
local sorter = {}

--- Filters and sorts entries by a prefix using fzy algorithm
--- Sets `score` and `matches` field of remaining entries
---@param entries neocomplete.entry[]
---@param prefix string
---@return neocomplete.entry[]
function sorter.sort(entries, prefix)
    ---@param entry neocomplete.entry
    local function get_filter_text(entry)
        -- TODO: makes more sense like this because label is what user sees?
        -- return entry.filterText or entry.label
        return entry.completion_item.label
    end

    local filter_texts = {}

    for i, entry in ipairs(entries) do
        entries[i].score = nil
        entries[i].matches = nil
        table.insert(filter_texts, get_filter_text(entry))
    end

    local fzy = require("fzy")

    for _, res in ipairs(fzy.filter(prefix, filter_texts)) do
        -- res is a table like `{2, {1, 5,  9}, 2.63}` {<index>, {<matches>}, <score>}
        entries[res[1]].score = res[3]
        entries[res[1]].matches = res[2]
    end
    entries = vim.iter(entries)
        :map(function(entry)
            if not entry.score then
                entry.score = 0
            end
            return entry
        end)
        :totable()

    table.sort(entries, function(a0, a1)
        return a0.score > a1.score
    end)

    return entries
end

return sorter
