---
title: Preset Components
description: Type description of care.preset_components
---

# Preset Components

This module contains some high-level components for easily creating `format_entry` functions.
# `care.preset_components`

# Methods

## ShortcutLabel
`preset_components.ShortcutLabel`
This adds a label for shortcuts [described here](/configuration_recipes#labels-and-shortcuts). By default this will
use the `Comment` highlight group. This can be overridden though.
![image](https://github.com/user-attachments/assets/c476d4e4-9cee-4168-96a5-08a7492f08a8)

## KindIcon
`preset_components.KindIcon`
This components displays a kind icon. You can choose between the blended and foreground style.
![image](https://github.com/user-attachments/assets/aea84adf-578d-401d-bbbc-911198357a13)
![image](https://github.com/user-attachments/assets/9d4918e7-2f5b-491e-a21e-8213d705b8a0)

## Label
`preset_components.Label`
This adds a completion item label to be displayed. Optionally this can also include a colored block if the items
is a color and we know the value of the color.
![image](https://github.com/user-attachments/assets/28415670-8799-45fa-b175-cd1d643b2cd4)

## ColoredBlock
`preset_components.ColoredBlock`
This component adds a colored block for the item if it is a color. The character used for the block can
optionally be configured.
![image](https://github.com/user-attachments/assets/e6bf8620-92af-4ffa-8973-635cab7beec4)