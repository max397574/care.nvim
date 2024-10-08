---@type care.preset_components
---@diagnostic disable-next-line: missing-fields
local components = {}

function components.ShortcutLabel(labels, entry, data, highlight_group)
    return {
        {
            " " .. require("care.presets.utils").label_entries(labels)(entry, data) .. " ",
            highlight_group or "Comment",
        },
    }
end

---@param style? "blended"|"fg"
function components.KindIcon(entry, style)
    local type_icons = require("care.config").options.ui.type_icons or {}
    local completion_item = entry.completion_item
    local entry_kind = type(completion_item.kind) == "string" and completion_item.kind
        or require("care.utils.lsp").get_kind_name(completion_item.kind)
    style = style or "fg"
    return {
        {
            " " .. (type_icons[entry_kind] or type_icons.Text) .. " ",
            style == "blended" and ("@care.type.blended.%s"):format(entry_kind)
                or ("@care.type.fg.%s"):format(entry_kind),
        },
    }
end

function components.Label(entry, data, display_colored_block)
    local completion_item = entry.completion_item
    local color = require("care.presets.utils").get_color(entry)

    return {
        { completion_item.label .. " ", data.deprecated and "Comment" or "@care.entry" },
        display_colored_block and color and {
            " ",
            require("care.presets.utils").get_highlight_for_hex(color) or "@care.entry",
        } or nil,
    }
end

function components.ColoredBlock(entry, character)
    local color = require("care.presets.utils").get_color(entry)

    return {
        color and {
            character or " ",
            require("care.presets.utils").get_highlight_for_hex(color) or "@care.entry",
        } or nil,
    }
end

return components
