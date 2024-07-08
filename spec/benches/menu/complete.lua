-- usage: `$ nvim --clean --headless -c "set runtimepath+=." -l spec/benches/menu/complete.lua`
local Context = require("neocomplete.context")
local Entry = require("neocomplete.entry")

local function complete(completion_item, context)
    ---@diagnostic disable-next-line: missing-fields
    local entry = Entry.new(completion_item, {
        get_keyword_pattern = function(_)
            return [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]]
        end,
    }, context)
    local menu = require("neocomplete.menu").new()
    menu:complete(entry)
end

local function do_complete()
    require("neocomplete").core = {
        block = function()
            return function() end
        end,
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

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
end



local start_time = os.clock()
for _ = 1, 1000 do
    do_complete()
end
print("Completing snippet entry with filter 1000 times")
local end_time = os.clock()
local time_taken = end_time - start_time
print(time_taken, "s")
