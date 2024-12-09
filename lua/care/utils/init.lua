local utils = {}

--- Gets length of longest string of an array
---@param lines table<string>
---@return number
function utils.longest(lines)
    local longest = vim.fn.strdisplaywidth(lines[1] or "")
    for _, line in ipairs(lines) do
        if vim.fn.strdisplaywidth(line) > longest then
            longest = vim.fn.strdisplaywidth(line)
        end
    end
    return longest
end

return utils
