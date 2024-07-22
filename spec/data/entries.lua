local entry_data = {}
local source_names = { "lsp", "snippet", "path" }
local kinds = {
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

---Creates an example source for testing
---It won't have any entries set
---@return care.internal_source
local function example_source()
    ---@type care.internal_source
    local source = require("care.source").new({
        complete = function()
            return {}
        end,
    })
    return source
end

---Returns `amount` completion items which have a `label` defined
---@param amount integer
---@return care.entry[]
function entry_data.label_only(amount)
    ---@type lsp.CompletionItem[]
    local ret = {}
    for i = 1, amount do
        table.insert(ret, require("care.entry").new({ label = "test" .. i }, example_source()))
    end
    return ret
end

---Returns `amount` completion items which have a `label`, `source`, and `kind`
---@param amount integer
---@return lsp.CompletionItem[]
function entry_data.minimal(amount)
    ---@type lsp.CompletionItem[]
    local ret = {}
    for i = 1, amount do
        table.insert(
            ret,
            require("care.entry").new(
                { label = "test" .. i, kind = (i % #kinds) + 1, source = example_source() },
                example_source()
            )
        )
    end
    return ret
end

return entry_data
