---
title: Internal source
description: Type description of internal neovim source
author: 
  - max397574
categories: 
  - docs,
  - types
created: 2024-05-31T12:48:14+0100
updated: 2024-08-01T10:46:49+0100
tangle: 
  languages: 
    lua: ../lua/care/types/internal_source.lua
  scope: tagged
  delimiter: none
version: 1.1.1
---


# General
The internal sources are used on top of [completion sources](#sourcemd) to store additional
metadata about which the source author doesn't have to care and sometimes can't know.

## Source
This field is used to store the source written by the source author.


## Entries
In the entries field entries gotten from the source are stored. This is used to be able to sort
and filter the entries when not getting new ones.

## New
This function creates a new instance.

## Incomplete
Here a boolean is set which shows whether the source already completed all it's entries or not.
This is mostly used by sources for performance reasons.

## Get keyword pattern
This function is used to get the keyword pattern for the source. It uses the string field, the
method to get it and as fallback the one from the config.

## Get trigger characters
This function is used to get the trigger characters for the source. At the moment it just checks
if the method exists on the source and otherwise just returns an empty table.

## Get offset

With this function the offset of the source is determined. The offset describes at which point
the completions for this source start. This is required to be able to remove that text if needed
and to determine the characters used for filtering and sorting.
