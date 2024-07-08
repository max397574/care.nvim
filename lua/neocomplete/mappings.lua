local mappings = {}

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
    vim.keymap.set("i", plug, function()
        if require("neocomplete").api.is_open() then
            callback()
        else
            vim.api.nvim_feedkeys(vim.keycode(get_mapping(plug)), "n", false)
        end
    end)
end

function mappings.setup()
    map("<Plug>(NeocompleteConfirm)", function()
        require("neocomplete").api.confirm()
    end)

    map("<Plug>(NeocompleteSelectNext)", function()
        require("neocomplete").api.select_next(1)
    end)

    map("<Plug>(NeocompleteSelectPrev)", function()
        require("neocomplete").api.select_prev(1)
    end)

    map("<Plug>(NeocompleteClose)", function()
        require("neocomplete").api.close()
    end)
end

return mappings
