---@type neocomplete.menu
---@diagnostic disable-next-line: missing-fields
local Menu = {}

function Menu.new()
    ---@type neocomplete.menu
    local self = setmetatable({}, { __index = Menu })
    self.entries = nil
    self.ns = vim.api.nvim_create_namespace("neocomplete")
    self.config = require("neocomplete.config").options
    self.buf = vim.api.nvim_create_buf(false, true)
    self.index = 0
    ---@diagnostic disable-next-line: missing-fields
    self.scrollbar_buf = vim.api.nvim_create_buf(false, true)
    self.window = require("neocomplete.menu.window").new(self.buf, self.scrollbar_buf)
    return self
end

Menu.draw = require("neocomplete.menu.draw")

function Menu:readjust_win(offset)
    self.window:readjust(self.entries, offset)
    self:draw()
end

function Menu.close(self)
    self.window:close()
    require("neocomplete.ghost_text").hide()
end

function Menu:select_next(count)
    count = count or 1
    self.index = self.index + count
    if self.index > #self.entries then
        self.index = self.index - #self.entries - 1
    end
    self.window:set_scroll(self.index, 1)
    self:draw()
end

function Menu:select_prev(count)
    count = count or 1
    self.index = self.index - count
    if self.index < 0 then
        self.index = #self.entries + self.index + 1
    end
    self.window:set_scroll(self.index, -1)
    self:draw()
end

function Menu:open(entries, offset)
    self.entries = entries
    if self.winnr then
        self:close()
    end
    if not entries or #entries < 1 then
        return
    end
    self.index = 0
    self.window:open_win(entries, offset)
    self:draw()
    self.window:set_scroll(self.index, -1)
end

function Menu:get_active_entry()
    if not self.entries then
        return nil
    end
    -- TODO: make configurable (cmpts "autoselect")
    if self.index == 0 then
        return self.entries[1]
    end
    return self.entries[self.index]
end

Menu.complete = require("neocomplete.menu.complete")

function Menu:confirm()
    -- Set undo point
    vim.o.ul = vim.o.ul
    local entry = self:get_active_entry()
    if not entry then
        return
    end
    self:complete(entry)
    self.window:close()
end

function Menu:is_open()
    return self.window:is_open()
end

return Menu
