---
title: API
description: Description of the external api provided by care.nvim
---

# Care.nvim API

All the api can be accessed with the following code:

```lua
require("care").api
```

From now on this will just be written as `Api`.

# Is open

The function `Api.is_open()` returns a boolean which indicates whether the
completion menu is currently open or not. This is especially useful for mappings
which should fallback to other actions if the menu isn't open.

# Confirm

With `Api.confirm()` you can confirm the currently selected entry. Note that
there is also `<Plug>(CareConfirm)` which should preferably be used in mappings.

# Complete

The function `Api.Complete` can be used to manually complete.

# Close

Use the function `Api.close()` to close the completion menu. There also is the
`<Plug>(CareClose)` mapping which does the same thing.

# Select next

Use `Api.select_next(count)` to select the next entry. Count determines how much
the selection should move. It defaults to 1. `<Plug>(CareSelectNext)` can also
be used to select the next entry.

# Select prev

Same as above but for the previous entry.

# Doc is open

The function `Api.doc_is_open` returns a boolean to indicate whether a
documentation window is open. This is especially useful together with the
function to scroll docs to only trigger the mapping in certain cases.

```lua
if require("care").api.doc_is_open() then
    require("care").api.scroll_docs(4)
else
    ...
end
```

# Scroll docs

Use `Api.scroll_docs(delta)` to scroll docs by `delta` lines. When a negative
delta is provided the docs will be scrolled upwards.

# Set index

With the function `Api.set_index(index)` the index which represents which entry
is selected can be directly set. This allows to jump anywhere in the completion
menu.

# Select visible

The function `Api.select_visible(index)` is used to select the entry at index
`index` where `index` indicates the visible position in the menu.

This is really useful to create shortcuts to certain entries like in the
[example in configuration recipes](/configuration_recipes#labels-and-shortcuts).
