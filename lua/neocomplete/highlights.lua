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

local kinds = {
    Text = "@string",
    Method = "@function.method",
    Function = "@function",
    Constructor = "@constructor",
    Field = "@property",
    Variable = "@variable",
    Class = "@type",
    Interface = "@type",
    Module = "@module",
    Property = "@property",
    Unit = "@constant",
    Value = "@boolean",
    Enum = "@constant",
    Keyword = "@keyword",
    Snippet = "@keyword",
    Color = "@string.special",
    File = "@string.special.url",
    Reference = "@property",
    Folder = "@string.special.url",
    EnumMember = "@variable.member",
    Constant = "@constant",
    Struct = "@type",
    Event = "@string.special",
    Operator = "@operator",
    TypeParameter = "@type",
}

for name, group in pairs(kinds) do
    hl(string.format("@neocomplete.type.%s", name), { link = group, default = true })
end

hl("@neocomplete", { link = "Normal", default = true })
hl("@neocomplete.type", { link = "Normal", default = true })
hl("@neocomplete.selected", { link = "Visual", default = true })
hl("@neocomplete.match", { link = "Special", default = true })
hl("@neocomplete.menu", { link = "NormalFloat", default = true })
hl("@neocomplete.scrollbar", { link = "PmenuSbar", default = true })
hl("@neocomplete.entry", { italic = true, default = true })
hl("@neocomplete.ghost_text", { link = "Comment", default = true })
