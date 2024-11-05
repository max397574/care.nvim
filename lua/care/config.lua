local config = {}

---@type care.config
---@diagnostic disable-next-line: missing-fields
config.options = {}

---@type care.config
config.defaults = {
    ui = {
        menu = {
            max_height = vim.o.pumheight ~= 0 and vim.o.pumheight or 10,
            border = "rounded",
            position = "auto",
            format_entry = function(entry, data)
                return require("care.presets").Default(entry, data)
            end,
            scrollbar = { enabled = true, character = "┃", offset = 0 },
            alignments = {},
        },
        docs_view = {
            max_height = 8,
            max_width = 80,
            border = "rounded",
            scrollbar = { enabled = true, character = "┃", offset = 0 },
            position = "auto",
            advanced_styling = false,
        },
        type_icons = {
            Class = "󰠱",
            Color = "󰏘",
            Constant = "󰏿",
            Constructor = "󰒓",
            Enum = "",
            EnumMember = "",
            Event = "",
            Field = "󰜢",
            File = "󰈚",
            Folder = "󰉋",
            Function = "󰆧",
            Interface = "󰙅",
            Keyword = "󰌋",
            Method = "󰆧",
            Module = "",
            Namespace = "󰌗",
            Operator = "󰆕",
            Property = "󰜢",
            Reference = "󰈇",
            Snippet = "",
            Struct = "󰙅",
            Text = "󰉿",
            TypeParameter = "󰊄",
            Unit = "󰑭",
            Value = "󰎠",
            Variable = "󰀫",
        },
        ghost_text = {
            enabled = true,
            position = "overlay",
        },
    },
    snippet_expansion = function(snippet_body)
        vim.snippet.expand(snippet_body)
    end,
    selection_behavior = "select",
    confirm_behavior = "insert",
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
    sources = {},
    preselect = true,
    sorting_direction = "top-down",
    completion_events = { "TextChangedI" },
    enabled = function()
        local enabled = true
        if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
            enabled = false
        end
        return enabled
    end,
    max_view_entries = 200,
    debug = false,
}

---@param opts care.config?
function config.setup(opts)
    if vim.tbl_isempty(config.options) then
        config.options = vim.tbl_deep_extend("force", config.defaults, opts or {})
    else
        config.options = vim.tbl_deep_extend("force", config.options, opts or {})
    end
end

config.setup({})

return config
