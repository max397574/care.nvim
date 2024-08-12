<div align="center">

<img src="res/care.svg" width=300>

# care.nvim

</div>

This is a simple Completion and Recommendation Engine for [Neovim](https://neovim.io).
This plugin is initialized automatically, which means there is no need to call the `setup()` function.

## Quick-start 🚀
### Using [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
{
    "max397574/care.nvim",
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
}
```

### Using [`rocks.nvim`](https://github.com/nvim-neorocks/rocks.nvim)
- First run `:Rocks install care.nvim` and `:Rocks install max397574/care-lsp`
- Add this snippet to your config
```lua

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
```
### Using [`packer.nvim`](https://github.com/wbthomason/packer.nvim) (Not recommended)
```lua
use {
    "max397574/care.nvim",
    requires = {"max397574/care-lsp"},
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
}
```

## Credits

- [MariaSolOs](https://github.com/MariaSolOs) for work in core and core in general

- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) was a big inspiration for this

- [mfussenegger](https://github.com/mfussenegger) for helping me out with my beginner questions

- [mrcjkb](https://github.com/mrcjkb) for helping me out with test infrastructure and luarocks setup
