---
title: Developers
description: Ressources to devlop care.nvim or sources for it
---

# Developer documentation

This is the internal documentation of the care.nvim code base. It also includes
documentation for developing sources for care.nvim.

If you want to contribute you should read the
[code style documentation](./code_style).

## Conventions used

For describing classes there is always a section for methods (functions) and one
for fields. The name and how to use the method/function is normally written
directly after the respective heading. Capital letters are used for accessing
the classes as lua modules (e.g. `Context.new`) and lowercase letters for
instances (e.g. `context.previous`). This should also be done in the codebase
like this.

A `.` or `:` indicates if the function is a method or a function. It also has to
be used this way.

After the `:` the return type of functions or the type of fields is indicated
(e.g. `context:changed(): bool`).
