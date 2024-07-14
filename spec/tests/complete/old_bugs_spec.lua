local Context = require("neocomplete.context")
local Entry = require("neocomplete.entry")

local function complete(completion_item, context)
    ---@diagnostic disable-next-line: missing-fields
    local entry = Entry.new(completion_item, {
        get_keyword_pattern = function(_)
            return [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]]
        end,
    }, context)
    require("neocomplete.menu.confirm")(entry)
end

describe("Old Bugs:", function()
    before_each(function()
        require("neocomplete").core = {
            block = function()
                return function() end
            end,
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end)
    it("luals require removes quote", function()
        vim.fn.setline(1, 'require"neo')
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            insertTextFormat = 2,
            kind = 17,
            label = "neocomplete.menu",
            sortText = "0216",
            textEdit = {
                newText = "neocomplete.menu",
                range = {
                    ["end"] = {
                        character = 7,
                        line = 0,
                    },
                    start = {
                        character = 8,
                        line = 0,
                    },
                },
            },
        }
        local entry_context = Context.new()
        entry_context.cursor = { col = 8, row = 1 }
        entry_context.line_before_cursor = 'require"'
        complete(completion_item, entry_context)
        local context = Context:new()
        assert.is.equal('require"neocomplete.menu', context.line)
        assert.is.equal('require"neocomplete.menu', context.line_before_cursor)
        assert.is.equal(24, context.cursor.col)
    end)
    it("luals require doesn't remove quote when triggering manually", function()
        vim.fn.setline(1, 'require"neo')
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            insertTextFormat = 2,
            kind = 17,
            label = "neocomplete.menu",
            sortText = "0039",
            documentation = "this",
            textEdit = {
                newText = "neocomplete.menu",
                range = {
                    ["end"] = {
                        character = 10,
                        line = 0,
                    },
                    start = {
                        character = 8,
                        line = 0,
                    },
                },
            },
        }
        local entry_context = Context.new()
        complete(completion_item, entry_context)
        local context = Context:new()
        assert.is.equal('require"neocomplete.menu', context.line)
        assert.is.equal('require"neocomplete.menu', context.line_before_cursor)
        assert.is.equal(24, context.cursor.col)
    end)
    it("luals require module doesn't remove prefix correctly", function()
        vim.fn.setline(1, 'require"neocomplete.me')
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            insertTextFormat = 2,
            kind = 17,
            label = "neocomplete.menu",
            sortText = "0038",
            textEdit = {
                newText = "neocomplete.menu",
                range = {
                    ["end"] = {
                        character = 19,
                        line = 0,
                    },
                    start = {
                        character = 8,
                        line = 0,
                    },
                },
            },
        }
        local entry_context = Context.new()
        complete(completion_item, entry_context)
        local context = Context:new()
        assert.is.equal('require"neocomplete.menu', context.line)
        assert.is.equal('require"neocomplete.menu', context.line_before_cursor)
        assert.is.equal(24, context.cursor.col)
    end)
end)
