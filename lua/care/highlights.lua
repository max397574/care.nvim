--[[
@care: Fallback for everything
@care.type: Fallback for the type highlights (only one defined)
@care.selected: Selected entry
@care.match: Matched part of entries
--]]

--- Gets red, green and blue values for color
---@param color string @#RRGGBB
---@return table
local function get_color_values(color)
    local red = tonumber(color:sub(2, 3), 16)
    local green = tonumber(color:sub(4, 5), 16)
    local blue = tonumber(color:sub(6, 7), 16)
    return { red, green, blue }
end

local function blend_colors(top, bottom, alpha)
    local top_rgb = get_color_values(top)
    local bottom_rgb = get_color_values(bottom)
    local function blend(c)
        c = (alpha * top_rgb[c] + ((1 - alpha) * bottom_rgb[c]))
        return math.floor(math.min(math.max(0, c), 255) + 0.5)
    end
    return ("#%02X%02X%02X"):format(blend(1), blend(2), blend(3))
end

local hl = function(...)
    vim.api.nvim_set_hl(0, ...)
end

local M = {}

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

local function setup_highlights()
    for name, group in pairs(kinds) do
        local highlights = vim.api.nvim_get_hl(0, { name = group, link = false })
        local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
        local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
        local fg = string.format("#%06x", highlights.fg or normal_float.fg or normal.fg)
        hl(string.format("@care.type.%s", name), { link = group, default = true })
        hl(string.format("@care.type.fg.%s", name), { fg = fg, default = true })
        hl(string.format("@care.type.blended.%s", name), {
            fg = fg,
            bg = blend_colors(fg, string.format("#%06x", normal_float.bg or normal.bg), 0.15),
            default = true,
        })
    end

    hl("@care", { link = "Normal", default = true })
    hl("@care.type", { link = "Normal", default = true })
    hl("@care.selected", { link = "Visual", default = true })
    hl("@care.match", { link = "Special", default = true })
    hl("@care.menu", { link = "NormalFloat", default = true })
    hl("@care.scrollbar", { link = "PmenuSbar", default = true })
    hl("@care.entry", { italic = true, default = true })
    hl("@care.ghost_text", { link = "Comment", default = true })
    hl("@care.scrollbar.thumb", { link = "PmenuSbar", default = true })
end

function M.setup()
    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function()
            for name, _ in pairs(kinds) do
                hl(string.format("@care.type.%s", name), {})
                hl(string.format("@care.type.fg.%s", name), {})
                hl(string.format("@care.type.blended.%s", name), {})
            end
            hl("@care", {})
            hl("@care.type", {})
            hl("@care.selected", {})
            hl("@care.match", {})
            hl("@care.menu", {})
            hl("@care.scrollbar", {})
            hl("@care.entry", {})
            hl("@care.ghost_text", {})
            hl("@care.scrollbar.thumb", {})
        end,
    })

    setup_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            setup_highlights()
        end,
    })
end

return M
