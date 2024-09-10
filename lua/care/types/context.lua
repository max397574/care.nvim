--- This is a class representing the current state. It includes buffer number and
--- cursor position. It is passed to completion sources to get completions.
---@class care.context
--- Whether the context changed in comparison to the previous one. This is used to
--- check whether to get new completions or not when using autocompletion.
---@field changed fun(care.context): boolean
--- Create a new context. This takes a previous context as argument. This one is
--- stored to determine if the context changed or not when completing. The previous
--- context of the previous one is deleted so this data structure doesn't grow
--- really large.
---@field new fun(previous: care.context?): care.context
--- The previous context which is used to determine whether the context changed or
--- not. The `previous` field of the previous context should always be `nil` so the
--- data structure doesn't grow infinitely.
---@field previous care.context?
--- The cursor position. This will have a `col` and a `row` field and has 1-based
--- line and 0-based column indexes. This is the same as in
--- `nvim_win_{get, set}_cursor()` (`:h api-indexing`).
---@field cursor care.context.cursor
--- Number of the buffer.
---@field bufnr integer
--- Reason for triggering completion. This is a `completionReason` so either 1 for
--- automatic triggering and 2 for manual triggering.
---@field reason care.completionReason?
--- The complete line on which the cursor was when the context was created.
---@field line string
--- The line before the cursor. This is mostly important to be correct in insert
--- mode. In normal mode the character on which the cursor is is not included.
---@field line_before_cursor string

--- A cursor position
---@class care.context.cursor
--- 1-based line index
---@field row integer
--- 0-based column index
---@field col integer
