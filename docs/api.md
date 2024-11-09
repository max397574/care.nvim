---
title: API
description: API documentation for care.nvimcare.api
---

# API

The API for care. This should be used for most interactions with the plugins.
The api can be accessed with the following code
---
```lua
local care_api = require("care").api
```
# `care.api`

# Methods

## Is Open
`api.is_open(): boolean`

This function returns a boolean which indicates whether the
completion menu is currently open or not. This is especially useful for mappings
which should fallback to other actions if the menu isn't open.

## Confirm
`api.confirm(): nil`

Used to confirm the currently selected entry. Note that
there is also `<Plug>(CareConfirm)` which should preferably be used in mappings.

## Complete
`api.complete(source_filter?: fun(name: string): boolean): nil`

This function is used to manually trigger completion

## Close
`api.close(): nil`

Closes the completion menu and documentation view if it is open.
For mappings `<Plug>(CareClose)` should be used.

## Select Next
`api.select_next(count: integer): nil`

Select next entry in completion menu. If count is provided the selection
will move down `count` entries.
For mappings `<Plug>(CareSelectNext)` can be used where count defaults to 1.

## Select Prev
`api.select_prev(count: integer): nil`

Select next entry in completion menu. If count is provided the selection
will move up `count` entries.
For mappings `<Plug>(CareSelectPrev)` can be used where count defaults to 1.

## Doc Is Open
`api.doc_is_open(): boolean`

Indicates whether there is a documentation window open or not.
This is especially useful together with the
function to scroll docs to only trigger the mapping in certain cases.
```lua
if require("care").api.doc_is_open() then
    require("care").api.scroll_docs(4)
else
    ...
end
```

## Scroll Docs
`api.scroll_docs(delta: integer): nil`

Use `scroll_docs(delta)` to scroll docs by `delta` lines. When a negative
delta is provided the docs will be scrolled upwards.

## Set Index
`api.set_index(index: integer): nil`

Allows the index which represents which entry is selected to be directly set.
This allows to jump anywhere in the completion menu.

## Get Index
`api.get_index(): integer`

Returns the index of the currently selected entry, 0 representing no selection.
This is e.g. useful to determine if an entry is selected:
```lua
local has_selection = function()
    return require("care").api.get_index() ~= 0
end
```

## Select Visible
`api.select_visible(index: integer): nil`

This function is used to select the entry at index `index` where `index`
indicates the visible position in the menu.
This is really useful to create shortcuts to certain entries like in the
[Example usage](/configuration_recipes#labels-and-shortcuts).

## Is Reversed
`api.is_reversed(): boolean`

Indicated whether the menu is reversed
Only relevant when using sorting direction "away-from-cursor"

## Get Documentation
`api.get_documentation(): string[]`

Get the documentation of the currently selected entry.
Will return an empty table if no documentation is available.
[Example usage](/configuration_recipes#access-documentation)