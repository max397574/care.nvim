local Context = require("care.context")
local Entry = require("care.entry")

local function complete(completion_item, context)
    ---@diagnostic disable-next-line: missing-fields
    local entry = Entry.new(completion_item, {
        get_keyword_pattern = function(_)
            return [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]]
        end,
    }, context)
    require("care.menu.confirm")(entry)
end

describe("Old Bugs:", function()
    before_each(function()
        require("care").core = {
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
            label = "care.menu",
            sortText = "0216",
            textEdit = {
                newText = "care.menu",
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
        assert.is.equal('require"care.menu', context.line)
        assert.is.equal('require"care.menu', context.line_before_cursor)
        assert.is.equal(17, context.cursor.col)
    end)
    it("luals require doesn't remove quote when triggering manually", function()
        vim.fn.setline(1, 'require"neo')
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            insertTextFormat = 2,
            kind = 17,
            label = "care.menu",
            sortText = "0039",
            documentation = "this",
            textEdit = {
                newText = "care.menu",
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
        assert.is.equal('require"care.menu', context.line)
        assert.is.equal('require"care.menu', context.line_before_cursor)
        assert.is.equal(17, context.cursor.col)
    end)
    it("luals require module doesn't remove prefix correctly", function()
        vim.fn.setline(1, 'require"care.me')
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            insertTextFormat = 2,
            kind = 17,
            label = "care.menu",
            sortText = "0038",
            textEdit = {
                newText = "care.menu",
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
        assert.is.equal('require"care.menu', context.line)
        assert.is.equal('require"care.menu', context.line_before_cursor)
        assert.is.equal(17, context.cursor.col)
    end)
    it("cmp-path doesn't set cursor properly", function()
        vim.fn.setline(1, "    ./in")
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            data = {},
            filterText = "init.lua",
            insertText = "init.lua",
            kind = 17,
            label = "init.lua",
        }
        local entry_context = {
            bufnr = 1,
            cursor = {
                col = 8,
                row = 1,
            },
            line = "    ./in",
            line_before_cursor = "    ./in",
            reason = 1,
        }
        ---@diagnostic disable-next-line: missing-fields
        local entry = Entry.new(completion_item, {
            get_keyword_pattern = function(_)
                return "\\%([^/\\\\:\\*?<>'\"`\\|]\\)" .. "*"
            end,
        }, entry_context)
        require("care.menu.confirm")(entry)

        local context = Context:new()
        assert.is.equal("    ./init.lua", context.line)
        assert.is.equal("    ./init.lua", context.line_before_cursor)
        assert.is.equal(14, context.cursor.col)
    end)
    it("problem with string enums when there is already a closing quote", function()
        vim.fn.setline(1, 'local x = "t"')
        vim.cmd.normal({ "ftl", bang = true })
        vim.cmd.startinsert()

        ---@type lsp.CompletionItem
        local completion_item = {
            insertTextFormat = 2,
            kind = 20,
            label = '"test"',
            sortText = "0001",
            textEdit = {
                newText = '"test"',
                range = {
                    ["end"] = {
                        character = 13,
                        line = 0,
                    },
                    start = {
                        character = 10,
                        line = 0,
                    },
                },
            },
        }
        local entry_context = {
            bufnr = 1,
            cursor = {
                col = 12,
                row = 1,
            },
            line = 'local x = "t"',
            line_before_cursor = 'local x = "t',
            reason = 1,
        }

        ---@diagnostic disable-next-line: missing-fields
        local entry = Entry.new(completion_item, {
            get_keyword_pattern = function(_)
                return "\\%([^/\\\\:\\*?<>'\"`\\|]\\)" .. "*"
            end,
        }, entry_context)
        require("care.menu.confirm")(entry)

        local context = Context:new()
        assert.is.equal('local x = "test"', context.line)
        assert.is.equal('local x = "test"', context.line_before_cursor)
        assert.is.equal(16, context.cursor.col)
    end)
end)
