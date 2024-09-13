---
title: Configuration
description: Configuration for care.nvim
---

# Configuration

<details>
  <summary>Full Default Config</summary>

```lua
---@type care.config
config.defaults = {
    ui = {
        menu = {
            max_height = 10,
            border = "rounded",
            position = "auto",
            format_entry = function(entry, data)
                local completion_item = entry.completion_item
                local type_icons = config.options.ui.type_icons or {}
                -- TODO: remove since now can only be number, or also allow custom string kinds?
                local entry_kind = type(completion_item.kind) == "string" and completion_item.kind
                    or require("care.utils.lsp").get_kind_name(completion_item.kind)
                return {
                    { { completion_item.label .. " ", data.deprecated and "Comment" or "@care.entry" } },
                    {
                        {
                            " " .. (type_icons[entry_kind] or type_icons.Text) .. " ",
                            ("@care.type.%s"):format(entry_kind),
                        },
                    },
                }
            end,
            scrollbar = { enabled = true, character = "█", offset = 0 },
            alignments = {},
        },
        docs_view = {
            max_height = 8,
            max_width = 80,
            border = "rounded",
            scrollbar = { enabled = true, character = "█", offset = 0 },
            position = "auto",
        },
        type_icons = {
            Class = "",
            Color = "",
            Constant = "",
            Constructor = "",
            Enum = "",
            EnumMember = "",
            Event = "",
            Field = "󰜢",
            File = "",
            Folder = "",
            Function = "",
            Interface = "",
            Keyword = "",
            Method = "ƒ",
            Module = "",
            Operator = "󰆕",
            Property = "",
            Reference = "",
            Snippet = "",
            Struct = "",
            Text = "",
            TypeParameter = "",
            Unit = "󰑭",
            Value = "󰎠",
            Variable = "󰫧",
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
```

</details>

The config of care is used to configure the UI and care itself.

To configure care you call the setup function of the config module with the options you want
to override. Also see [configuration recipes](/configuration_recipes).
```lua
require("care").setup({
...
}
```

The configuration consists of two main parts. The UI Configuration and the
configuration of the completion behaviors of care.
# `care.config`

# Methods

## Snippet Expansion
`config.snippet_expansion?(body: string): nil`

With this field a function for expanding snippets is defined. By default this is the
builtin `vim.snippet.expand()`. You can also use a plugin like luasnip for this:
```lua
snippet_expansion = function(body)
    require("luasnip").lsp_expand(body)
end
```

## Enabled
`config.enabled?(): boolean`

This function can be used to disable care in certain contexts. By default this
disables care in prompts.
# Fields

## Ui
`config.ui? care.config.ui`

