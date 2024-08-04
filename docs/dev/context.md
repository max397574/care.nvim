---
title: Context
description: The context type in care.nvim
---

# Context

This is a class representing the current state. It includes buffer number and
cursor position. It is passed to completion sources to get completions.

# Methods

## Changed

`context:changed(): bool`

Whether the context changed in comparison to the previous one. This is used to
check whether to get new completions or not when using autocompletion.

## New

`Context.new(): care.context`

Create a new context. This takes a previous context as argument. This one is
stored to determine if the context changed or not when completing. The previous
context of the previous one is deleted so this data structure doesn't grow
really large.

# Fields

## Previous

`context.previous: care.context`

The previous context which is used to determine whether the context changed or
not. The `previous` field of the previous context should always be `nil` so the
data structure doesn't grow infinitely.

## Cursor

`context.cursor: {row: integer, col: integer}`

The cursor position. This will have a `col` and a `row` field and has 1-based
line and 0-based column indexes. This is the same as in
`nvim_win_{get, set}_cursor()` (`:h api-indexing`).

## Bufnr

`context.bufnr: integer`

Number of the buffer.

## Reason

`context.reason: 1|2`

Reason for triggering completion. This is a `completionReason` so either 1 for
automatic triggering and 2 for manual triggering.

## Current line

`context.current_line: string`

The complete line on which the cursor was when the context was created.

## Line before cursor

`context.line_before_cursor: string`

The line before the cursor. This is mostly important to be correct in insert
mode. In normal mode the character on which the cursor is is not included.
