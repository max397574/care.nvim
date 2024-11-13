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
    integration = { autopairs = false },
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

    if type(config.options.ui.type_icons) == "string" then
        if config.options.ui.type_icons == "mini.icons" then
            ---@diagnostic disable-next-line: undefined-field
            if not _G.MiniIcons then
                vim.notify("[care.nvim] Using an unavailable source ui.type_icons (mini.icons)", vim.log.levels.WARN)
                config.options.ui.type_icons = config.defaults.ui.type_icons
                return
            end
            local icons = {}
            ---@diagnostic disable-next-line: param-type-mismatch
            for name, _ in pairs(config.defaults.ui.type_icons) do
                icons[name] = _G.MiniIcons.get("lsp", string.lower(name))
            end
            config.options.ui.type_icons = icons
        elseif config.options.ui.type_icons == "lspkind" then
            local ok, lsp_kind = pcall(require, "lspkind")
            if not ok then
                vim.notify("[care.nvim] Using an unavailable source ui.type_icons (lspkind)", vim.log.levels.WARN)
                config.options.ui.type_icons = config.defaults.ui.type_icons
                return
            else
                config.options.ui.type_icons = lsp_kind.symbol_map
            end
        else
            vim.notify("[care.nvim] Using an invalid string value for ui.type_icons", vim.log.levels.WARN)
            config.options.ui.type_icons = config.defaults.ui.type_icons
        end
    end
end

config.setup({})

return config
