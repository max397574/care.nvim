---
title: Configuration Recipes
description: Some common configuration recipes for care.nvim
---

# Configuration recipes

Here are some useful configurations for care.

## Labels and shortcuts

This configuration will add labels to your items and allow to select them with
`ctrl+label`.

```lua
local labels = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}

-- Add this to formatting

{ {
    " " .. require("care.presets.utils").LabelEntries(labels)(entry, data) .. " ",
    "Comment",
}, },

-- Keymappings
for i, label in ipairs(labels) do
    vim.keymap.set("i", "<c-"..label..">", function()
        require("care").api.select_visible(i)
        -- If you also want to confirm the entry
        require("care").api.confirm()
    end)
end
```

## Reverse keybindings for reversed menu

When using `"away-from-cursor"` as `sorting_direction` in the configuration the
menu can be reversed. The `select_{next, prev}` mappings will still go in the
same direction though. If you always want to use `select_next` to select the
entry with a lower match than current one you can use mappings like this:

```lua
vim.keymap.set("i", "<c-n>", function()
    if require("care").api.is_reversed() then
        require("care").api.select_prev()
    else
        require("care").api.select_next()
    end
end)

vim.keymap.set("i", "<c-p>", function()
    if require("care").api.is_reversed() then
        require("care").api.select_next()
    else
        require("care").api.select_prev()
    end
end)
```
