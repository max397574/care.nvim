---
title: Source
description: Type description of care.source
---

# Source

The sources are used to get completions for care.nvim.
# `care.source`

# Methods

## Is Available
`source:is_available?(): boolean`

Each source can have a function to show whether it's available or not. If your source should
for example be enabled for a certain filetype you can just do it like this:
```lua
function my_source.is_available()
    return vim.bo.ft == "lua"
end
```
This function will be called quite often so developers should try to keep it more or less
performant. This won't be an issue in the vast majority of cases though.

## Resolve Item
`source:resolve_item?(item: lsp.CompletionItem, callback: fun(item: lsp.CompletionItem)): nil`

This is a function used to get additional details for completion items. This is especially
important for the lsp source which needs to send the `completionItem/resolve` request.
Resolving completion items is used for performance reasons so e.g. the documentation for an item
doesn't always have to be sent.

## Get Trigger Characters
`source:get_trigger_characters?(): string[]`

This function should return characters which trigger completion for the source. If one of those
characters is types the completion will be retriggered. Otherwise newly entered characters are
used for sorting and filtering.
An example for this could be `.`, `\\` and `/` when working with paths.
```lua
function my_source:get_trigger_characters()
    return { ".", "\\", "/" }
end
```

## Get Keyword Pattern
`source:get_keyword_pattern?(): string`

The `get_keyword_pattern` function has higher priority and will overwrite the string if provided.

## Complete
`source.complete(completion_context: care.completion_context, callback: fun(items: lsp.CompletionItem[], is_incomplete?: boolean)): nil`

This is arguably the most important function of each source. This function returns completions.
The function takes in a completion context and should return a
list of entries.

## Execute
`source:execute?(entry: care.entry): nil`

See [care.entry](/dev/entry)


# Fields

## Name
`source.name string`

The `name` field is used for configuring the source. It should just contain characters, `_`, and `-`.

## Display Name
`source.display_name? string`

The `display_name` of a field can be any string. This name is displayed in sources overview.
It falls back to `name`.

## Keyword Pattern
`source.keyword_pattern? string`

The keyword pattern is used to overwrite the keyword pattern from the config per source. It
should basically represent the format of entries the source will provide as regex.