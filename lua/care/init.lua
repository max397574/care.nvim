local care = {}

_G.care_debug = false

---@type care.core
care.core = nil

local function on_insert_enter()
    care.core = require("care.core").new()
    care.core:setup()
end

care.api = {
    get_fallback = function(key)
        return require("care.mappings").get_fallback(key)
    end,
    is_open = function()
        return care.core and care.core.menu:is_open()
    end,
    confirm = function()
        care.core.menu:confirm()
    end,
    complete = function()
        care.core:complete(2)
    end,
    close = function()
        care.core.menu:close()
    end,
    select_prev = function(count)
        care.core.menu:select_prev(count)
    end,
    select_next = function(count)
        care.core.menu:select_next(count)
    end,
    jump_to_entry = function(index)
        care.core.menu.index = index
    end,
    doc_is_open = function()
        return care.core and care.core.menu and care.core.menu:docs_visible()
    end,
    scroll_docs = function(delta)
        care.core.menu:scroll_docs(delta)
    end,
    set_index = function(index)
        care.core.menu.index = index
    end,
}

--- Sets up care
function care.setup(options)
    require("care.mappings").setup()
    require("care.config").setup(options)
    require("care.highlights")

    local augroup = vim.api.nvim_create_augroup("care", {})
    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            on_insert_enter()
        end,
        once = true,
        group = augroup,
    })
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            care.api.close()
        end,
    })
end

return care
