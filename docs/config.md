---
title: Source
description: Type description of care.nvim config
author:
  - max397574
categories:
  - docs,
  - types
---

# General

The config of care is used to configure the ui and care itself.

There are two main parts to the config. The first one is the `ui` field and the second on is the
rest of the configuration which is for configuring care itself.

## UI

In the ui field the completion menu, the docs view and the format of the entries are configured.
There is also a field for configuring type icons.

## Snippet expansion

Here a function for expanding snippets is defined. By default this is the builtin
`vim.snippet.expand()`. You can also use a plugin like luasnip for this like this:

```lua
snippet_expansion = function(body)
    require("luasnip").lsp_expand(body)
end
```

## Selection behavior

With the selection behavior the user can determine what happens when selecting an entry. This can
either be `"select"` or `"insert"`. Selecting will just select the entry and do nothing else. Insert
will actually insert the text of the entry (this is not necessarily the whole text).

## Keyword pattern

Pattern used to determine keywords, used to determine what to use for filtering and what to
remove if insert text is used.

## Completion events

The `completion_events` table is used to set events for completion. By default it just contains
`"TextChangedI"`. You can set it to an empty table (`{}`) to disable autocompletion.

## Sources

TODO

## Preselect

Whether items should be preselected or not

## Enabled

This function can be used to disable care in certain contexts. By default this disables
care in prompts.

# UI

The ui configuration is used to configure the whole ui of care. One of the main goals of
this is to be as extensible as possible. This is especially important for the completion entries.
Read more about that under [Configuraton of item display](./design.md#configuraton-of-item-display).

The most important part for many users will be the `menu` field. It's used to configure the
completion menu.

You can also configure the documentation view just like the main menu.

Lastly the users can also configure the icons which will be used for the different items.

## Ghost text

with this option the user can determine if ghost text should be displayed. Ghost text is just
virtual text which shows a preview of the entry.

You can use the `enabled` field to determine whether the ghost text should be enabled or not.
The `position` can either be `"inline"` or `"overlay"`. Inline will add the text inline right
where the cursor is. With the overlay position the text will overlap with existing text after the
cursor.

## Menu

This configuration should allow you to completely adapt the completion menu to your likings.

It includes some basic window properties like the border and the maximum height of the window. It
also has a field to define the character used for the scrollbar.
Set `scrollbar` to `nil` value to disable the scrollbar.

## Position

If the menu should be displayed on top, bottom or automatically

Another field is `format_entry`. This is a function which recieves an entry of the completion
menu and determines how it's formatted. For that a table with text-highlight chunks like
`:h nvim_buf_set_extmarks()` is used. You can create sections which are represented by tables
and can have a different alignment each. This is specified with another field which takes a table
with the alignment of each section.

For example you want to have the label of an entry in a red highlight and an icon in a entry-kind
specific color left aligned first and then the source of the entry right aligned in blue.
You could do that like this:

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

Notice that there are multiple differences between having one table containing the chunks for the
label and kind and having them separately. The latter would require another entry in the `alignment`
table. It would also change the style of the menu because the left sides of the icons would be
aligned at the same column and not be next to the labels. In the example there also was some
spacing added in between the two.

## Documentation view

This configuration allows you to configure the documentation view.
It consists of some basic window properties like the border and the maximum height of the window.
It also has a field to define the character used for the scrollbar.

## Type Icons

This is a table which defines the different icons.
