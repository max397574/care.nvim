---@type neocomplete.menu
---@diagnostic disable-next-line: missing-fields
local Menu = {}

local format_utils = require("neocomplete.utils.format")

function Menu.new()
    ---@type neocomplete.menu
    local self = setmetatable({}, { __index = Menu })
    self.entries = nil
    self.ns = vim.api.nvim_create_namespace("neocomplete")
    self.config = require("neocomplete.config").options
    self.buf = vim.api.nvim_create_buf(false, true)
    self.winnr = nil
    self.index = 0
    ---@diagnostic disable-next-line: missing-fields
    self.scrollbar = {}
    self.scrollbar.win = nil
    self.scrollbar.buf = vim.api.nvim_create_buf(false, true)
    return self
end

Menu.draw = require("neocomplete.menu.draw")

function Menu:open_win(offset)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local screenpos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
    local space_below = vim.o.lines - screenpos.row - 3 - vim.o.cmdheight

    local width, _ = format_utils.get_width(self.entries)
    local space_above = vim.fn.line(".") - vim.fn.line("w0") - 1
    -- local space_below = vim.fn.line("w$") - vim.fn.line(".")
    local available_space = math.max(space_above, space_below)
    local wanted_space = math.min(#self.entries, self.config.ui.menu.max_height)
    local position = "below"
    local config_position = self.config.ui.menu.position
    local height
    if config_position == "auto" then
        if space_below < wanted_space then
            position = "above"
            if space_above < wanted_space then
                position = space_above > space_below and "above" or "below"
            end
        end
        height = math.min(wanted_space, available_space)
    elseif config_position == "bottom" then
        position = "below"
        height = math.min(wanted_space, space_below)
    elseif config_position == "top" then
        position = "above"
        height = math.min(wanted_space, space_above)
    end
    Menu.winnr = vim.api.nvim_open_win(self.buf, false, {
        relative = "cursor",
        height = height,
        width = width,
        style = "minimal",
        border = self.config.ui.menu.border,
        row = position == "below" and 1 or -(height + 2),
        col = -offset,
        zindex = 1000,
    })
    vim.wo[self.winnr][self.buf].scrolloff = 0

    if self.config.ui.menu.scrollbar then
        self.scrollbar.win = vim.api.nvim_open_win(self.scrollbar.buf, false, {
            height = height,
            relative = "cursor",
            col = -offset + width,
            row = position == "below" and 2 or -(height + 2) + 1,
            width = 1,
            style = "minimal",
            border = "none",
            zindex = 2000,
        })
    end
end

function Menu:close()
    -- TODO: reset more things?
    pcall(vim.api.nvim_win_close, self.winnr, true)
    pcall(vim.api.nvim_win_close, self.scrollbar.win, true)
    require("neocomplete.ghost_text").hide()
    Menu.winnr = nil
end

function Menu:set_scroll(direction)
    --- Scrolls to a certain line in the window
    --- This line will be at the top of the window
    ---@param line integer
    local function scroll_to_line(line)
        vim.api.nvim_win_call(self.winnr, function()
            vim.cmd("normal! " .. line .. "zt")
        end)
    end
    local top_visible = vim.fn.line("w0", self.winnr)
    local bottom_visible = vim.fn.line("w$", self.winnr)
    local visible_amount = bottom_visible - top_visible + 1
    local selected_line = self.index
    if selected_line == 0 then
        scroll_to_line(1)
        return
    elseif selected_line >= top_visible and selected_line <= bottom_visible then
        return
    elseif direction == 1 and selected_line > bottom_visible then
        scroll_to_line(selected_line - visible_amount + 1)
    elseif direction == -1 and selected_line < top_visible then
        scroll_to_line(selected_line)
    elseif direction == -1 and selected_line > bottom_visible then
        -- wrap around
        scroll_to_line(selected_line - visible_amount + 1)
    end
end

function Menu:select_next(count)
    self.index = self.index + count
    if self.index > #self.entries then
        self.index = self.index - #self.entries - 1
    end
    self:set_scroll(1)
    self:draw()
end

function Menu:select_prev(count)
    self.index = self.index - count
    if self.index < 0 then
        self.index = #self.entries + self.index + 1
    end
    self:set_scroll(-1)
    self:draw()
end

function Menu:open(entries, offset)
    self.entries = entries
    if not entries or #entries < 1 then
        return
    end
    if self.winnr then
        self:close()
    end
    self.index = 0
    if not self.winnr then
        self:open_win(offset)
        self:draw()
    end
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
    self:close()
end

function Menu:is_open()
    return self.winnr ~= nil
end

return Menu
