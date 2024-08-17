---
title: Config
description: Configuration for care.nvim
---


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
            format_entry = function(entry)
                local deprecated = entry.completion_item.deprecated
                    or vim.tbl_contains(entry.completion_item.tags or {}, 1)
                local completion_item = entry.completion_item
                local type_icons = config.options.ui.type_icons
                -- TODO: remove since now can only be number, or also allow custom string kinds?
                local entry_kind = type(completion_item.kind) == "string" and completion_item.kind
                    or require("care.utils.lsp").get_kind_name(completion_item.kind)
                return {
                    { { completion_item.label .. " ", deprecated and "Comment" or "@care.entry" } },
                    {
                        {
                            " " .. (type_icons[entry_kind] or type_icons.Text) .. " ",
                            ("@care.type.%s"):format(entry_kind),
                        },
                    },
                }
            end,
            scrollbar = "█",
            alignment = {},
        },
        docs_view = {
            max_height = 8,
            max_width = 80,
            border = "rounded",
            scrollbar = "█",
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
    completion_events = { "TextChangedI" },
    enabled = function()
        local enabled = true
        if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
            enabled = false
        end
        return enabled
    end,
}
```

</details>
# Config

The config of care is used to configure the ui and care itself.

There are two main parts to the config. The first one is the `ui` field and the
second on is the rest of the configuration which is for configuring the general
behavior of care.
# `care.config`

# Methods

## Snippet Expansion
`config.snippet_expansion(string): nil`

Here a function for expanding snippets is defined. By default this is the
builtin `vim.snippet.expand()`. You can also use a plugin like luasnip for this
like this:

```lua
snippet_expansion = function(body)
    require("luasnip").lsp_expand(body)
end
```

## Enabled
`config.enabled(): boolean`

This function can be used to disable care in certain contexts. By default this
disables care in prompts.
# Fields

## Ui
`config.ui care.config.ui`

The [ui configuration](#Ui-Configuration) is used to configure the whole ui of care. One of the main
goals of this is to be as extensible as possible. This is especially important
for the completion entries. Read more about that under
[Configuration of item display](/design/#configuration-of-item-display).
The most important part for many users will be the `menu` field. It's used to
configure the completion menu.
You can also configure the documentation view just like the main menu.
Lastly the users can also configure the icons which will be used for the
different items.

## Selection Behavior
`config.selection_behavior "select"|"insert"`

With the selection behavior the user can determine what happens when selecting
an entry. This can either be `"select"` or `"insert"`. Selecting will just
select the entry and do nothing else. Insert will actually insert the text of
the entry (this is not necessarily the whole text).

## Confirm Behavior
`config.confirm_behavior "insert"|"replace"`

Behavior when confirming entry

## Sources
`config.sources care.config.source[]`

Configuration for the different sources

## Completion Events
`config.completion_events string[]`

The `completion_events` table is used to set events for completion. By default
it just contains `"TextChangedI"`. You can set it to an empty table (`{}`) to
disable autocompletion.

## Keyword Pattern
`config.keyword_pattern string`

Pattern used to determine keywords, used to determine what to use for filtering
and what to remove if insert text is used.

## Preselect
`config.preselect boolean`

Whether items should be preselected or not

# Ui Configuration
The main class for the ui configuration of care.nvim
# `care.config.ui`

# Fields

## Menu
`config.ui.menu care.config.ui.menu`

Configuration of the completion menu of care.nvim

## Docs View
`config.ui.docs_view care.config.ui.docs`

This configuration allows you to configure the documentation view. It consists
of some basic window properties like the border and the maximum height of the
window. It also has a field to define the character used for the scrollbar.

## Type Icons
`config.ui.type_icons care.config.ui.type_icons`

This is a table which defines the different icons.

## Ghost Text
`config.ui.ghost_text care.config.ui.ghost_text`

Configuration of ghost text

Configuration for the ghost text
# `care.config.ui.ghost_text`

# Fields

## Enabled
`config.ui.ghost_text.enabled boolean`

You can use the `enabled` field to determine whether the ghost text should be
enabled or not. The `position` can either be `"inline"` or `"overlay"`. Inline
will add the text inline right where the cursor is. With the overlay position
the text will overlap with existing text after the cursor.

## Position
`config.ui.ghost_text.position "inline"|"overlay"`



This configuration should allow you to completely adapt the completion menu to
your likings.

It includes some basic window properties like the border and the maximum height
of the window. It also has a field to define the character used for the
scrollbar. Set `scrollbar` to `nil` value to disable the scrollbar.
# `care.config.ui.menu`

# Methods

## Format Entry
`config.ui.menu.format_entry(entry: care.entry): { [1]: string, [2]: string }[][]`
See: [care.entry](/dev/entry)

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
`config.ui.menu.max_height integer`

Maximum height of the menu

## Border
`config.ui.menu.border string|string[]|string[][]`

The border of the completion menu

## Scrollbar
`config.ui.menu.scrollbar string?`

Character used for the scrollbar

## Position
`config.ui.menu.position "auto"|"bottom"|"top"`

If the menu should be displayed on top, bottom or automatically

## Alignment
`config.ui.menu.alignment ("left"|"center"|"right")[]`

How the sections in the menu should be aligned


# `care.config.source`

# Methods

## Enabled
`config.source.enabled boolean|nil|fun():boolean`

Whether the source is enabled (default true)

## Filter
`config.source.filter(entry: care.entry): boolean`
See: [care.entry](/dev/entry)

Filter function for entries by the source
# Fields

## Max Entries
`config.source.max_entries integer?`

The maximum amount of entries which can be displayed by this source

## Priority
`config.source.priority integer?`

The priority of this source. Is more important than matching score

Configuration of the completion menu of care.nvim
# `care.config.ui.docs`

# Fields

## Max Height
`config.ui.docs.max_height integer`

Maximum height of the documentation view

## Max Width
`config.ui.docs.max_width integer`

Maximum width of the documentation view

## Border
`config.ui.docs.border string|string[]|string[][]`

The border of the documentation view

## Scrollbar
`config.ui.docs.scrollbar string`

Character used for the scrollbar