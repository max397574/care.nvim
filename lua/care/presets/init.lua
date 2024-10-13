---@type care.presets
---@diagnostic disable-next-line: missing-fields
local Presets = {}

function Presets.Default(entry, data)
    local components = require("care.presets.components")
    return {
        components.Padding(1),
        components.Label(entry, data, true),
        components.Padding(1),
        components.KindIcon(entry, "fg"),
        components.Padding(1),
    }
end

function Presets.Atom(entry, data)
    local components = require("care.presets.components")
    return {
        components.KindIcon(entry, "blended"),
        components.Padding(1),
        components.Label(entry, data, true),
        components.Padding(1),
    }
end

return Presets
