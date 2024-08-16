--- Context provided to completion sources
---@class care.completion_context
---@field completion_context lsp.CompletionContext
---@field context care.context

--- Reason for triggering completion
---@alias care.completionReason
---| 1 # Auto
---| 2 # Manual

--- The icons used for the different completion item types
---@alias care.config.ui.type_icons table<string, string>
