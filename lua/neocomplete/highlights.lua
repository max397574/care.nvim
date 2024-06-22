--[[
@neocomplete: Fallback for everything
@neocomplete.type: Fallback for the type highlights (only one defined)
@neocomplete.selected: Selected entry
@neocomplete.match: Matched part of entries
--]]

-- TODO: move into function?

local hl = function(...)
    vim.api.nvim_set_hl(0, ...)
end

hl("@neocomplete", { link = "Normal", default = true })
hl("@neocomplete.type", { link = "Normal", default = true })
hl("@neocomplete.selected", { link = "Visual", default = true })
hl("@neocomplete.match", { link = "Special", default = true })
hl("@neocomplete.menu", { link = "NormalFloat", default = true })
hl("@neocomplete.scrollbar", { link = "PmenuSbar", default = true })
hl("@neocomplete.entry", { italic = true, default = true })
hl("@neocomplete.ghost_text", { link = "Comment", default = true })
