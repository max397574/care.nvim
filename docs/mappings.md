---
title: Mappings
description: How mappings work in care.nvim
sidebar_position: 3
---

# Mappings

## Usage

For basic mappings the user should use the provided `<Plug>` mappings.

-   `<Plug>(CareConfirm)`: Confirm the currently selected entry
-   `<Plug>(CareSelectNext)`: Select the next entry in the menu
-   `<Plug>(CareSelectPrev)`: Select the previous entry in the menu
-   `<Plug>(CareClose)`: Close the completion menu

These mappings will automatically fallback to the default actions of the keys
mapped if the menu isn't open. That means that if `<CR>` is mapped to confirm
like this

```lua
vim.keymap.set("i", "<cr>", "<Plug>(CareConfirm)")
```

pressing `<CR>` will still go to a new line when the completion menu isn't open.

To create more advanced mappings the [api](/api) should be used. For fallback to
the unmapped action of a key `nvim_feedkeys` can be used. An example for this
would be the following:

```lua
vim.keymap.set("i", "<c-f>", function()
    if require("care").api.doc_is_open() then
        require("care").api.scroll_docs(4)
    else
        vim.api.nvim_feedkeys(vim.keycode("<c-f>"), "n", false)
    end
end)
```

## Design

When designing the mapping system it was important that as much native
functionality as possible is used. Therefore it was really important that the
mappings could be set by the user with `vim.keymap.set` without any additional
abstractions.

To have the best possible user experience `<Plug>` mappings are used for some
simple mappings while still allowing to create more complex mappings which do
multiple things with one key.
