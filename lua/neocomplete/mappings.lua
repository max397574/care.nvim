local mappings = {}

function mappings.get_fallback(key)
    local lhs = ("<Plug>(NeocompleteFallback.%s)"):format(key)
    vim.keymap.set("i", lhs, key, { noremap = false })
    return function()
        vim.api.nvim_feedkeys(vim.keycode(lhs), "im", false)
    end
end

local function get_mapping(rhs)
    for _, map in pairs(vim.api.nvim_get_keymap("i")) do
        ---@diagnostic disable-next-line: undefined-field
        if type(map.rhs) == "string" and map.rhs == rhs then
            ---@diagnostic disable-next-line: undefined-field
            return map.lhs
        end
    end
end

local function map(plug, callback)
    local key = get_mapping(plug)
    vim.keymap.set("i", plug, function()
        if require("neocomplete").core.menu:is_open() then
            callback()
        else
            mappings.get_fallback(key)()
        end
    end)
end

function mappings.setup()
    map("<Plug>(NeocompleteConfirm)", function()
        require("neocomplete").core.menu:confirm()
    end)

    map("<Plug>(NeocompleteSelectNext)", function()
        require("neocomplete").core.menu:select_next(1)
    end)

    map("<Plug>(NeocompleteSelectPrev)", function()
        require("neocomplete").core.menu:select_prev(1)
    end)

    map("<Plug>(NeocompleteClose)", function()
        require("neocomplete").core.menu:close()
    end)
end

return mappings
