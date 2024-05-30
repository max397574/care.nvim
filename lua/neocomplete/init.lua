local neocomplete = {}

---@type neocomplete.core
neocomplete.core = nil

local function on_insert_enter()
    neocomplete.core = require("neocomplete.core").new()
    neocomplete.core:setup()
end

--- Sets up neocomplete
function neocomplete.setup()
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
