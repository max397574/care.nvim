---
title: Core
description: Type description of care.nvim source
author: 
  - max397574
categories: 
  - docs,
  - types
created: 2023-11-15T17:42:46+0100
updated: 2024-07-10T21:06:51+0100
tangle: 
  languages: 
    lua: ../lua/care/types/core.lua
  scope: tagged
  delimiter: none
version: 1.1.1
---


# General
This module is for the core of care. There all comes together with the menu being opened
and the completion triggered.

## New
Use this function to create a new instance.

# Methods
## Complete
This function starts the completion. It goes through all the sources, triggers them (completion
or sorting) and opens the menu with the result.

## On Change
This function is invoked on every text change. It updates the context field and triggers
completion if it changed.

## Block
The `block` method can be used to temporarily disable care. It returns a function which is
used to unblock it again.
This is used for the `insert` selection behavior where you don't want to get new completions when
changing the text.

## Setup
The setup function is used to setup care so it will actually provide autocompletion when
typing by setting up an autocommand.

# Fields
## Context
This is used to store the current context. There is always a new one created in `on_change` and
compared to see if it changed.

## Menu
In this field a menu instance which is used in core is stored.

## Blocked
This field is used by the [Block](#block) method. It just completely disables autocompletion when set
to true.

## Last opened at
This variable is used to determine where a new completion window was opened for the last time.
This is used to determine when to reopen the completion window.
