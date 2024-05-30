local utils = {}

--- Gets lenght of longest string of an array
---@param lines table<string>
---@return number
function utils.longest(lines)
    local longest = #(lines[1] or "")
    for _, line in ipairs(lines) do
        if #line > longest then
            longest = #line
        end
    end
    return longest
end

return utils
