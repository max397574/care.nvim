-- some parts are adapted from https://github.com/folke/trouble.nvim
local async = {}

local uv = vim.loop or vim.uv

local Queue = {}
Queue.queue = {}
Queue.checker = uv.new_check()

function Queue.step()
    local budget = 1 * 1e6
    local start = uv.hrtime()
    while #Queue.queue > 0 and uv.hrtime() - start < budget do
        local a = table.remove(Queue.queue, 1)
        a:step()
        if a.running then
            table.insert(Queue._queue, a)
        end
    end
    if #Queue.queue == 0 then
        return Queue.checker:stop()
    end
end

function Queue.add(a)
    table.insert(Queue.queue, a)
    if not Queue.checker:is_active() then
        Queue.checker:start(vim.schedule_wrap(Queue.step))
    end
end

local AsyncTask = {}

function AsyncTask.new(fn)
    local self = setmetatable({}, { __index = AsyncTask })
    self.callbacks = {}
    self.running = true
    self.thread = coroutine.create(fn)
    Queue.add(self)
    return self
end

function AsyncTask:step()
    local ok, res = coroutine.resume(self.thread)
    if not ok then
        return self:_done(nil, res)
    elseif res == "abort" then
        return self:_done(nil, "abort")
    elseif coroutine.status(self.thread) == "dead" then
        return self:_done(res)
    end
end

--- Returns a function which can be called to execute the callback
--- After the first time executes earliest after `timeout` ms again
---@param fn function
---@param timeout integer
---@return table?
---@overload fun(...): any?
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
