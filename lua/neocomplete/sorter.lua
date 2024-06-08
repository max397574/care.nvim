local sorter = {}

---@param entries neocomplete.entry[]
---@param prefix string
---@return neocomplete.entry[]
function sorter.sort(entries, prefix)
    ---@param entry neocomplete.entry
    local function get_filter_text(entry)
        -- TODO: makes more sense like this because label is what user sees?
        -- return entry.filterText or entry.label
        return entry.label
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

    local filtered_entries = vim.iter(entries)
        :filter(function(entry)
            return entry.score and entry.score > 0
        end)
        :totable()

    table.sort(filtered_entries, function(a0, a1)
        return a0.score > a1.score
    end)

    return filtered_entries
end

return sorter
