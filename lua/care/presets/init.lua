---@type care.presets
---@diagnostic disable-next-line: missing-fields
local Presets = {}

function Presets.Default(entry, data)
    local components = require("care.presets.components")
    return {
        components.Label(entry, data, true),
        components.KindIcon(entry, "fg"),
    }
end

function Presets.Atom(entry, data)
    local components = require("care.presets.components")
    return {
        components.KindIcon(entry, "blended"),
        { { " ", "@care.menu" } },
        components.Label(entry, data, true),
    }
end

return Presets
