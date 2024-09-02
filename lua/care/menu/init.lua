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
    self.menu_window = require("care.utils.window").new()
    self.docs_window = require("care.utils.window").new()
    self.ghost_text = require("care.ghost_text").new()
    return self
end

Menu.draw = require("care.menu.draw")

function Menu:close()
    self.menu_window:close()
    self.docs_window:close()
    self.ghost_text:hide()
    vim.cmd.redraw({ bang = true })
    vim.api.nvim_exec_autocmds("User", { pattern = "CareMenuClosed" })
    local sources = require("care.sources").get_sources()
    for i, _ in ipairs(sources) do
        require("care.sources").sources[i].entries = nil
    end
end

---@param menu care.menu
local function draw_docs(menu, entry, config)
    if not entry or menu.index == 0 then
        if menu:docs_visible() then
            menu.docs_window:close()
        end
        return
    end

    local function open_docs_window(doc_entry, offset)
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

        local menu_border = menu.config.ui.menu.border
        local menu_has_border = menu_border and menu_border ~= "none"

        local TODO = 100000
        --- Width of full window including borders
        local right_width = math.min(
            vim.o.columns
                - (offset + (menu_has_border and 2 or 0))
                - vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
                - 2,
            config.max_width
        )
        local left_width = menu.menu_window.opened_at.col
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
        local height = math.min(TODO, config.max_height)

        local border = menu.config.ui.docs_view.border
        local has_border = border and border ~= "none"

        local do_stylize = format == "markdown" and vim.g.syntax_on ~= nil

        if do_stylize then
            contents = vim.lsp.util._normalize_markdown(contents, { width = width - (has_border and 2 or 0) })
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
        width = math.min(width, require("care.utils").longest(contents) + (has_border and 2 or 0))

        if position == "right" then
            menu.docs_window:open_cursor_relative(
                width,
                math.min(height, menu.menu_window.max_height),
                offset + (menu_has_border and 2 or 0),
                menu.config.ui.docs_view
            )
        else
            menu.docs_window:open_cursor_relative(
                width,
                math.min(height, menu.menu_window.max_height),
                menu.menu_window.opened_at.col - width - 2,
                menu.config.ui.docs_view
            )
        end
        menu.docs_window:draw_scrollbar()

        vim.api.nvim_set_option_value("scrolloff", 0, { win = menu.docs_window.winnr })
    end

    if entry.source.source.resolve_item then
        entry.source.source:resolve_item(entry.completion_item, function(resolved_item)
            entry.completion_item = resolved_item
            open_docs_window(entry, menu.menu_window.opened_at.col + vim.api.nvim_win_get_width(menu.menu_window.winnr))
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
    local width, _ = format_utils.get_width(self.entries)
    if not self.entries or #self.entries < 1 then
        self:close()
        return
    end
    draw_docs(self, self:get_active_entry(), self.config.ui.docs_view)
    self.menu_window:readjust(#self.entries, width, offset)
    preselect(self)
    self:draw()
    self.menu_window:draw_scrollbar()
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
    if self.menu_window:is_open() then
        self:close()
    end
    if not entries or #entries < 1 then
        return
    end
    vim.api.nvim_exec_autocmds("User", { pattern = "CareMenuOpened" })
    self.index = 0
    preselect(self)
    local width, _ = format_utils.get_width(self.entries)
    self.menu_window:open_cursor_relative(width, #self.entries, offset, self.config.ui.menu)
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
    require("care.menu.confirm")(entry)
    vim.api.nvim_exec_autocmds("User", { pattern = "CareConfirmed" })
    self:close()
    vim.api.nvim_exec_autocmds("User", { pattern = "CareMenuClosed" })
end

function Menu:is_open()
    return self.menu_window:is_open()
end

return Menu
