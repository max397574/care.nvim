---@type care.core
---@diagnostic disable-next-line: missing-fields
local Core = {}

local Log = require("care.utils.log")

function Core.new()
    ---@type care.core
    local self = setmetatable({}, { __index = Core })
    self.context = require("care.context").new()
    self.menu = require("care.menu").new()
    self.blocked = false
    self.last_opened_at = -1
    self.completing = false
    return self
end

function Core:complete(reason, source_filter)
    reason = reason or 2
    local sources = require("care.sources").get_sources()
    if source_filter then
        sources = vim.iter(sources)
            :filter(function(source)
                return source_filter(source.source.name)
            end)
            :totable()
    end
    ---@type care.entry[]
    local entries = {}
    local remaining = #sources
    self.context.reason = reason
    local offset = self.context.cursor.col
    for i, source in ipairs(sources) do
        if source.source.is_available() and source:is_enabled() then
            require("care.sources").complete(self.context, source, function(items, is_incomplete)
                source.incomplete = is_incomplete or false
                source.entries = items
                require("care.sources").sources[i].incomplete = is_incomplete or false
                require("care.sources").sources[i].entries = items
                remaining = remaining - 1
                if not vim.tbl_isempty(items or {}) then
                    local source_offset = source:get_offset(self.context)
                    if source_offset then
                        offset = math.min(offset, source_offset)
                    end
                    local filtered_items = vim.iter(items):filter(function(entry)
                        return not entry.score or entry.score > 0
                    end)
                    if source.config.filter then
                        filtered_items:filter(source.config.filter)
                    end
                    if source.config.max_entries then
                        filtered_items:take(source.config.max_entries)
                    end

                    vim.list_extend(entries, filtered_items:totable())
                    vim.schedule(function()
                        if remaining == 0 then
                            -- TODO: source priority and max entries
                            local opened_at = offset
                            if opened_at == self.last_opened_at and self.menu:is_open() then
                                self.menu.entries =
                                    vim.iter(entries):take(require("care.config").options.max_view_entries):totable()
                                self.menu:readjust_win(offset)
                            else
                                self.menu:open(entries, offset)
                            end
                            self.last_opened_at = opened_at
                        end
                    end)
                end
            end)
        else
            remaining = remaining - 1
        end
    end
end

function Core:filter()
    Log.log("Core: filtering")
    if not self.menu:is_open() then
        return
    end
    local context = require("care.context").new()
    local offset = context.cursor.col
    local entries = {}
    local sources = require("care.sources").get_sources()
    for i, source in ipairs(sources) do
        if source.entries and #source.entries > 0 then
            local source_offset = source:get_offset(context)
            if source_offset then
                offset = math.min(offset, source_offset)
            end

            local prefix = context.line_before_cursor:sub(source_offset + 1)
            local items = require("care.sorter").sort(source.entries, prefix)
            require("care.sources").sources[i].entries = items
            local filtered_items = vim.iter(items):filter(function(entry)
                return not entry.score or entry.score > 0
            end)
            if source.config.filter then
                filtered_items:filter(source.config.filter)
            end
            if source.config.max_entries then
                filtered_items:take(source.config.max_entries)
            end

            vim.list_extend(entries, filtered_items:totable())
        end
    end
    if #entries == 0 then
        return
    end

    self.menu.entries = vim.iter(entries):take(require("care.config").options.max_view_entries):totable()
    self.menu:readjust_win(offset)
end

function Core:setup()
    Log.log("Setting up core")
    vim.api.nvim_create_autocmd("CursorMovedI", {
        callback = function()
            -- TODO: doesn't work with manual completion because context doesn't get updated
            vim.schedule(function()
                if not self.completing then
                    self:filter()
                end
                self.completing = false
            end)
        end,
    })
    if #require("care.config").options.completion_events == 0 then
        return
    end
    vim.api.nvim_create_autocmd(require("care.config").options.completion_events, {
        callback = function()
            self.completing = true
            self:on_change()
        end,
        group = "care",
    })
end

function Core:block()
    Log.log("Core blocked")
    self.blocked = true
    return vim.schedule_wrap(function()
        Log.log("Core unblocked")
        self.blocked = false
    end)
end

function Core:on_change()
    Log.log("Core: on_change")
    if self.blocked then
        return
    end
    self.context = require("care.context").new(self.context)
    Log.log("Context", self.context.line_before_cursor)
    if not require("care.config").options.enabled() then
        Log.log("Core: care disabled")
        return
    end
    if not self.context:changed() then
        Log.log("Core: Context not changed")
        return
    end
    self:complete(1)
end

return Core
