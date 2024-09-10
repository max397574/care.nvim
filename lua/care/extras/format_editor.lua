local FormatEditor = {}

local function get_config_function()
    local info = debug.getinfo(require("care.config").options.ui.menu.format_entry, "S")
    local lines = vim.iter(vim.fn.readfile(info.source:sub(2)))
        :skip(info.linedefined - 1)
        :take(info.lastlinedefined - info.linedefined + 1)
        :totable()
    local min_spaces = 10000
    local new_contents = {}
    for _, line in ipairs(lines) do
        if #line ~= 0 then
            min_spaces = math.min(min_spaces, #(line:match("^%s*")))
        end
    end
    for _, line in ipairs(lines) do
        table.insert(new_contents, line:sub(min_spaces + 1, -1))
    end
    new_contents[1] = new_contents[1]:gsub(".*function(%(.*%))$", "local function format_entry%1")
    new_contents[#new_contents] = new_contents[#new_contents]:gsub("^.*end.*$", "end")
    return new_contents
end

function FormatEditor.draw(entries, ns, buf, format_entry, alignments)
    local function get_texts(aligned_sec)
        local texts = {}
        for _, aligned_chunks in ipairs(aligned_sec) do
            local line_text = {}
            for _, chunk in ipairs(aligned_chunks) do
                table.insert(line_text, chunk[1])
            end
            table.insert(texts, table.concat(line_text, ""))
        end
        return texts
    end

    local function add_extmarks(aligned_sec, realign, column)
        for line, aligned_chunks in ipairs(aligned_sec) do
            local realigned_chunks = {}
            for _, chunk in ipairs(aligned_chunks) do
                table.insert(realigned_chunks, realign(chunk))
            end
            vim.api.nvim_buf_set_extmark(buf, ns, line - 1, column, {
                virt_text = realigned_chunks,
                virt_text_pos = "overlay",
                hl_mode = "combine",
            })
        end
    end
    local utils = require("care.utils")

    local function get_width()
        local formatted_concat = {}
        for _, entry in ipairs(entries) do
            local formatted = format_entry(entry.entry, entry.data)
            local chunk_texts = {}
            for _, aligned in ipairs(formatted) do
                for _, chunk in ipairs(aligned) do
                    table.insert(chunk_texts, chunk[1])
                end
            end
            table.insert(formatted_concat, table.concat(chunk_texts, ""))
        end
        return utils.longest(formatted_concat), formatted_concat
    end

    local function get_align_tables()
        local aligned_table = {}
        for _, entry in ipairs(entries) do
            local formatted = format_entry(entry.entry, entry.data)
            for aligned_index, aligned_chunks in ipairs(formatted) do
                if not aligned_table[aligned_index] then
                    aligned_table[aligned_index] = {}
                end
                table.insert(aligned_table[aligned_index], aligned_chunks)
            end
        end
        return aligned_table
    end

    local width, _ = get_width()
    local aligned_table = get_align_tables()
    local column = 0
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local spaces = {}
    for _ = 1, #entries do
        table.insert(spaces, (" "):rep(width))
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, spaces)
    vim.api.nvim_buf_set_extmark(buf, ns, 1, 0, {
        virt_text = { { string.rep(" ", width), "@care.selected" } },
        virt_text_pos = "overlay",
    })
    for i, aligned_sec in ipairs(aligned_table) do
        if not alignments[i] or alignments[i] == "left" then
            local texts = {}
            for line, aligned_chunks in ipairs(aligned_sec) do
                local line_text = {}
                for _, chunk in ipairs(aligned_chunks) do
                    table.insert(line_text, chunk[1])
                end
                local cur_line_text = table.concat(line_text, "")
                table.insert(texts, cur_line_text)
                vim.api.nvim_buf_set_extmark(buf, ns, line - 1, column, {
                    virt_text = aligned_chunks,
                    virt_text_pos = "overlay",
                    hl_mode = "combine",
                })
            end
            column = column + utils.longest(texts)
        elseif alignments[i] == "right" then
            local texts = get_texts(aligned_sec)
            local length = utils.longest(texts)
            add_extmarks(aligned_sec, function(chunk)
                return { string.rep(" ", length - #chunk[1]) .. chunk[1], chunk[2] }
            end, column)
            column = column + length
        elseif alignments[i] == "center" then
            local texts = get_texts(aligned_sec)
            local length = utils.longest(texts)
            add_extmarks(aligned_sec, function(chunk)
                return { string.rep(" ", math.floor((length - #chunk[1]) / 2)) .. chunk[1], chunk[2] }
            end, column)
            column = column + length
        end
    end
end

local function open_test_buf(contents, alignments)
    local ns = vim.api.nvim_create_namespace("care-format-editor")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep(" ", 100), string.rep(" ", 100) })
    local entries = {
        {
            entry = [[local entry = { completion_item = { label = "Test", kind = 1, }, }]],
            data = [[local data = { index = 1, deprecated = true }]],
        },
        {
            entry = [[local entry = { completion_item = { label = "nvim_exec_lua()", kind = 7, }, }]],
            data = [[local data = { index = 1, deprecated = false }]],
        },
    }
    FormatEditor.draw(entries, ns, buf, function(entry, data)
        local new_contents = vim.deepcopy(contents)
        table.insert(new_contents, 1, entry)
        table.insert(new_contents, 1, data)
        table.insert(new_contents, "return format_entry(entry, data)")
        return loadstring(table.concat(new_contents, "\n"))()
    end, alignments)
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        style = "minimal",
        width = #vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1],
        height = 5,
        row = 15,
        col = 100,
        border = "rounded",
    })
end

function FormatEditor.start()
    local buf = vim.api.nvim_create_buf(false, true)
    local contents = get_config_function()
    table.insert(
        contents,
        'local alignments = { "' .. table.concat(require("care.config").options.ui.menu.alignments, '", "') .. '" }'
    )
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
    vim.bo[buf].ft = "lua"
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        style = "minimal",
        width = 80,
        height = 25,
        row = 15,
        col = 10,
        border = "rounded",
    })
    vim.keymap.set("n", "<cr>", function()
        local alignment_table =
            vim.api.nvim_buf_get_lines(0, -2, -1, false)[1]:gsub("local alignments.*=.*{.-(.*).-}", "%1")
        open_test_buf(
            vim.api.nvim_buf_get_lines(buf, 0, -2, false),
            vim.iter(vim.split(alignment_table, ","))
                :map(function(alignment)
                    alignment = vim.trim(alignment)
                    alignment = alignment:gsub([=[['"](.*)[%'"]]=], "%1")
                    if not vim.tbl_contains({ "left", "right", "center" }, alignment) then
                        vim.notify("Ignoring unknow aligment: " .. alignment)
                        alignment = "left"
                    end
                    return vim.trim(alignment)
                end)
                :totable()
        )
    end, { buffer = buf })
end
FormatEditor.start()

return FormatEditor
