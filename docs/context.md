---
title: Index
description: Type description of context
author: 
  - max397574
categories: 
  - docs,
  - types
created: 2023-11-15T17:42:46+0100
updated: 2024-06-18T18:18:38+0100
tangle: 
  languages: 
    lua: ../lua/care/types/context.lua
  scope: tagged
  delimiter: none
version: 1.1.1
---



This is a class representing the current state. It includes buffer number and cursor position. It
is passed to completion sources to get completions.

# Methods
## Changed
Whether the context changed in comparison to the previous one. This is used to check whether to
get new completions or not.

## New
Create a new context. This takes the previous one as argument. This one is stored to determine if
the context changed or not when completing.
The previous context of the previous one is deleted so this data structure doesn't grow really
large.

# Fields
## Previous
The previous context which is used to determine whether the context changed or not.

## Cursor
The cursor positon.

## Bufnr
Number of the buffer.

## Reason
Reason for triggering completion.

## Current line
The current line.

## Line before cursor
Part of the current line which is before the cursor.
