---
title: Entry
description: Type description of care.nvim entry
author: 
  - max397574
categories: 
  - docs,
  - types
created: 2023-11-15T17:42:46+0100
updated: 2024-07-15T19:07:45+0100
tangle: 
  languages: 
    lua: ../lua/care/types/entry.lua
  scope: tagged
  delimiter: none
version: 1.1.1
---


# General

Entries are the basic items in the completion menu. Arguably the most important field is the
completion item for which the lsp type is used.

# Methods
## New
The new function is the constructor for a new completion entry.

## Get insert text
This function is used to get the text that will be inserted for the entry. This is important for
the ghost text.

## Get insert word
This function is used to get part of the text that will be inserted for the entry. It just uses
a pattern to match the insert text and get the beginning of it which matches a vim `word`. This
is often e.g. the method name but without the parentheses and parameter names. That function is
used for the `insert` selection behavior.

# Fields
## Source
This is the source from which the entry came. This is important for using the right keyword
pattern and getting the right offset.

## Context
This is the context in which the entry was completed. This is important to now what context text-
edits of the entry target.

## Matches
Position of matches which were found during filtering. This is just used to highlight them in the
completion menu with `@care.match`.

## Score
This is the score obtained from filtering. It is used to sort which happens in the
`care.sorter` module.

## Get Offset
Essentially where entry insertion should happen (column)
