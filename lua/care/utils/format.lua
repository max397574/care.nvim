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
---@return number
function format_utils.get_width(entries)
    local columns = {}
    for i, entry in ipairs(entries) do
        local formatted = config.ui.menu.format_entry(entry, get_format_data(entry, i))
        for j, aligned in ipairs(formatted) do
            local chunk_texts = {}
            for _, chunk in ipairs(aligned) do
                table.insert(chunk_texts, chunk[1])
            end
            if not columns[j] then
                columns[j] = {}
            end
            table.insert(columns[j], table.concat(chunk_texts, ""))
        end
    end
    local width = 0
    vim.iter(columns):each(function(column)
        width = width + utils.longest(column)
    end)
    return width
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
