local async = {}

local uv = vim.loop or vim.uv

--- Returns a function which can be called to execute the callback
--- After the first time executes earliest after `timeout` ms again
---@param fn function
---@param timeout integer
---@return table?
function async.throttle(fn, timeout)
    local timer = vim.uv.new_timer()
    local last_executed = nil
    if not timer then
        return nil
    end
    local throttle = setmetatable({
        timeout = timeout,
    }, {
        __call = function(self, ...)
            local args = { ... }
            if not last_executed then
                fn(unpack(args))
                last_executed = uv.now()
                return
            end
            timer:stop()
            timer:start(math.max(0, timeout - (uv.now() - last_executed)), 0, function()
                vim.schedule(function()
                    fn(unpack(args))
                    last_executed = uv.now()
                end)
            end)
        end,
    })
    return throttle
end

--- Returns a function which can be called to execute the callback
--- The callback only gets executed if the function didn't get called for timeout ms
---@param fn function
---@param timeout integer
---@return table?
function async.debounce(fn, timeout)
    local timer = vim.uv.new_timer()
    if not timer then
        return nil
    end
    local throttle = setmetatable({
        timeout = timeout,
    }, {
        __call = function(_, ...)
            local args = { ... }
            pcall(function()
                timer:stop()
            end)
            timer:start(math.max(0, timeout), 0, function()
                vim.schedule(function()
                    fn(unpack(args))
                end)
            end)
        end,
    })
    return throttle
end

return async