The [UI Configuration](#Ui-Configuration) is used to configure the whole UI of care.
One of the main goals of this is to be as extensible as possible. This is especially important
for the completion entries. Read more about that under
[Configuration of item display](/design/#configuration-of-item-display).

## Selection Behavior
`config.selection_behavior? "select"|"insert"`

With the selection behavior the user can determine what happens when selecting
an entry. This can either be `"select"` or `"insert"`. Selecting will just
select the entry and do nothing else. Insert will actually insert the text of
the entry (this is not necessarily the whole text).

## Confirm Behavior
`config.confirm_behavior? "insert"|"replace"`

This field controls the behavior when confirming an entry.

## Sources
`config.sources? table<string, care.config.source>`

See [care.config.source](/config/#source-configuration)

This field is used to configure the sources for care.nvim.
Use a table where the fields is the source name and the value is the configuration
```lua
sources = {
    nvim_lsp = {
        enabled = function()
            ...
        end,
        ...
    }
}
```

## Completion Events
`config.completion_events? string[]`

The `completion_events` table is used to set events for autocompletion. By default
it just contains `"TextChangedI"`. You can set it to an empty table (`{}`) to
disable autocompletion.

## Keyword Pattern
`config.keyword_pattern? string`

The keyword pattern is used to determine keywords. These are used to determine what
to use for filtering and what to remove if insert text is used.
It should essentially just describe the entries of a source.

## Preselect
`config.preselect? boolean`

Whether items should be preselected or not. Which items are preselected is determined
by the source.

## Sorting Direction
`config.sorting_direction? "top-down"|"away-from-cursor"`

How to sort the entries in the completion menu.
This can either be top to bottom or so the best match is always next to the cursor.

## Debug
`config.debug? boolean`

Whether debugging should be enabled or not. This will write a log to a `care.log` file
in the current directory.

## Max View Entries
`config.max_view_entries? integer`

The max entries to display in the menu. Note that this just affects
the entries displayed at a time. So there are still more entries on which you
can filter by continue typing. This limit just exists for performance reasons
because there are some sources which return up to multiple thousand
entries through which a user never will scroll.
The default value is 200 which will open the menu instantly in most cases so there
isn't much need for a lower value.
Values of up to about 1000 should also not cause performance issue.

# Ui Configuration
This is used to configure the whole UI of care.
# `care.config.ui`

# Fields

## Menu
`config.ui.menu? care.config.ui.menu`

Configuration of the completion menu of care.nvim

## Docs View
`config.ui.docs_view? care.config.ui.docs`

This configuration allows you to configure the documentation view. It consists
of some basic window properties like the border and the maximum height of the
window. It also has a field to define the character used for the scrollbar.

## Type Icons
`config.ui.type_icons? care.config.ui.type_icons`

This is a table which defines the different icons.

## Ghost Text
`config.ui.ghost_text? care.config.ui.ghost_text`

Configuration of ghost text.

With this field the user can control how ghost text is displayed.
# `care.config.ui.ghost_text`

# Fields

## Enabled
`config.ui.ghost_text.enabled? boolean`

You can use the `enabled` field to determine whether the ghost text should be
enabled or not.

## Position
`config.ui.ghost_text.position? "inline"|"overlay"`

The `position` can either be `"inline"` or `"overlay"`. Inline
will add the text inline right where the cursor is. With the overlay position
the text will overlap with existing text after the cursor.

This configuration should allow you to completely adapt the completion menu to
your likings.

It includes some basic window properties like the border and the maximum height
of the window. It also has a field to define the character used for the
scrollbar. Set `scrollbar` to `nil` value to disable the scrollbar.
# `care.config.ui.menu`

# Methods

## Format Entry
`config.ui.menu.format_entry?(entry: care.entry, data: care.format_data): { [1]: string, [2]: string }[][]`

See [care.entry](/dev/entry)

Another field is `format_entry`. This is a function which recieves an entry of
the completion menu and determines how it's formatted. For that a table with
text-highlight chunks like `:h nvim_buf_set_extmarks()` is used. You can create
sections which are represented by tables and can have a different alignment
each. This is specified with another field which takes a table with the
alignment of each section.
For example you want to have the label of an entry in a red highlight and an
icon in a entry-kind specific color left aligned first and then the source of
the entry right aligned in blue. You could do that like this:
```lua
format_entry = function(entry)
    return {
        -- The first section with the two chunks for the label and the icon
        { { entry.label .. " ", "MyRedHlGroup" }, { entry.kind, "HighlightKind" .. entry.kind } }
        -- The second section for the source
        { { entry.source, "MyBlueHlGroup" } }
    }
end,
alignment = { "left", "right" }
```
Notice that there are multiple differences between having one table containing
the chunks for the label and kind and having them separately. The latter would
require another entry in the `alignment` table. It would also change the style
of the menu because the left sides of the icons would be aligned at the same
column and not be next to the labels. In the example there also was some spacing
added in between the two.
# Fields

## Max Height
`config.ui.menu.max_height? integer`

Maximum height of the menu

## Border
`config.ui.menu.border? string|string[]|string[][]`

The border of the completion menu

## Scrollbar
`config.ui.menu.scrollbar? care.config.scrollbar`

Configuration of the scrollbar

## Position
`config.ui.menu.position? "auto"|"bottom"|"top"`

If the menu should be displayed on top, bottom or automatically

## Alignments
`config.ui.menu.alignments? ("left"|"center"|"right")[]`

How the sections in the menu should be aligned

## Source configuration
Configuration for the sources of care.nvim
# `care.config.source`

# Methods

## Enabled
`config.source.enabled? boolean|fun():boolean`

Whether the source is enabled (default true)

## Filter
`config.source.filter?(entry: care.entry): boolean`

See [care.entry](/dev/entry)

Filter function for entries by the source
# Fields

## Max Entries
`config.source.max_entries? integer`

The maximum amount? of entries which can be displayed by this source

## Priority
`config.source.priority? integer`

The priority of this source. Is more important than matching score

Configuration of the completion menu of care.nvim
# `care.config.ui.docs`

# Fields

## Max Height
`config.ui.docs.max_height? integer`

Maximum height of the documentation view

## Max Width
`config.ui.docs.max_width? integer`

Maximum width of the documentation view

## Border
`config.ui.docs.border? string|string[]|string[][]`

The border of the documentation view

## Scrollbar
`config.ui.docs.scrollbar? care.config.scrollbar`

Configuration of the scrollbar

## Position
`config.ui.docs.position? "auto"|"left"|"right"`

Position of docs view.
Auto will prefer right if there is enough space

Additional data passed to format function to allow more advanced formatting
# `care.format_data`

# Fields

## Index
`format_data.index integer`

Index of the entry in the completion menu

## Deprecated
`format_data.deprecated boolean`

Whether the item is marked as deprecated by the source or not

## Source Name
`format_data.source_name string`

The name of the source from which the entry was completed

## Source Display Name
`format_data.source_display_name string`

The display name of the source from which the entry was completed which
is more detailed than the normal name


# `care.config.scrollbar`

# Fields

## Character
`config.scrollbar.character? string`

The character used for drawing the scrollbar

## Enabled
`config.scrollbar.enabled? boolean`

Whether the scrollbar is enabled or not

## Offset
`config.scrollbar.offset? integer`

Offset of the scrollbar. 0 is at the border of the window