local care = {}

---@type care.core
care.core = nil

local function on_insert_enter()
    require("care.utils.log").log("On Insert Enter")
    care.core = require("care.core").new()
    care.core:setup()
end

---@type care.api
care.api = {
    is_open = function()
        return care.core and care.core.menu:is_open()
    end,
    confirm = function()
        care.core.menu:confirm()
    end,
    complete = function(source_filter)
        care.core.context = require("care.context").new(care.core.context)
        care.core:complete(2, source_filter)
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
    doc_is_open = function()
        return care.core and care.core.menu and care.core.menu:docs_visible()
    end,
    get_documentation = function()
        return (care.core and care.core.menu and care.core.menu:docs_visible())
                and vim.api.nvim_buf_get_lines(care.core.menu.docs_window.buf, 0, -1, false)
            or {}
    end,
    scroll_docs = function(delta)
        care.core.menu:scroll_docs(delta)
    end,
    set_index = function(index)
        care.core.menu.index = index
        care.core.menu:select()
    end,
    get_index = function()
        return care.core.menu.index
    end,
    ---@param index integer 1-based index of entry to select
    select_visible = function(index)
        local topline
        vim.api.nvim_win_call(care.core.menu.menu_window.winnr, function()
            topline = vim.fn.winsaveview().topline
        end)
        care.core.menu.index = topline + index - 1
        care.core.menu:select()
    end,
    is_reversed = function()
        return care.core.menu.reversed
    end,
}

---@param options? care.config
function care.setup(options)
    require("care.config").setup(options)
    require("care.sources").update_configs()
end

--- Sets up care
function care.initialize(options)
    if options then
        vim.notify("You should use `care`.setup() module to configure care", vim.log.levels.WARN)
        care.setup(options)
    end
    require("care.utils.log").log("Initial Setup")
    require("care.mappings").setup()
    require("care.highlights").setup()

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
