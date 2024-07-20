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

describe("Complete at EOL", function()
    before_each(function()
        require("neocomplete").core = {
            block = function()
                return function() end
            end,
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end)
    -- Tests for the case where the completion was triggered automatically
    -- So there should be no text edit touching the filter if there is any
    describe("no context offset", function()
        describe("simple entry", function()
            it("with no filter", function()
                vim.fn.setline(1, "vim.")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api",
                }
                local entry_context = Context.new()
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api", context.line)
                assert.is.equal("vim.api", context.line_before_cursor)
                assert.is.equal(7, context.cursor.col)
            end)
            it("with filter", function()
                vim.fn.setline(1, "vim.ap")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api",
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api", context.line)
                assert.is.equal("vim.api", context.line_before_cursor)
                assert.is.equal(7, context.cursor.col)
            end)
            it("with filter and insertText", function()
                vim.fn.setline(1, "vim.ap")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api",
                    insertText = "API",
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.API", context.line)
                assert.is.equal("vim.API", context.line_before_cursor)
                assert.is.equal(7, context.cursor.col)
            end)
        end)
        describe("multiline simple entry", function()
            it("with no filter", function()
                vim.fn.setline(1, "vim.")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api\ntest",
                }
                local entry_context = Context.new()
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("test", context.line)
                assert.is.equal("test", context.line_before_cursor)
                assert.is.equal(4, context.cursor.col)
                assert.is.equal(2, context.cursor.row)
            end)
            it("with filter", function()
                vim.fn.setline(1, "vim.ap")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api\ntest",
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                assert.is.equal("vim.api", lines[1])
                assert.is.equal("test", context.line)
                assert.is.equal("test", context.line_before_cursor)
                assert.is.equal(4, context.cursor.col)
                assert.is.equal(2, context.cursor.row)
            end)
            it("with filter and insertText", function()
                vim.fn.setline(1, "vim.ap")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api",
                    insertText = "API\ntest",
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                assert.is.equal("vim.API", lines[1])
                assert.is.equal("test", context.line)
                assert.is.equal("test", context.line_before_cursor)
                assert.is.equal(4, context.cursor.col)
                assert.is.equal(2, context.cursor.row)
            end)
        end)
        describe("snippet entry", function()
            it("with no filter", function()
                vim.fn.setline(1, "vim.")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api($0)",
                    insertTextFormat = 2,
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api()", context.line)
                assert.is.equal("vim.api(", context.line_before_cursor)
                assert.is.equal(8, context.cursor.col)
            end)
            it("with filter", function()
                vim.fn.setline(1, "vim.ap")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api($0)",
                    insertTextFormat = 2,
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api()", context.line)
                assert.is.equal("vim.api(", context.line_before_cursor)
                assert.is.equal(8, context.cursor.col)
            end)
            it("with filter and insertText", function()
                vim.fn.setline(1, "vim.ap")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "api",
                    insertText = "API($0)",
                    insertTextFormat = 2,
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 4,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim."
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.API()", context.line)
                assert.is.equal("vim.API(", context.line_before_cursor)
                assert.is.equal(8, context.cursor.col)
            end)
        end)
        -- describe("with textEdit", function() end)
    end)
    -- Tests for the case where the entrys context isn't where the filter starts
    -- This occurs if completion was triggered manually and has to be treated specially because part of the filter is taken care of by a textEdit
    describe("with context offset", function()
        describe("simple entry", function()
            it("with no additional filter", function()
                vim.fn.setline(1, "vim.api.nvim_")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "nvim_buf_set_lines",
                    textEdit = {
                        range = {
                            start = {
                                line = 0,
                                character = 8,
                            },
                            ["end"] = {
                                line = 0,
                                character = 13,
                            },
                        },
                        newText = "nvim_buf_set_lines",
                    },
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 13,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim.api.nvim_"
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api.nvim_buf_set_lines", context.line)
                assert.is.equal("vim.api.nvim_buf_set_lines", context.line_before_cursor)
                assert.is.equal(26, context.cursor.col)
            end)
            it("with additional filter", function()
                vim.fn.setline(1, "vim.api.nvim_buf")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "nvim_buf_set_lines",
                    textEdit = {
                        range = {
                            start = {
                                line = 0,
                                character = 8,
                            },
                            ["end"] = {
                                line = 0,
                                character = 13,
                            },
                        },
                        newText = "nvim_buf_set_lines",
                    },
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 13,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim.api.nvim_"
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api.nvim_buf_set_lines", context.line)
                assert.is.equal("vim.api.nvim_buf_set_lines", context.line_before_cursor)
                assert.is.equal(26, context.cursor.col)
            end)
        end)
        describe("snippet entry", function()
            it("with no additional filter", function()
                vim.fn.setline(1, "vim.api.nvim_")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "nvim_buf_set_lines",
                    insertTextFormat = 2,
                    textEdit = {
                        range = {
                            start = {
                                line = 0,
                                character = 8,
                            },
                            ["end"] = {
                                line = 0,
                                character = 13,
                            },
                        },
                        newText = "nvim_buf_set_lines($0)",
                    },
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 13,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim.api.nvim_"
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api.nvim_buf_set_lines()", context.line)
                assert.is.equal("vim.api.nvim_buf_set_lines(", context.line_before_cursor)
                assert.is.equal(27, context.cursor.col)
            end)
            it("with additional filter", function()
                vim.fn.setline(1, "vim.api.nvim_buf")
                vim.cmd.startinsert({ bang = true })
                ---@type lsp.CompletionItem
                local completion_item = {
                    label = "nvim_buf_set_lines",
                    insertTextFormat = 2,
                    textEdit = {
                        range = {
                            start = {
                                line = 0,
                                character = 8,
                            },
                            ["end"] = {
                                line = 0,
                                character = 13,
                            },
                        },
                        newText = "nvim_buf_set_lines($0)",
                    },
                }
                local entry_context = Context.new()
                entry_context.cursor = {
                    col = 13,
                    row = 1,
                }
                entry_context.line_before_cursor = "vim.api.nvim_"
                complete(completion_item, entry_context)
                local context = Context:new()
                assert.is.equal("vim.api.nvim_buf_set_lines()", context.line)
                assert.is.equal("vim.api.nvim_buf_set_lines(", context.line_before_cursor)
                assert.is.equal(27, context.cursor.col)
            end)
        end)
    end)
end)
