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

return PresetUtils
