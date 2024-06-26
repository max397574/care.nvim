local async = {}

--- Returns a function which can be called to execute the callback
--- After the first time executes earliest after `timeout` ms again
---@param fn function
---@param timeout integer
---@return function|nil
function async.throttle(fn, timeout)
    local timer = vim.uv.new_timer()
    local another_waiting = false
    if not timer then
        return nil
    end

    return function(...)
        local args = { ... }
        if timer:is_active() then
            another_waiting = true
            return
        end
        timer:start(0, timeout, function()
            vim.schedule(function()
                fn(unpack(args))
                if another_waiting then
                    another_waiting = false
                else
                    timer:stop()
                end
            end)
        end)
    end
end

return async
