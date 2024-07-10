---@type neocomplete.core
---@diagnostic disable-next-line: missing-fields
local core = {}

function core.new()
    ---@type neocomplete.core
    local self = setmetatable({}, { __index = core })
    self.context = require("neocomplete.context").new()
    self.menu = require("neocomplete.menu").new()
    self.blocked = false
    self.last_opened_at = -1
    return self
end

function core:complete(reason)
    reason = reason or 2
    local sources = require("neocomplete.sources").get_sources()
    local entries = {}
    local remaining = #sources
    self.context.reason = reason
    local offset = 0
    for i, source in ipairs(sources) do
        if source.source.is_available() then
            require("neocomplete.sources").complete(self.context, source, function(items, is_incomplete)
                source.incomplete = is_incomplete or false
                source.entries = items
                require("neocomplete.sources").sources[i].incomplete = is_incomplete or false
                require("neocomplete.sources").sources[i].entries = items
                remaining = remaining - 1
                offset = math.max(offset, source:get_offset(self.context))
                if not vim.tbl_isempty(items or {}) then
                    vim.list_extend(entries, items)
                    vim.schedule(function()
                        if remaining == 0 then
                            local filtered_entries = vim.iter(entries)
                                :filter(function(entry)
                                    return not entry.score or entry.score > 0
                                end)
                                :totable()
                            -- TODO: source priority and max entries
                            local opened_at = self.context.cursor.col - offset
                            if opened_at ~= self.last_opened_at then
                                self.menu:open(filtered_entries, offset)
                            else
                                self.menu.entries = filtered_entries
                                self.menu:readjust_win(offset)
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

function core.setup(self)
    vim.api.nvim_create_autocmd("TextChangedI", {
        callback = function()
            self:on_change()
        end,
        group = "neocomplete",
    })
end

function core:block()
    self.blocked = true
    return vim.schedule_wrap(function()
        self.blocked = false
    end)
end

function core.on_change(self)
    if self.blocked then
        return
    end
    self.context = require("neocomplete.context").new(self.context)
    if not require("neocomplete.config").options.enabled() then
        return
    end
    if not self.context:changed() then
        return
    end
    self:complete(1)
end

return core
