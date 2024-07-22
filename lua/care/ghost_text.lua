---@class care.ghost_text
---@field entry care.entry?
---@field ns integer
---@field win integer?
---@field extmark_id integer?
---@field new fun(): care.ghost_text
---@field config care.config.ui.ghost_text
---@field hide fun(self: care.ghost_text): nil
---@field show fun(self: care.ghost_text, entry: care.entry?, window: integer): nil

---@type care.ghost_text
---@diagnostic disable-next-line: missing-fields
local Ghost_text = {}

function Ghost_text.new()
    ---@type care.ghost_text
    local self = setmetatable({}, { __index = Ghost_text })
    self.ns = vim.api.nvim_create_namespace("care.ghost_text")
    ---@type care.entry?
    self.entry = nil
    ---@type integer?
    self.win = nil
    ---@type integer?
    self.extmark_id = nil
    self.config = require("care.config").options.ui.ghost_text
    vim.api.nvim_set_decoration_provider(self.ns, {
        on_win = function(_, win)
            return win == self.win
        end,
        on_line = function()
            if self.extmark_id then
                vim.api.nvim_buf_del_extmark(vim.api.nvim_get_current_buf(), self.ns, self.extmark_id)
                self.extmark_id = nil
            end
            if (not self.config.enabled) or not self.entry then
                return
            end
            local word = self.entry:get_insert_word()
            local offset = self.entry:get_offset()
            local cursor = vim.api.nvim_win_get_cursor(self.win)
            local text_after_filter = word:sub(cursor[2] - offset + 1)
            if self.config.position == "inline" then
                self.extmark_id =
                    vim.api.nvim_buf_set_extmark(vim.api.nvim_get_current_buf(), self.ns, cursor[1] - 1, cursor[2], {
                        virt_text = { { text_after_filter, "@care.ghost_text" } },
                        virt_text_pos = "inline",
                    })
            elseif self.config.position == "overlay" then
                self.extmark_id =
                    vim.api.nvim_buf_set_extmark(vim.api.nvim_get_current_buf(), self.ns, cursor[1] - 1, cursor[2], {
                        virt_text = { { text_after_filter, "@care.ghost_text" } },
                        virt_text_pos = "overlay",
                        ephemeral = true,
                    })
            end
        end,
    })
    return self
end

function Ghost_text:show(entry, window)
    if not entry then
        self.entry = nil
        return
    end
    local changed = self.entry ~= entry
    self.entry = entry
    self.win = window
    if changed then
        vim.cmd.redraw({ bang = true })
    end
end

function Ghost_text:hide()
    self.entry = nil
    self.win = nil
    if self.extmark_id then
        vim.api.nvim_buf_del_extmark(vim.api.nvim_get_current_buf(), self.ns, self.extmark_id)
        self.extmark_id = nil
    end
end

return Ghost_text
