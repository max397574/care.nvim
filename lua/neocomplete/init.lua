local neocomplete = {}

---@type neocomplete.core
neocomplete.core = nil

local function on_insert_enter()
    neocomplete.core = require("neocomplete.core").new()
    neocomplete.core:setup()
end

neocomplete.mappings = {
    get_fallback = function(key)
        return require("neocomplete.mappings").get_fallback(key)
    end,
    is_open = function()
        return neocomplete.core and neocomplete.core.menu:is_open()
    end,
    confirm = function()
        neocomplete.core.menu:confirm()
    end,
    close = function()
        neocomplete.core.menu:close()
    end,
    select_prev = function(count)
        neocomplete.core.menu:select_next(count)
    end,
    select_next = function(count)
        neocomplete.core.menu:select_prev(count)
    end,
}

--- Sets up neocomplete
function neocomplete.setup()
    require("neocomplete.mappings").setup()
    require("neocomplete.config").setup()
    require("neocomplete.highlights")

    local augroup = vim.api.nvim_create_augroup("neocomplete", {})
    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            on_insert_enter()
        end,
        once = true,
        group = augroup,
    })
end

return neocomplete
