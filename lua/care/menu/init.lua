---@type care.menu
---@diagnostic disable-next-line: missing-fields
local Menu = {}

local format_utils = require("care.utils.format")

function Menu.new()
    ---@type care.menu
    local self = setmetatable({}, { __index = Menu })
    self.entries = nil
    self.ns = vim.api.nvim_create_namespace("care")
    self.config = require("care.config").options
    self.index = 0
    self.menu_window = require("care.utils.window").new({ scrollbar = self.config.ui.menu.scrollbar })
    self.docs_window = require("care.utils.window").new({ scrollbar = self.config.ui.docs_view.scrollbar })
    self.ghost_text = require("care.ghost_text").new()
    self.reversed = false
    return self
end

Menu.draw = require("care.menu.draw")

function Menu:close()
    self.menu_window:close()
    self.docs_window:close()
    self.ghost_text:hide()
    self.reversed = false
    self.index = 0
    vim.cmd.redraw({ bang = true })
    vim.api.nvim_exec_autocmds("User", { pattern = "CareMenuClosed" })
    local sources = require("care.sources").get_sources()
    for i, _ in ipairs(sources) do
        require("care.sources").sources[i].entries = nil
    end
end

Menu.draw_docs = require("care.utils.async").throttle(function(self, entry)
    if not entry or self.index == 0 or self.menu_window.winnr == nil then
        if self:docs_visible() then
            self.docs_window:close()
        end
        return
    end

    ---@param doc_entry care.entry
    local function open_docs_window(doc_entry)
        local config = self.config.ui.docs_view or {}

        local menu_border = self.config.ui.menu.border
        local menu_has_border = menu_border and menu_border ~= "none"

        local right_width = math.min(
            vim.o.columns
                - (self.menu_window.opened_at.col + 1 + vim.api.nvim_win_get_width(self.menu_window.winnr) + (menu_has_border and 2 or 0))
                - 1,
            config.max_width
        )
        local left_width = self.menu_window.opened_at.col
        --- Width of full window including borders
        local width
        local position
        if config.position == "right" then
            width = right_width
        elseif config.position == "left" then
            width = left_width
        elseif config.position == "auto" then
            if right_width >= left_width then
                width = right_width
                position = "right"
            else
                width = left_width
                position = "left"
            end
        end
        if not width or width < 1 then
            self.docs_window:close()
            return
        end

        local border = self.config.ui.docs_view.border
        local has_border = border and border ~= "none"

        width = width - (has_border and 2 or 0)

        local docs = doc_entry:get_documentation()

        if docs == nil or #docs == 0 then
            self.docs_window:close()
            return
        end

        if self.config.ui.docs_view.advanced_styling then
            docs = vim.lsp.util._normalize_markdown(
                vim.split(table.concat(docs, "\n"), "\n", { trimempty = true }),
                { width = width }
            )
            vim.bo[self.docs_window.buf].filetype = "markdown"
            vim.treesitter.start(self.docs_window.buf)
            vim.api.nvim_buf_set_lines(self.docs_window.buf, 0, -1, false, docs)
        else
            docs = vim.lsp.util._normalize_markdown(
                vim.split(table.concat(docs, "\n"), "\n", { trimempty = true }),
                { width = width }
            )

            vim.api.nvim_buf_call(self.docs_window.buf, function()
                vim.cmd([[syntax clear]])
                vim.api.nvim_buf_set_lines(self.docs_window.buf, 0, -1, false, {})
            end)

            local stylize_markdown = function(bufnr, contents, opts)
                local new_contents = {}

                -- Filter out links/anchors
                for _, line in ipairs(contents) do
                    -- Remove markdown links like [text](url) and ![text](url)
                    local cleaned_line = line:gsub("!?%b[]%b()", "")
                    table.insert(new_contents, cleaned_line)
                end

                return vim.lsp.util.stylize_markdown(bufnr, new_contents, opts)
            end

            stylize_markdown(self.docs_window.buf, docs, { max_width = width })
        end

        width = math.min(width, require("care.utils").longest(docs))

        local win_offset
        if position == "right" then
            win_offset = self.menu_window.opened_at.col
                + vim.api.nvim_win_get_width(self.menu_window.winnr)
                + (menu_has_border and 2 or 0)
        else
            win_offset = self.menu_window.opened_at.col - width - 2
        end

        local content_height = 0
        for _, line in ipairs(vim.api.nvim_buf_get_lines(self.docs_window.buf, 0, -1, false)) do
            content_height = content_height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / width))
        end

        local height = math.min(content_height, config.max_height)

        local docs_view_conf = self.config.ui.docs_view or {}

        if self.docs_window:is_open() then
            self.docs_window:readjust(height, width, win_offset)
        else
            self.docs_window:open_cursor_relative(width, height, win_offset, {
                border = docs_view_conf.border,
                position = self.menu_window.position,
                max_height = docs_view_conf.max_height,
            })
        end

        vim.wo[self.docs_window.winnr][0].conceallevel = 2
        vim.wo[self.docs_window.winnr][0].concealcursor = "n"

        self.docs_window:set_scroll(1, 1, false)
        self.docs_window:draw_scrollbar()
    end

    if entry.source.source.resolve_item then
        entry.source.source:resolve_item(entry.completion_item, function(resolved_item)
            entry.completion_item = resolved_item
            -- TODO: perhaps better solution for this?, e.g. cancel callback?
            -- Required to not run into issues when closing immediatelly after selection
            if not self.menu_window:is_open() then
                return
            end
            open_docs_window(entry)
        end)
    else
        open_docs_window(entry)
    end
