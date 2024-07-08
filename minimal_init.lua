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
        "max397574/neocomplete.nvim",
        event = "InsertEnter",
        dependencies = { "max397574/neocomplete-lsp" },
        config = function()
            vim.keymap.set("i", "<c-n>", function()
                vim.snippet.jump(1)
            end)
            vim.keymap.set("i", "<c-p>", function()
                vim.snippet.jump(-1)
            end)
            vim.keymap.set("i", "<c-space>", function()
                require("neocomplete").api.complete()
            end)

            vim.keymap.set("i", "<cr>", "<Plug>(NeocompleteConfirm)")
            vim.keymap.set("i", "<c-e>", "<Plug>(NeocompleteClose)")
            vim.keymap.set("i", "<tab>", "<Plug>(NeocompleteSelectNext)")
            vim.keymap.set("i", "<s-tab>", "<Plug>(NeocompleteSelectPrev)")

            vim.api.nvim_create_autocmd("InsertLeave", {
                callback = function()
                    require("neocomplete").core.menu:close()
                end,
            })
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
