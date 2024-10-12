---
title: Getting started
description: How to get started using care.nvim
sidebar_position: 1
---

# Getting started

## Installation

You can install care with your favourite package manager. How you set up
mappings is the same for every package manager.

<details>
<summary>Mappings snippet</summary>

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

</details>

### Lazy.nvim

If you have enabled [rockspec support](https://lazy.folke.io/packages#rockspec)
you can simply install care.nvim as any other plugin.

It is recommended to not lazyload this plugin since it is already lazy loaded
internally.

<details>
<summary>Installation snippet with rockspec support</summary>

```lua
{
    "max397574/care.nvim",
    config = function()
        -- Set up mappings here
    end
}
```

</details>

If you don't have rockspec support you need to install `fzy` as a dependency.

<details>
<summary>Installation snippet without rockspec</summary>

```lua
{
    "max397574/care.nvim",
    dependencies = {
        {
            "romgrk/fzy-lua-native",
            build = "make" -- optional, uses faster native version
        }
    },
    config = function()
        -- Set up mappings here
    end
}
```

</details>

### Rocks.nvim

<details>
<summary>Installation instructions for rocks.nvim</summary>

You can simply run `:Rocks install care.nvim` and then add the keymapping
snippet to your config.

</details>

## Development

See the [devloper documentation](./dev) for more information about the code and
developing sources.
