---
title: Menu
description: Type description of care.menu
---

# Menu

This is the main class of the care completion menu. The menu is used to display
completion entries and also contains the logic for selecting and inserting the
completions.
# `care.menu`

# Methods

## New
`menu.new`
Creates a new instance of the completion menu.

## Draw
`menu.draw`
Draws the menu. This includes formatting the entries with the function from the
config and setting the virtual text used to display the labels. It also adds the
highlights for the selected entry and for the matched chars.

## Is Open
`menu.is_open`
This is a function which can be used to determine whether the completion menu is
open or not. This is especially useful for mappings which have a fallback action
when the menu isn't visible.

## Select Next
`menu.select_next`
This function can be used to select the next entry. It accepts a count to skip
over some entries. It automatically wraps at the bottom and jumps up again.

## Select Prev
`menu.select_prev`
This function is used to select the previous entry analogous to
[Select next](#select-next)

## Open
`menu.open`
The `open` function is used to open the completion menu with a specified set of
entries. This includes opening the window and displaying the text.

## Close
`menu.close`
This function closes the menu and resets some internal things.

## Get Active Entry
`menu.get_active_entry`
With this function you can get the currently selected entry. This can be used
for the docs view or some other api functions. It is also used when the
selection is confirmed.

## Confirm
`menu.confirm`
This is the function to trigger the completion with a selected entry. It gets
the selected entry closes the menu and completes.

## Complete
`menu.complete`
This function completes with a given entry. That means it removes text used for
filtering (if necessary), expands snippet with the configured function, applies
text edits and lsp commands.

## Readjust Win
`menu.readjust_win`
This function readjusts the size of the completion window without reopening it.

## Docs Visible
`menu.docs_visible`
Checks whether docs are visible or not

## Scroll Docs
`menu.scroll_docs`
Scroll up or down in the docs window by `delta` lines.

## Select
`menu.select`
This method is used for selection. It's called in `select_prev` and `select_next` and is responsible
for redrawing the menu, opening documentation and inserting the selected entry if required.
Direction can either be 1 (down) or -1 (up)

## Draw Docs
`menu.draw_docs`
Opens the documentation window for a selected entry
# Fields

## Menu Window
`menu.menu_window`
Wrapper for utilities for the window of the menu

## Docs Window
`menu.docs_window`
Wrapper for utilities for the window of the docs

## Ghost Text
`menu.ghost_text`
The ghost text instance used to draw the ghost text.

## Entries
`menu.entries`
This field is used to store all the entries of the completion menu.

## Ns
`menu.ns`
The namespace is used to draw the extmarks and add the additional highlights.

## Config
`menu.config`
In this field the user config is stored for easier access.

## Buf
`menu.buf`
This is the buffer used for the menu. It's just created once when initially
creating a new instance.

## Index
`menu.index`
The index is used to determine the selected entry. It is used to get this entry
when confirming the completion. The function to select the next and previous
entries simply change this index.

## Scrollbar Buf
`menu.scrollbar_buf`
This field is used to store the buffer for drawing the scrollbar.

## Reversed
`menu.reversed`
Indicates if the menu is reversed (window above cursor and sorting_direction away from cursor)