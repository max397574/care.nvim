--- The internal sources are used on top of [completion sources](#source) to store additional
--- metadata about which the source author doesn't have to care and sometimes can't know.
---@class care.internal_source
--- This field is used to store the source written by the source author.
---@field source care.source
--- In the entries field entries gotten from the source are stored. This is used to be able to sort
--- and filter the entries when not getting new ones.
---@field entries care.entry[]
--- This function creates a new instance.
---@field new fun(completion_source: care.source): care.internal_source
--- Here a boolean is set which shows whether the source already completed all it's entries or not.
--- This is mostly used by sources for performance reasons.
---@field incomplete boolean
--- This function is used to get the keyword pattern for the source. It uses the string field, the
--- method to get it and as fallback the one from the config.
---@field get_keyword_pattern fun(self: care.internal_source): string
--- With this function the offset of the source is determined. The offset describes at which point
--- the completions for this source start. This is required to be able to remove that text if needed
--- and to determine the characters used for filtering and sorting.
---@field get_offset fun(self: care.internal_source, context: care.context): integer
--- This function is used to get the trigger characters for the source. At the moment it just checks
--- if the method exists on the source and otherwise just returns an empty table.
---@field get_trigger_characters fun(self: care.internal_source): string[]
--- The configuration for the source
---@field config care.config.source
--- This function checks whether the function is enabled or not based on it's config.
---@field is_enabled fun(self: care.internal_source): boolean
--- Executes a function for an entry after completion
--- This can e.g. be used for snippet expansion by a source
---@field execute fun(self: care.internal_source, entry: care.entry)
