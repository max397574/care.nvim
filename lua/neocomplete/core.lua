---@type neocomplete.core
---@diagnostic disable-next-line: missing-fields
local core = {}

function core.new()
    ---@type neocomplete.core
    local self = setmetatable({}, { __index = core })
    self.context = require("neocomplete.context").new()
    self.menu = require("neocomplete.menu").new()
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
                            -- TODO: source priority and max entries
                            self.menu:open(entries, offset)
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

function core.on_change(self)
    self.context = require("neocomplete.context").new(self.context)
    if not self.context:changed() then
        return
    end
    self:complete(1)
end

return core