end, 10)

local function preselect(menu)
    if not menu.config.preselect then
        return
    end
    for index, entry in ipairs(menu.entries) do
        if entry.completion_item.preselect then
            menu.index = index
            break
        end
    end
end

function Menu:readjust_win(offset)
    self.index = 0
    local width = format_utils.get_width(self.entries)
    if not self.entries or #self.entries < 1 then
        self:close()
        return
    end
    self.menu_window:readjust(#self.entries, width, offset)
    self.reversed = self.config.sorting_direction == "away-from-cursor" and self.menu_window.position == "above"
    preselect(self)
    self.docs_window:close()
    self:select()
end

function Menu:docs_visible()
    return self.docs_window:is_open()
end

function Menu:scroll_docs(delta)
    if not self:docs_visible() then
        return
    end
    self.docs_window:scroll(delta)
    self.docs_window:draw_scrollbar()
end

function Menu:select(direction)
    direction = direction or 1
    if self.index ~= 0 then
        self:draw_docs(self:get_active_entry())
    else
        self.docs_window:close()
    end

    local width = format_utils.get_width(self.entries)
    local spaces = {}
    for _ = 1, #self.entries do
        table.insert(spaces, (" "):rep(width))
    end
    vim.api.nvim_buf_set_lines(self.menu_window.buf, 0, -1, false, spaces)

    self.menu_window:set_scroll(self.index, direction, self.reversed)
    self:draw()
    self.ghost_text:show(self:get_active_entry(), vim.api.nvim_get_current_win())
    self.menu_window:draw_scrollbar()
    self.docs_window:draw_scrollbar()
end

function Menu:select_next(count)
    count = count or 1
    self.index = (self.index + count) % (#self.entries + 1)

    self:select(1)
end

function Menu:select_prev(count)
    count = count or 1
    self.index = (self.index - count) % (#self.entries + 1)

    self:select(-1)
end

function Menu:open(entries, offset)
    self.entries = entries
    if self.menu_window:is_open() then
        self:close()
    end
    if not entries or #entries < 1 then
        return
    end
    vim.api.nvim_exec_autocmds("User", { pattern = "CareMenuOpened" })
    self.index = 0
    preselect(self)
    local width = format_utils.get_width(self.entries)
    -- local win_offset = vim.fn.screenpos(0, 0, offset + 1).col
    local win_offset = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].wincol
        + vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
        + offset
        - 1

    self.menu_window:open_cursor_relative(width, #self.entries, win_offset, self.config.ui.menu)
    self.reversed = self.config.sorting_direction == "away-from-cursor" and self.menu_window.position == "above"
    self:select()
end

function Menu:get_active_entry()
    if not self.entries then
        return nil
    end
    if self.reversed then
        if self.index == 0 then
            return self.entries[1]
        else
            return self.entries[#self.entries - self.index + 1]
        end
    else
        return self.entries[self.index == 0 and 1 or self.index]
    end
end

function Menu:confirm()
    -- Set undo point
    vim.o.ul = vim.o.ul
    local entry = self:get_active_entry()
    if not entry then
        return
    end
    require("care.menu.confirm")(entry)
    vim.api.nvim_exec_autocmds("User", { pattern = "CareConfirmed" })
    self:close()
    vim.api.nvim_exec_autocmds("User", { pattern = "CareMenuClosed" })
end

function Menu:is_open()
    return self.menu_window:is_open()
end

return Menu
