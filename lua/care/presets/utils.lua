local PresetUtils = {}

---@param labels string[]
function PresetUtils.LabelEntries(labels)
    local placeholder = string.rep(" ", require("care.utils").longest(labels))
    return function(_, data)
        return require("care").core.menu.menu_window.winnr
                and (function()
                    local topline
                    vim.api.nvim_win_call(require("care").core.menu.menu_window.winnr, function()
                        topline = vim.fn.winsaveview().topline
                    end)
                    local line = data.index - topline + 1
                    if line > #labels then
                        return placeholder
                    end
                    return labels[line]
                end)()
            or placeholder
    end
end

--- Gets color of entry if it is a color and has a hex color code
--- in completion item
---@param entry care.entry
---@return string?
function PresetUtils.GetColor(entry)
    if entry.completion_item.kind ~= 16 then
        return nil
    end
    local doc = entry.completion_item.documentation
            and (entry.completion_item.documentation.value or entry.completion_item.documentation or nil)
        or nil
    if doc and doc:find("#%x%x%x%x%x%x") then
        local start, finish = doc:find("#%x%x%x%x%x%x")
        if start and finish then
            return doc:sub(start, finish)
        end
    end
end

---@param hex string
---@return string
function PresetUtils.GetHighlightForHex(hex)
    -- Adapted from nvchad
    local hl = "hex-" .. hex:sub(2)
    if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then
        vim.api.nvim_set_hl(0, hl, { fg = hex })
    end
    return hl
end

return PresetUtils
