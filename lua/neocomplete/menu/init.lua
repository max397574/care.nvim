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
    self.index = 0
    self.menu_window = require("neocomplete.utils.window").new()
    self.docs_window = require("neocomplete.utils.window").new()
    self.ghost_text = require("neocomplete.ghost_text").new()
    return self
end

Menu.draw = require("neocomplete.menu.draw")

function Menu:readjust_win(offset)
    self.index = 0
    local width, _ = format_utils.get_width(self.entries)
    if not self.entries or #self.entries < 1 then
        self.menu_window:close()
        return
    end
    self.menu_window:readjust(#self.entries, width, offset)
    self:draw()
    self.menu_window:draw_scrollbar()
end

function Menu.close(self)
    self.menu_window:close()
    self.docs_window:close()
    self.ghost_text:hide()
end

---@param menu neocomplete.menu
local function draw_docs(menu, entry, config)
    if not entry then
        return
    end

    local function open_docs_window(doc_entry, x_offset)
        if not doc_entry.completion_item.documentation then
            return
        end
        local documentation = doc_entry.completion_item.documentation
        local format = "markdown"
        local contents
        if type(documentation) == "table" and documentation.kind == "plaintext" then
            format = "plaintext"
            contents = vim.split(documentation.value or "", "\n", { trimempty = true })
        else
            contents = vim.lsp.util.convert_input_to_markdown_lines(documentation --[[@as string]])
        end

        local TODO = 100000
        local width = math.min(vim.o.columns - x_offset, config.max_width)
        local height = math.min(TODO, config.max_height)

        local do_stylize = format == "markdown" and vim.g.syntax_on ~= nil

        if do_stylize then
            contents = vim.lsp.util._normalize_markdown(contents, { width = width })
            vim.bo[menu.docs_window.buf].filetype = "markdown"
            vim.treesitter.start(menu.docs_window.buf)
            vim.api.nvim_buf_set_lines(menu.docs_window.buf, 0, -1, false, contents)
        else
            -- Clean up input: trim empty lines
            contents = vim.split(table.concat(contents, "\n"), "\n", { trimempty = true })

            if format then
                vim.bo[menu.docs_window.buf].syntax = format
            end
            vim.api.nvim_buf_set_lines(menu.docs_window.buf, 0, -1, true, contents)
        end

        menu.docs_window:open_cursor_relative(width, height, -x_offset)
        menu.docs_window:draw_scrollbar()

        vim.api.nvim_set_option_value("scrolloff", 0, { win = menu.docs_window.winnr })
    end

    if entry.source.source.resolve_item then
        entry.source.source:resolve_item(entry.completion_item, function(resolved_item)
            entry.completion_item = resolved_item
            open_docs_window(
                entry,
                menu.menu_window.opened_at.col
                    + vim.api.nvim_win_get_width(menu.menu_window.winnr)
                    - (vim.api.nvim_win_get_cursor(0)[2] - 1)
                    + 1
            )
        end)
    else
        open_docs_window(
            entry,
            menu.menu_window.opened_at.col
                + vim.api.nvim_win_get_width(menu.menu_window.winnr)
                - (vim.api.nvim_win_get_cursor(0)[2] - 1)
                + 1
        )
    end
end

function Menu:docs_visible()
    return self.docs_window:is_open()
end

function Menu:scroll_docs(delta)
    if not self:docs_visible() then
        return
    end
    self.docs_window:scroll(delta)
end

function Menu:select_next(count)
    count = count or 1
    self.index = self.index + count
    if self.index > #self.entries then
        self.index = self.index - #self.entries - 1
    end
    self.menu_window:set_scroll(self.index, 1)
    draw_docs(self, self:get_active_entry(), self.config.ui.docs_view)
    self:draw()
    self.menu_window:draw_scrollbar()
    self.ghost_text:show(self:get_active_entry(), vim.api.nvim_get_current_win())
end

function Menu:select_prev(count)
    count = count or 1
    self.index = self.index - count
    if self.index < 0 then
        self.index = #self.entries + self.index + 1
    end
    self.menu_window:set_scroll(self.index, -1)
    draw_docs(self, self:get_active_entry(), self.config.ui.docs_view)
    self:draw()
    self.menu_window:draw_scrollbar()
    self.ghost_text:show(self:get_active_entry(), vim.api.nvim_get_current_win())
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
    local width, _ = format_utils.get_width(self.entries)
    self.menu_window:open_cursor_relative(width, #self.entries, offset)
    self:draw()
    self.menu_window:draw_scrollbar()
    self.menu_window:set_scroll(self.index, -1)
    self.ghost_text:show(self:get_active_entry(), vim.api.nvim_get_current_win())
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

function Menu:confirm()
    -- Set undo point
    vim.o.ul = vim.o.ul
    local entry = self:get_active_entry()
    if not entry then
        return
    end
    require("neocomplete.menu.confirm")(entry)
    self.menu_window:close()
    self.docs_window:close()
end

function Menu:is_open()
    return self.menu_window:is_open()
end

return Menu
