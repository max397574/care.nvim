---
title: Presets
description: Type description of care.presets
---

# Presets

In this module some presets for the format_entry function are available. They can be accessed like this
```lua
format_entry = function(entry, data)
return require("care.presets").<preset_name>(entry, data)
end
```
# `care.presets`

# Methods

## Default
`presets.Default`
The default preset. Just includes the label and a simple icon.
![image](https://github.com/user-attachments/assets/d3d7d338-db32-471f-ae20-89ea7703cb55)

## Atom
`presets.Atom`
The atom preset is an atom-like configuration. It displays the kind icon with a blended colored background and
the label.
![image](https://github.com/user-attachments/assets/f8715fa7-1a0e-4be9-85ae-14b85cc2b7fd)