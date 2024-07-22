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
        assert.is.equal(24, context.cursor.col)
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
        assert.is.equal(24, context.cursor.col)
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
        assert.is.equal(24, context.cursor.col)
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
    it('problem with ["end"] from luals', function()
        vim.fn.setline(1, "    completion_item.range.")
        vim.cmd.startinsert({ bang = true })
        ---@type lsp.CompletionItem
        local completion_item = {
            additionalTextEdits = {
                {
                    newText = "",
                    range = {
                        ["end"] = { character = 35, line = 1 },
                        start = { character = 34, line = 1 },
                    },
                },
            },
            data = { id = 119, uri = "not relevant" },
            detail = "lsp.Position",
            documentation = { kind = "markdown", value = "not relevant" },
            insertTextFormat = 2,
            kind = 5,
            label = '"end"',
            sortText = "0001",
            textEdit = {
                newText = '["end"]',
                range = {
                    ["end"] = { character = 35, line = 1 },
                    start = { character = 4, line = 3 },
                },
            },
        }
        local entry_context = {
            bufnr = 1,
            cursor = { col = 35, row = 1 },
            line = "    completion_item.textEdit.range.",
            line_before_cursor = "    completion_item.textEdit.range.",
            previous = nil,
            reason = 1,
        }

        complete(completion_item, entry_context)

        local context = Context:new()
        -- TODO: readd once a response on https://github.com/LuaLS/lua-language-server/issues/2762
        -- assert.is.equal('    completion_item.textEdit.range["end"]', context.line)
        -- assert.is.equal('    completion_item.textEdit.range["end"]', context.line_before_cursor)
        -- assert.is.equal(14, context.cursor.col)
    end)
end)
