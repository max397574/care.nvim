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

function core:complete()
    local sources = require("neocomplete.sources").get_sources()
    local entries = {}
    local remaining = #sources
    for _, source in ipairs(sources) do
        if source.is_available() then
            require("neocomplete.sources").complete(self.context, source, function(items)
                remaining = remaining - 1
                if items and not vim.tbl_isempty(items) then
                    vim.list_extend(entries, items)
                    vim.schedule(function()
                        if remaining == 0 then
                            self.menu:open(entries)
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
    if self.context and (not self.context:changed()) then
        return
    end
    self:complete()
end

return core
