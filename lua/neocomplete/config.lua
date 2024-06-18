local config = {}

---@type neocomplete.config
---@diagnostic disable-next-line: missing-fields
config.options = {}

---@type neocomplete.config
config.defaults = {
    ui = {
        menu = {
            max_height = 10,
            border = "rounded",
            position = "auto",
            format_entry = function(entry)
                local completion_item = entry.completion_item
                local type_icons = config.options.ui.type_icons
                local entry_kind = type(completion_item.kind) == "string" and completion_item.kind
                    or require("neocomplete.utils.lsp").get_kind_name(completion_item.kind)
                return {
                    { { completion_item.label .. " ", "@neocomplete.entry" } },
                    { { type_icons[entry_kind] or "", ("@neocomplete.type.%s"):format(entry_kind) } },
                }
            end,
            alignment = {},
        },
        docs_view = {
            max_height = 7,
            border = "rounded",
        },
        type_icons = {
            Class = "  ",
            Color = "  ",
            Constant = "  ",
            Constructor = "  ",
            Enum = " 了",
            EnumMember = "  ",
            Event = "  ",
            Field = " 󰜢 ",
            File = " ",
            Folder = "  ",
            Function = "  ",
            Interface = "  ",
            Keyword = "  ",
            Method = " ƒ ",
            Module = "  ",
            Operator = " 󰆕 ",
            Property = "  ",
            Reference = "  ",
            Snippet = "  ",
            Struct = "  ",
            Text = "  ",
            TypeParameter = "",
            Unit = " 󰑭 ",
            Value = " 󰎠 ",
            Variable = "  ",
        },
    },
    snippet_expansion = function(snippet_body)
        vim.snippet.expand(snippet_body)
    end,
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
    enabled = function()
        local enabled = true
        if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
            enabled = false
        end
        return enabled
    end,
}

function config.setup(opts)
    if vim.tbl_isempty(config.options) then
        config.options = vim.tbl_deep_extend("force", config.defaults, opts or {})
    else
        config.options = vim.tbl_deep_extend("force", config.options, opts or {})
    end
end

config.setup({})

return config
