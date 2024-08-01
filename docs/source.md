---
title: Source
description: Type description of care.nvim source
author:
  - max397574
categories:
  - docs,
  - types
created: 2023-11-15T17:42:46+0100
updated: 2024-07-15T20:10:47+0100
tangle:
  languages:
    lua: ../lua/care/types/source.lua
  scope: tagged
  delimiter: none
version: 1.1.1
---

# General

The sources are used to get get completions for care.nvim.

# Fields

## Name

There are two fields for the name of a source. They are both strings. The `name` field is used for
configuring the source. It should just contain characters, `_`, and `-`. There is also the
`display_name` field. This name is displayed in sources overview. It can be any string.

The display name is optional and falls back to the normal name.

# Methods

## `is_available()`

Each source can have a function to show whether it's available or not. If your source should
for example be enabled for a certain filetype you can just do it like this:

```lua
function my_source.is_available()
    return vim.bo.ft == "lua"
end
```

This function will be called quite often so developers should try to keep it more or less
performant. This won't be an issue in the vast majority of cases though.

## Resolve

This is a function used to get additional details for completion items. This is especially
important for the lsp source which needs to send the `completionItem/resolve` request.
Resolving completion items is used for performance reasons so e.g. the documentation for an item
doesn't always have to be sent.

## `get_trigger_characters()`

This function should return characters which trigger completion for the source. If one of those
characters is types the completion will be retriggered. Otherwise newly entered characters are
used for sorting and filtering.
An example for this could be `.`, `\\` and `/` when working with paths.

```lua
function my_source.get_trigger_characters()
    return { ".", "\\", "/" }
end
```

## Keyword pattern

The keyword pattern is used to overwrite the keyword pattern from the config per source. It
should basically represent the format of entries the source will provide as regex.
It can either be provided as a string with `keyword_pattern` or dynamically with
`get_keyword_pattern`.
The `get_keyword_pattern` function has higher priority and will overwrite the string if provided.

## Complete

This is arguably the most important function of each source. This function returns completions.
The function takes in a [completion context](./index.md#completion-context) and should return a
list of [entries](#entrymd).
