local format_utils = {}

local config = require("care.config").options
local utils = require("care.utils")

---comment
---@param entry care.entry
---@param index integer
---@return care.format_data
local function get_format_data(entry, index)
    return {
        index = index,
        deprecated = entry.completion_item.deprecated or vim.tbl_contains(entry.completion_item.tags or {}, 1),
        source_name = entry.source.source.name,
        source_display_name = entry.source.source.display_name or entry.source.source.name,
    }
end

--- Gets the width a window for displaying entries must have
---@param entries care.entry[]
---@return number, string[]
function format_utils.get_width(entries)
    local formatted_concat = {}
    for i, entry in ipairs(entries) do
        local formatted = config.ui.menu.format_entry(entry, get_format_data(entry, i))
        local chunk_texts = {}
        for _, aligned in ipairs(formatted) do
            for _, chunk in ipairs(aligned) do
                table.insert(chunk_texts, chunk[1])
            end
        end
        table.insert(formatted_concat, table.concat(chunk_texts, ""))
    end
    return utils.longest(formatted_concat), formatted_concat
end

--- Gets a table with one table for each aligned chunk inside
---@param entries care.entry[]
---@return table
function format_utils.get_align_tables(entries)
    local aligned_table = {}
    for i, entry in ipairs(entries) do
        local formatted = config.ui.menu.format_entry(entry, get_format_data(entry, i))
        for aligned_index, aligned_chunks in ipairs(formatted) do
            if not aligned_table[aligned_index] then
                aligned_table[aligned_index] = {}
            end
            table.insert(aligned_table[aligned_index], aligned_chunks)
        end
    end
    return aligned_table
end

return format_utils
