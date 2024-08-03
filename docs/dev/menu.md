---
title: Menu
description: Type description of care.nvim menu
author:
  - max397574
categories:
  - docs,
  - types
---

# General

This is the main class of the care completion menu. The menu is used to display completion
entries and also contains the logic for selecting and inserting the completions.

# Internals

## Index

The index is used to determine the selected entry. It is used to get this entry when confirming
the completion.
The function to select the next and previous entries simply change this index.

# Methods

## New

Creates a new instance of the completion menu.

## Draw

Draws the menu. This includes formatting the entries with the function from the config and
setting the virtual text used to display the labels. It also adds the highlights for the selected
entry and for the matched chars.

## Is open

This is a function which can be used to determine whether the completion menu is open or not.
This is especially useful for mappings which have a fallback action when the menu isn't visible.

## Select next

This function can be used to select the next entry. It accepts a count to skip over some entries.
It automatically wraps at the bottom and jumps up again.

## Select prev

This function is used to select the previous entry analogous to [Select next](#select-next)

## Open

The `open` function is used to open the completion menu with a specified set of entries. This
includes opening the window and displaying the text.

## Close

This function closes the menu and resets some internal things.

## Get active entry

With this function you can get the currently selected entry. This can be used for the docs view
or some other api functions. It is also used when the selection is confirmed.

## Confirm

This is the function to trigger the completion with a selected entry. It gets the selected entry
closes the menu and completes.

## Complete

This function completes with a given entry. That means it removes text used for filtering
(if necessary), expands snippet with the configured function, applies text edits and lsp
commands.

## Readjust window

This function readjusts the size of the completion window without reopening it.

## Docs Visible

Checks whether docs are visible or not

## Scroll docs

Scroll up or down in the docs window by `delta` lines.

# Fields

## Menu Window

## Docs Window

## Ghost text

The ghost text instance used to draw the ghost text.

## Entries

This field is used to store all the entries of the completion menu.

## Namespace

The namespace is used to draw the extmarks and add the additional highlights.

## Config

In this field the user config is stored for easier access.

## Buffer

This is the buffer used for the menu. It's just created once when initially creating a new
instance.

## Window

Window number of the window used to display the menu. This is always newly created when the menu
gets opened and is only set if the menu is open.

## Index

The index is used to get and track the currently selected item. It gets modified by the functions
to select next and previous entry.

## Scrollbar Buffer

This field is used to store the buffer for drawing the scrollbar.
