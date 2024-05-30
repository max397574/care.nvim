local format_utils = {}

local config = require("neocomplete.config").options
local utils = require("neocomplete.utils")

--- Gets the width a window for displaying entries must have
---@return number, string[]
function format_utils.get_width(entries)
    local formatted_concat = {}
    for _, entry in ipairs(entries) do
        local formatted = config.ui.menu.format_entry(entry)
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
---@return table
function format_utils.get_align_tables(entries)
    local aligned_table = {}
    for _, entry in ipairs(entries) do
        local formatted = config.ui.menu.format_entry(entry)
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
