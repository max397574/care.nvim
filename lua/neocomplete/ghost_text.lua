local ghost_text = {}

local ns = vim.api.nvim_create_namespace("neocomplete.ghost_text")

---@param entry neocomplete.entry
---@param offset integer
function ghost_text.show(entry, offset)
    -- TODO: allow multiline text
    vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(), ns, 0, -1)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local select_behavior = require("neocomplete.config").options.selection_behavior
    if select_behavior == "select" then
        local text = entry:get_insert_text()
        local text_after_filter = text:sub(offset + 1)
        vim.api.nvim_buf_set_extmark(vim.api.nvim_get_current_buf(), ns, cursor[1] - 1, cursor[2], {
            virt_text = { { text_after_filter, "@neocomplete.ghost_text" } },
            virt_text_pos = "inline",
        })
    elseif select_behavior == "select" then
        vim.o.ul = vim.o.ul
        -- TODO: allow going back to original (filter) text
        local word = entry:get_insert_word()
        local unblock = require("neocomplete").core:block()
        -- vim.api.nvim_buf_set_text(0, cursor[1] - 1, cursor[2] - offset, cursor[1] - 1, cursor[2], { word })
        -- vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] - offset + #word })
        vim.api.nvim_feedkeys(vim.keycode(string.rep("<BS>", offset) .. word), "i", false)
        unblock()
        local text = entry:get_insert_text()
        local text_after_word = text:sub(#word + 1)
        vim.api.nvim_buf_set_extmark(vim.api.nvim_get_current_buf(), ns, cursor[1] - 1, cursor[2], {
            virt_text = { { text_after_word, "@neocomplete.ghost_text" } },
            virt_text_pos = "inline",
        })
    end
end

function ghost_text.hide()
    vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(), ns, 0, -1)
end

return ghost_text
