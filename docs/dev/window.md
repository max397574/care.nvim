---
title: Window Util
description: Type description of care.window, care.window.data
---

# Window Util

Utility class for working with windows in care
# `care.window`

# Methods

## New
`Window.new(): care.window`

See [care.window](/dev/window)

Creates a new instance of the menu window

## Is Open
`window:is_open(): boolean`

Method to check whether the window is open or not

## Scrollbar Is Open
`window:scrollbar_is_open(): boolean`

Method to check whether the scrollbar window is open or not

## Readjust
`window:readjust(content_len: integer, width: integer, offset: integer): nil`

Adjust the window size to new entries. Modifies height and width while keeping position

## Open Scrollbar Win
`window:open_scrollbar_win(width: integer, height: integer, offset: integer): nil`

Opens the window for the scrollbar

## Close
`window:close(): nil`

Closes the window and the scrollbar window and resets fields

## Set Scroll
`window:set_scroll(index: integer, direction: integer): nil`

Sets the scroll of the window

## Open Cursor Relative
`window:open_cursor_relative(width: integer, wanted_height: integer, offset: integer, config: care.config.ui.docs|care.config.ui.menu): nil`

Opens a new main window

## Draw Scrollbar
`window:draw_scrollbar(): nil`

Draw the scrollbar for the window if needed

## Scroll
`window:scroll(delta: integer)`

Change scroll of window

## Get Data
`window:get_data(): care.window.data`

See [care.window](/dev/window)


# Fields

## Winnr (optional)
`window.winnr? integer`



## Config
`window.config care.config`

Instance of the care config

## Buf
`window.buf integer`



## Position (optional)
`window.position? "above"|"below"`

Whether the window is currently opened above or below the cursor

## Scrollbar
`window.scrollbar {win: integer, buf: integer}`

Data for the scrollbar of the window

## Max Height
`window.max_height integer`

The maximum available height where the window is currently open

## Opened At
`window.opened_at {row: integer, col: integer}`

Where the window was last opened

## Ns
`window.ns integer`

Namespace used for setting extmarks

## Current Scroll
`window.current_scroll integer`

Current scroll of the window


# `care.window.data`

# Fields

## First Visible Line
`window.data.first_visible_line integer`



## Last Visible Line
`window.data.last_visible_line integer`



## Visible Lines
`window.data.visible_lines integer`



## Height Without Border
`window.data.height_without_border integer`



## Width Without Border
`window.data.width_without_border integer`



## Border
`window.data.border any`



## Has Border
`window.data.has_border boolean`



## Width With Border
`window.data.width_with_border integer`



## Height With Border
`window.data.height_with_border integer`



## Total Lines
`window.data.total_lines integer`

