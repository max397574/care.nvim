---
title: Core
description: Type description of care.core
---
# Core

This module is for the core of care. Here everything comes together with the
most important things being the menu being opened and the completion triggered.
# `care.core`

# Methods

## New
`Core.new(): care.core`

Use this function to create a new instance. It takes no arguments and should be
called only once when the plugin is first set up.

## Complete
`core:complete(reason: care.completionReason?): nil`

This function starts the completion. It goes through all the sources, triggers
them (completion and sorting) and opens the menu with the result.

## On Change
`core:on_change(): nil`

This function is invoked on every text change (by default, see
`completion_events` in config). It updates the context field and triggers
completion if the context changed.

## Block
`core:block(): fun(): nil`

The `block` method can be used to temporarily disable care. It returns a
function which is used to unblock it again. This is used for the `insert`
selection behavior where you don't want to get new completions when changing the
text.

## Setup
`core:setup(): nil`

The setup function is used to setup care so it will actually provide
autocompletion when typing by setting up an autocommand with the
`completion_events` from the configuration.

## Filter
`core:filter(): nil`

Filter currently visible menu. This is used when moving the cursor.
# Fields

## Context
`core.context care.context`

This is used to store the current context. There is always a new one created in
`on_change` and compared to see if it changed.

## Menu
`core.menu care.menu`

In this field a menu instance which is used in core is stored.

## Blocked
`core.blocked boolean`

This field is used by the [block()](#block) method. It just completely disables
autocompletion when set to true.

## Last Opened At
`core.last_opened_at integer`

This variable is used to determine where a new completion window was opened for
the last time. This is used to determine when to reopen the completion window.