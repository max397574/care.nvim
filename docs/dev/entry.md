---
title: Entry
description: Type description of care.entry
---

# Entry

Entries are the basic items in the completion menu. Arguably the most important field is the
completion item for which the lsp type is used.
# `care.entry`

# Methods

## New
`entry.new`
The new function is the constructor for a new completion entry.

## Get Insert Text
`entry.get_insert_text`
This function is used to get the text that will be inserted for the entry. This is important for
the ghost text.

## Get Insert Word
`entry.get_insert_word`
This function is used to get part of the text that will be inserted for the entry. It just uses
a pattern to match the insert text and get the beginning of it which matches a vim `word`. This
is often e.g. the method name but without the parentheses and parameter names. That function is
used for the `insert` selection behavior.

## Get Offset
`entry.get_offset`
Essentially where entry insertion should happen (column, 0-based)

## Get Insert Range
`entry.get_insert_range`
Gets the range for inserting the entry (insert of InsertReplaceEdit)

## Get Replace Range
`entry.get_replace_range`
Gets the range for inserting the entry (insert of InsertReplaceEdit)

##  Get Default Range
`entry._get_default_range`
Gets the default range for entry (if there is no textEdit)
# Fields

## Completion Item
`entry.completion_item`


## Source
`entry.source`
This is the source from which the entry came. This is important for using the right keyword
pattern and getting the right offset.

## Context
`entry.context`
This is the context in which the entry was completed. This is important to now what context text-
edits of the entry target.

## Matches
`entry.matches`
Position of matches which were found during filtering. This is just used to highlight them in the
completion menu with `@care.match`.

## Score
`entry.score`
This is the score obtained from filtering. It is used to sort which happens in the
`care.matcher` module.