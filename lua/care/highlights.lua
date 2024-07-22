--[[
@care: Fallback for everything
@care.type: Fallback for the type highlights (only one defined)
@care.selected: Selected entry
@care.match: Matched part of entries
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
    hl(string.format("@care.type.%s", name), { link = group, default = true })
end

hl("@care", { link = "Normal", default = true })
hl("@care.type", { link = "Normal", default = true })
hl("@care.selected", { link = "Visual", default = true })
hl("@care.match", { link = "Special", default = true })
hl("@care.menu", { link = "NormalFloat", default = true })
hl("@care.scrollbar", { link = "PmenuSbar", default = true })
hl("@care.entry", { italic = true, default = true })
hl("@care.ghost_text", { link = "Comment", default = true })
