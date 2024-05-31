-- From https://github.com/nvim-neorg/neorg

-- This build.lua exists to bridge luarocks installation for lazy.nvim users.
-- It's main purposes are:
-- - Shelling out to luarocks.nvim for installation
-- - Installing neocomplete's dependencies as rocks

-- Important note: we execute the build code in a vim.schedule
-- to defer the execution and ensure that the runtimepath is appropriately set.

vim.schedule(function()
    local ok, luarocks = pcall(require, "luarocks-nvim.rocks")

    assert(ok, "Unable to install neocomplete: required dependency `vhyrro/luarocks.nvim` not found!")

    luarocks.ensure({
        "fzy == 1.0.3",
    })

    package.loaded["neocomplete"] = nil
    require("neocomplete").setup()
end)
