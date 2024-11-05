---@diagnostic disable: need-check-nil
local async = require("care.utils.async")

describe("Debounce", function()
    local count
    before_each(function()
        count = 0
    end)
    local test_func = function()
        count = count + 1
    end
    it("only calls once with two calls right after each other", function()
        local fn = async.debounce(test_func, 100)
        fn()
        fn()
        vim.wait(120, function() end)
        assert.is.truthy(count == 1)
    end)

    it("can call second time after timeout", function()
        local fn = async.debounce(test_func, 100)
        fn()
        vim.wait(105, function() end)
        fn()
        vim.wait(105, function() end)
        assert.are.equal(2, count)
    end)
end)

describe("Throttle", function()
    local count
    before_each(function()
        count = 0
    end)
    local test_func = function()
        count = count + 1
    end
    it("makes first call immediately", function()
        local start = vim.uv.now()
        local fn = async.throttle(test_func, 100)
        fn()
        vim.wait(1000, function()
            return count == 1
        end)
        local ms_passed = vim.uv.now() - start
        assert.is.truthy(ms_passed < 50)
    end)

    it("waits for timeout before second call", function()
        local start = vim.uv.now()
        local fn = async.throttle(test_func, 100)
        fn()
        fn()
        vim.wait(1000, function()
            return count == 2
        end)
        local ms_passed = vim.uv.now() - start
        assert.is.truthy(ms_passed >= 100 and ms_passed < 200)
    end)

    it("doesn't queue up more than one call", function()
        local start = vim.uv.now()
        local fn = async.throttle(test_func, 100)
        fn()
        fn()
        fn()
        vim.wait(500, function()
            return count == 3
        end)
        local ms_passed = vim.uv.now() - start
        assert.is.truthy(ms_passed >= 500)
    end)
end)
