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
        if require("care").api.is_open() then
            callback()
        else
            vim.api.nvim_feedkeys(vim.keycode(get_mapping(plug)), "n", false)
        end
    end)
end

function mappings.setup()
    -- TODO: perhaps add more
    map("<Plug>(CareConfirm)", function()
        require("care").api.confirm()
    end)

    map("<Plug>(CareSelectNext)", function()
        require("care").api.select_next(1)
    end)

    map("<Plug>(CareSelectPrev)", function()
        require("care").api.select_prev(1)
    end)

    map("<Plug>(CareClose)", function()
        require("care").api.close()
    end)
end

return mappings
