---
title: Misc
description: Misc types
author: 
  - max397574
categories: 
  - docs,
  - types
created: 2024-05-29T11:30:25+0100
updated: 2024-06-08T18:52:40+0100
tangle: 
  languages: 
    lua: ../lua/care/types/misc.lua
  scope: tagged
  delimiter: none
version: 1.1.1
---



# Completion context
The completion context describes the current context. It's used so not every source has again to
determine e.g. where the cursor is in the file and what text was typed. The completion context
required by the lsp is part of this context.

# Reason
This type is used in the core to determine why completion was triggered. This is important because
if completion was triggered automatically it will only fetch new completions if there aren't any
or if a trigger character was typed. Otherwise it will just sort existing ones.
