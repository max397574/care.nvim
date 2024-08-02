local root = vim.fn.fnamemodify("./.repro", ":p")

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins
local plugins = {
    -- do not remove the colorscheme!
    { "folke/tokyonight.nvim" },
    {
        "max397574/care.nvim",
        event = "InsertEnter",
        dependencies = { "max397574/care-lsp" },
        config = function()
            vim.keymap.set("i", "<c-n>", function()
                vim.snippet.jump(1)
            end)
            vim.keymap.set("i", "<c-p>", function()
                vim.snippet.jump(-1)
            end)
            vim.keymap.set("i", "<c-space>", function()
                require("care").api.complete()
            end)

            vim.keymap.set("i", "<cr>", "<Plug>(CareConfirm)")
            vim.keymap.set("i", "<c-e>", "<Plug>(CareClose)")
            vim.keymap.set("i", "<tab>", "<Plug>(CareSelectNext)")
            vim.keymap.set("i", "<s-tab>", "<Plug>(CareSelectPrev)")

            vim.keymap.set("i", "<c-f>", function()
                if require("care").api.doc_is_open() then
                    require("care").api.scroll_docs(4)
                else
                    vim.api.nvim_feedkeys(vim.keycode("<c-f>"), "n", false)
                end
            end)

            vim.keymap.set("i", "<c-d>", function()
                if require("care").api.doc_is_open() then
                    require("care").api.scroll_docs(-4)
                else
                    vim.api.nvim_feedkeys(vim.keycode("<c-f>"), "n", false)
                end
            end)
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig")["lua_ls"].setup({})
        end,
    },
    -- =========TODO=============
    -- your lspconfig stuff here
    -- =========TODO=============
    -- add any other pugins here
}
require("lazy").setup(plugins, {
    root = root .. "/plugins",
})

-- add anything else here
vim.opt.termguicolors = true
-- do not remove the colorscheme!
vim.cmd([[colorscheme tokyonight]])
