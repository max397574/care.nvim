local lsp_utils = {}

--- Gets the name for an lsp kind
---@param kind_number lsp.CompletionItemKind
function lsp_utils.get_kind_name(kind_number)
    if kind_number == nil then
        return "Text"
    end
    local lsp_kinds = {
        "Text",
        "Method",
        "Function",
        "Constructor",
        "Field",
        "Variable",
        "Class",
        "Interface",
        "Module",
        "Property",
        "Unit",
        "Value",
        "Enum",
        "Keyword",
        "Snippet",
        "Color",
        "File",
        "Reference",
        "Folder",
        "EnumMember",
        "Constant",
        "Struct",
        "Event",
        "Operator",
        "TypeParameter",
    }
    return lsp_kinds[kind_number] or ""
end

return lsp_utils
