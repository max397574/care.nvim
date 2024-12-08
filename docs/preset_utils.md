---
title: Preset Utils
description: Type description of care.preset_utils
---

# Preset Utils

This module contains lower level utilities for the presets and the preset components.
# `care.preset_utils`

# Methods

## Label Entries
`preset_utils.label_entries(labels: string[]): fun(_,data: care.format_data): string`

This function can be used to get a function to label the entries with shortscuts as [described
here](/configuration_recipes#labels-and-shortcuts).

## Get Color
`preset_utils.get_color(entry: care.entry): string?`

See [care.entry](/dev/entry)

With this function you can get a color if the entry is a color and the hex color code is available in the
completion item.

## Get Highlight For Hex
`preset_utils.get_highlight_for_hex(hex: string): string`

This function allows to get a highlight group for a certain hex color code. This is useful because like that the
user doesn't have to constantly create new highlight groups to apply a hex value to a certain thing. The
highlight group will have the hex value as foregroung color.

## Kind Highlight
`preset_utils.kind_highlight(entry: care.entry, style: "fg"|"blended"): string`

See [care.entry](/dev/entry)

With this function you can get the kind highlight group for a specific entry. The style can either be foreground
or blended.

## Get Label Detail
`preset_utils.get_label_detail(entry: care.entry): string`

See [care.entry](/dev/entry)

Gets the label detail if provided by the language serve.
This is equivalent to the `vim_item.menu` from nvim-cmp