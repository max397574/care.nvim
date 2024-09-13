---
title: Configuration Recipes
description: Some common configuration recipes for care.nvim
---

# Configuration recipes

Here are some useful configurations for care.

## Common fields

This section lists some commonly uses fields in which users might be interested.

### Source name

You can access the name of the source form which the entry was completed with
the `source_name` or the `source_display_name` field in the additional data
passed to the `format_entry` function. The display name will often be
significantly longer so it's recommended to use `source_name`.

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

## Manual completion like builtin neovim

You can use filters to only complete certain sources. This can be used to create
a behavior like builtin neovim.

There are always certain sources required for the mappings.

You likely also want to set [completion_events](/config#completion-events) to an
empty table `{}` to disable autocompletion if you want this behavior.

### LSP Omnifunc

You can create something similar to the behavior of setting omnifunc to
`vim.lsp.omnifunc()` like this:

```lua
-- Source: none, is builtin
vim.keymap.set("i", "<c-x><c-o>", function()
    require("care").api.complete(function(name)
        return name == "lsp"
    end)
end)
```

### Paths

```lua
-- Source: "hrsh7th/cmp-path" (requires "max397574/care-cmp")
-- Limitations: In comparison to builtin completion the pattern to find filenames is different
-- So you have to use e.g. `./in` to complete `init.lua` instead of just `in` like builting completion

vim.keymap.set("i", "<c-x><c-f>", function()
    require("care").api.complete(function(name)
        return name == "cmp_path"
    end)
end)
```

### Buffer keywords

```lua
-- Source: "hrsh7th/cmp-buffer" (requires "max397574/care-cmp")
-- Limitations: Searches in whole buffers, forwards and backwards cursor

-- same for "<c-x><c-n>", "<c-x><c-p>"
vim.keymap.set("i", "<c-x><c-i>", function()
    require("care").api.complete(function(name)
        return name == "cmp_buffer"
    end)
end)
```

### Buffer lines

```lua
-- Source: "amarakon/nvim-cmp-buffer-lines" (requires "max397574/care-cmp")
-- Limitations: Not tested enough to know

vim.keymap.set("i", "<c-x><c-l>", function()
    require("care").api.complete(function(name)
        return name == "cmp_buffer-lines"
    end)
end)
```

### Spelling

```lua
-- Source: "f3fora/cmp-spell" (requires "max397574/care-cmp")
-- Limitations: Not tested enough to know

vim.keymap.set("i", "<c-x><c-s>", function()
    require("care").api.complete(function(name)
        return name == "cmp_spell"
    end)
end)
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
