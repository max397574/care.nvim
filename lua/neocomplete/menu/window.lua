---@type neocomplete.menu_window
---@diagnostic disable-next-line: missing-fields
local Menu_window = {}
local format_utils = require("neocomplete.utils.format")

function Menu_window.new(buf, scrollbar_buf)
    ---@type neocomplete.menu_window
    local self = setmetatable({}, { __index = Menu_window })
    self.winnr = nil
    self.config = require("neocomplete.config").options
    self.buf = buf
    self.position = nil
    self.scrollbar = {}
    self.scrollbar.win = nil
    self.max_height = nil
    self.scrollbar.buf = scrollbar_buf
    return self
end

function Menu_window:open_win(entries, offset)
    if self:is_open() then
        self:close()
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local screenpos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
    local space_below = vim.o.lines - screenpos.row - 3 - vim.o.cmdheight

    local width, _ = format_utils.get_width(entries)
    local space_above = vim.fn.line(".") - vim.fn.line("w0") - 1
    -- local space_below = vim.fn.line("w$") - vim.fn.line(".")
    local available_space = math.max(space_above, space_below)
    local wanted_space = math.min(#entries, self.config.ui.menu.max_height)
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
    self.max_height = height
    self.position = position
    self.winnr = vim.api.nvim_open_win(self.buf, false, {
        relative = "cursor",
        height = height,
        width = width,
        anchor = position == "below" and "NW" or "SW",
        style = "minimal",
        border = self.config.ui.menu.border,
        row = position == "below" and 1 or 0,
        col = -offset,
        zindex = 1000,
    })
    vim.wo[self.winnr][0].scrolloff = 0
    self:open_scrollbar_win(width, height, offset)
end

function Menu_window:readjust(entries, offset)
    if not entries or #entries < 1 then
        self:close()
        return
    end
    if not self.winnr or not vim.api.nvim_win_is_valid(self.winnr) then
        self:close()
        self:open_win(entries, offset)
        self:set_scroll(0, -1)
        return
    end
    local width, _ = format_utils.get_width(entries)
    local current_height = vim.api.nvim_win_get_height(self.winnr)
    local current_width = vim.api.nvim_win_get_width(self.winnr)
    if width ~= current_width then
        vim.api.nvim_win_set_width(self.winnr, width)
    end
    if #entries ~= current_height then
        vim.api.nvim_win_set_height(self.winnr, math.min(self.max_height, #entries))
    end
    -- if self.position == "below" then
    -- elseif self.position == "above" then
    -- end
    self:set_scroll(0, -1)
    self:open_scrollbar_win(width, math.min(current_height, #entries), offset)
end

function Menu_window:open_scrollbar_win(width, height, offset)
    if self.scrollbar.win then
        pcall(vim.api.nvim_win_close, self.scrollbar.win, true)
        self.scrollbar.win = nil
    end
    if self.config.ui.menu.scrollbar then
        self.scrollbar.win = vim.api.nvim_open_win(self.scrollbar.buf, false, {
            height = height,
            relative = "cursor",
            col = -offset + width,
            row = self.position == "below" and 2 or -(height + 2) + 1,
            width = 1,
            style = "minimal",
            border = "none",
            zindex = 2000,
        })
    end
end

function Menu_window:close()
    pcall(vim.api.nvim_win_close, self.winnr, true)
    self.winnr = nil
    pcall(vim.api.nvim_win_close, self.scrollbar.win, true)
    self.scrollbar.win = nil
    self.max_height = nil
    self.position = nil
end

function Menu_window:set_scroll(index, direction)
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
    local selected_line = index
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

function Menu_window:is_open()
    return self.winnr ~= nil
end

function Menu_window:scrollbar_is_open()
    return self.scrollbar.win ~= nil
end

return Menu_window
