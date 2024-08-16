---
title: Internal Source
description: Type description of care.internal_source
---
# Internal Source

# `care.internal_source`

# Methods

## New
`Internal_source.new(completion_source: care.source): care.internal_source`

This function creates a new instance.

## Get Keyword Pattern
`internal_source:get_keyword_pattern(): string`

This function is used to get the keyword pattern for the source. It uses the string field, the
method to get it and as fallback the one from the config.

## Get Offset
`internal_source:get_offset(context: care.context): integer`

With this function the offset of the source is determined. The offset describes at which point
the completions for this source start. This is required to be able to remove that text if needed
and to determine the characters used for filtering and sorting.

## Get Trigger Characters
`internal_source:get_trigger_characters(): string[]`

This function is used to get the trigger characters for the source. At the moment it just checks
if the method exists on the source and otherwise just returns an empty table.

## Is Enabled
`internal_source:is_enabled(): boolean`

This function checks whether the function is enabled or not based on it's config.
# Fields

## Source
`internal_source.source care.source`

This field is used to store the source written by the source author.

## Entries
`internal_source.entries care.entry[]`

In the entries field entries gotten from the source are stored. This is used to be able to sort
and filter the entries when not getting new ones.

## Incomplete
`internal_source.incomplete boolean`

Here a boolean is set which shows whether the source already completed all it's entries or not.
This is mostly used by sources for performance reasons.

## Config
`internal_source.config care.config.source`

The configuration for the source