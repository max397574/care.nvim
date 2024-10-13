---
title: Window Util
description: Type description of care.window, care.window.data
---

# Window Util

Utility class for working with windows in care
# `care.window`

# Methods

## New
`window.new`
Creates a new instance of the menu window

## Is Open
`window.is_open`
Method to check whether the window is open or not

## Scrollbar Is Open
`window.scrollbar_is_open`
Method to check whether the scrollbar window is open or not

## Readjust
`window.readjust`
Adjust the window size to new entries. Modifies height and width while keeping position

## Open Scrollbar Win
`window.open_scrollbar_win`
Opens the window for the scrollbar

## Close
`window.close`
Closes the window and the scrollbar window and resets fields

## Set Scroll
`window.set_scroll`
Sets the scroll of the window

## Open Cursor Relative
`window.open_cursor_relative`
Opens a new main window

## Draw Scrollbar
`window.draw_scrollbar`
Draw the scrollbar for the window if needed

## Scroll
`window.scroll`
Change scroll of window

## Get Data
`window.get_data`

# Fields

## Winnr (optional)
`window.winnr?`


## Config
`window.config`
Instance of the care config

## Buf
`window.buf`


## Position (optional)
`window.position?`
Whether the window is currently opened above or below the cursor

## Scrollbar
`window.scrollbar`
Data for the scrollbar of the window

## Max Height
`window.max_height`
The maximum available height where the window is currently open

## Opened At
`window.opened_at`
Where the window was last opened

## Ns
`window.ns`
Namespace used for setting extmarks

## Current Scroll
`window.current_scroll`
Current scroll of the window


# `care.window.data`

# Fields

## First Visible Line
`window.data.first_visible_line`


## Last Visible Line
`window.data.last_visible_line`


## Visible Lines
`window.data.visible_lines`


## Height Without Border
`window.data.height_without_border`


## Width Without Border
`window.data.width_without_border`


## Border
`window.data.border`


## Has Border
`window.data.has_border`


## Width With Border
`window.data.width_with_border`


## Height With Border
`window.data.height_with_border`


## Total Lines
`window.data.total_lines`
