---@type neocomplete.window
---@diagnostic disable-next-line: missing-fields
local Window = {}

function Window.new()
    ---@type neocomplete.window
    local self = setmetatable({}, { __index = Window })
    self.winnr = nil
    self.config = require("neocomplete.config").options
    self.ns = vim.api.nvim_create_namespace("neocomplete_window")
    self.buf = vim.api.nvim_create_buf(false, true)
    self.position = nil
    self.opened_at = {}
    self.scrollbar = {}
    self.scrollbar.win = nil
    self.max_height = nil
    self.current_scroll = 1
    self.scrollbar.buf = vim.api.nvim_create_buf(false, true)
    return self
end

function Window:open_cursor_relative(width, wanted_height, offset)
    if self:is_open() then
        self:close()
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local screenpos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
    local space_below = vim.o.lines - screenpos.row - 3 - vim.o.cmdheight

    local space_above = vim.fn.line(".") - vim.fn.line("w0") - 1
    -- local space_below = vim.fn.line("w$") - vim.fn.line(".")
    local available_space = math.max(space_above, space_below)
    local wanted_space = math.min(wanted_height, self.config.ui.menu.max_height)
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
    self.opened_at = {
        row = cursor[1] - 1,
        col = cursor[2] - offset,
    }
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

function Window:readjust(content_len, width, offset)
    if not content_len then
        self:close()
        return
    end
    if not self.winnr or not vim.api.nvim_win_is_valid(self.winnr) then
        self:close()
        return
    end
    local current_height = vim.api.nvim_win_get_height(self.winnr)
    local current_width = vim.api.nvim_win_get_width(self.winnr)
    if width ~= current_width then
        vim.api.nvim_win_set_width(self.winnr, width)
    end
    if content_len ~= current_height then
        vim.api.nvim_win_set_height(self.winnr, math.min(self.max_height, content_len))
    end
    self:set_scroll(0, -1)
    self:open_scrollbar_win(width, math.min(current_height, content_len), offset)
end

function Window:scroll(delta)
    self.current_scroll = self.current_scroll + delta
    local top_visible = vim.fn.line("w0", self.winnr)
    local bottom_visible = vim.fn.line("w$", self.winnr)
    local visible_amount = bottom_visible - top_visible + 1
    self.current_scroll = math.max(self.current_scroll, 1)
    self.current_scroll =
        math.min(self.current_scroll, #vim.api.nvim_buf_get_lines(self.buf, 0, -1, false) - visible_amount + 1)
    vim.api.nvim_win_call(self.winnr, function()
        vim.cmd("normal! " .. self.current_scroll .. "zt")
    end)
    self:draw_scrollbar()
end

function Window:set_scroll(index, direction)
    --- Scrolls to a certain line in the window
    --- This line will be at the top of the window
    ---@param line integer
    local function scroll_to_line(line)
        vim.api.nvim_win_call(self.winnr, function()
            vim.cmd("normal! " .. line .. "zt")
            self.current_scroll = line
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

function Window:close()
    pcall(vim.api.nvim_win_close, self.winnr, true)
    self.winnr = nil
    pcall(vim.api.nvim_win_close, self.scrollbar.win, true)
    self.scrollbar.win = nil
    self.current_scroll = 1
    self.opened_at = {}
    self.max_height = nil
    self.position = nil
end

function Window:open_scrollbar_win(width, height, offset)
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

function Window:draw_scrollbar()
    if not self:scrollbar_is_open() then
        return
    end
    vim.api.nvim_buf_clear_namespace(self.scrollbar.buf, self.ns, 0, -1)

    local total_lines = #vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
    local top_visible = vim.fn.line("w0", self.winnr)
    local bottom_visible = vim.fn.line("w$", self.winnr)
    local visible_lines = bottom_visible - top_visible + 1
    if visible_lines >= total_lines then
        return
    end
    local scrollbar_height =
        math.max(math.min(math.floor(visible_lines * (visible_lines / total_lines) + 0.5), visible_lines), 1)
    vim.api.nvim_buf_set_lines(self.scrollbar.buf, 0, -1, false, vim.split(string.rep(" ", visible_lines + 1), ""))
    local scrollbar_offset = math.max(math.floor(visible_lines * (top_visible / total_lines)), 1)
    for i = scrollbar_offset, scrollbar_offset + scrollbar_height do
        vim.api.nvim_buf_set_extmark(self.scrollbar.buf, self.ns, i - 1, 0, {
            virt_text = { { self.config.ui.menu.scrollbar, "PmenuSbar" } },
            virt_text_pos = "overlay",
        })
    end
end

function Window:is_open()
    return self.winnr ~= nil
end

function Window:scrollbar_is_open()
    return self.scrollbar.win ~= nil
end

return Window
