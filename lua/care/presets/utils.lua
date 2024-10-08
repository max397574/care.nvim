---@type care.preset_utils
---@diagnostic disable-next-line: missing-fields
local PresetUtils = {}

---@param labels string[]
function PresetUtils.label_entries(labels)
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

function PresetUtils.get_color(entry)
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
function PresetUtils.get_highlight_for_hex(hex)
    -- Adapted from nvchad
    local hl = "hex-" .. hex:sub(2)
    if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then
        vim.api.nvim_set_hl(0, hl, { fg = hex })
    end
    return hl
end

---@param style? "blended"|"fg"
function PresetUtils.kind_highlight(entry, style)
    local completion_item = entry.completion_item
    local entry_kind = type(completion_item.kind) == "string" and completion_item.kind
        or require("care.utils.lsp").get_kind_name(completion_item.kind)

    style = style or "fg"
    return style == "fg" and ("@care.type.fg.%s"):format(entry_kind) or ("@care.type.blended.%s"):format(entry_kind)
end

return PresetUtils
